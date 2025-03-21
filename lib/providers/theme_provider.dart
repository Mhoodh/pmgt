import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  // تحميل تفضيل السمة من التخزين المحلي
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      notifyListeners();
    } catch (e) {
      print('خطأ في تحميل تفضيل السمة: $e');
    }
  }

  // تبديل وضع السمة (فاتح/داكن)
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode);
    } catch (e) {
      print('خطأ في حفظ تفضيل السمة: $e');
    }
  }

  // الحصول على سمة التطبيق الحالية
  ThemeData getTheme() {
    if (_isDarkMode) {
      return _getDarkTheme();
    } else {
      return _getLightTheme();
    }
  }

  // سمة الوضع الفاتح
  ThemeData _getLightTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        error: AppColors.errorColor,
        background: Colors.white,
        surface: AppColors.surfaceColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryTextColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconColor,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: AppColors.primaryTextColor),
        titleMedium: TextStyle(color: AppColors.primaryTextColor),
        bodyLarge: TextStyle(color: AppColors.primaryTextColor),
        bodyMedium: TextStyle(color: AppColors.secondaryTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.iconColor,
      ),
    );
  }

  // سمة الوضع الداكن
  ThemeData _getDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        error: AppColors.errorColor,
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white70,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}