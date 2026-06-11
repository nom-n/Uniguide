import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/constants/app_constants.dart';
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
  late AnimationController _controller;
  String? _selectedLanguage;
  bool _showLanguageBox = false;

  final List<Map<String, String>> languages = [
    {'name': 'Türkçe', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'Français', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Bahasa Indonesia', 'code': 'id', 'flag': '🇮🇩'},
    {'name': 'اردو', 'code': 'ur', 'flag': '🇵🇰'},
    {'name': 'Soomaali', 'code': 'so', 'flag': '🇸🇴'},
    {'name': 'Қазақша', 'code': 'kk', 'flag': '🇰🇿'},
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
                _buildTitle(isMobile, isSmallScreen),
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

  Widget _buildTitle(bool isMobile, bool isSmallScreen) {
    final lang = AppLocalizations.of(context)!;
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
        lang.chooseLanguage,
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
      bool isMobile, bool isSmallScreen, bool isTablet) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 8 : 12,
            horizontal: isMobile ? 8 : 12,
          ),
          child: Column(
            children: List.generate(
              languages.length,
              (index) {
                final lang = languages[index];
                return _buildLanguageTile(
                  lang['name']!,
                  lang['code']!,
                  lang['flag']!,
                  isMobile,
                  isSmallScreen,
                  isTablet,
                  index == languages.length - 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    String title,
    String code,
    String flag,
    bool isMobile,
    bool isSmallScreen,
    bool isTablet,
    bool isLast,
  ) {
    final isSelected = _selectedLanguage == code;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectLanguage(code),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: _getTileVerticalPadding(isMobile, isSmallScreen),
                horizontal: _getTileHorizontalPadding(isMobile, isSmallScreen),
              ),
              child: Row(
                children: [
                  Text(
                    flag,
                    style: TextStyle(
                      fontSize: _getFlagSize(isMobile, isSmallScreen),
                    ),
                  ),
                  SizedBox(
                      width: _getTileHorizontalPadding(isMobile, isSmallScreen)),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: _getTileFontSize(isMobile, isSmallScreen),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  _buildSelectionIndicator(isSelected, isMobile, isSmallScreen),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getTileHorizontalPadding(isMobile, isSmallScreen),
            ),
            child: Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectionIndicator(
    bool isSelected,
    bool isMobile,
    bool isSmallScreen,
  ) {
    final size = _getCheckboxSize(isMobile, isSmallScreen);
    final checkSize = _getCheckIconSize(isMobile, isSmallScreen);

    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF007AFF),
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: checkSize,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
      );
    }
  }
}
