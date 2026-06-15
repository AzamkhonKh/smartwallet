import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Load persisted locale before first frame
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const RecipeWalletApp(),
    ),
  );
}

class RecipeWalletApp extends StatelessWidget {
  const RecipeWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: 'Neo Wallet',
      debugShowCheckedModeBanner: false,

      // ── Localization ────────────────────────────────────────────────────
      locale: locale,
      supportedLocales: appSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale == null) return supportedLocales.first;
        // Exact match first
        for (final supported in supportedLocales) {
          if (supported.languageCode == deviceLocale.languageCode &&
              supported.scriptCode == deviceLocale.scriptCode) {
            return supported;
          }
        }
        // Language-only match
        for (final supported in supportedLocales) {
          if (supported.languageCode == deviceLocale.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },

      // ── Theme ───────────────────────────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF070A13),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00D2FF),
          surface: Color(0xFF101424),
          error: Color(0xFFC70039),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0F1424),
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Colors.white38,
        ),
      ),

      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
        },
      ),

      builder: (context, child) {
        final width = MediaQuery.of(context).size.width;
        if (width > 800) {
          return Container(
            color: const Color(0xFF070A13),
            child: Center(
              child: ClipRect(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: child,
                ),
              ),
            ),
          );
        }
        return child!;
      },
    );
  }
}
