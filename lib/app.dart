import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/projects_screen.dart';
import 'screens/project_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_project_screen.dart';
import 'screens/edit_project_screen.dart';
import 'screens/notifications_screen.dart';
import 'providers/auth_provider.dart'; // استخدام المصادقة الحقيقية
import 'utils/constants.dart';
import 'models/project.dart';
import 'providers/language_provider.dart';

class App extends StatelessWidget {
  final ThemeData? themeData;
  
  const App({Key? key, this.themeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // التحقق مما إذا كان المستخدم قد سجل الدخول مسبقًا
      future: Provider.of<AuthProvider>(context, listen: false).initializeUser(),
      builder: (context, snapshot) {
        final appTheme = themeData ?? ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            secondary: AppColors.accentColor,
            error: AppColors.errorColor,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.backgroundColor,
            foregroundColor: AppColors.primaryTextColor,
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 60,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
            iconTheme: IconThemeData(
              color: AppColors.primaryColor,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.inputFillColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.errorColor, width: 1),
            ),
            labelStyle: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              elevation: 2,
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: AppColors.cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          ),
        );
        
        return MaterialApp(
          title: 'إدارة المشاريع',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          
          // اللغة والاتجاه
          locale: Provider.of<LanguageProvider>(context).currentLocale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          // تحديد الشاشة المبدئية بناءً على حالة تسجيل الدخول
          home: snapshot.connectionState == ConnectionState.waiting 
              ? _buildLoadingScreen() 
              : (snapshot.hasData && snapshot.data == true 
                  ? HomeScreen() 
                  : LoginScreen()),
          
          // تعريف مسارات التنقل
          routes: {
            LoginScreen.routeName: (ctx) => LoginScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            ProjectsScreen.routeName: (ctx) => ProjectsScreen(),
            ProjectDetailsScreen.routeName: (ctx) => ProjectDetailsScreen(),
            AddProjectScreen.routeName: (ctx) => AddProjectScreen(),
            NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            EditProjectScreen.routeName: (ctx) => EditProjectScreen(
              project: ModalRoute.of(ctx)!.settings.arguments as Project,
            ),
          },
        );
      },
    );
  }

  // شاشة التحميل أثناء التحقق من حالة تسجيل الدخول
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 24),
            Text(
              'إدارة المشاريع',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}