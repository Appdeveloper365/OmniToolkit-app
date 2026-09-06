/**
 * Firebase Cloud Functions Backend for OomniToolkit Monetization
 * - Handles Stripe Checkout session creation using environment variables.
 * - Processes checkout.session.completed webhooks and grants lifetime access.
 */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// Retrieve Stripe keys and Price ID from environment variables
const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
const stripePriceId = process.env.STRIPE_PRICE_ID || "price_1UCeoyF7QpgCf4wXI2wvEFoz";
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET || "";

const stripe = require("stripe")(stripeSecretKey);

/**
 * 1. Create Stripe Checkout Session
 * Called from authenticated client to initiate checkout for OomniToolkit Lifetime Access ($9.99 USD).
 */
exports.createStripeCheckoutSession = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const uid = context.auth.uid;
  const email = context.auth.token.email || "";
  const appBaseUrl = process.env.APP_BASE_URL || "https://appdeveloper365.github.io/OmniToolkit-app";

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment", // One-time payment (No subscriptions)
      customer_email: email,
      client_reference_id: uid,
      line_items: [
        {
          price: stripePriceId, // price_1UCeoyF7QpgCf4wXI2wvEFoz ($9.99 USD)
          quantity: 1,
        },
      ],
      success_url: `${appBaseUrl}/#/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appBaseUrl}/#/payment-cancelled`,
    });

    return { sessionUrl: session.url };
  } catch (error) {
    console.error("[StripeCheckoutError]", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * 2. Stripe Webhook Endpoint
 * Listens for checkout.session.completed and fulfills lifetime access.
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"];

  let event;
  try {
    if (stripeWebhookSecret) {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, stripeWebhookSecret);
    } else {
      event = req.body;
    }
  } catch (err) {
    console.error("[WebhookSignatureError]", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const uid = session.client_reference_id;
    const customerId = session.customer;
    const sessionId = session.id;

    if (uid) {
      await db.collection("users").doc(uid).set(
        {
          paymentStatus: "paid",
          hasLifetimeAccess: true,
          purchaseDate: admin.firestore.FieldValue.serverTimestamp(),
          stripeCustomerId: customerId,
          stripeSessionId: sessionId,
        },
        { merge: true }
      );

      console.log(`[FULFILLMENT SUCCESS] Granted OomniToolkit Lifetime Access to UID: ${uid}`);
    }
  }

  res.json({ received: true });
});
