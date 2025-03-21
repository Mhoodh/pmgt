import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mock_projects_provider.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../utils/constants.dart';
import 'add_project_screen.dart';
import 'project_details_screen.dart';

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                // إضافة وظيفة البحث هنا
                              },
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
                            color: AppColors.primaryTextColor,
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
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد مشاريع نشطة',
                        style: TextStyle(
                          color: AppColors.secondaryTextColor,
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
                      return _buildModernProjectCard(project, context);
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

  // بطاقة مشروع محسنة
  Widget _buildModernProjectCard(Project project, BuildContext context) {
    double progress = _calculateProgress(project);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                          color: AppColors.primaryTextColor,
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
                      color: AppColors.secondaryTextColor,
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
                            color: AppColors.secondaryTextColor,
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
                        backgroundColor: Colors.grey.shade200,
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
                          color: AppColors.secondaryTextColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          project.endDate != null 
                            ? _formatDate(project.endDate!) 
                            : 'غير محدد',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryTextColor,
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