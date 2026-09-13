const { onRequest, onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();

// Stripe credentials are managed via Firebase Secret Manager (not source
// control): `firebase functions:secrets:set STRIPE_SECRET_KEY` etc.
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const stripePriceId = defineSecret("STRIPE_PRICE_ID");

const APP_BASE_URL =
  process.env.APP_BASE_URL || "https://appdeveloper365.github.io/OmniToolkit-app";

function normalizeEmail(value) {
  return (value || "").trim().toLowerCase();
}

function entitlementPayload(email, values = {}) {
  return {
    email,
    emailVerified: values.emailVerified === true,
    trialStartDate: values.trialStartDate ?? null,
    trialEndDate: values.trialEndDate ?? null,
    hasLifetimeAccess: values.hasLifetimeAccess === true,
    purchaseDate: values.purchaseDate ?? null,
    lastSeenDate: values.lastSeenDate ?? admin.firestore.FieldValue.serverTimestamp(),
  };
}

function timestampToIso(value) {
  return value?.toDate ? value.toDate().toISOString() : null;
}

function entitlementResponse(email, data) {
  const trialEndDate = data?.trialEndDate;
  const trialActive = !data?.hasLifetimeAccess &&
    trialEndDate?.toDate && trialEndDate.toDate().getTime() > Date.now();
  return {
    email,
    hasLifetimeAccess: data?.hasLifetimeAccess === true,
    trialActive,
    trialStartDate: timestampToIso(data?.trialStartDate),
    trialEndDate: timestampToIso(trialEndDate),
    purchaseDate: timestampToIso(data?.purchaseDate),
    emailVerified: data?.emailVerified === true,
  };
}

async function resolveCheckoutEmail(stripe, session) {
  const directEmail = normalizeEmail(
    session.customer_details?.email || session.customer_email
  );
  if (directEmail) return directEmail;

  if (session.customer && typeof session.customer === "object") {
    const expandedCustomerEmail = normalizeEmail(session.customer.email);
    if (expandedCustomerEmail) return expandedCustomerEmail;
  }

  if (typeof session.customer === "string" && session.customer) {
    const customer = await stripe.customers.retrieve(session.customer);
    if (!customer.deleted) {
      const customerEmail = normalizeEmail(customer.email);
      if (customerEmail) return customerEmail;
    }
  }

  return "";
}

// Shared: is there a completed, paid Stripe session for this email?
// Uses the Stripe SEARCH API (O(1)). Falls back to list() if search errors.
async function stripeHasPaidSession(email, stripe) {
  if (!stripe || !email) return false;
  try {
    const found = await stripe.checkout.sessions.search({
      query: `status:'complete' AND (customer_details.email:'${email}' OR customer_email:'${email}')`,
      limit: 5,
    });
    if (found.data && found.data.some((s) => s.payment_status === "paid" && s.status === "complete")) {
      return true;
    }
  } catch (searchError) {
    console.warn("[stripeHasPaidSession] search failed, falling back to list:", searchError.message);
    try {
      const sessions = await stripe.checkout.sessions.list({ limit: 100 });
      return sessions.data.some((s) => {
        const directEmail = normalizeEmail(
          s.customer_email || (s.customer_details && s.customer_details.email)
        );
        return directEmail === email && s.payment_status === "paid" && s.status === "complete";
      });
    } catch (listError) {
      console.error("[stripeHasPaidSession] list fallback failed:", listError.message);
      return false;
    }
  }
  return false;
}

// Shared: Firestore-first, Stripe-fallback (self-healing) entitlement check.
async function isEntitled(email, stripe) {
  if (!email) return false;
  const entitlementRef = db.collection("entitlements").doc(email);
  const snapshot = await entitlementRef.get();
  if (snapshot.exists && snapshot.data().hasLifetimeAccess === true) {
    return true;
  }
  if (stripe && (await stripeHasPaidSession(email, stripe))) {
    // Self-heal Firestore for next time
    const existingData = snapshot.exists ? snapshot.data() : {};
    await entitlementRef.set(
      entitlementPayload(email, {
        emailVerified: true,
        trialStartDate: existingData.trialStartDate ?? null,
        trialEndDate: existingData.trialEndDate ?? null,
        hasLifetimeAccess: true,
        purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
        lastSeenDate: admin.firestore.FieldValue.serverTimestamp(),
      }),
      { merge: true }
    );
    return true;
  }
  return false;
}

/**
 * CALLABLE FUNCTION: Creates a Stripe Checkout Session for OmniToolkit
 * Lifetime Membership.
 *
 * DUPLICATE PURCHASE PROTECTION (Server Layer):
 * Checks Firestore + Stripe Search API. If already entitled, returns
 * { alreadyOwned: true } without creating a new Stripe checkout session.
 */
exports.createStripeCheckoutSession = onCall(
  { secrets: [stripeSecretKey, stripePriceId] },
  async (request) => {
    if (!request.auth || request.auth.token?.email_verified !== true) {
      throw new HttpsError("unauthenticated", "Verified email sign-in is required before checkout.");
    }

    if (request.data?.disclaimerAccepted !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Purchase acknowledgement is required before checkout."
      );
    }

    const stripe = Stripe(stripeSecretKey.value());

    const authenticatedEmail = normalizeEmail(request.auth?.token?.email);
    const requestedEmail = normalizeEmail(request.data?.billingEmail);

    if (authenticatedEmail && requestedEmail && authenticatedEmail !== requestedEmail) {
      throw new HttpsError(
        "invalid-argument",
        "Billing email must match the signed-in account email."
      );
    }
    const emailHint = authenticatedEmail || requestedEmail || undefined;

    // DUPLICATE PURCHASE PROTECTION: check if user already owns Lifetime Access
    if (emailHint && (await isEntitled(emailHint, stripe))) {
      return { alreadyOwned: true };
    }

    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer_email: emailHint,
        customer_creation: "always",
        metadata: { purchaseEmail: authenticatedEmail },
        line_items: [{ price: stripePriceId.value(), quantity: 1 }],
        success_url: `${APP_BASE_URL}/#/payment-success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${APP_BASE_URL}/#/payment-cancelled`,
      });

      return { sessionUrl: session.url, url: session.url };
    } catch (error) {
      console.error("[createStripeCheckoutSession]", error);
      throw new HttpsError("internal", error.message);
    }
  }
);

