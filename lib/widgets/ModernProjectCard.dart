import 'package:flutter/material.dart';
import '../models/project.dart';
import '../utils/constants.dart';
import '../screens/project_details_screen.dart';

class ModernProjectCard extends StatelessWidget {
  final Project project;
  
  const ModernProjectCard({
    Key? key,
    required this.project,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
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