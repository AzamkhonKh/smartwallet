import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_ru.dart';
import 'strings_uz.dart';
import 'strings_uz_cyrl.dart';

/// Provides typed accessors to all user-visible strings for the current locale.
/// Retrieve via [AppLocalizations.of(context)].
///
/// Supported locales: en, ru, uz (Latin), uz_Cyrl (Cyrillic).
class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    _strings = _stringsFor(locale);
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, String> _stringsFor(Locale locale) {
    if (locale.languageCode == 'ru') return stringsRu;
    if (locale.languageCode == 'uz') {
      if (locale.scriptCode == 'Cyrl') return stringsUzCyrl;
      return stringsUz;
    }
    return stringsEn;
  }

  // ── Internal helper ───────────────────────────────────────────────────────
  String _s(String key) => _strings[key] ?? stringsEn[key] ?? key;

  // ── App ───────────────────────────────────────────────────────────────────
  String get appTitle => _s('appTitle');
  String get appSubtitle => _s('appSubtitle');

  // ── Bottom navigation ─────────────────────────────────────────────────────
  String get navHome => _s('navHome');
  String get navScan => _s('navScan');
  String get navAccounts => _s('navAccounts');
  String get navProfile => _s('navProfile');

  // ── Login ─────────────────────────────────────────────────────────────────
  String get loginGetStarted => _s('loginGetStarted');
  String get loginGoogle => _s('loginGoogle');
  String get loginOr => _s('loginOr');
  String get loginDemoUsername => _s('loginDemoUsername');
  String get loginDemoButton => _s('loginDemoButton');
  String get loginSignInFailed => _s('loginSignInFailed');

  // ── Home ──────────────────────────────────────────────────────────────────
  String get homeGreeting => _s('homeGreeting');
  String get homeTotalSpending => _s('homeTotalSpending');
  String get homeRecentTransactions => _s('homeRecentTransactions');
  String get homeNoTransactions => _s('homeNoTransactions');
  String get homeAddManual => _s('homeAddManual');
  String get homeSettingsTitle => _s('homeSettingsTitle');
  String get homeSettingsName => _s('homeSettingsName');
  String get homeSettingsCurrency => _s('homeSettingsCurrency');
  String get homeSettingsSave => _s('homeSettingsSave');

  // ── Scanner ───────────────────────────────────────────────────────────────
  String get scanTitle => _s('scanTitle');
  String get scanAlignHint => _s('scanAlignHint');
  String get scanSourceAccount => _s('scanSourceAccount');
  String get scanGallery => _s('scanGallery');
  String get scanCamera => _s('scanCamera');
  String get scanOCR => _s('scanOCR');
  String get scanParsingItems => _s('scanParsingItems');
  String get scanSavingDrafts => _s('scanSavingDrafts');
  String get scanAllDuplicate => _s('scanAllDuplicate');
  String get scanGemmaReading => _s('scanGemmaReading');
  String scanQueuedSuccess(int count) =>
      _s('scanQueuedSuccess').replaceAll('{count}', count.toString());
  String uploadingBatch(int count) =>
      _s('uploadingBatch').replaceAll('{count}', count.toString());

  // ── Transaction details ───────────────────────────────────────────────────
  String get receiptImage => _s('receiptImage');
  String get receiptZoomHint => _s('receiptZoomHint');
  String get extractedItems => _s('extractedItems');
  String get noLineItems => _s('noLineItems');
  String get gemmaAdviceTitle => _s('gemmaAdviceTitle');
  String get gemmaGenerate => _s('gemmaGenerate');
  String get gemmaWaiting => _s('gemmaWaiting');
  String get deleteScanTitle => _s('deleteScanTitle');
  String get deleteScanContent => _s('deleteScanContent');
  String get duplicateTitle => _s('duplicateTitle');
  String get duplicateDescription => _s('duplicateDescription');
  String get keepBoth => _s('keepBoth');
  String get deleteDuplicate => _s('deleteDuplicate');
  String get gemmaProcessing => _s('gemmaProcessing');

  // ── Transaction form ──────────────────────────────────────────────────────
  String get formAddTitle => _s('formAddTitle');
  String get formEditTitle => _s('formEditTitle');
  String get formMerchant => _s('formMerchant');
  String get formSourceAccount => _s('formSourceAccount');
  String get formIsTransfer => _s('formIsTransfer');
  String get formDestAccount => _s('formDestAccount');
  String get formCurrency => _s('formCurrency');
  String get formAmount => _s('formAmount');
  String get formAddress => _s('formAddress');
  String get formCategories => _s('formCategories');
  String get formNoCategoriesHint => _s('formNoCategoriesHint');
  String get formLineItems => _s('formLineItems');
  String get formAddItem => _s('formAddItem');
  String get formNoItems => _s('formNoItems');
  String get formDateTime => _s('formDateTime');
  String get formSaveEdits => _s('formSaveEdits');
  String get formSaveTransaction => _s('formSaveTransaction');
  String get formMerchantRequired => _s('formMerchantRequired');
  String get formSourceRequired => _s('formSourceRequired');
  String get formDestRequired => _s('formDestRequired');
  String get formAmountRequired => _s('formAmountRequired');
  String get formAmountInvalid => _s('formAmountInvalid');
  String get formItemNameRequired => _s('formItemNameRequired');
  String get formItemRequired => _s('formItemRequired');
  String get formItemInvalid => _s('formItemInvalid');

  // ── Accounts ──────────────────────────────────────────────────────────────
  String get accountsTitle => _s('accountsTitle');
  String get accountsSubtitle => _s('accountsSubtitle');
  String get accountsEmpty => _s('accountsEmpty');
  String get accountsCreateTitle => _s('accountsCreateTitle');
  String get accountsName => _s('accountsName');
  String get accountsType => _s('accountsType');
  String get accountsInitialBalance => _s('accountsInitialBalance');
  String get accountsCurrency => _s('accountsCurrency');
  String get accountsCreate => _s('accountsCreate');
  String get accountsDeleteTitle => _s('accountsDeleteTitle');
  String accountsDeleteContent(String name) =>
      _s('accountsDeleteContent').replaceAll('{name}', name);

  // ── Profile ───────────────────────────────────────────────────────────────
  String get profileTitle => _s('profileTitle');
  String get profileEditButton => _s('profileEditButton');
  String get profileEditTitle => _s('profileEditTitle');
  String get profileFullName => _s('profileFullName');
  String get profileNameHint => _s('profileNameHint');
  String get profilePrimaryCurrency => _s('profilePrimaryCurrency');
  String profilePrimaryCurrencyLabel(String currency, String symbol) =>
      _s('profilePrimaryCurrencyLabel')
          .replaceAll('{currency}', currency)
          .replaceAll('{symbol}', symbol);
  String get profileSave => _s('profileSave');
  String get profilePreferences => _s('profilePreferences');
  String get profileCategories => _s('profileCategories');
  String get profileCategoriesSubtitle => _s('profileCategoriesSubtitle');
  String get profileStatistics => _s('profileStatistics');
  String get profileStatisticsSubtitle => _s('profileStatisticsSubtitle');
  String get profileExchangeRates => _s('profileExchangeRates');
  String get profileExchangeRatesSubtitle => _s('profileExchangeRatesSubtitle');
  String get profileLanguage => _s('profileLanguage');
  String get profileLanguageSubtitle => _s('profileLanguageSubtitle');
  String get profileAccountOps => _s('profileAccountOps');
  String get profileLogout => _s('profileLogout');
  String get profileLogoutSubtitle => _s('profileLogoutSubtitle');

  // ── Language picker ───────────────────────────────────────────────────────
  String get languageSelect => _s('languageSelect');

  // ── Categories ────────────────────────────────────────────────────────────
  String get categoriesTitle => _s('categoriesTitle');
  String get categoriesSubtitle => _s('categoriesSubtitle');
  String get categoriesNewHint => _s('categoriesNewHint');
  String get categoriesAdd => _s('categoriesAdd');
  String get categoriesEmpty => _s('categoriesEmpty');

  // ── Statistics / Exchange Rates ───────────────────────────────────────────
  String get statsTitle => _s('statsTitle');
  String get exchangeRatesTitle => _s('exchangeRatesTitle');

  // ── Common ────────────────────────────────────────────────────────────────
  String get cancel => _s('cancel');
  String get delete => _s('delete');
  String get edit => _s('edit');
  String get save => _s('save');
  String get close => _s('close');
  String get loading => _s('loading');

  // ── Errors ────────────────────────────────────────────────────────────────
  String get errorNetwork => _s('errorNetwork');
  String get error400 => _s('error400');
  String get error401 => _s('error401');
  String get error403 => _s('error403');
  String get error404 => _s('error404');
  String get error409 => _s('error409');
  String get error413 => _s('error413');
  String get error500 => _s('error500');
  String get errorDefault => _s('errorDefault');

  /// Returns the localized default error message for an HTTP status code.
  String errorForStatus(int statusCode) {
    switch (statusCode) {
      case 400: return error400;
      case 401: return error401;
      case 403: return error403;
      case 404: return error404;
      case 409: return error409;
      case 413: return error413;
      case 500: return error500;
      default:  return errorDefault;
    }
  }

  // ── Success ───────────────────────────────────────────────────────────────
  String get successProfileUpdated => _s('successProfileUpdated');
  String get successTransactionSaved => _s('successTransactionSaved');
  String get successBothKept => _s('successBothKept');
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const _supported = ['en', 'ru', 'uz'];

  @override
  bool isSupported(Locale locale) =>
      _supported.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
