import 'package:flutter/material.dart';

// نصوص التطبيق بعدة لغات
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // القواميس التي تحتوي على النصوص بمختلف اللغات
  static Map<String, Map<String, String>> _localizedValues = {
    // نصوص عامة
    'app_name': {
      'ar': 'إدارة المشاريع',
      'en': 'Project Manager',
    },
    
    // شاشة تسجيل الدخول
    'login_title': {
      'ar': 'تسجيل الدخول',
      'en': 'Login',
    },
    'email': {
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
    },
    'password': {
      'ar': 'كلمة المرور',
      'en': 'Password',
    },
    'login_button': {
      'ar': 'تسجيل الدخول',
      'en': 'Login',
    },
    'forgot_password': {
      'ar': 'نسيت كلمة المرور؟',
      'en': 'Forgot Password?',
    },
    'no_account': {
      'ar': 'ليس لديك حساب؟',
      'en': 'Don\'t have an account?',
    },
    'create_account': {
      'ar': 'إنشاء حساب',
      'en': 'Create Account',
    },
    
    // شاشة الرئيسية
    'home': {
      'ar': 'الرئيسية',
      'en': 'Home',
    },
    'projects': {
      'ar': 'المشاريع',
      'en': 'Projects',
    },
    'notifications': {
      'ar': 'الإشعارات',
      'en': 'Notifications',
    },
    'settings': {
      'ar': 'الإعدادات',
      'en': 'Settings',
    },
    'active_projects': {
      'ar': 'المشاريع النشطة',
      'en': 'Active Projects',
    },
    'in_progress': {
      'ar': 'قيد التنفيذ',
      'en': 'In Progress',
    },
    'completed': {
      'ar': 'مكتملة',
      'en': 'Completed',
    },
    'delayed': {
      'ar': 'متأخرة',
      'en': 'Delayed',
    },
    
    // حالات المشروع
    'status_not_started': {
      'ar': 'لم يبدأ',
      'en': 'Not Started',
    },
    'status_in_progress': {
      'ar': 'قيد التنفيذ',
      'en': 'In Progress',
    },
    'status_completed': {
      'ar': 'مكتمل',
      'en': 'Completed',
    },
    'status_delayed': {
      'ar': 'متأخر',
      'en': 'Delayed',
    },
    'status_cancelled': {
      'ar': 'ملغي',
      'en': 'Cancelled',
    },
    
    // شاشة الإعدادات
    'display_settings': {
      'ar': 'إعدادات العرض',
      'en': 'Display Settings',
    },
    'dark_mode': {
      'ar': 'الوضع الليلي',
      'en': 'Dark Mode',
    },
    'language': {
      'ar': 'اللغة',
      'en': 'Language',
    },
    'choose_language': {
      'ar': 'اختر لغة التطبيق',
      'en': 'Choose App Language',
    },
    'data_settings': {
      'ar': 'إعدادات البيانات',
      'en': 'Data Settings',
    },
    'reset_data': {
      'ar': 'إعادة ضبط البيانات',
      'en': 'Reset Data',
    },
    'backup': {
      'ar': 'نسخ احتياطي',
      'en': 'Backup',
    },
    'restore': {
      'ar': 'استعادة البيانات',
      'en': 'Restore Data',
    },
    'about_app': {
      'ar': 'عن التطبيق',
      'en': 'About App',
    },
    'logout': {
      'ar': 'تسجيل الخروج',
      'en': 'Logout',
    },
    
    // رسائل
    'success': {
      'ar': 'تم بنجاح',
      'en': 'Success',
    },
    'error': {
      'ar': 'خطأ',
      'en': 'Error',
    },
    'confirm': {
      'ar': 'تأكيد',
      'en': 'Confirm',
    },
    'cancel': {
      'ar': 'إلغاء',
      'en': 'Cancel',
    },
  };

  // الحصول على النص المترجم
  String translate(String key) {
    // التحقق من وجود ترجمة للمفتاح واللغة المطلوبة
    if (_localizedValues.containsKey(key)) {
      final translations = _localizedValues[key]!;
      
      // محاولة الحصول على الترجمة باللغة المطلوبة
      if (translations.containsKey(locale.languageCode)) {
        return translations[locale.languageCode]!;
      }
      
      // إذا لم توجد ترجمة باللغة المطلوبة، استخدم اللغة العربية كلغة افتراضية
      if (translations.containsKey('ar')) {
        return translations['ar']!;
      }
    }
    
    // إذا لم يوجد ترجمة، أعد المفتاح نفسه
    return key;
  }

  // للحصول على كائن الترجمة من السياق
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }
}