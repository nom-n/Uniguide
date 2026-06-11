import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:uniguide/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _langCode = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  final Map<String, String> _languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'id': 'Bahasa Indonesia',
    'ur': 'اردو',
    'so': 'Soomaali',
    'kk': 'Қазақша',
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.kPrefsLangKey);
    final tcode = prefs.getString(AppConstants.kPrefsThemeModeKey);
    setState(() {
      _langCode = code ?? _langCode;
      _themeMode = tcode == 'light'
          ? ThemeMode.light
          : tcode == 'dark'
          ? ThemeMode.dark
          : ThemeMode.system;
    });
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.kPrefsLangKey, code);
    if (!mounted) return;
    setState(() => _langCode = code);
    UniGuideApp.setLocale(context, Locale(code));
  }

  Future<void> _setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final code = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await prefs.setString(AppConstants.kPrefsThemeModeKey, code);
    if (!mounted) return;
    setState(() => _themeMode = mode);
    UniGuideApp.setThemeMode(context, mode);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.themeModeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(loc.chooseLanguage),
              subtitle: Text(_languageNames[_langCode] ?? _langCode),
              trailing: DropdownButton<String>(
                value: _langCode,
                onChanged: (v) {
                  if (v != null) _setLanguage(v);
                },
                items: _languageNames.keys.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(_languageNames[code]!),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(loc.themeModeTitle),
              subtitle: Text(
                _themeMode == ThemeMode.system
                    ? loc.themeModeSystem
                    : _themeMode == ThemeMode.light
                    ? loc.themeModeLight
                    : loc.themeModeDark,
              ),
              trailing: DropdownButton<ThemeMode>(
                value: _themeMode,
                onChanged: (v) {
                  if (v != null) _setTheme(v);
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(loc.themeModeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(loc.themeModeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(loc.themeModeDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
