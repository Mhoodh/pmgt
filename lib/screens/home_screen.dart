import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../screens/add_project_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/project_details_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/projects_provider.dart';
import '../models/project.dart';
import '../providers/theme_provider.dart'; 

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // قائمة بالشاشات التي سيتم عرضها في شريط التنقل السفلي
  final List<Widget> _screens = [
    const _DashboardTab(),
    const ProjectsScreen(), // استخدام شاشة المشاريع الكاملة
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // للتأكد من أن الزر العائم يظهر عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // تحديث الواجهة مرة واحدة بعد بناءها بالكامل
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على حالة الوضع الليلي
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // تأكيد أن الزر يظهر في الشاشة الرئيسية والمشاريع والإشعارات (الشاشات 0 و 1 و 2)
    final showFAB = _selectedIndex != 3;

    return Scaffold(
      body: _screens[_selectedIndex],
      
      // شريط التنقل العصري المحسن مع دعم الوضع الليلي
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDarkMode
                ? AppColors.primaryColor.withOpacity(0.15)
                : AppColors.primaryColor.withOpacity(0.08),
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: isDarkMode 
                ? Colors.grey.shade400
                : Colors.grey.shade600,
              showUnselectedLabels: true,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
              elevation: 0,
              items: [
                _buildBottomNavigationBarItem(
                  isDarkMode: isDarkMode,
                  label: 'الرئيسية',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                ),
                _buildBottomNavigationBarItem(
                  isDarkMode: isDarkMode,
                  label: 'المشاريع',
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                ),
                _buildBottomNavigationBarItem(
                  isDarkMode: isDarkMode,
                  label: 'الإشعارات',
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                ),
                _buildBottomNavigationBarItem(
                  isDarkMode: isDarkMode,
                  label: 'الإعدادات',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
   
      // زر الإضافة المعائم المحسن مع إظهاره فقط في غير شاشة الإعدادات
      floatingActionButton: showFAB 
        ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                )
              ],
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: FloatingActionButton(
              onPressed: () {
                // إضافة مشروع جديد
                Navigator.of(context).pushNamed(AddProjectScreen.routeName);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          )
        : null,
    );
  }

  // دالة مساعدة لإنشاء عناصر شريط التنقل مع دعم الوضع الليلي
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required bool isDarkMode,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [AppColors.primaryColor, AppColors.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Icon(activeIcon, color: Colors.white),
        ),
      ),
      label: label,
    );
  }
}

  // دالة لعرض نافذة البحث
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'البحث عن مشروع',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.primaryTextColor,
          ),
        ),
        content: TextField(
          controller: searchController,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.primaryTextColor,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل اسم المشروع',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
              ),
            ),
            filled: true,
            fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // تنفيذ البحث هنا (يمكن إضافة وظيفة البحث في مزود المشاريع)
              final searchTerm = searchController.text.trim();
              if (searchTerm.isNotEmpty) {
                // انتقل إلى شاشة المشاريع مع تمرير مصطلح البحث
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(
                  ProjectsScreen.routeName,
                  arguments: {'searchTerm': searchTerm},
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text('بحث'),
          ),
        ],
      ),
    );
  
}

