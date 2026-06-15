// Russian strings
const Map<String, String> stringsRu = {
  // App
  'appTitle': 'NEO WALLET',
  'appSubtitle': 'Умный ИИ-трекер чеков и кошелька',

  // Bottom navigation
  'navHome': 'Главная',
  'navScan': 'Сканер',
  'navAccounts': 'Счета',
  'navProfile': 'Профиль',

  // Login screen
  'loginGetStarted': 'Начать',
  'loginGoogle': 'Войти через Google',
  'loginOr': 'ИЛИ ДЕМО',
  'loginDemoUsername': 'Демо-логин',
  'loginDemoButton': 'Войти как демо-пользователь',
  'loginSignInFailed': 'Ошибка входа',

  // Home screen
  'homeGreeting': 'Добрый день',
  'homeTotalSpending': 'Общие расходы',
  'homeRecentTransactions': 'ПОСЛЕДНИЕ ТРАНЗАКЦИИ',
  'homeNoTransactions': 'Транзакций пока нет.\nОтсканируйте чек для начала!',
  'homeAddManual': 'Добавить вручную',
  'homeSettingsTitle': 'Быстрые настройки',
  'homeSettingsName': 'ВАШЕ ИМЯ',
  'homeSettingsCurrency': 'ОСНОВНАЯ ВАЛЮТА',
  'homeSettingsSave': 'Сохранить',

  // Scanner screen
  'scanTitle': 'Сканер чеков',
  'scanAlignHint': 'Совместите чек с рамкой',
  'scanSourceAccount': 'Исходный счёт',
  'scanGallery': 'Галерея',
  'scanCamera': 'Камера',
  'scanOCR': 'Распознавание данных...',
  'scanParsingItems': 'Обработка позиций и суммы',
  'scanSavingDrafts': 'Сохранение в очередь',
  'scanAllDuplicate': 'Все выбранные чеки уже были загружены.',
  'scanGemmaReading': 'Gemma читает позиции чека...',

  // Transaction details
  'receiptImage': 'ИЗОБРАЖЕНИЕ ЧЕКА',
  'receiptZoomHint': 'Нажмите для увеличения',
  'extractedItems': 'ИЗВЛЕЧЁННЫЕ ТОВАРЫ',
  'noLineItems': 'Конкретные позиции не извлечены.',
  'gemmaAdviceTitle': 'СОВЕТЫ GEMMA 3N',
  'gemmaGenerate': 'Получить советы Gemma',
  'gemmaWaiting': 'Советы появятся после завершения обработки.',
  'deleteScanTitle': 'Удалить чек?',
  'deleteScanContent': 'Транзакция будет удалена и балансы обновятся.',
  'duplicateTitle': 'Обнаружен возможный дубликат',
  'duplicateDescription': 'Эта транзакция совпадает с другой записью (магазин, дата и сумма). Проверьте, является ли это дубликатом.',
  'keepBoth': 'Оставить оба',
  'deleteDuplicate': 'Удалить дубликат',
  'gemmaProcessing': 'Gemma 3n генерирует рекомендации...',

  // Transaction form
  'formAddTitle': 'Добавить транзакцию',
  'formEditTitle': 'Редактировать транзакцию',
  'formMerchant': 'Название магазина/получателя',
  'formSourceAccount': 'Исходный счёт',
  'formIsTransfer': 'Это перевод между счетами?',
  'formDestAccount': 'Счёт назначения',
  'formCurrency': 'Валюта транзакции',
  'formAmount': 'Общая сумма',
  'formAddress': 'Адрес магазина (необязательно)',
  'formCategories': 'КАТЕГОРИИ (МОЖНО НЕСКОЛЬКО)',
  'formNoCategoriesHint': 'Нет категорий. Добавьте их в разделе Категории.',
  'formLineItems': 'ПОЗИЦИИ',
  'formAddItem': 'Добавить позицию',
  'formNoItems': 'Позиций нет. Нажмите "Добавить позицию".',
  'formDateTime': 'ДАТА И ВРЕМЯ',
  'formSaveEdits': 'Сохранить изменения',
  'formSaveTransaction': 'Сохранить транзакцию',
  'formMerchantRequired': 'Введите название магазина',
  'formSourceRequired': 'Выберите исходный счёт',
  'formDestRequired': 'Выберите счёт назначения для перевода',
  'formAmountRequired': 'Введите сумму',
  'formAmountInvalid': 'Введите корректную сумму',
  'formItemNameRequired': 'Введите название товара',
  'formItemRequired': 'Обязательное поле',
  'formItemInvalid': 'Неверное значение',

  // Accounts screen
  'accountsTitle': 'Счета',
  'accountsSubtitle': 'Управляйте банковскими счетами, кошельками и картами.',
  'accountsEmpty': 'Счета не найдены. Добавьте через кнопку вверху справа.',
  'accountsCreateTitle': 'Создать новый счёт',
  'accountsName': 'Название счёта',
  'accountsType': 'Тип счёта',
  'accountsInitialBalance': 'Начальный баланс',
  'accountsCurrency': 'Валюта',
  'accountsCreate': 'Создать счёт',
  'accountsDeleteTitle': 'Удалить счёт?',
  'accountsDeleteContent': 'Вы уверены, что хотите удалить «{name}»? Все связанные транзакции также будут удалены.',

  // Profile screen
  'profileTitle': 'Профиль',
  'profileEditButton': 'Редактировать профиль',
  'profileEditTitle': 'Настройки профиля',
  'profileFullName': 'ПОЛНОЕ ИМЯ',
  'profileNameHint': 'Введите ваше имя',
  'profilePrimaryCurrency': 'ОСНОВНАЯ ВАЛЮТА',
  'profilePrimaryCurrencyLabel': 'Основная валюта: {currency} ({symbol})',
  'profileSave': 'Сохранить',
  'profilePreferences': 'НАСТРОЙКИ И АНАЛИТИКА',
  'profileCategories': 'Категории',
  'profileCategoriesSubtitle': 'Управление метками категорий',
  'profileStatistics': 'Статистика',
  'profileStatisticsSubtitle': 'Аналитика расходов по категориям',
  'profileExchangeRates': 'Курсы валют',
  'profileExchangeRatesSubtitle': 'Курсы валют в реальном времени',
  'profileLanguage': 'Язык',
  'profileLanguageSubtitle': 'Выберите язык приложения',
  'profileAccountOps': 'ОПЕРАЦИИ С АККАУНТОМ',
  'profileLogout': 'Выйти',
  'profileLogoutSubtitle': 'Выйти из умного кошелька',

  // Language picker
  'languageSelect': 'Выберите язык',

  // Categories screen
  'categoriesTitle': 'Категории',
  'categoriesSubtitle': 'Управление метками для классификации транзакций',
  'categoriesNewHint': 'Новая категория...',
  'categoriesAdd': 'Добавить',
  'categoriesEmpty': 'Категорий нет. Потяните вниз для обновления.',

  // Statistics screen
  'statsTitle': 'Статистика',

  // Exchange rates screen
  'exchangeRatesTitle': 'Курсы валют',

  // Common
  'cancel': 'Отмена',
  'delete': 'Удалить',
  'edit': 'Редактировать',
  'save': 'Сохранить',
  'close': 'Закрыть',
  'loading': 'Загрузка...',

  // Errors
  'errorNetwork': 'Нет подключения к серверу. Проверьте интернет.',
  'error400': 'Неверный запрос. Проверьте введённые данные.',
  'error401': 'Вы не авторизованы. Пожалуйста, войдите в систему.',
  'error403': 'У вас нет прав для выполнения этого действия.',
  'error404': 'Запрошенный ресурс не найден.',
  'error409': 'Этот чек уже был загружен.',
  'error413': 'Файл слишком большой. Используйте изображение до 10 МБ.',
  'error500': 'Ошибка на сервере. Попробуйте позже.',
  'errorDefault': 'Произошла неожиданная ошибка. Попробуйте снова.',

  // Success messages
  'successProfileUpdated': 'Профиль успешно обновлён!',
  'successTransactionSaved': 'Транзакция сохранена!',
  'successBothKept': 'Обе транзакции сохранены. Флаги сняты.',

  // Formatted
  'scanQueuedSuccess': 'Добавлено {count} чеков! Обработка в фоне.',
  'uploadingBatch': 'Загрузка {count} чеков...',
};
