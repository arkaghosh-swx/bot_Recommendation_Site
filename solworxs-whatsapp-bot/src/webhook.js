const { sendTextMessage, sendListMenu, sendButtonMessage } = require("./whatsapp");
const { getAIReply } = require("./claude");

const conversations = {};
const seenUsers = {};

function verifyWebhook(req, res) {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];
  if (mode === "subscribe" && token === process.env.WEBHOOK_VERIFY_TOKEN) {
    console.log("✅ Webhook verified");
    res.status(200).send(challenge);
  } else {
    res.sendStatus(403);
  }
}

async function handleWebhook(req, res) {
  res.sendStatus(200);
  try {
    const body = req.body;
    if (
      body.object !== "whatsapp_business_account" ||
      !body.entry?.[0]?.changes?.[0]?.value?.messages?.[0]
    ) return;

    const value = body.entry[0].changes[0].value;
    const message = value.messages[0];
    const from = message.from;

    if (!seenUsers[from]) {
      seenUsers[from] = true;
      await sendListMenu(from);
      return;
    }

    if (message.type === "interactive" && message.interactive.type === "list_reply") {
      await handleMenuSelection(from, message.interactive.list_reply.id);
      return;
    }

    if (message.type === "interactive" && message.interactive.type === "button_reply") {
      await handleButtonReply(from, message.interactive.button_reply.id);
      return;
    }

    if (message.type === "text") {
      const userText = message.text.body.trim();
      if (!conversations[from]) conversations[from] = [];
      conversations[from].push({ role: "user", content: userText });
      if (conversations[from].length > 10) conversations[from].shift();
      const reply = await getAIReply(conversations[from]);
      conversations[from].push({ role: "assistant", content: reply });
      await sendTextMessage(from, reply);
      await sendButtonMessage(from, "Can I help with anything else?", [
        { id: "btn_menu", title: "📋 Main Menu" },
        { id: "btn_book", title: "📅 Book Now" },
        { id: "btn_contact", title: "📞 Contact Us" },
      ]);
      return;
    }

    await sendTextMessage(from, "Sorry, I can only handle text messages right now. 🙏");
  } catch (err) {
    console.error("Webhook error:", err.message);
  }
}

async function handleMenuSelection(from, selectedId) {
  switch (selectedId) {

    case "menu_about":
      await sendTextMessage(from,
        "🏥 *About Warrior Homoeopath*\n\n" +
        "We are a global collective of licensed Homoeopaths led by Dr Gayatri, with practitioners across India, UAE, and UK.\n\n" +
        "We specialise in precision-based Homoeopathic care for chronic and complex conditions — focusing on root-cause resolution, not just symptom control.\n\n" +
        "_Aude sapere. Dare to heal._ 🌿"
      );
      await sendButtonMessage(from, "What would you like to know next?", [
        { id: "btn_conditions", title: "🩺 Conditions" },
        { id: "btn_consult", title: "💬 Consultations" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_conditions":
      await sendTextMessage(from,
        "🩺 *Conditions We Treat*\n\n" +
        "• Skin: Eczema, Psoriasis, Acne, Vitiligo\n" +
        "• Chronic: Migraines, PCOS, Hormonal imbalances\n" +
        "• Digestive: SIBO, IBS, Indigestion\n" +
        "• Mental health: Anxiety, Depression, Sleep issues\n" +
        "• Autoimmune: Rheumatoid Arthritis, Lupus\n" +
        "• Men's health: BPH, Male infertility\n" +
        "• Veterans: PTSD, Chronic pain, Tinnitus\n" +
        "• Autism spectrum support\n" +
        "• And much more!\n\n" +
        "📧 Not sure if we can help? Email ask@warriorhomoeopath.com"
      );
      await sendButtonMessage(from, "Ready to start your healing journey?", [
        { id: "btn_book", title: "📅 Book Now" },
        { id: "btn_pricing", title: "💰 Pricing" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_consult":
      await sendTextMessage(from,
        "💬 *About Consultations*\n\n" +
        "All consultations are online via Zoom, Google Meet, or Teams.\n\n" +
        "⏱ *Duration:*\n" +
        "• First consultation: 45–60 mins\n" +
        "• Follow-up: 30 mins\n" +
        "• Urgent care: 15–20 mins\n\n" +
        "🔒 100% private and confidential\n" +
        "🌍 Available worldwide\n" +
        "🗣 English only (translator welcome)"
      );
      await sendButtonMessage(from, "Would you like to book?", [
        { id: "btn_book", title: "📅 Book Now" },
        { id: "btn_pricing", title: "💰 See Pricing" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_pricing":
      await sendTextMessage(from,
        "💰 *Consultation Fees*\n\n" +
        "🌍 *International (GBP):*\n" +
        "• First consultation: £150\n" +
        "• Follow-up: £75\n" +
        "• Urgent care: £50\n\n" +
        "🇮🇳 *India (INR):*\n" +
        "• First consultation: ₹5,000\n" +
        "• Follow-up: ₹1,500\n" +
        "• Urgent care: ₹1,000\n\n" +
        "⚠️ Medicines are NOT included and must be purchased separately.\n" +
        "❌ No refunds once booked. Reschedule 48hrs in advance."
      );
      await sendButtonMessage(from, "Ready to book your consultation?", [
        { id: "btn_book", title: "📅 Book Now" },
        { id: "btn_consult", title: "💬 Learn More" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_book":
      await sendTextMessage(from,
        "📅 *Book Your Consultation*\n\n" +
        "Click the link below to book your appointment:\n" +
        "👉 https://warriorhomoeopath.dayschedule.com\n\n" +
        "For appointment queries:\n" +
        "📧 appointment@warriorhomoeopath.com\n\n" +
        "Our team will confirm your slot and send you a secure video link. 🌿"
      );
      await sendButtonMessage(from, "Anything else I can help with?", [
        { id: "btn_pricing", title: "💰 Pricing" },
        { id: "btn_contact", title: "📞 Contact Us" },
        { id: "btn_menu", title: "📋 Main Menu" },
      ]);
      break;

    case "menu_contact":
      await sendTextMessage(from,
        "📞 *Contact Warrior Homoeopath*\n\n" +
        "📧 Appointments: appointment@warriorhomoeopath.com\n" +
        "📧 Enquiries: ask@warriorhomoeopath.com\n\n" +
        "📱 India: +91 9071961355\n" +
        "📱 UK: +44 7700 148710\n\n" +
        "🌐 Website: warriorhomeopath.com\n\n" +
        "We respond within 24 hours. 💚"
      );
      await sendButtonMessage(from, "Can I help you further?", [
        { id: "btn_book", title: "📅 Book Now" },
        { id: "btn_menu", title: "📋 Main Menu" },
        { id: "btn_conditions", title: "🩺 Conditions" },
      ]);
      break;

    default:
      await sendListMenu(from);
  }
}

async function handleButtonReply(from, buttonId) {
  switch (buttonId) {
    case "btn_menu": await sendListMenu(from); break;
    case "btn_book": await handleMenuSelection(from, "menu_book"); break;
    case "btn_contact": await handleMenuSelection(from, "menu_contact"); break;
    case "btn_pricing": await handleMenuSelection(from, "menu_pricing"); break;
    case "btn_conditions": await handleMenuSelection(from, "menu_conditions"); break;
    case "btn_consult": await handleMenuSelection(from, "menu_consult"); break;
    default: await sendListMenu(from);
  }
}

module.exports = { verifyWebhook, handleWebhook };