/**
 * HTTP FUNCTION: Handles Stripe webhooks and fulfills Lifetime Membership.
 *
 * Entitlement is written to entitlements/{purchaseEmail}. Checkout is
 * restricted to a verified Firebase email account.
 */
exports.stripeWebhook = onRequest(
  { secrets: [stripeSecretKey, stripeWebhookSecret] },
  async (req, res) => {
    const stripe = Stripe(stripeSecretKey.value());
    const signature = req.headers["stripe-signature"];
    let event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        stripeWebhookSecret.value()
      );
    } catch (error) {
      console.error("[stripeWebhook.signature]", error.message);
      res.status(400).send(`Webhook Error: ${error.message}`);
      return;
    }

    if (event.type !== "checkout.session.completed") {
      res.status(200).json({ received: true });
      return;
    }

    const session = event.data.object;
    const billingEmail = await resolveCheckoutEmail(stripe, session);

    if (!billingEmail) {
      console.error("[stripeWebhook.missingEmail]", session.id);
      res.status(400).send("Checkout session did not include a purchaser email.");
      return;
    }

    if (session.mode !== "payment" || session.payment_status !== "paid") {
      console.error(
        "[stripeWebhook.invalidSession]",
        session.id,
        session.mode,
        session.payment_status
      );
      res.status(400).send("Checkout session is not a paid one-time payment.");
      return;
    }

    const eventRef = db.collection("stripeWebhookEvents").doc(event.id);
    const entitlementRef = db.collection("entitlements").doc(billingEmail);

    await db.runTransaction(async (transaction) => {
      const processed = await transaction.get(eventRef);
      if (processed.exists) {
        return;
      }

      const existingEntitlement = await transaction.get(entitlementRef);
      const existingData = existingEntitlement.exists ? existingEntitlement.data() : {};

      transaction.set(eventRef, {
        type: event.type,
        stripeSessionId: session.id,
        purchaseEmail: billingEmail,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(
        entitlementRef,
        entitlementPayload(billingEmail, {
          emailVerified: true,
          trialStartDate: existingData.trialStartDate ?? null,
          trialEndDate: existingData.trialEndDate ?? null,
          hasLifetimeAccess: true,
          purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
          lastSeenDate: admin.firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    console.log(`[stripeWebhook.fulfilled] email=${billingEmail} session=${session.id}`);
    res.status(200).json({ received: true });
  }
);

/**
 * CALLABLE FUNCTION: Restores existing entitlement status (Lifetime Access
 * or none) for a verified email address.
 *
 * Checks Firestore + Stripe Search API (self-healing) and returns the caller's
 * current entitlement.
 */
exports.startOrRestoreTrial = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    if (!request.auth || request.auth.token?.email_verified !== true) {
      throw new HttpsError("unauthenticated", "Verify email ownership before continuing.");
    }

    const email = normalizeEmail(request.auth.token.email);
    if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
      throw new HttpsError("invalid-argument", "A valid email address is required.");
    }

    let stripe = null;
    try {
      if (stripeSecretKey.value()) {
        stripe = Stripe(stripeSecretKey.value());
      }
    } catch (_) {}

    await isEntitled(email, stripe);

    const entitlementRef = db.collection("entitlements").doc(email);
    let entitlement;
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(entitlementRef);
      const now = admin.firestore.Timestamp.now();
      if (!snapshot.exists) {
        const payload = entitlementPayload(email, {
          emailVerified: true,
          hasLifetimeAccess: false,
          lastSeenDate: now,
        });
        transaction.set(entitlementRef, payload);
        entitlement = payload;
        return;
      }

      transaction.update(entitlementRef, {
        emailVerified: true,
        lastSeenDate: admin.firestore.FieldValue.serverTimestamp(),
      });
      entitlement = { ...snapshot.data(), emailVerified: true };
    });

    return entitlementResponse(email, entitlement);
  }
);

