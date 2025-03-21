import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/projects_provider.dart'; // تغيير إلى مزود المشاريع الحقيقي
import '../models/project.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'edit_project_screen.dart';

class ProjectDetailsScreen extends StatelessWidget {
  static const routeName = '/project-details';

  const ProjectDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخراج معرف المشروع من المعلمات
    final projectId = ModalRoute.of(context)!.settings.arguments as int?;

    if (projectId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المشروع'),
        ),
        body: Center(
          child: Text(
            'لا يوجد مشروع محدد',
            style: TextStyle(color: AppColors.errorColor),
          ),
        ),
      );
    }

    return Consumer<ProjectsProvider>(
      builder: (ctx, projectsProvider, child) {
        // الحصول على المشروع بواسطة المعرف
        final project = projectsProvider.getProjectById(projectId);

        if (project == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل المشروع'),
            ),
            body: Center(
              child: Text(
                'لم يتم العثور على المشروع',
                style: TextStyle(color: AppColors.errorColor),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المشروع'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // فتح نموذج تعديل المشروع
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => EditProjectScreen(project: project),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context, projectsProvider, project);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان المشروع وحالته
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                    _buildStatusWidget(project.status),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // تفاصيل المشروع
                _buildSectionTitle('تفاصيل المشروع'),
                SizedBox(height: 8),
                Text(
                  project.description ?? 'لا يوجد وصف',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // معلومات التاريخ والفترة
                _buildSectionTitle('الفترة الزمنية'),
                SizedBox(height: 12),
                _buildDateCard(project),
                
                SizedBox(height: 24),
                
                // فريق العمل (يمكن إضافته لاحقًا)
                _buildSectionTitle('فريق العمل'),
                SizedBox(height: 12),
                _buildTeamSection(),
                
                SizedBox(height: 24),
                
                // التكلفة (يمكن إضافتها لاحقًا)
                _buildSectionTitle('تكلفة المشروع'),
                SizedBox(height: 12),
                _buildCostSection(),
                
                SizedBox(height: 36),
                
                // أزرار الإجراءات
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'تعديل المشروع',
                        icon: Icons.edit,
                        onPressed: () {
                          // فتح نموذج تعديل المشروع
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => EditProjectScreen(project: project),
                            ),
                          );
                        },
                        isPrimary: true,
                      ),
                    ),
                    SizedBox(width: 16),
                    CircleIconButton(
                      icon: Icons.delete,
                      backgroundColor: AppColors.errorColor.withOpacity(0.1),
                      iconColor: AppColors.errorColor,
                      tooltip: 'حذف المشروع',
                      onPressed: () {
                        _showDeleteConfirmation(context, projectsProvider, project);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildStatusWidget(ProjectStatus status) {
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateCard(Project project) {
    final dateFormatter = DateFormat.yMMMd('ar');
    
    return Container(
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateItem(
                  label: 'تاريخ البدء',
                  date: project.startDate,
                  icon: Icons.calendar_today,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDateItem(
                  label: 'تاريخ الانتهاء',
                  date: project.endDate,
                  icon: Icons.event_available,
                  color: AppColors.accentColor,
                ),
              ),
            ],
          ),
          if (project.startDate != null && project.endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildDurationInfo(project.startDate!, project.endDate!),
            ),
        ],
      ),
    );
  }

  Widget _buildDateItem({
    required String label,
    required DateTime? date,
    required IconData icon,
    required Color color,
  }) {
    final dateFormatter = DateFormat.yMMMd('ar');
    final formattedDate = date != null
        ? dateFormatter.format(date)
        : 'غير محدد';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryTextColor,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationInfo(DateTime startDate, DateTime endDate) {
    // حساب المدة بين تاريخ البدء وتاريخ الانتهاء
    final duration = endDate.difference(startDate);
    final days = duration.inDays;
    
    // حساب المدة المتبقية من اليوم الحالي حتى تاريخ الانتهاء
    final now = DateTime.now();
    final bool isCompleted = now.isAfter(endDate);
    final bool isStarted = now.isAfter(startDate);
    
    String durationText;
    Color textColor;
    
    if (isCompleted) {
      durationText = 'مكتمل منذ ${now.difference(endDate).inDays} يوم';
      textColor = AppColors.statusCompleted;
    } else if (isStarted) {
      final remainingDays = endDate.difference(now).inDays;
      durationText = 'متبقي $remainingDays يوم';
      textColor = remainingDays > 5 
          ? AppColors.statusInProgress 
          : AppColors.statusDelayed;
    } else {
      durationText = 'يبدأ بعد ${startDate.difference(now).inDays} يوم';
      textColor = AppColors.secondaryTextColor;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'المدة الإجمالية: $days يوم',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryTextColor,
          ),
        ),
        Text(
          durationText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    // هذا قسم مؤقت، يمكن تحسينه لاحقًا لعرض فريق العمل الفعلي
    return Container(
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
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 12),
          Text(
            'لم يتم تعيين أعضاء للفريق',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              // فتح نموذج إضافة أعضاء للفريق
            },
            child: Text(
              'إضافة',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    // هذا قسم مؤقت، يمكن تحسينه لاحقًا لعرض تكلفة المشروع الفعلية
    return Container(
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
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 12),
          Text(
            'لم يتم تحديد تكلفة',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              // فتح نموذج تحديد التكلفة
            },
            child: Text(
              'إضافة',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ProjectsProvider provider,
    Project project,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف المشروع',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف المشروع "${project.title}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await provider.deleteProject(project.id!);
              
              if (success) {
                Navigator.of(context).pop(); // العودة إلى شاشة المشاريع
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المشروع بنجاح'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'فشل حذف المشروع'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}