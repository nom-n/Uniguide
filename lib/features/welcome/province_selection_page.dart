import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/main.dart';
import 'intro_video_page.dart';
import 'language_selection_page.dart';

/// ترتيب ثابت لمعرّفات الولايات التركية المدعومة.
const List<String> kProvinceIds = <String>[
  'kutahya',
  'istanbul',
  'ankara',
  'izmir',
  'eskisehir',
  'bursa',
  'konya',
  'antalya',
  'trabzon',
  'gaziantep',
];

class ProvinceSelectionPage extends StatefulWidget {
  const ProvinceSelectionPage({super.key});

  @override
  State<ProvinceSelectionPage> createState() => _ProvinceSelectionPageState();
}

class _ProvinceSelectionPageState extends State<ProvinceSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _selected;
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _showList = true);
        _controller.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocaleFromPrefs();
    });
  }

  Future<void> _syncLocaleFromPrefs() async {
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

  String _provinceName(AppLocalizations l, String id) {
    switch (id) {
      case 'kutahya':
        return l.provinceKutahya;
      case 'istanbul':
        return l.provinceIstanbul;
      case 'ankara':
        return l.provinceAnkara;
      case 'izmir':
        return l.provinceIzmir;
      case 'eskisehir':
        return l.provinceEskisehir;
      case 'bursa':
        return l.provinceBursa;
      case 'konya':
        return l.provinceKonya;
      case 'antalya':
        return l.provinceAntalya;
      case 'trabzon':
        return l.provinceTrabzon;
      case 'gaziantep':
        return l.provinceGaziantep;
      default:
        return id;
    }
  }

  Future<void> _selectProvince(String id) async {
    setState(() => _selected = id);

    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kPrefsProvinceKey, id);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const IntroVideoPage(),
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
    final lang = AppLocalizations.of(context)!;

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
                  child: _buildBackButton(isMobile, isSmallScreen, lang),
                ),
                SizedBox(height: _getSpacing(isMobile, isSmallScreen, isTablet)),
                _buildTitle(isMobile, isSmallScreen, lang),
                SizedBox(height: _getSpacing(isMobile, isSmallScreen, isTablet)),
                if (_showList)
                  _buildList(isMobile, isSmallScreen, isTablet, lang)
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

  double _getTileFontSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 13 : (isSmallScreen ? 14 : 16);

  double _getCheckboxSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 18 : (isSmallScreen ? 20 : 24);

  double _getCheckIconSize(bool isMobile, bool isSmallScreen) =>
      isMobile ? 12 : (isSmallScreen ? 14 : 16);

  Widget _buildBackButton(
    bool isMobile,
    bool isSmallScreen,
    AppLocalizations l,
  ) {
    return Tooltip(
      message: l.back,
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
                      const LanguageSelectionPage(),
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
    bool isMobile,
    bool isSmallScreen,
    AppLocalizations l,
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
        l.selectProvince,
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

  Widget _buildList(
    bool isMobile,
    bool isSmallScreen,
    bool isTablet,
    AppLocalizations l,
  ) {
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
              kProvinceIds.length,
              (index) {
                final id = kProvinceIds[index];
                return _buildTile(
                  _provinceName(l, id),
                  id,
                  isMobile,
                  isSmallScreen,
                  index == kProvinceIds.length - 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    String title,
    String code,
    bool isMobile,
    bool isSmallScreen,
    bool isLast,
  ) {
    final isSelected = _selected == code;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectProvince(code),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: _getTileVerticalPadding(isMobile, isSmallScreen),
                horizontal: _getTileHorizontalPadding(isMobile, isSmallScreen),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF007AFF),
                    size: isMobile ? 22 : 24,
                  ),
                  SizedBox(
                    width: _getTileHorizontalPadding(isMobile, isSmallScreen),
                  ),
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
