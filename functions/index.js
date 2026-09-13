const functions = require("firebase-functions");
const Stripe = require("stripe");

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

exports.createStripeCheckoutSession = functions.https.onCall(async () => {
  const appBaseUrl = configValue("APP_BASE_URL") || "https://appdeveloper365.github.io/OmniToolkit-app";
  const stripe = stripeClient();
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    payment_method_types: ["card"],
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
  if (session.mode !== "payment" || session.payment_status !== "paid") {
    console.error("[stripeWebhook.invalidSession]", session.id, session.mode, session.payment_status);
    res.status(400).send("Checkout session is not a paid one-time payment.");
    return;
  }

  console.log(`[stripeWebhook.fulfilled] session=${session.id}`);
  res.json({ received: true });
});
