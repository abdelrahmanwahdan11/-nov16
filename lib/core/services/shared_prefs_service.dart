import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  ThemeMode? get themeMode {
    final value = _prefs?.getString('theme_mode');
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs?.setString(
      'theme_mode',
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
              ? 'light'
              : 'system',
    );
  }

  Color? get primaryColor {
    final value = _prefs?.getInt('primary_color');
    return value != null ? Color(value) : null;
  }

  Future<void> savePrimaryColor(Color color) async {
    await _prefs?.setInt('primary_color', color.value);
  }

  Locale? get locale {
    final code = _prefs?.getString('locale_code');
    if (code == null) return null;
    return Locale(code);
  }

  Future<void> saveLocale(Locale locale) async {
    await _prefs?.setString('locale_code', locale.languageCode);
  }
}
