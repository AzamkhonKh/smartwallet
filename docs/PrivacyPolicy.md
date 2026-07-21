# Privacy Policy — Recipe Wallet (Spendy)

**Effective Date:** July 18, 2026  
**Last Updated:** July 18, 2026

---

## 1. Introduction

Welcome to **Recipe Wallet** ("Spendy", "we", "our", or "us"). We are committed to protecting your privacy and handling your personal information with transparency and care.

This Privacy Policy explains what data we collect, how we use it, who we share it with, and what rights you have. By using our app, you agree to the practices described in this policy.

**Contact:**  
📧 azamkhon.kh@proton.me  
🏢 Azamkhon Khudoyberdiev

---

## 2. Information We Collect

### 2.1 Account Information
When you register or sign in, we collect:
- **Email address** — via Firebase Authentication or Google Sign-In
- **Display name** — from your Google account (if using Google Sign-In)
- **Profile photo URL** — from your Google account (optional)
- **User ID** — a unique identifier assigned to your account

### 2.2 Camera & Photo Library Access
Our app requests access to your **camera** and **photo library** solely to allow you to capture or select receipt images for expense tracking. We do **not** store raw photos on our servers beyond what is required for receipt processing.

- Receipt images are uploaded to secure cloud storage for OCR processing
- After structured data is extracted, the image is retained as an audit reference linked to your transaction record
- You may delete any transaction (and its associated image) at any time from within the app

### 2.3 Financial & Transaction Data
To provide our core budgeting and expense-tracking service, we collect:
- **Receipt items** — individual line items extracted from your scanned receipts (name, price, quantity)
- **Merchant information** — name, address, and transaction date
- **Transaction amounts and categories** — e.g., Groceries, Cafes & Dining, Transport
- **Budget limits** — monthly spending limits you configure per category

This data is stored in our secure database and is used exclusively to power your personal financial dashboard.

### 2.4 AI Data Processing & Sharing
To provide features like automated receipt parsing and budgeting recommendations, the app shares raw text and transaction parameters with secure third-party AI services. **This sharing only happens with your explicit prior consent.**
- Receipt images and extracted OCR text are processed via AI to classify items, total amount, merchant, and dates.
- Transaction summary fields (amounts, merchant name, categories) are processed to generate smart saving advice.
You can enable or disable this data sharing at any time in the app's Profile settings.

### 2.5 Usage Data
We may collect anonymized, aggregated usage information such as:
- App feature interactions (e.g., receipt scanner usage frequency)
- Crash reports and performance diagnostics

This data does **not** identify you personally and is used only to improve app quality.

---

## 3. How We Use Your Information

| Purpose | Data Used | Recipient |
|---------|-----------|-----------|
| User authentication & session management | Email, User ID, Firebase token | Firebase Authentication (Google) |
| Receipt OCR processing & text extraction | Receipt images, raw OCR text | Mistral AI & OpenRouter (Gemma) |
| Spending recommendations & insights | Transaction summary fields (merchant, amounts, categories) | OpenRouter (Gemma) |
| Expense tracking & budget management | Transaction items, amounts, categories | Private database storage |
| Providing analytics charts within the app | Aggregated transaction data | Private database storage |
| Sending processing status notifications | User ID, transaction status | Private backend services |
| Improving app performance | Anonymized crash & usage logs | Firebase Crashlytics |

We do **not** use your data for advertising, sell it to third parties, or share it with data brokers.

---

## 4. Third-Party Services

We integrate with the following third-party providers to power specific app features:

| Service | Purpose | Data Shared | Privacy Policy |
|---------|---------|-------------|----------------|
| **Firebase Authentication** (Google) | Secure user login | Email, name, authentication tokens | [firebase.google.com/support/privacy](https://firebase.google.com/support/privacy) |
| **Google Sign-In** | OAuth login option | Google profile info (name, email) | [policies.google.com/privacy](https://policies.google.com/privacy) |
| **Firebase Crashlytics** | Crash reporting | Anonymized diagnostics and crash traces | [firebase.google.com/support/privacy](https://firebase.google.com/support/privacy) |
| **OpenRouter AI** | Receipt text parsing and generating budgeting tips | Receipt OCR text, transaction summaries (merchant, total, tags) | [openrouter.ai/privacy](https://openrouter.ai/privacy) |
| **Mistral AI** | Receipt text extraction and OCR processing | Uploaded receipt images/scans | [mistral.ai/privacy-policy/](https://mistral.ai/privacy-policy/) |

All data transmitted to OpenRouter and Mistral AI is sent over secure, encrypted SSL connections. These services do not store your data for advertising and are contractually prohibited from using your data to train their models.

---

## 5. Data Storage & Security

- All data is transmitted over **HTTPS/TLS** encrypted connections
- Receipt images are stored in private, access-controlled cloud storage
- Database access is restricted to authenticated backend services only
- We retain your data for as long as your account is active

---

## 6. Data Retention

- **Account data** is retained until you delete your account
- **Transaction & receipt data** is retained until you delete individual records or your account
- **Anonymized usage logs** may be retained for up to 12 months

---

## 7. Your Rights & Choice

Depending on your jurisdiction, you may have the right to:

- ✅ **Access** — Request a copy of the personal data we hold about you
- ✅ **Correction** — Request correction of inaccurate data
- ✅ **Deletion** — Request deletion of your account and all associated data
- ✅ **Export** — Request an export of your financial data in a portable format
- ✅ **Withdraw Consent** — Revoke camera/photo library permissions at any time via iOS Settings, or toggle off "AI Sharing Consent" in the app's Profile settings to disable AI-based receipt scanning and insights.

To exercise any of these rights, contact us at: **azamkhon.kh@proton.me**

---

## 8. Children's Privacy

Recipe Wallet is not directed at children under the age of **13**. We do not knowingly collect personal information from children. If you believe a child has provided us with personal data, please contact us immediately and we will delete it.

---

## 9. Camera & Microphone Permissions

| Permission | Why It's Needed |
|-----------|----------------|
| **Camera** | To capture receipt photos directly within the app |
| **Photo Library (Read)** | To upload existing receipt images from your device |
| **Photo Library (Write)** | To save receipt images if you choose to export |
| **Microphone** | Required by Apple's camera framework; we do not record audio |

You can revoke these permissions at any time in **iOS Settings → Recipe Wallet**.

---

## 10. Changes to This Policy

We may update this Privacy Policy from time to time. When we do, we will update the **"Last Updated"** date at the top and notify you via an in-app notice if the changes are significant.

---

## 11. Contact Us

**📧 Email:** azamkhon.kh@proton.me  
**🏢 Developer:** Azamkhon Khudoyberdiev

---

*This privacy policy applies to the Recipe Wallet (Spendy) iOS application, bundle ID: `com.recipewallet.spendy`.*
