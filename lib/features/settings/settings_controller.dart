import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/prefs.dart';

class AppSettings {
  const AppSettings({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  @override
  AppSettings build() {
    final prefs = ref.watch(prefsProvider);
    return AppSettings(
      themeMode: ThemeMode.values[prefs.getInt(_themeKey) ?? 0],
      locale: Locale(prefs.getString(_localeKey) ?? 'ar'),
    );
  }

  void setThemeMode(ThemeMode mode) {
    ref.read(prefsProvider).setInt(_themeKey, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale locale) {
    ref.read(prefsProvider).setString(_localeKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }
}
