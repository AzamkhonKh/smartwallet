// Uzbek (Latin script) strings
const Map<String, String> stringsUz = {
  // App
  'appTitle': 'Spendy',
  'appSubtitle': 'AI-asosida chek va hamyon kuzatuv tizimi',

  // Bottom navigation
  'navHome': 'Bosh sahifa',
  'navScan': 'Skaner',
  'navAccounts': 'Hisoblar',
  'navProfile': 'Profil',

  // Login screen
  'loginGetStarted': 'Boshlash',
  'loginGoogle': 'Google orqali kirish',
  'loginOr': 'YOKI DEMO',
  'loginDemoUsername': 'Demo foydalanuvchi',
  'loginDemoButton': 'Demo sifatida kirish',
  'loginSignInFailed': 'Kirishda xato',

  // Home screen
  'homeGreeting': 'Xayrli kun',
  'homeTotalSpending': 'Jami xarajatlar',
  'homeRecentTransactions': 'SO\'NGGI TRANZAKSIYALAR',
  'homeNoTransactions': 'Tranzaksiyalar yo\'q.\nBoshlash uchun chek skanerlang!',
  'homeAddManual': 'Qo\'lda qo\'shish',
  'homeSettingsTitle': 'Tezkor sozlamalar',
  'homeSettingsName': 'ISMINGIZ',
  'homeSettingsCurrency': 'ASOSIY VALYUTA',
  'homeSettingsSave': 'Saqlash',

  // Scanner screen
  'scanTitle': 'Chek skaneri',
  'scanAlignHint': 'Chekni ramkaga to\'g\'rilang',
  'scanSourceAccount': 'Manba hisob',
  'scanGallery': 'Galereya',
  'scanCamera': 'Kamera',
  'scanOCR': 'Ma\'lumotlar tanib olinmoqda...',
  'scanParsingItems': 'Tovarlar va jami qayta ishlanmoqda',
  'scanSavingDrafts': 'Navbatga saqlanmoqda',
  'scanAllDuplicate': 'Tanlangan barcha cheklar avval yuklangan.',
  'scanGemmaReading': 'Gemma chek tovarlarini o\'qimoqda...',

  // Transaction details
  'receiptImage': 'CHEK RASMI',
  'receiptZoomHint': 'Kattalashtirish uchun bosing',
  'extractedItems': 'AJRATIB OLINGAN TOVARLAR',
  'noLineItems': 'Aniq satr elementlari topilmadi.',
  'gemmaAdviceTitle': 'GEMMA 3N MASLAHATLARI',
  'gemmaGenerate': 'Gemma tavsiyalarini olish',
  'gemmaWaiting': 'Tavsiyalar qayta ishlanganidan so\'ng ko\'rinadi.',
  'deleteScanTitle': 'Chekni o\'chirish?',
  'deleteScanContent': 'Tranzaksiya o\'chiriladi va balanslar yangilanadi.',
  'duplicateTitle': 'Mumkin bo\'lgan takror aniqlandi',
  'duplicateDescription': 'Bu tranzaksiya boshqa yozuv bilan mos keladi (do\'kon, sana va summa). Takrorligini tekshiring.',
  'keepBoth': 'Ikkisini saqlash',
  'deleteDuplicate': 'Takrorni o\'chirish',
  'gemmaProcessing': 'Gemma 3n tavsiyalar yaratmoqda...',

  // Transaction form
  'formAddTitle': 'Tranzaksiya qo\'shish',
  'formEditTitle': 'Tranzaksiyani tahrirlash',
  'formMerchant': 'Do\'kon nomi/To\'lovchi',
  'formSourceAccount': 'Manba hisob',
  'formIsTransfer': 'Bu hisoblar o\'rtasidagi o\'tkazma?',
  'formDestAccount': 'Manzil hisob',
  'formCurrency': 'Tranzaksiya valyutasi',
  'formAmount': 'Jami summa',
  'formAddress': 'Do\'kon manzili (ixtiyoriy)',
  'formCategories': 'KATEGORIYALAR (BIR NECHTA TANLASH MUMKIN)',
  'formNoCategoriesHint': 'Kategoriyalar yo\'q. Kategoriyalar bo\'limida qo\'shing.',
  'formLineItems': 'SATR ELEMENTLARI',
  'formAddItem': 'Element qo\'shish',
  'formNoItems': 'Elementlar yo\'q. "Element qo\'shish" tugmasini bosing.',
  'formDateTime': 'TRANZAKSIYA SANASI VA VAQTI',
  'formSaveEdits': 'O\'zgarishlarni saqlash',
  'formSaveTransaction': 'Tranzaksiyani saqlash',
  'formMerchantRequired': 'Do\'kon nomini kiriting',
  'formSourceRequired': 'Manba hisobni tanlang',
  'formDestRequired': 'O\'tkazma uchun manzil hisobni tanlang',
  'formAmountRequired': 'Summani kiriting',
  'formAmountInvalid': 'To\'g\'ri summani kiriting',
  'formItemNameRequired': 'Tovar nomini kiriting',
  'formItemRequired': 'Majburiy maydon',
  'formItemInvalid': 'Noto\'g\'ri qiymat',

  // Accounts screen
  'accountsTitle': 'Hisoblar',
  'accountsSubtitle': 'Bank hisoblaringiz, hamyonlar va kartalarni boshqaring.',
  'accountsEmpty': 'Hisoblar topilmadi. Yuqori o\'ng tugma orqali qo\'shing.',
  'accountsCreateTitle': 'Yangi hisob yaratish',
  'accountsName': 'Hisob nomi',
  'accountsType': 'Hisob turi',
  'accountsInitialBalance': 'Boshlang\'ich balans',
  'accountsCurrency': 'Valyuta',
  'accountsCreate': 'Hisob yaratish',
  'accountsDeleteTitle': 'Hisobni o\'chirish?',
  'accountsDeleteContent': '"{name}" hisobini o\'chirishni xohlaysizmi? Ushbu hisobga bog\'liq barcha tranzaksiyalar ham o\'chiriladi.',

  // Profile screen
  'profileTitle': 'Profil',
  'profileEditButton': 'Profilni tahrirlash',
  'profileEditTitle': 'Profil sozlamalarini tahrirlash',
  'profileFullName': 'TO\'LIQ ISM',
  'profileNameHint': 'Ismingizni kiriting',
  'profilePrimaryCurrency': 'ASOSIY VALYUTA',
  'profilePrimaryCurrencyLabel': 'Asosiy valyuta: {currency} ({symbol})',
  'profileSave': 'Saqlash',
  'profilePreferences': 'SOZLAMALAR VA TAHLIL',
  'profileCategories': 'Kategoriyalar',
  'profileCategoriesSubtitle': 'Maxsus kategoriya yorliqlarini boshqaring',
  'profileStatistics': 'Statistika',
  'profileStatisticsSubtitle': 'Kategoriyalar bo\'yicha xarajat tahlili',
  'profileExchangeRates': 'Valyuta kurslari',
  'profileExchangeRatesSubtitle': 'Real vaqtli valyuta kurslarini ko\'rish',
  'profileLanguage': 'Til',
  'profileLanguageSubtitle': 'Ilova tilini tanlang',
  'profileAccountOps': 'HISOB AMALLARI',
  'profileLogout': 'Chiqish',
  'profileLogoutSubtitle': 'Aqlli hamyondan chiqish',

  // Language picker
  'languageSelect': 'Tilni tanlang',

  // Categories screen
  'categoriesTitle': 'Kategoriyalar',
  'categoriesSubtitle': 'Tranzaksiyalarni belgilash uchun kategoriya yorliqlarini boshqaring',
  'categoriesNewHint': 'Yangi kategoriya...',
  'categoriesAdd': 'Qo\'shish',
  'categoriesEmpty': 'Kategoriyalar topilmadi. Yangilash uchun pastga torting.',

  // Statistics
  'statsTitle': 'Statistika',

  // Exchange rates
  'exchangeRatesTitle': 'Valyuta kurslari',

  // Common
  'cancel': 'Bekor qilish',
  'delete': 'O\'chirish',
  'edit': 'Tahrirlash',
  'save': 'Saqlash',
  'close': 'Yopish',
  'loading': 'Yuklanmoqda...',

  // Errors
  'errorNetwork': 'Serverga ulanib bo\'lmadi. Internetni tekshiring.',
  'error400': 'Noto\'g\'ri so\'rov. Kiritilgan ma\'lumotlarni tekshiring.',
  'error401': 'Tizimga kirmagansiz. Iltimos, kiring.',
  'error403': 'Bu amalni bajarish uchun ruxsatingiz yo\'q.',
  'error404': 'So\'ralgan resurs topilmadi.',
  'error409': 'Bu chek allaqachon yuklangan.',
  'error413': 'Fayl juda katta. 10 MB dan kichik rasm ishlating.',
  'error500': 'Server xatosi yuz berdi. Keyinroq urinib ko\'ring.',
  'errorDefault': 'Kutilmagan xato yuz berdi. Qaytadan urinib ko\'ring.',

  // Success
  'successProfileUpdated': 'Profil muvaffaqiyatli yangilandi!',
  'successTransactionSaved': 'Tranzaksiya saqlandi!',
  'successBothKept': 'Ikki tranzaksiya ham saqlandi. Bayroqlar olib tashlandi.',

  // Formatted
  'scanQueuedSuccess': '{count} ta chek navbatga qo\'shildi! Fon rejimida qayta ishlanmoqda.',
  'uploadingBatch': '{count} ta chek yuklanmoqda...',
};
