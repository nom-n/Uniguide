import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/core/localization/ui_texts.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/main.dart';

import 'province_selection_page.dart';
import 'welcome_animation_page.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String? _selectedLanguage;
  bool _showLanguageBox = false;

  final List<Map<String, String>> languages = const [
    {'code': 'tr', 'flag': '🇹🇷'},
    {'code': 'en', 'flag': '🇺🇸'},
    {'code': 'ar', 'flag': '🇸🇦'},
    {'code': 'fr', 'flag': '🇫🇷'},
    {'code': 'id', 'flag': '🇮🇩'},
    {'code': 'ur', 'flag': '🇵🇰'},
    {'code': 'so', 'flag': '🇸🇴'},
    {'code': 'kk', 'flag': '🇰🇿'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showLanguageBox = true);
        _controller.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreLocaleFromPrefs();
    });
  }

  Future<void> _restoreLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final code = prefs.getString(AppConstants.kPrefsLangKey);
    if (code == null) return;
    UniGuideApp.setLocale(context, Locale(code));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    if (mounted) {
      UniGuideApp.setLocale(context, Locale(code));
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kPrefsLangKey, code);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProvinceSelectionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMobile = screenSize.width < 400;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getPaddingValue(isMobile, isSmallScreen),
              vertical: _getVerticalPadding(isMobile, isSmallScreen),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildBackButton(isMobile, isSmallScreen),
                ),
                SizedBox(height: _getSpacing(isMobile, isSmallScreen, isTablet)),
                Image.asset(
                  'assets/images/app_logo.png',
                  width: isMobile ? 90 : 110,
                  height: isMobile ? 90 : 110,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 14),
                _buildTitle(loc, isMobile, isSmallScreen),
                SizedBox(height: _getSpacing(isMobile, isSmallScreen, isTablet)),
                if (_showLanguageBox)
                  _buildLanguagesList(isMobile, isSmallScreen, isTablet)
                else
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getPaddingValue(bool isMobile, bool isSmallScreen) =>
      isMobile ? 12.0 : (isSmallScreen ? 16.0 : 24.0);

  double _getVerticalPadding(bool isMobile, bool isSmallScreen) =>
      isMobile ? 8.0 : (isSmallScreen ? 12.0 : 16.0);

  double _getSpacing(bool isMobile, bool isSmallScreen, bool isTablet) =>
      isMobile ? 16.0 : (isSmallScreen ? 20.0 : 32.0);

  double _getIconSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 18 : (isSmallScreen ? 20 : 24);

  double _getTitleSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 16 : (isSmallScreen ? 18 : 22);

  double _getTileVerticalPadding(bool isMobile, bool isSmallScreen) =>
      isMobile ? 10 : (isSmallScreen ? 12 : 16);

  double _getTileHorizontalPadding(bool isMobile, bool isSmallScreen) =>
      isMobile ? 10 : (isSmallScreen ? 12 : 16);

  double _getFlagSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 22 : (isSmallScreen ? 24 : 28);

  double _getTileFontSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 13 : (isSmallScreen ? 14 : 16);

  double _getCheckboxSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 18 : (isSmallScreen ? 20 : 24);

  double _getCheckIconSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 12 : (isSmallScreen ? 14 : 16);

  Widget _buildBackButton(bool isMobile, bool isSmallScreen) {
    final lang = AppLocalizations.of(context)!;
    return Tooltip(
      message: lang.back,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const WelcomeAnimationPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFF007AFF),
                size: _getIconSize(isMobile, isSmallScreen),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(
    AppLocalizations loc,
    bool isMobile,
    bool isSmallScreen,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      ),
      child: Text(
        loc.chooseLanguage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: _getTitleSize(isMobile, isSmallScreen),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLanguagesList(
    bool isMobile,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: languages.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final language = languages[index];
          final code = language['code']!;
          final flag = language['flag']!;
          final name = UiTexts.languageName(context, code);
          final isSelected = _selectedLanguage == code;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: _getTileVerticalPadding(isMobile, isSmallScreen),
            ),
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, isTablet ? 0.2 : 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      index / languages.length,
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _selectLanguage(code),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getTileHorizontalPadding(
                            isMobile,
                            isSmallScreen,
                          ),
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: _getFlagSize(isMobile, isSmallScreen),
                              height: _getFlagSize(isMobile, isSmallScreen),
                              alignment: Alignment.center,
                              child: Text(
                                flag,
                                style: TextStyle(
                                  fontSize:
                                      _getFlagSize(isMobile, isSmallScreen),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: _getTileFontSize(
                                    isMobile,
                                    isSmallScreen,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: _getCheckboxSize(isMobile, isSmallScreen),
                              height: _getCheckboxSize(isMobile, isSmallScreen),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF007AFF)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF007AFF)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: _getCheckIconSize(
                                        isMobile,
                                        isSmallScreen,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
