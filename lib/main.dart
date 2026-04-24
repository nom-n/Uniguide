import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/core/navigation/main_navigation.dart';
import 'package:uniguide/features/welcome/province_selection_page.dart';
import 'package:uniguide/features/welcome/welcome_animation_page.dart';

void main() {
  runApp(const UniGuideApp());
}

class UniGuideApp extends StatefulWidget {
  const UniGuideApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_UniGuideAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<UniGuideApp> createState() => _UniGuideAppState();
}

class _UniGuideAppState extends State<UniGuideApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('tr'),
        Locale('fr'),
        Locale('id'),
        Locale('ur'),
        Locale('so'),
        Locale('kk'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
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
    String? langCode = prefs.getString('lang');

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (langCode == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeAnimationPage()),
      );
    } else {
      UniGuideApp.setLocale(context, Locale(langCode));
      final province = prefs.getString(kPrefsProvinceKey);
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
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
