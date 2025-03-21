import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('ar');
  bool get isArabic => _currentLocale.languageCode == 'ar';
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadLanguagePreference();
  }

  // تحميل تفضيل اللغة من التخزين المحلي
  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'ar';
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('خطأ في تحميل تفضيل اللغة: $e');
    }
  }

  // تغيير اللغة
  Future<void> setLocale(String languageCode) async {
    _currentLocale = Locale(languageCode);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      print('خطأ في حفظ تفضيل اللغة: $e');
    }
  }

  // الحصول على نص حسب اللغة الحالية
  String getLocalizedText(Map<String, String> texts) {
    return texts[_currentLocale.languageCode] ?? texts['ar'] ?? '';
  }
}