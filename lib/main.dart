import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/projects_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/backup_provider.dart';
import 'database/db_helper.dart';

void main() async {
  // ضروري لاستخدام القنوات الأصلية
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة قاعدة البيانات للعمل على مختلف المنصات
  if (kIsWeb) {
    print('تشغيل في بيئة الويب - SQLite قد لا تكون مدعومة بالكامل');
  } else if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('تم تهيئة قاعدة البيانات للعمل على سطح المكتب');
  } else {
    print('تشغيل على جهاز محمول - قاعدة البيانات جاهزة');
  }
  
  // تأكيد: تهيئة DbHelper
  DbHelper.initDatabaseFactory();
  
  // تهيئة قاعدة البيانات مبكراً
  try {
    final dbHelper = DbHelper();
    await dbHelper.database; // هذه العملية ستؤدي إلى فتح/إنشاء قاعدة البيانات
    print('تم تهيئة قاعدة البيانات بنجاح');
  } catch (e) {
    print('خطأ أثناء تهيئة قاعدة البيانات: $e');
  }
  
  
  // تعيين توجيه التطبيق من اليمين لليسار (للغة العربية)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // مزود المصادقة
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // مزود المشاريع مع ربطه بمزود المصادقة
        ChangeNotifierProxyProvider<AuthProvider, ProjectsProvider>(
          create: (_) => ProjectsProvider(),
          update: (ctx, auth, previousProjects) {
            final projects = previousProjects ?? ProjectsProvider();
            if (auth.isLoggedIn && auth.currentUser != null) {
              print("تعيين معرف المستخدم في main.dart: ${auth.currentUser!.id}");
              projects.setCurrentUserId(auth.currentUser!.id!);
            } else {
              print("لا يوجد مستخدم حالي في main.dart");
              // استخدام معرف افتراضي 1 للتجريب
              if (auth.currentUser == null && kIsWeb) {
                print("استخدام معرف افتراضي (1) في بيئة الويب");
                projects.setCurrentUserId(1);
              }
            }
            return projects;
          },
        ),
        
        // مزودات أخرى
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => BackupProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, _) => App(themeData: themeProvider.getTheme()),
      ),
    );
  }
}