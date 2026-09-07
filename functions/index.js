const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();

const db = admin.firestore();

function configValue(name) {
  const legacyStripeConfigKey = name.toLowerCase().replace("stripe_", "");
  if (process.env[name]) return process.env[name];
  if (name.startsWith("STRIPE_") && functions.config().stripe?.[legacyStripeConfigKey]) {
    return functions.config().stripe[legacyStripeConfigKey];
  }
  if (name === "APP_BASE_URL" && functions.config().app?.base_url) {
    return functions.config().app.base_url;
  }
  return undefined;
}

function requiredEnv(name) {
  const value = configValue(name);
  if (!value) {
    throw new functions.https.HttpsError("failed-precondition", `${name} is not configured.`);
  }
  return value;
}

function stripeClient() {
  return new Stripe(requiredEnv("STRIPE_SECRET_KEY"), { apiVersion: "2023-10-16" });
}

function normalizeEmail(value) {
  return (value || "").trim().toLowerCase();
}

// Anonymous visitors may purchase Lifetime Membership. Firebase Auth is
// optional: if the caller happens to be signed in, their account email is
// used as a checkout hint and linked immediately. Otherwise Stripe Checkout
// collects the purchaser's email directly and entitlement is keyed by that
// email so it can be matched against a future sign-in.
exports.createStripeCheckoutSession = functions.https.onCall(async (data, context) => {
  if (data?.disclaimerAccepted !== true) {
    throw new functions.https.HttpsError("failed-precondition", "Purchase acknowledgement is required before checkout.");
  }

  const uid = context.auth?.uid || null;
  const authenticatedEmail = normalizeEmail(context.auth?.token?.email);
  const requestedEmail = normalizeEmail(data?.billingEmail);
  if (authenticatedEmail && requestedEmail && authenticatedEmail !== requestedEmail) {
    throw new functions.https.HttpsError("invalid-argument", "Billing email must match the signed-in account email.");
  }
  const emailHint = authenticatedEmail || requestedEmail || undefined;

  const appBaseUrl = configValue("APP_BASE_URL") || "https://appdeveloper365.github.io/OmniToolkit-app";
  const stripe = stripeClient();
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    payment_method_types: ["card"],
    customer_email: emailHint,
    customer_creation: "always",
    client_reference_id: uid || undefined,
    metadata: uid ? { uid } : {},
    line_items: [{ price: requiredEnv("STRIPE_PRICE_ID"), quantity: 1 }],
    success_url: `${appBaseUrl}/#/payment-success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${appBaseUrl}/#/payment-cancelled`,
  });

  return { sessionUrl: session.url };
});

exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const signature = req.headers["stripe-signature"];
  const stripe = stripeClient();
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, signature, requiredEnv("STRIPE_WEBHOOK_SECRET"));
  } catch (error) {
    console.error("[stripeWebhook.signature]", error.message);
    res.status(400).send(`Webhook Error: ${error.message}`);
    return;
  }

  if (event.type !== "checkout.session.completed") {
    res.json({ received: true });
    return;
  }

  const session = event.data.object;
  const billingEmail = normalizeEmail(session.customer_details?.email || session.customer_email);

  if (!billingEmail) {
    console.error("[stripeWebhook.missingEmail]", session.id);
    res.status(400).send("Checkout session did not include a purchaser email.");
    return;
  }

  if (session.mode !== "payment" || session.payment_status !== "paid") {
    console.error("[stripeWebhook.invalidSession]", session.id, session.mode, session.payment_status);
    res.status(400).send("Checkout session is not a paid one-time payment.");
    return;
  }

  const eventRef = db.collection("stripeWebhookEvents").doc(event.id);
  // Entitlements are keyed by the purchase email so that anonymous
  // purchases can later be claimed by a matching authenticated sign-in.
  const entitlementRef = db.collection("entitlements").doc(billingEmail);
  const uid = session.client_reference_id || session.metadata?.uid || null;

  await db.runTransaction(async (transaction) => {
    const processed = await transaction.get(eventRef);
    if (processed.exists) {
      return;
    }

    transaction.set(eventRef, {
      type: event.type,
      stripeSessionId: session.id,
      purchaseEmail: billingEmail,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    transaction.set(entitlementRef, {
      email: billingEmail,
      paymentStatus: "paid",
      hasLifetimeAccess: true,
      premium_active: true,
      purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
      stripeCustomerId: session.customer || null,
      stripeSessionId: session.id,
      purchaseEmail: billingEmail,
      linkedUid: uid,
    }, { merge: true });

    if (uid) {
      transaction.set(db.collection("users").doc(uid), {
        paymentStatus: "paid",
        hasLifetimeAccess: true,
        premium_active: true,
        purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
        stripeCustomerId: session.customer || null,
        stripeSessionId: session.id,
        purchaseEmail: billingEmail,
      }, { merge: true });
    }
  });

  console.log(`[stripeWebhook.fulfilled] email=${billingEmail} session=${session.id}`);
  res.json({ received: true });
});

// Public restore lookup: the app currently has no sign-in UI, so visitors
// restore a Lifetime Membership by entering the email used at checkout.
// Only entitlement existence/status is returned; no other account data.
exports.checkEntitlementByEmail = functions.https.onCall(async (data) => {
  const email = normalizeEmail(data?.email);
  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "A purchase email is required.");
  }

  const entitlementSnapshot = await db.collection("entitlements").doc(email).get();
  if (!entitlementSnapshot.exists) {
    return { hasLifetimeAccess: false, matched: false, reason: "no-purchase-found" };
  }

  const entitlement = entitlementSnapshot.data();
  return {
    hasLifetimeAccess: entitlement?.hasLifetimeAccess === true,
    matched: true,
    purchaseEmail: entitlement?.purchaseEmail || email,
  };
});
// Called after sign-in to compare the authenticated account email against
// any Lifetime Membership purchased anonymously (or under a different
// account) with a matching email. Returns a clear match/mismatch result so
// the client can grant access or explain how to resolve access.
exports.checkEntitlementForSignedInUser = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be signed in to check entitlement.");
  }

  const accountEmail = normalizeEmail(context.auth.token.email);
  if (!accountEmail) {
    return { hasLifetimeAccess: false, matched: false, reason: "no-account-email" };
  }

  const entitlementSnapshot = await db.collection("entitlements").doc(accountEmail).get();
  if (!entitlementSnapshot.exists) {
    return { hasLifetimeAccess: false, matched: false, reason: "no-purchase-found" };
  }

  const entitlement = entitlementSnapshot.data();
  const hasLifetimeAccess = entitlement?.hasLifetimeAccess === true;

  if (hasLifetimeAccess && entitlement.linkedUid !== context.auth.uid) {
    await entitlementSnapshot.ref.set({ linkedUid: context.auth.uid }, { merge: true });
  }

  return {
    hasLifetimeAccess,
    matched: true,
    purchaseEmail: entitlement?.purchaseEmail || accountEmail,
  };
});