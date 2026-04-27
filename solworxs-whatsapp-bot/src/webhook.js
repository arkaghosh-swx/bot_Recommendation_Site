const { sendTextMessage, sendListMenu, sendButtonMessage } = require("./whatsapp");
const { getAIReply } = require("./claude");

// In-memory stores
const conversations = {}; // chat history per user
const seenUsers = {}; // track if user has been greeted

// ── Verify webhook (Meta sends a GET to confirm your URL)
function verifyWebhook(req, res) {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode === "subscribe" && token === process.env.WEBHOOK_VERIFY_TOKEN) {
    console.log("✅ Webhook verified by Meta");
    res.status(200).send(challenge);
  } else {
    console.error("❌ Webhook verification failed");
    res.sendStatus(403);
  }
}

// ── Handle incoming messages
async function handleWebhook(req, res) {
  res.sendStatus(200); // always respond immediately

  try {
    const body = req.body;

    if (
      body.object !== "whatsapp_business_account" ||
      !body.entry?.[0]?.changes?.[0]?.value?.messages?.[0]
    ) return;

    const value = body.entry[0].changes[0].value;
    const message = value.messages[0];
    const from = message.from;

    // ── FIRST TIME user → show main list menu
    if (!seenUsers[from]) {
      seenUsers[from] = true;
      await sendListMenu(from);
      return;
    }

    // ── User picked from LIST MENU
    if (message.type === "interactive" && message.interactive.type === "list_reply") {
      const selectedId = message.interactive.list_reply.id;
      await handleMenuSelection(from, selectedId);
      return;
    }

    // ── User tapped a BUTTON
    if (message.type === "interactive" && message.interactive.type === "button_reply") {
      const buttonId = message.interactive.button_reply.id;
      await handleButtonReply(from, buttonId);
      return;
    }

    // ── Regular text message → AI reply
    if (message.type === "text") {
      const userText = message.text.body.trim();
      console.log(`📩 Message from ${from}: ${userText}`);

      if (!conversations[from]) conversations[from] = [];
      conversations[from].push({ role: "user", content: userText });
      if (conversations[from].length > 10) conversations[from].shift();

      const reply = await getAIReply(conversations[from]);
      conversations[from].push({ role: "assistant", content: reply });

      await sendTextMessage(from, reply);

      // After AI reply, offer to go back to menu
      await sendButtonMessage(from, "Anything else I can help with?", [
        { id: "btn_menu", title: "📋 Main Menu" },
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_support", title: "🙋 Talk to Team" },
      ]);
      return;
    }

    // ── Unsupported message type
    await sendTextMessage(from, "Sorry, I can only handle text messages right now. 🙏");

  } catch (err) {
    console.error("Error handling webhook:", err.message);
  }
}

// ── Handle main menu selections
async function handleMenuSelection(from, selectedId) {
  switch (selectedId) {

    case "menu_products":
      await sendTextMessage(from,
        "🤖 *Our AI Bots*\n\n" +
        "1. *Support Bot* — 24/7 customer support, FAQ handling, lead capture\n" +
        "2. *AI Assistant* — Smart replies, demo booking, conversion analytics\n" +
        "3. *WhatsApp Bot* — Instant replies, order updates, lead collection\n\n" +
        "All bots are powered by advanced AI, secure cloud hosting, and real-time platform integrations."
      );
      await sendButtonMessage(from, "Would you like to know more?", [
        { id: "btn_pricing", title: "💰 See Pricing" },
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_pricing":
      await sendTextMessage(from,
        "💰 *Pricing Plans*\n\n" +
        "• *Starter* — ₹4,999/month\n  1 bot, up to 1,000 conversations\n\n" +
        "• *Growth* — ₹9,999/month\n  2 bots, up to 5,000 conversations\n\n" +
        "• *Enterprise* — Custom pricing\n  Unlimited bots & conversations\n\n" +
        "All plans include setup support and analytics dashboard."
      );
      await sendButtonMessage(from, "Ready to get started?", [
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_support", title: "🙋 Talk to Team" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_demo":
      await sendTextMessage(from,
        "📅 *Book a Free Demo*\n\n" +
        "We'd love to show you what our bots can do for your business!\n\n" +
        "To schedule your free demo session:\n" +
        "📧 Email us: info@solworxs.com\n" +
        "🌐 Or visit: solworxs.com\n\n" +
        "Our team will get back to you within 24 hours. ⚡"
      );
      await sendButtonMessage(from, "Can I help with anything else?", [
        { id: "btn_products", title: "🤖 Our Bots" },
        { id: "btn_pricing", title: "💰 Pricing" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_support":
      await sendTextMessage(from,
        "🙋 *Talk to Our Team*\n\n" +
        "Our team is available Mon–Sat, 9AM–6PM IST.\n\n" +
        "📞 Call us: +91 9676829514\n" +
        "📧 Email: info@solworxs.com\n" +
        "🌐 Website: solworxs.com\n" +
        "📍 Location: Bangalore, India"
      );
      await sendButtonMessage(from, "Anything else?", [
        { id: "btn_menu", title: "📋 Main Menu" },
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_faq", title: "❓ FAQs" },
      ]);
      break;

    case "menu_faq":
      await sendTextMessage(from,
        "❓ *Frequently Asked Questions*\n\n" +
        "*Q: How long does setup take?*\n" +
        "A: Most bots go live within 24–48 hours.\n\n" +
        "*Q: Do I need technical knowledge?*\n" +
        "A: No. We handle everything for you.\n\n" +
        "*Q: Which platforms do you integrate with?*\n" +
        "A: Slack, WhatsApp, HubSpot, Salesforce, and more.\n\n" +
        "*Q: Is there a free trial?*\n" +
        "A: Yes — book a free demo to see it in action!"
      );
      await sendButtonMessage(from, "Still have questions?", [
        { id: "btn_support", title: "🙋 Talk to Team" },
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_about":
      await sendTextMessage(from,
        "🏢 *About Solworxs*\n\n" +
        "Solworxs builds enterprise-grade AI bots that automate workflows, accelerate sales pipelines, and elevate customer experiences.\n\n" +
        "🚀 10M+ conversations handled\n" +
        "✅ 99.9% uptime SLA\n" +
        "🔒 SOC-2 ready, enterprise encryption\n" +
        "📍 Based in Bangalore, India"
      );
      await sendButtonMessage(from, "Interested in working with us?", [
        { id: "btn_demo", title: "📅 Book a Demo" },
        { id: "btn_pricing", title: "💰 See Pricing" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    default:
      await sendListMenu(from);
  }
}

// ── Handle button taps
async function handleButtonReply(from, buttonId) {
  switch (buttonId) {
    case "btn_menu":
      await sendListMenu(from);
      break;
    case "btn_demo":
      await handleMenuSelection(from, "menu_demo");
      break;
    case "btn_support":
      await handleMenuSelection(from, "menu_support");
      break;
    case "btn_pricing":
      await handleMenuSelection(from, "menu_pricing");
      break;
    case "btn_products":
      await handleMenuSelection(from, "menu_products");
      break;
    case "btn_faq":
      await handleMenuSelection(from, "menu_faq");
      break;
    default:
      await sendListMenu(from);
  }
}

module.exports = { verifyWebhook, handleWebhook };
