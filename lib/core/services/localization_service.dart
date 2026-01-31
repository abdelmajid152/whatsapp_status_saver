import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends GetxService {
  static LocalizationService get to => Get.find();

  final _key = 'language';
  final _prefs = Get.find<SharedPreferences>();

  Locale get locale {
    final langCode = _prefs.getString(_key);
    if (langCode == null) {
      return const Locale('ar', 'SA'); // Default to Arabic
    }
    return Locale(langCode);
  }

  void switchLanguage(String langCode) {
    final locale = Locale(langCode);
    Get.updateLocale(locale);
    _prefs.setString(_key, langCode);
  }

  Future<LocalizationService> init() async {
    return this;
  }
}
