import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniguide/core/constants/app_constants.dart';
import 'package:uniguide/core/localization/ui_texts.dart';
import 'package:uniguide/features/admin/admin_console_page.dart';
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

  static const List<String> _supportedLanguages = [
    'tr',
    'en',
    'ar',
    'fr',
    'id',
    'ur',
    'so',
    'kk',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.kPrefsLangKey);
    final tcode = prefs.getString(AppConstants.kPrefsThemeModeKey);
    if (!mounted) return;
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
              subtitle: Text(UiTexts.languageName(context, _langCode)),
              trailing: DropdownButton<String>(
                value: _langCode,
                onChanged: (value) {
                  if (value != null) _setLanguage(value);
                },
                items: _supportedLanguages.map((code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(UiTexts.languageName(context, code)),
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
                onChanged: (value) {
                  if (value != null) _setTheme(value);
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
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(_text(context, en: 'Admin console', ar: 'لوحة الإدارة')),
              subtitle: Text(
                _text(
                  context,
                  en: 'Manage guides, tasks, places, and notification campaigns.',
                  ar: 'إدارة الأدلة والمهام والأماكن وحملات الإشعارات.',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminConsolePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _text(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}
