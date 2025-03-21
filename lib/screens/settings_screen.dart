import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart'; // تغيير إلى المزود الحقيقي
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/projects_provider.dart'; // تغيير إلى المزود الحقيقي
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _currentLanguage = 'العربية';
  final List<String> _availableLanguages = ['العربية', 'English'];
  
  @override
  void initState() {
    super.initState();
    
    // تحديث حالة الوضع الليلي من المزود
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _isDarkMode = themeProvider.isDarkMode;
      });
      
      // تحديث حالة اللغة من المزود
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _currentLanguage = languageProvider.isArabic ? 'العربية' : 'English';
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إعدادات العرض
            _buildSectionTitle('إعدادات العرض', Icons.palette_outlined),
            const SizedBox(height: 8),
            _buildDarkModeSwitch(),
            const Divider(),
            
            // إعدادات اللغة
            _buildSectionTitle('اللغة', Icons.language),
            const SizedBox(height: 8),
            _buildLanguageSelector(),
            const Divider(),
            
            // إعدادات البيانات
            _buildSectionTitle('البيانات', Icons.storage_outlined),
            const SizedBox(height: 8),
            _buildDataSettings(),
            const Divider(),
            
            // عن التطبيق
            _buildSectionTitle('عن التطبيق', Icons.info_outline),
            const SizedBox(height: 8),
            _buildAboutApp(),
            const Divider(),
            
            // تسجيل الخروج
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDarkModeSwitch() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Consumer<ThemeProvider>(
          builder: (ctx, themeProvider, _) => SwitchListTile(
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل المظهر الداكن للتطبيق'),
            value: themeProvider.isDarkMode,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              themeProvider.toggleTheme();
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildLanguageSelector() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اختر لغة التطبيق',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Consumer<LanguageProvider>(
              builder: (ctx, languageProvider, _) => DropdownButtonFormField<String>(
                value: _currentLanguage,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: _availableLanguages.map((language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentLanguage = value;
                    });
                    
                    // تغيير اللغة
                    final languageCode = value == 'العربية' ? 'ar' : 'en';
                    languageProvider.setLocale(languageCode);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم تغيير اللغة إلى $_currentLanguage'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.restore, color: AppColors.iconColor),
            title: const Text('إعادة ضبط البيانات'),
            subtitle: const Text('حذف جميع المشاريع وإعادة تعيين الإعدادات'),
            onTap: _confirmReset,
          ),
          const Divider(height: 1),
          Consumer<BackupProvider>(
            builder: (ctx, backupProvider, _) => ListTile(
              leading: Icon(Icons.cloud_download_outlined, color: AppColors.iconColor),
              title: const Text('نسخ احتياطي'),
              subtitle: Text(
                backupProvider.lastBackupDate != null 
                  ? 'آخر نسخ: ${_formatDateTime(backupProvider.lastBackupDate!)}'
                  : 'حفظ نسخة من بياناتك الحالية'
              ),
              trailing: backupProvider.isLoading 
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                : null,
              onTap: () => _createBackup(backupProvider),
            ),
          ),
          const Divider(height: 1),
          Consumer<BackupProvider>(
            builder: (ctx, backupProvider, _) => ListTile(
              leading: Icon(Icons.cloud_upload_outlined, color: AppColors.iconColor),
              title: const Text('استعادة البيانات'),
              subtitle: const Text('استعادة بياناتك من نسخة احتياطية'),
              trailing: backupProvider.isLoading 
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                : null,
              onTap: () => _showRestoreDialog(backupProvider),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final dateFormatter = DateFormat.yMd().add_jm();
      return dateFormatter.format(dateTime);
    } catch (e) {
      return 'غير معروف';
    }
  }
  
  Widget _buildAboutApp() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.iconColor),
            title: const Text('عن التطبيق'),
            subtitle: const Text('معلومات حول التطبيق والإصدار'),
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.star_outline, color: AppColors.iconColor),
            title: const Text('تقييم التطبيق'),
            subtitle: const Text('شارك رأيك وقيّم التطبيق'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سيتم دعم تقييم التطبيق في تحديث قادم'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.bug_report_outlined, color: AppColors.iconColor),
            title: const Text('الإبلاغ عن مشكلة'),
            subtitle: const Text('المساعدة في تحسين التطبيق'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سيتم دعم الإبلاغ عن المشاكل في تحديث قادم'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: Icon(Icons.logout),
        label: Text('تسجيل الخروج'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إعادة ضبط البيانات'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف جميع المشاريع وإعادة تعيين الإعدادات؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              
              // إعادة ضبط بيانات المشاريع
              final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
              projectsProvider.resetProjects().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تمت إعادة ضبط البيانات'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }
  
  // إنشاء نسخة احتياطية
  void _createBackup(BackupProvider backupProvider) async {
    final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
    
    final backupPath = await backupProvider.createBackup(projectsProvider);
    
    if (backupPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء نسخة احتياطية بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إنشاء النسخة الاحتياطية'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // عرض مربع حوار استعادة النسخ الاحتياطية
  void _showRestoreDialog(BackupProvider backupProvider) async {
    // الحصول على قائمة ملفات النسخ الاحتياطية
    final backupFiles = await backupProvider.getBackupFiles();
    
    if (backupFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد نسخ احتياطية متاحة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('استعادة البيانات'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: backupFiles.length,
            itemBuilder: (context, index) {
              final file = backupFiles[index];
              final fileName = file.path.split('/').last;
              
              // استخراج التاريخ من اسم الملف
              final regex = RegExp(r'backup_(\d+)\.json');
              final match = regex.firstMatch(fileName);
              
              String formattedDate = 'غير معروف';
              if (match != null && match.groupCount >= 1) {
                final timestamp = int.tryParse(match.group(1)!);
                if (timestamp != null) {
                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                  formattedDate = DateFormat.yMd().add_jm().format(date);
                }
              }
              
              return ListTile(
                title: Text('نسخة احتياطية'),
                subtitle: Text(formattedDate),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteBackup(file.path, backupProvider);
                  },
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmRestoreBackup(file.path, backupProvider);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }
  
  // تأكيد استعادة النسخة الاحتياطية
  void _confirmRestoreBackup(String path, BackupProvider backupProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('استعادة النسخة الاحتياطية'),
        content: Text(
          'هل أنت متأكد من رغبتك في استعادة هذه النسخة الاحتياطية؟ سيتم استبدال جميع البيانات الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
              final success = await backupProvider.restoreBackup(path, projectsProvider);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                    ? 'تمت استعادة النسخة الاحتياطية بنجاح' 
                    : 'فشل استعادة النسخة الاحتياطية'
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text('استعادة'),
          ),
        ],
      ),
    );
  }
  
  // تأكيد حذف النسخة الاحتياطية
  void _confirmDeleteBackup(String path, BackupProvider backupProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف النسخة الاحتياطية'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف هذه النسخة الاحتياطية؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              final success = await backupProvider.deleteBackup(path);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                    ? 'تم حذف النسخة الاحتياطية بنجاح' 
                    : 'فشل حذف النسخة الاحتياطية'
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
  
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تسجيل الخروج'),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              
              // تسجيل الخروج باستخدام مزود المصادقة
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout().then((_) {
                // العودة إلى شاشة تسجيل الدخول
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (route) => false,
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AboutDialog(
        applicationName: 'تطبيق إدارة المشاريع',
        applicationVersion: 'الإصدار 1.0.0',
        applicationIcon: Icon(
          Icons.task_alt,
          size: 48,
          color: AppColors.primaryColor,
        ),
        applicationLegalese: '© 2025 جميع الحقوق محفوظة',
        children: [
          const SizedBox(height: 16),
          Text(
            'تطبيق إدارة المشاريع يساعدك على تنظيم وتتبع مشاريعك بطريقة سهلة وفعالة.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'تم تطويره باستخدام Flutter وSQLite.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}