// علامة تبويب الصفحة الرئيسية
class _DashboardTab extends StatelessWidget {
  const _DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // الحصول على حالة الوضع الليلي
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Consumer<ProjectsProvider>(
      builder: (ctx, projectsProvider, child) {
        final now = DateTime.now();
        final allProjects = projectsProvider.projects;
        
        // المشاريع قيد الإنشاء
        final inProgressProjects = allProjects.where((project) => 
          project.status == ProjectStatus.inProgress || 
          project.status == ProjectStatus.notStarted
        ).toList();
        
        // المشاريع المكتملة
        final completedProjects = allProjects.where((project) => 
          project.status == ProjectStatus.completed
        ).toList();
        
        // المشاريع المتأخرة
        final delayedProjects = allProjects.where((project) => 
          project.status == ProjectStatus.delayed || 
          (project.endDate != null && 
           project.endDate!.isBefore(now) && 
           project.status != ProjectStatus.completed)
        ).toList();
        
        // الإحصائيات
        final stats = {
          'inProgress': inProgressProjects.length,
          'completed': completedProjects.length, 
          'delayed': delayedProjects.length
        };
        
        return CustomScrollView(
          slivers: [
            // رأس صفحة متحرك
            SliverAppBar(
              expandedHeight: 150.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.9),
                        AppColors.accentColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 24,
                              child: Icon(
                                Icons.person,
                                color: AppColors.primaryColor,
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  DateTime.now().hour < 12 
                                    ? 'صباح الخير' 
                                    : (DateTime.now().hour < 17 
                                        ? 'مساء الخير' 
                                        : 'مساء الخير'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                           
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // محتوى الصفحة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    
                    // الإحصائيات
                    Container(
                      height: 160,
                      child: _buildAnimatedStatsCards(stats),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // عنوان المشاريع
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المشاريع النشطة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : AppColors.primaryTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // الانتقال إلى صفحة المشاريع
                          },
                          child: Text(
                            'عرض الكل',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // قائمة المشاريع
            inProgressProjects.isEmpty
            ? SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Icon(
                        Icons.folder_off,
                        size: 60,
                        color: isDarkMode 
                          ? Colors.grey.withOpacity(0.7)
                          : Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد مشاريع نشطة',
                        style: TextStyle(
                          color: isDarkMode 
                            ? Colors.grey.shade400
                            : AppColors.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = inProgressProjects[index];
                      return _buildModernProjectCard(
                        project, 
                        context,
                        isDarkMode,
                      );
                    },
                    childCount: inProgressProjects.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // بطاقات إحصائيات متحركة
  Widget _buildAnimatedStatsCards(Map<String, int> stats) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildStatCardModern(
          title: 'المشاريع الجارية',
          count: stats['inProgress'] ?? 0,
          icon: Icons.play_circle_filled,
          color: AppColors.statusInProgress,
          gradient: LinearGradient(
            colors: [Color(0xFF4A88E0), Color(0xFF63B9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        SizedBox(width: 16),
        _buildStatCardModern(
          title: 'المشاريع المكتملة',
          count: stats['completed'] ?? 0,
          icon: Icons.task_alt,
          color: AppColors.statusCompleted,
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        SizedBox(width: 16),
        _buildStatCardModern(
          title: 'المشاريع المتأخرة',
          count: stats['delayed'] ?? 0,
          icon: Icons.warning_amber_rounded,
          color: AppColors.statusDelayed,
          gradient: LinearGradient(
            colors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  // بطاقة إحصائيات محسنة
  Widget _buildStatCardModern({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            Spacer(),
            Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة مشروع محسنة مع دعم الوضع الليلي
  Widget _buildModernProjectCard(Project project, BuildContext context, bool isDarkMode) {
    double progress = _calculateProgress(project);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).pushNamed(
              ProjectDetailsScreen.routeName,
              arguments: project.id,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(project.status),
                  ],
                ),
                SizedBox(height: 10),
                if (project.description != null && project.description!.isNotEmpty)
                  Text(
                    project.description!,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : AppColors.secondaryTextColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 16),
                
                // شريط التقدم
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : AppColors.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(progress),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 10),
                
                // معلومات إضافية في الأسفل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isDarkMode ? Colors.grey.shade400 : AppColors.secondaryTextColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          project.endDate != null 
                            ? _formatDate(project.endDate!) 
                            : 'غير محدد',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey.shade400 : AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    if (project.endDate != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTimeLeftColor(project.endDate!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTimeLeftText(project.endDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getTimeLeftColor(project.endDate!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // حساب نسبة تقدم المشروع
  double _calculateProgress(Project project) {
    if (project.status == ProjectStatus.completed) {
      return 1.0;
    } else if (project.status == ProjectStatus.notStarted) {
      return 0.0;
    } else if (project.startDate == null || project.endDate == null) {
      // إذا لم يكن هناك تواريخ محددة، أرجع قيمة افتراضية
      return project.status == ProjectStatus.inProgress ? 0.5 : 0.3;
    } else {
      final now = DateTime.now();
      
      if (now.isBefore(project.startDate!)) {
        return 0.0;
      } else if (now.isAfter(project.endDate!)) {
        return project.status == ProjectStatus.completed ? 1.0 : 0.8;
      } else {
        // حساب النسبة بناءً على الوقت المنقضي
        final totalDuration = project.endDate!.difference(project.startDate!).inMilliseconds;
        final elapsedDuration = now.difference(project.startDate!).inMilliseconds;
        
        return elapsedDuration / totalDuration;
      }
    }
  }
  
  // لون شريط التقدم
  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'اليوم';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'غداً';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  Widget _buildStatusChip(ProjectStatus status) {
    // تحديد اللون والنص حسب حالة المشروع
    Color chipColor;
    String statusText;

    switch (status) {
      case ProjectStatus.notStarted:
        chipColor = Colors.grey;
        statusText = 'لم يبدأ';
        break;
      case ProjectStatus.inProgress:
        chipColor = AppColors.statusInProgress;
        statusText = 'قيد التنفيذ';
        break;
      case ProjectStatus.completed:
        chipColor = AppColors.statusCompleted;
        statusText = 'مكتمل';
        break;
      case ProjectStatus.delayed:
        chipColor = AppColors.statusDelayed;
        statusText = 'متأخر';
        break;
      case ProjectStatus.cancelled:
        chipColor = AppColors.statusCancelled;
        statusText = 'ملغي';
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'غير معروف';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _getTimeLeftText(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (endDate.isBefore(now)) {
      final days = now.difference(endDate).inDays;
      return 'متأخر بـ $days ' + (days == 1 ? 'يوم' : 'أيام');
    } else if (difference.inDays == 0) {
      return 'ينتهي اليوم';
    } else {
      return 'متبقي ${difference.inDays} ' + (difference.inDays == 1 ? 'يوم' : 'أيام');
    }
  }
  
  Color _getTimeLeftColor(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (endDate.isBefore(now)) {
      return AppColors.statusDelayed;
    } else if (difference.inDays <= 3) {
      return AppColors.statusInProgress;
    } else {
      return AppColors.secondaryTextColor;
    }
  }
}

// علامة تبويب الإشعارات
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NotificationsScreen();
  }
}

// علامة تبويب الإعدادات
class _SettingsTab extends StatelessWidget {
  const _SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}