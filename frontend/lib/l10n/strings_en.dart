// English strings
const Map<String, String> stringsEn = {
  // App
  'appTitle': 'Spendy',
  'appSubtitle': 'Intelligent AI-Powered Receipts & Wallet Tracker',

  // Bottom navigation
  'navHome': 'Home',
  'navScan': 'Scan',
  'navAccounts': 'Accounts',
  'navProfile': 'Profile',

  // Login screen
  'loginGetStarted': 'Get Started',
  'loginGoogle': 'Continue with Google',
  'loginOr': 'OTHER METHODS',
  'loginDemoUsername': 'Demo Username',
  'loginDemoButton': 'Sign In as Demo User',
  'loginSignInFailed': 'Sign-in failed',
  'loginApple': 'Continue with Apple',

  // Home screen
  'homeGreeting': 'Good day',
  'homeTotalSpending': 'Total Spending',
  'homeRecentTransactions': 'RECENT TRANSACTIONS',
  'homeNoTransactions': 'No transactions yet.\nScan a receipt to get started!',
  'homeAddManual': 'Add Manually',
  'homeSettingsTitle': 'Quick Settings',
  'homeSettingsName': 'YOUR NAME',
  'homeSettingsCurrency': 'PRIMARY CURRENCY',
  'homeSettingsSave': 'Save Changes',

  // Scanner screen
  'scanTitle': 'Receipt Scanner',
  'scanAlignHint': 'Align receipt within frame',
  'scanSourceAccount': 'Source Account',
  'scanGallery': 'Gallery',
  'scanCamera': 'Camera',
  'scanOCR': 'Running OCR Data Extraction...',
  'scanParsingItems': 'Parsing items & total',
  'scanSavingDrafts': 'Saving drafts to task queue',
  'scanAllDuplicate': 'All selected receipts had already been uploaded.',
  'scanGemmaReading': 'Gemma is reading the receipt items...',

  // Transaction details
  'receiptImage': 'RECEIPT IMAGE',
  'receiptZoomHint': 'Tap to zoom receipt image',
  'extractedItems': 'EXTRACTED ITEMS',
  'noLineItems': 'No specific line items extracted.',
  'gemmaAdviceTitle': 'GEMMA 3N SAVINGS ADVICE',
  'gemmaGenerate': 'Generate Gemma Insights',
  'gemmaWaiting': 'Insights will become available after parsing is complete.',
  'deleteScanTitle': 'Delete Scan?',
  'deleteScanContent':
      'This will remove the transaction and update your balances.',
  'duplicateTitle': 'Possible Duplicate Detected',
  'duplicateDescription':
      'This transaction matches another record (Merchant, Date, and Amount match). Verify if it is a duplicate.',
  'keepBoth': 'Keep Both',
  'deleteDuplicate': 'Delete Duplicate',
  'gemmaProcessing': 'Gemma 3n is generating recommendations...',

  // Transaction form
  'formAddTitle': 'Add Transaction',
  'formEditTitle': 'Edit Transaction',
  'formMerchant': 'Merchant Name/Payee',
  'formSourceAccount': 'Source Account',
  'formIsTransfer': 'Is this a transfer to another account?',
  'formDestAccount': 'Destination Account',
  'formCurrency': 'Transaction Currency',
  'formAmount': 'Total Amount',
  'formAddress': 'Merchant Address (Optional)',
  'formCategories': 'CATEGORIES (SELECT MULTIPLE TAGS)',
  'formNoCategoriesHint':
      'No categories available. Please add some in the Categories tab.',
  'formLineItems': 'LINE ITEMS',
  'formAddItem': 'Add Item',
  'formNoItems': 'No items added yet. Click Add Item to enter products.',
  'formDateTime': 'TRANSACTION DATE & TIME',
  'formSaveEdits': 'Save Edits',
  'formSaveTransaction': 'Save Transaction',
  'formMerchantRequired': 'Please enter the merchant name',
  'formSourceRequired': 'Source account is required',
  'formDestRequired': 'Destination account is required for transfers',
  'formAmountRequired': 'Please enter the amount',
  'formAmountInvalid': 'Please enter a valid amount',
  'formItemNameRequired': 'Enter item name',
  'formItemRequired': 'Required',
  'formItemInvalid': 'Invalid',

  // Accounts screen
  'accountsTitle': 'Accounts',
  'accountsSubtitle':
      'Manage your bank accounts, digital wallets, cash balances, and cards.',
  'accountsEmpty': 'No accounts found. Add one using the top right button.',
  'accountsCreateTitle': 'Create New Account',
  'accountsName': 'Account Name',
  'accountsType': 'Account Type',
  'accountsInitialBalance': 'Initial Balance',
  'accountsCurrency': 'Currency',
  'accountsCreate': 'Create Account',
  'accountsDeleteTitle': 'Delete Account?',
  'accountsDeleteContent':
      'Are you sure you want to delete "{name}"? All transactions associated with this account will also be deleted.',

  // Profile screen
  'profileTitle': 'Profile',
  'profileEditButton': 'Edit Profile',
  'profileEditTitle': 'Edit Profile Settings',
  'profileFullName': 'FULL NAME',
  'profileNameHint': 'Enter your name',
  'profilePrimaryCurrency': 'PRIMARY CURRENCY',
  'profilePrimaryCurrencyLabel': 'Primary Currency: {currency} ({symbol})',
  'profileSave': 'Save Changes',
  'profilePreferences': 'PREFERENCES & ANALYTICS',
  'profileCategories': 'Categories',
  'profileCategoriesSubtitle': 'Manage your custom category labels',
  'profileStatistics': 'Statistics',
  'profileStatisticsSubtitle': 'View category-wise spending analytics',
  'profileExchangeRates': 'Exchange Rates',
  'profileExchangeRatesSubtitle': 'View real-time currency exchange rates',
  'profileLanguage': 'Language',
  'profileLanguageSubtitle': 'Choose app display language',
  'profileAccountOps': 'ACCOUNT OPERATIONS',
  'profileLogout': 'Logout',
  'profileLogoutSubtitle': 'Sign out of your smart wallet account',
  'profileDeleteAccount': 'Delete Account',
  'profileDeleteAccountSubtitle':
      'Permanently delete your account and all data',
  'deleteAccountConfirmTitle': 'Delete Account?',
  'deleteAccountConfirmContent':
      'Are you absolutely sure? All your data (transactions, accounts, categories) will be permanently deleted and cannot be undone.',

  // Language picker
  'languageSelect': 'Select Language',

  // Categories screen
  'categoriesTitle': 'Categories',
  'categoriesSubtitle': 'Manage category labels for tagging transactions',
  'categoriesNewHint': 'New category label...',
  'categoriesAdd': 'Add',
  'categoriesEmpty': 'No categories found. Pull down to refresh.',

  // Statistics screen
  'statsTitle': 'Statistics',

  // Exchange rates screen
  'exchangeRatesTitle': 'Exchange Rates',

  // Common
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'save': 'Save',
  'close': 'Close',
  'loading': 'Loading...',

  // Errors (AppSnackBar defaults)
  'errorNetwork':
      'Could not connect to the server. Check your internet connection.',
  'error400': 'Invalid request. Please check your input and try again.',
  'error401': 'You are not signed in. Please log in and try again.',
  'error403': 'You do not have permission to perform this action.',
  'error404': 'The requested resource was not found.',
  'error409': 'This receipt has already been uploaded.',
  'error413': 'The file is too large. Please use an image under 10 MB.',
  'error500': 'Something went wrong on our end. Please try again later.',
  'errorDefault': 'An unexpected error occurred. Please try again.',

  // Success messages
  'successProfileUpdated': 'Profile updated successfully!',
  'successTransactionSaved': 'Transaction saved!',
  'successBothKept': 'Both transactions kept. Flags cleared.',

  // Formatted strings (use {placeholder})
  'scanQueuedSuccess':
      'Successfully queued {count} receipts! Processing in the background.',
  'uploadingBatch': 'Uploading {count} receipts...',

  // AI Consent
  'aiConsentTitle': 'AI Privacy Consent',
  'aiConsentSubtitle': 'Privacy & Data Sharing Disclosure',
  'aiConsentDesc': 'To provide automated receipt scanning and personalized spending tips, Spendy integrates with secure third-party AI services.',
  'aiConsentWhoTitle': 'Who is the data sent to?',
  'aiConsentWhoDesc': 'We securely send receipt details to OpenRouter (running Gemini models) and Mistral AI. They do not store your data to train their models.',
  'aiConsentWhatTitle': 'What data is sent?',
  'aiConsentWhatDesc': 'Receipt images/text are sent for OCR processing, and transaction summaries are sent to generate saving advice.',
  'aiConsentProtectedTitle': 'How is it protected?',
  'aiConsentProtectedDesc': 'All requests are encrypted. No personal information like email or passwords is ever shared.',
  'aiConsentDecline': 'Decline',
  'aiConsentAgree': 'Agree & Enable',
  'aiConsentSnackbarDecline': 'AI features are disabled without consent.',
  'aiConsentSnackbarAgree': 'AI features enabled successfully!',
  'profileAiConsent': 'AI Sharing Consent',
  'profileAiConsentSub': 'Authorize data sharing with third-party AI services',
  'profilePrivacyPolicy': 'Privacy Policy',
  'profilePrivacyPolicySub': 'View our user data protection practices',
};
