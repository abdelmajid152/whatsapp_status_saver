import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _key = 'isDarkMode';
  final _prefs = Get.find<SharedPreferences>();

  bool get isDarkMode => _prefs.getBool(_key) ?? false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    _prefs.setBool(_key, !isDarkMode);
  }

  Future<ThemeService> init() async {
    return this;
  }
}
