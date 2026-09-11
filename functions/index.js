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

/**
 * CALLABLE FUNCTION: Creates a Stripe Checkout Session for OmniToolkit
 * Lifetime Membership.
 *
 * Firebase Auth is OPTIONAL. Anonymous visitors may purchase without
 * signing in; Stripe Checkout collects the purchaser's email directly in
 * that case. If the caller is signed in, their account email is used as a
 * checkout hint and linked immediately. Entitlement is always keyed by the
 * purchase email so an anonymous purchase can later be claimed by a
 * matching authenticated sign-in (see checkEntitlementForSignedInUser).
 */
exports.createStripeCheckoutSession = onCall(
  { secrets: [stripeSecretKey, stripePriceId] },
  async (request) => {
    if (request.data?.disclaimerAccepted !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Purchase acknowledgement is required before checkout."
      );
    }

    const stripe = Stripe(stripeSecretKey.value());

    const uid = request.auth?.uid || null;
    const authenticatedEmail = normalizeEmail(request.auth?.token?.email);
    const requestedEmail = normalizeEmail(request.data?.billingEmail);

    if (authenticatedEmail && requestedEmail && authenticatedEmail !== requestedEmail) {
      throw new HttpsError(
        "invalid-argument",
        "Billing email must match the signed-in account email."
      );
    }
    const emailHint = authenticatedEmail || requestedEmail || undefined;

    try {
      // Reuse an existing Stripe Customer for signed-in users so repeat
      // purchases / receipts are consolidated under one customer record.
      let customerId;
      if (uid) {
        const userDoc = await db.collection("users").doc(uid).get();
        customerId = userDoc.data()?.stripeCustomerId;
        if (!customerId) {
          const customer = await stripe.customers.create({
            email: emailHint,
            metadata: { firebaseUID: uid },
          });
          customerId = customer.id;
          await db.collection("users").doc(uid).set(
            { stripeCustomerId: customerId },
            { merge: true }
          );
        }
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        mode: "payment",
        customer: customerId,
        customer_email: customerId ? undefined : emailHint,
        customer_creation: customerId ? undefined : "always",
        client_reference_id: uid || undefined,
        metadata: uid ? { firebaseUID: uid } : {},
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
 * Entitlement is written to entitlements/{purchaseEmail} regardless of
 * whether the purchaser was signed in, so purchases are never blocked by
 * authentication. If a Firebase uid is available it is mirrored into
 * users/{uid} as well (best effort, for already-authenticated purchasers).
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

    const uid = session.client_reference_id || session.metadata?.firebaseUID || null;
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
          trialStartDate: existingData.trialStartDate ?? null,
          trialEndDate: existingData.trialEndDate ?? null,
          hasLifetimeAccess: true,
          purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
          lastSeenDate: admin.firestore.FieldValue.serverTimestamp(),
        })
      );

      if (uid) {
        transaction.set(
          db.collection("users").doc(uid),
          {
            paymentStatus: "paid",
            hasLifetimeAccess: true,
            premium_active: true,
            purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
            stripeCustomerId: session.customer || null,
            stripeSessionId: session.id,
            purchaseEmail: billingEmail,
          },
          { merge: true }
        );

        transaction.set(
          db.collection("users").doc(uid).collection("payments").doc(session.id),
          {
            amount: (session.amount_total || 0) / 100,
            currency: session.currency,
            status: "succeeded",
            created: admin.firestore.FieldValue.serverTimestamp(),
          }
        );
      }
    });

    console.log(`[stripeWebhook.fulfilled] email=${billingEmail} session=${session.id}`);
    res.status(200).json({ received: true });
  }
);

/**
 * CALLABLE FUNCTION: Starts or restores the single seven-day trial for an
 * email address. The transaction makes trial creation idempotent across
 * reinstalls and devices.
 */
exports.startOrRestoreTrial = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
    throw new HttpsError("invalid-argument", "A valid email address is required.");
  }

  const entitlementRef = db.collection("entitlements").doc(email);
  let entitlement;
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(entitlementRef);
    const current = snapshot.exists ? snapshot.data() : {};
    if (!snapshot.exists) {
      const now = admin.firestore.Timestamp.now();
      const trialEnd = admin.firestore.Timestamp.fromMillis(
        now.toMillis() + 7 * 24 * 60 * 60 * 1000
      );
      transaction.set(entitlementRef, entitlementPayload(email, {
        trialStartDate: now,
        trialEndDate: trialEnd,
        hasLifetimeAccess: false,
        lastSeenDate: now,
      }));
      entitlement = entitlementPayload(email, {
        trialStartDate: now,
        trialEndDate: trialEnd,
        hasLifetimeAccess: false,
        lastSeenDate: now,
      });
      return;
    }

    transaction.update(entitlementRef, {
      lastSeenDate: admin.firestore.FieldValue.serverTimestamp(),
    });
    entitlement = { ...current };
  });

  return entitlementResponse(email, entitlement);
});

/**
 * CALLABLE FUNCTION: Public restore lookup. Lets any visitor (signed in or
 * not) check Lifetime Membership status by supplying the email used at
 * checkout. No other account data is exposed.
 */
exports.checkEntitlementByEmail = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  if (!email) {
    throw new HttpsError("invalid-argument", "A purchase email is required.");
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
});

/**
 * CALLABLE FUNCTION: Compares the signed-in account email against any
 * Lifetime Membership purchased anonymously (or under a different session)
 * with a matching email.
 */
exports.checkEntitlementForSignedInUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be signed in to check entitlement.");
  }

  const accountEmail = normalizeEmail(request.auth.token?.email);
  if (!accountEmail) {
    return { email: accountEmail, hasLifetimeAccess: false, matched: false, reason: "no-account-email" };
  }

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
});