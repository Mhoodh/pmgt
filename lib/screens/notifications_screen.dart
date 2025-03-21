import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/projects_provider.dart'; // تغيير إلى مزود المشاريع الحقيقي
import '../models/project.dart';
import '../utils/constants.dart';
import 'project_details_screen.dart';
class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
      ),
      body: Consumer<ProjectsProvider>(
        builder: (ctx, projectsProvider, child) {
          final allProjects = projectsProvider.projects;
          final now = DateTime.now();
          
          // تصفية المشاريع التي تجاوزت تاريخ انتهائها
          final overdueProjects = allProjects.where((project) => 
            project.endDate != null && 
            project.endDate!.isBefore(now) &&
            project.status != ProjectStatus.completed &&
            project.status != ProjectStatus.cancelled
          ).toList();
          
          // تصفية المشاريع التي اقترب موعد انتهائها (خلال 3 أيام)
          final upcomingProjects = allProjects.where((project) => 
            project.endDate != null && 
            project.endDate!.isAfter(now) &&
            project.endDate!.difference(now).inDays <= 3 &&
            project.status != ProjectStatus.completed &&
            project.status != ProjectStatus.cancelled
          ).toList();
          
          if (projectsProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (overdueProjects.isEmpty && upcomingProjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: AppColors.secondaryTextColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ستظهر هنا المشاريع التي تجاوزت موعدها أو على وشك الانتهاء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // إحصائيات الإشعارات
                _buildNotificationsStats(overdueProjects.length, upcomingProjects.length),
                SizedBox(height: 24),
                
                // المشاريع المتأخرة
                if (overdueProjects.isNotEmpty) ...[
                  _buildSectionTitle('مشاريع متأخرة', AppColors.statusDelayed),
                  SizedBox(height: 8),
                  ..._buildNotificationsList(context, overdueProjects, true),
                  SizedBox(height: 24),
                ],
                
                // المشاريع القادمة
                if (upcomingProjects.isNotEmpty) ...[
                  _buildSectionTitle('مشاريع على وشك الانتهاء', AppColors.statusInProgress),
                  SizedBox(height: 8),
                  ..._buildNotificationsList(context, upcomingProjects, false),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsStats(int overdueCount, int upcomingCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الإشعارات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTextColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('المتأخرة', overdueCount, AppColors.statusDelayed),
              _buildStatItem('على وشك الانتهاء', upcomingCount, AppColors.statusInProgress),
              _buildStatItem('إجمالي الإشعارات', overdueCount + upcomingCount, AppColors.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
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

  List<Widget> _buildNotificationsList(BuildContext context, List<Project> projects, bool isOverdue) {
    final dateFormatter = DateFormat.yMMMd('ar');
    
    return projects.map((project) {
      final daysCount = project.endDate!.difference(DateTime.now()).inDays.abs();
      final daysText = isOverdue
          ? 'متأخر بـ $daysCount ' + (daysCount == 1 ? 'يوم' : 'أيام')
          : 'ينتهي خلال $daysCount ' + (daysCount == 1 ? 'يوم' : 'أيام');
      
      return Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isOverdue ? AppColors.statusDelayed.withOpacity(0.3) : AppColors.statusInProgress.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProjectDetailsScreen.routeName,
              arguments: project.id,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning_amber_rounded : Icons.access_time,
                      color: isOverdue ? AppColors.statusDelayed : AppColors.statusInProgress,
                      size: 20,
                    ),
                    SizedBox(width: 8),
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
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  daysText,
                  style: TextStyle(
                    color: isOverdue ? AppColors.statusDelayed : AppColors.statusInProgress,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تاريخ الانتهاء: ${dateFormatter.format(project.endDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    _buildStatusChip(project.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
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
}