/**
 * CALLABLE FUNCTION: Public restore lookup. Lets ANY visitor (signed in or
 * not, verified or not) check Lifetime Membership status by supplying the
 * email used at checkout. Intentionally requires no Firebase Authentication
 * -- "Verify Purchase" must work immediately.
 *
 * Uses Firestore + Stripe Search API for self-healing entitlement lookups.
 */
exports.checkEntitlementByEmail = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    const email = normalizeEmail(request.data?.email);
    if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
      throw new HttpsError("invalid-argument", "A valid email address is required.");
    }

    let stripe = null;
    try {
      if (stripeSecretKey.value()) {
        stripe = Stripe(stripeSecretKey.value());
      }
    } catch (_) {}

    const owned = await isEntitled(email, stripe);
    if (owned) {
      const entitlementSnapshot = await db.collection("entitlements").doc(email).get();
      const entitlement = entitlementSnapshot.exists
        ? entitlementSnapshot.data()
        : { hasLifetimeAccess: true, emailVerified: true };
      return {
        ...entitlementResponse(email, entitlement),
        hasLifetimeAccess: true,
        matched: true,
      };
    }

    const entitlementSnapshot = await db.collection("entitlements").doc(email).get();
    if (!entitlementSnapshot.exists) {
      return { email, hasLifetimeAccess: false, matched: false, reason: "no-purchase-found" };
    }

    const entitlement = entitlementSnapshot.data();
    return {
      ...entitlementResponse(email, entitlement),
      matched: true,
    };
  }
);

// Backwards-compatible alias for checkEntitlementByEmail
exports.restoreLookup = exports.checkEntitlementByEmail;

/**
 * CALLABLE FUNCTION: Compares the signed-in account email against any
 * Lifetime Membership purchased anonymously (or under a different session)
 * with a matching email.
 */
exports.checkEntitlementForSignedInUser = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    if (!request.auth || request.auth.token?.email_verified !== true) {
      throw new HttpsError("unauthenticated", "Verified email sign-in is required to restore membership.");
    }

    const accountEmail = normalizeEmail(request.auth.token?.email);
    if (!accountEmail) {
      return { email: accountEmail, hasLifetimeAccess: false, matched: false, reason: "no-account-email" };
    }

    let stripe = null;
    try {
      if (stripeSecretKey.value()) {
        stripe = Stripe(stripeSecretKey.value());
      }
    } catch (_) {}

    await isEntitled(accountEmail, stripe);

    const entitlementRef = db.collection("entitlements").doc(accountEmail);
    const entitlementSnapshot = await entitlementRef.get();
    if (!entitlementSnapshot.exists) {
      return { email: accountEmail, hasLifetimeAccess: false, matched: false, reason: "no-purchase-found" };
    }

    const entitlement = entitlementSnapshot.data();
    return {
      ...entitlementResponse(accountEmail, entitlement),
      matched: true,
    };
  }
);