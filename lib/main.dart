import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/core/notifications/push_notification_service.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/core/navigation/main_navigation.dart';
import 'package:uniguide/features/welcome/province_selection_page.dart';
import 'package:uniguide/features/welcome/welcome_animation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PushNotificationService.instance.initialize();

  runApp(const UniGuideApp());
}

class UniGuideApp extends StatefulWidget {
  const UniGuideApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_UniGuideAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_UniGuideAppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<UniGuideApp> createState() => _UniGuideAppState();
}

class _UniGuideAppState extends State<UniGuideApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    PushNotificationService.instance.initialize();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeCode = prefs.getString(AppConstants.kPrefsThemeModeKey);
    if (!mounted) return;
    setThemeMode(_parseThemeMode(themeCode));
  }

  static ThemeMode _parseThemeMode(String? code) {
    switch (code) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppConstants.primaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.dark,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppConstants.primaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
          ),
        ),
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.35,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLanguage();
  }

  Future<void> _checkLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString(AppConstants.kPrefsLangKey);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (langCode == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeAnimationPage()),
      );
    } else {
      UniGuideApp.setLocale(context, Locale(langCode));
      final province = prefs.getString(AppConstants.kPrefsProvinceKey);
      if (province == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProvinceSelectionPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.backgroundColor,
              AppConstants.secondaryBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.appLogoPath,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: AppConstants.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
