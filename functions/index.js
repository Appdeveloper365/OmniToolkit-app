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

exports.createStripeCheckoutSession = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const uid = context.auth.uid;
  const email = (context.auth.token.email || "").trim().toLowerCase();
  if (!email) {
    throw new functions.https.HttpsError("failed-precondition", "A verified account email is required before checkout.");
  }
  const userRef = db.collection("users").doc(uid);
  const userSnapshot = await userRef.get();
  const user = userSnapshot.data();

  if (!userSnapshot.exists) {
    throw new functions.https.HttpsError("failed-precondition", "User record was not found.");
  }
  if (user.hasLifetimeAccess === true || user.premium_active === true || user.paymentStatus === "paid") {
    throw new functions.https.HttpsError("failed-precondition", "Lifetime access is already active for this account.");
  }
  if (user.disclaimerAccepted !== true) {
    throw new functions.https.HttpsError("failed-precondition", "Purchase acknowledgement is required before checkout.");
  }

  const appBaseUrl = configValue("APP_BASE_URL") || "https://appdeveloper365.github.io/OmniToolkit-app";
  const stripe = stripeClient();
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    payment_method_types: ["card"],
    customer_email: email,
    client_reference_id: uid,
    metadata: { uid, accountEmail: email },
    customer_creation: "always",
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
  const uid = session.client_reference_id || session.metadata?.uid;

  if (!uid) {
    console.error("[stripeWebhook.missingUid]", session.id);
    res.status(400).send("Missing Firebase user reference.");
    return;
  }

  const account = await admin.auth().getUser(uid);
  const accountEmail = (account.email || "").trim().toLowerCase();
  const billingEmail = (session.customer_details?.email || session.customer_email || "").trim().toLowerCase();
  if (!accountEmail || !billingEmail || accountEmail !== billingEmail) {
    console.error("[stripeWebhook.emailMismatch]", session.id, uid);
    res.status(400).send("Billing email must match the authenticated account email.");
    return;
  }

  if (session.mode !== "payment" || session.payment_status !== "paid") {
    console.error("[stripeWebhook.invalidSession]", session.id, session.mode, session.payment_status);
    res.status(400).send("Checkout session is not a paid one-time payment.");
    return;
  }

  const eventRef = db.collection("stripeWebhookEvents").doc(event.id);
  const userRef = db.collection("users").doc(uid);

  await db.runTransaction(async (transaction) => {
    const processed = await transaction.get(eventRef);
    if (processed.exists) {
      return;
    }

    transaction.set(eventRef, {
      type: event.type,
      stripeSessionId: session.id,
      purchaseEmail: billingEmail,
      uid,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    transaction.set(userRef, {
      paymentStatus: "paid",
      hasLifetimeAccess: true,
      premium_active: true,
      purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
      stripeCustomerId: session.customer || null,
      stripeSessionId: session.id,
      purchaseEmail: billingEmail,
    }, { merge: true });
  });

  console.log(`[stripeWebhook.fulfilled] uid=${uid} session=${session.id}`);
  res.json({ received: true });
});
