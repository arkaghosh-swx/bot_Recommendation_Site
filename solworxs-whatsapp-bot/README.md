# Solworxs WhatsApp AI Bot

A real WhatsApp bot powered by Claude AI, built on Meta's Cloud API and hosted on Railway.

---

## Architecture

```
User on WhatsApp → Meta Cloud API → Your webhook (Railway) → Claude AI → Reply
```

---

## Step 1 — Meta Developer Setup

### 1.1 Create a Meta Developer Account
1. Go to **https://developers.facebook.com**
2. Click **Get Started** → log in with your Facebook account
3. Accept developer terms

### 1.2 Create a new App
1. Click **My Apps → Create App**
2. Select **Business** as the app type
3. Fill in App Name: `Solworxs WhatsApp Bot`
4. Click **Create App**

### 1.3 Add WhatsApp to your App
1. In your app dashboard, scroll to **Add Products**
2. Find **WhatsApp** → click **Set Up**
3. You'll land on the **WhatsApp Getting Started** page

### 1.4 Get your credentials
On the **WhatsApp → API Setup** page you'll see:
- **Phone Number ID** → copy this (goes in `WHATSAPP_PHONE_NUMBER_ID`)
- **Temporary Access Token** → copy this for now (we'll make it permanent later)

### 1.5 Add a test phone number
- Meta gives you a free test number to start
- Add your own WhatsApp number as a recipient under **To** field
- Send a test message to confirm it works

---

## Step 2 — Deploy to Railway

### 2.1 Push code to GitHub
1. Create a new repo on GitHub (e.g. `solworxs-whatsapp-bot`)
2. Push this entire folder to that repo:
```bash
git init
git add .
git commit -m "Initial bot setup"
git remote add origin https://github.com/YOUR_USERNAME/solworxs-whatsapp-bot.git
git push -u origin main
```

### 2.2 Deploy on Railway
1. Go to **https://railway.app** → sign up with GitHub
2. Click **New Project → Deploy from GitHub repo**
3. Select your `solworxs-whatsapp-bot` repo
4. Railway will auto-detect Node.js and deploy

### 2.3 Add Environment Variables on Railway
In your Railway project → **Variables** tab, add:

| Variable | Value |
|---|---|
| `WHATSAPP_PHONE_NUMBER_ID` | From Meta Step 1.4 |
| `WHATSAPP_ACCESS_TOKEN` | From Meta Step 1.4 |
| `WEBHOOK_VERIFY_TOKEN` | `solworxs_webhook_secret_2026` |
| `ANTHROPIC_API_KEY` | From https://console.anthropic.com |

### 2.4 Get your public URL
- Railway gives you a URL like: `https://solworxs-whatsapp-bot-production.up.railway.app`
- Copy this — you'll need it in the next step

---

## Step 3 — Connect Webhook to Meta

### 3.1 Configure the webhook
1. In Meta Developer Console → **WhatsApp → Configuration**
2. Click **Edit** next to Webhook
3. Fill in:
   - **Callback URL**: `https://YOUR-RAILWAY-URL.up.railway.app/webhook`
   - **Verify Token**: `solworxs_webhook_secret_2026`
4. Click **Verify and Save**
   - If it shows ✅ — your server is running and verified!

### 3.2 Subscribe to messages
1. Under **Webhook Fields**, find **messages**
2. Click **Subscribe**

---

## Step 4 — Generate a Permanent Access Token

The temporary token expires in 24 hours. Here's how to make it permanent:

1. Go to **https://business.facebook.com** → create a Business account if needed
2. In Meta Developer Console → **App Settings → Basic** → link your Business account
3. Go to **System Users** in Business Manager → create a System User
4. Assign your WhatsApp app to the System User with `whatsapp_business_messaging` permission
5. Generate a token → this is your permanent `WHATSAPP_ACCESS_TOKEN`
6. Update this in Railway Variables

---

## Step 5 — Update your website

In your `index.html`, change the WhatsApp bot card's Explore button:

```html
<!-- Change this: -->
<a href="#" class="btn-outline full bot-link">

<!-- To this (your WhatsApp number with wa.me link): -->
<a href="https://wa.me/91XXXXXXXXXX?text=Hi%20Solworxs!" 
   target="_blank" class="btn-outline full bot-link">
```

Replace `91XXXXXXXXXX` with your WhatsApp Business number (country code + number, no +).

---

## Testing

Once deployed, send a WhatsApp message to your business number.
You should get an AI reply within 2-3 seconds.

Check Railway logs (Deployments → View Logs) to debug any issues.

---

## File Structure

```
solworxs-whatsapp-bot/
├── src/
│   ├── server.js      # Express server + routes
│   ├── webhook.js     # Message receive + reply logic
│   ├── claude.js      # Claude AI integration
│   └── whatsapp.js    # Meta Cloud API sender
├── .env.example       # Environment variable template
├── .gitignore
├── package.json
└── README.md
```

---

## Customising the Bot

To change what the bot says or how it behaves, edit the `SYSTEM_PROMPT` in `src/claude.js`.

For example, to make it only answer Solworxs-related questions:
```js
const SYSTEM_PROMPT = `You are a support agent for Solworxs only. 
Only answer questions related to Solworxs products and services.
For off-topic questions, politely redirect.`;
```

---

## Support

Email: info@solworxs.com
