import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart'; // تغيير إلى المزود الحقيقي
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../utils/constants.dart';
import 'add_project_screen.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  static const routeName = '/projects';

  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // التحقق من وجود مصطلح بحث تم تمريره من شاشة أخرى
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final searchTerm = args?['searchTerm'] as String?;
    
    if (searchTerm != null && searchTerm.isNotEmpty) {
      // عرض رسالة البحث
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // تطبيق البحث على مزود المشاريع
        Provider.of<ProjectsProvider>(context, listen: false).searchProjects(searchTerm);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جارٍ البحث عن: $searchTerm'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<ProjectsProvider>(
        builder: (ctx, projectsProvider, child) {
          final projects = projectsProvider.projects;
          
          if (projectsProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off,
                    size: 80,
                    color: AppColors.secondaryTextColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد مشاريع',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AddProjectScreen.routeName);
                    },
                    icon: Icon(Icons.add),
                    label: Text('إضافة مشروع جديد'),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // إحصائيات المشاريع
                FutureBuilder<Map<String, int>>(
                  future: projectsProvider.getProjectsStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    final stats = snapshot.data ?? {
                      'total': projects.length,
                      'notStarted': 0,
                      'inProgress': 0,
                      'completed': 0,
                      'delayed': 0,
                      'cancelled': 0,
                    };
                    
                    return _buildProjectStats(stats, context);
                  },
                ),
                SizedBox(height: 16),
                
                Text(
                  'جميع المشاريع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 8),
                
                // قائمة المشاريع
                Expanded(
                  child: ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (ctx, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            ProjectDetailsScreen.routeName,
                            arguments: project.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddProjectScreen.routeName);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectStats(Map<String, int> stats, BuildContext context) {
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
            'إحصائيات المشاريع',
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
              _buildStatItem('الكل', stats['total'] ?? 0, Colors.blue),
              _buildStatItem('قيد التنفيذ', stats['inProgress'] ?? 0, AppColors.statusInProgress),
              _buildStatItem('مكتملة', stats['completed'] ?? 0, AppColors.statusCompleted),
              _buildStatItem('متأخرة', stats['delayed'] ?? 0, AppColors.statusDelayed),
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

  void _showFilterDialog(BuildContext context) {
    ProjectStatus? selectedStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'تصفية المشاريع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(
                context, 
                'جميع المشاريع', 
                null, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
              _buildFilterOption(
                context, 
                'لم تبدأ بعد', 
                ProjectStatus.notStarted, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
              _buildFilterOption(
                context, 
                'قيد التنفيذ', 
                ProjectStatus.inProgress, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
              _buildFilterOption(
                context, 
                'مكتملة', 
                ProjectStatus.completed, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
              _buildFilterOption(
                context, 
                'متأخرة', 
                ProjectStatus.delayed, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
              _buildFilterOption(
                context, 
                'ملغية', 
                ProjectStatus.cancelled, 
                selectedStatus, 
                (value) => setState(() => selectedStatus = value),
              ),
            ],
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
                Navigator.of(ctx).pop(selectedStatus);
              },
              child: Text('تطبيق'),
            ),
          ],
        ),
      ),
    ).then((status) {
      if (status != null) {
        // تطبيق التصفية هنا
        _filterProjects(context, status);
      }
    });
  }

  Widget _buildFilterOption(
    BuildContext context, 
    String title, 
    ProjectStatus? status, 
    ProjectStatus? selectedStatus, 
    Function(ProjectStatus?) onChanged,
  ) {
    return RadioListTile<ProjectStatus?>(
      title: Text(title),
      value: status,
      groupValue: selectedStatus,
      onChanged: (value) => onChanged(value),
    );
  }

  // دالة لعرض نافذة البحث
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('البحث عن مشروع'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'أدخل اسم المشروع',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(ctx).pop();
              _searchProjects(context, value.trim());
            }
          },
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
              final searchTerm = searchController.text.trim();
              if (searchTerm.isNotEmpty) {
                Navigator.of(ctx).pop();
                _searchProjects(context, searchTerm);
              }
            },
            child: Text('بحث'),
          ),
        ],
      ),
    );
  }

  // تنفيذ عملية البحث
  void _searchProjects(BuildContext context, String searchTerm) {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    provider.searchProjects(searchTerm);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جارٍ البحث عن: $searchTerm'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // طريقة مساعدة لتصفية المشاريع
  void _filterProjects(BuildContext context, ProjectStatus? status) {
    final provider = Provider.of<ProjectsProvider>(context, listen: false);
    provider.filterByStatus(status);
    
    // عرض رسالة تأكيد للمستخدم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == null 
            ? 'عرض جميع المشاريع' 
            : 'تم تصفية المشاريع حسب: ${_getStatusName(status)}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // الحصول على اسم الحالة بالعربية
  String _getStatusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return 'لم تبدأ بعد';
      case ProjectStatus.inProgress:
        return 'قيد التنفيذ';
      case ProjectStatus.completed:
        return 'مكتملة';
      case ProjectStatus.delayed:
        return 'متأخرة';
      case ProjectStatus.cancelled:
        return 'ملغية';
      default:
        return 'غير معروفة';
    }
  }
}