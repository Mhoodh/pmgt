import 'package:flutter/material.dart';

class AppColors {
  // ألوان رئيسية
  static final Color primaryColor = Color(0xFF536DFE); // أزرق مميز
  static final Color accentColor = Color(0xFF03DAC6); // فيروزي
  static final Color errorColor = Color(0xFFB00020); // أحمر
  static final Color successColor = Color(0xFF4CAF50); // أخضر

  // ألوان الخلفية
  static final Color backgroundColor = Colors.white;
  static final Color surfaceColor = Color(0xFFF5F5F5);
  static final Color cardColor = Colors.white;
  static final Color inputFillColor = Color(0xFFF5F7FA);
  
  // ألوان النصوص
  static final Color primaryTextColor = Color(0xFF1D1D1D);
  static final Color secondaryTextColor = Color(0xFF757575);
  static final Color disabledTextColor = Color(0xFFBDBDBD);
  
  // ألوان أخرى
  static final Color dividerColor = Color(0xFFE0E0E0);
  static final Color borderColor = Color(0xFFE0E0E0);
  static final Color iconColor = Color(0xFF757575);
  static final Color shadowColor = Color(0x1A000000);
  
  // ألوان حالة المشاريع
  static final Color statusNotStarted = Color(0xFFE0E0E0); // رمادي
  static final Color statusInProgress = Color(0xFF42A5F5); // أزرق
  static final Color statusCompleted = Color(0xFF66BB6A); // أخضر
  static final Color statusDelayed = Color(0xFFFFB74D); // برتقالي
  static final Color statusCancelled = Color(0xFFEF5350); // أحمر
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  
  static const double buttonHeight = 54.0;
  static const double inputHeight = 56.0;
}

// مدة الأنيميشن المستخدمة في التطبيق
class AppAnimations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

// رسائل خطأ شائعة
class AppMessages {
  static const String required = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جدًا';
  static const String serverError = 'حدث خطأ في الخادم، يرجى المحاولة لاحقًا';
  static const String connectionError = 'تحقق من اتصالك بالإنترنت';
}