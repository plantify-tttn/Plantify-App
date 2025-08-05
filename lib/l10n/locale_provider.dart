import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleProvider extends ChangeNotifier {
  final Box _box = Hive.box('settings');
  late Locale _locale;

  LocaleProvider() {
    String code = _box.get('localeCode', defaultValue: 'vi');
    _locale = Locale(code);
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'vi'].contains(locale.languageCode)) return;
    _locale = locale;
    _box.put('localeCode', locale.languageCode); // 👈 Lưu vào Hive
    notifyListeners();
  }
}
