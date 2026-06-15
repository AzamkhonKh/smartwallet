import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app locales.
const List<Locale> appSupportedLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('uz'),
  Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
];

/// Display metadata for each supported locale.
class LocaleOption {
  final Locale locale;
  final String flag;
  final String nativeName;
  final String scriptLabel; // shown below native name in picker

  const LocaleOption({
    required this.locale,
    required this.flag,
    required this.nativeName,
    required this.scriptLabel,
  });
}

const List<LocaleOption> localeOptions = [
  LocaleOption(
    locale: Locale('en'),
    flag: '🇬🇧',
    nativeName: 'English',
    scriptLabel: 'Latin',
  ),
  LocaleOption(
    locale: Locale('ru'),
    flag: '🇷🇺',
    nativeName: 'Русский',
    scriptLabel: 'Кириллица',
  ),
  LocaleOption(
    locale: Locale('uz'),
    flag: '🇺🇿',
    nativeName: "O'zbek",
    scriptLabel: 'Latin',
  ),
  LocaleOption(
    locale: Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    flag: '🇺🇿',
    nativeName: 'Ўзбек',
    scriptLabel: 'Кирилл',
  ),
];

const _kLocaleKey = 'app_locale';

/// Persists and provides the active [Locale] to the whole widget tree.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Call once at startup to restore persisted locale.
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(_kLocaleKey);
    if (tag != null) {
      _locale = _tagToLocale(tag);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, _localeToTag(locale));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _localeToTag(Locale l) =>
      l.scriptCode != null ? '${l.languageCode}_${l.scriptCode}' : l.languageCode;

  static Locale _tagToLocale(String tag) {
    final parts = tag.split('_');
    if (parts.length >= 2 && parts[1].length > 2) {
      // e.g. uz_Cyrl
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(parts[0]);
  }
}
