import 'package:flutter/material.dart';
import '../models/project.dart';

class MockProjectsProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Project>? _filteredProjects; // للمشاريع المصفّاة
  bool _isLoading = false;
  String? _errorMessage;

  MockProjectsProvider() {
    // تهيئة بعض المشاريع الوهمية للاختبار
    _initProjects();
  }

  List<Project> get projects => _filteredProjects ?? [..._projects];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initProjects() {
    final now = DateTime.now();
    
    _projects = [
      Project(
        id: 1,
        title: 'تطوير تطبيق إدارة المشاريع',
        description: 'تطوير تطبيق لإدارة المشاريع باستخدام Flutter وSQLite',
        startDate: DateTime(now.year, now.month - 1, 15),
        endDate: DateTime(now.year, now.month + 1, 30),
        status: ProjectStatus.inProgress,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 2,
        title: 'تصميم الواجهة الرسومية',
        description: 'تصميم واجهة المستخدم للتطبيق الجديد',
        startDate: DateTime(now.year, now.month - 2, 10),
        endDate: DateTime(now.year, now.month - 1, 5),
        status: ProjectStatus.completed,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 3,
        title: 'تحسين أداء التطبيق',
        description: 'تحسين الأداء وتقليل استهلاك الموارد',
        startDate: DateTime(now.year, now.month, 1),
        endDate: now.add(Duration(days: 2)), // على وشك الانتهاء
        status: ProjectStatus.inProgress,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 4,
        title: 'إصلاح الأخطاء البرمجية',
        description: 'معالجة الأخطاء المكتشفة في الإصدار الأخير',
        startDate: DateTime(now.year, now.month - 1, 20),
        endDate: now.subtract(Duration(days: 5)), // متأخر
        status: ProjectStatus.delayed,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 5,
        title: 'توثيق المشروع',
        description: 'إعداد وثائق المشروع والأدلة الإرشادية',
        startDate: DateTime(now.year, now.month, 15),
        endDate: now.subtract(Duration(days: 3)), // متأخر
        status: ProjectStatus.inProgress,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 6,
        title: 'إعداد الخطة التسويقية',
        description: 'إنشاء وتنفيذ خطة تسويقية للمنتج الجديد',
        startDate: DateTime(now.year, now.month - 2, 15),
        endDate: now.add(Duration(days: 1)), // ينتهي غداً
        status: ProjectStatus.inProgress,
        userId: 1,
        createdAt: DateTime.now(),
      ),
      Project(
        id: 7,
        title: 'تنظيم ورشة عمل',
        description: 'تخطيط وتنفيذ ورشة عمل للمطورين',
        startDate: DateTime(now.year, now.month, 10),
        endDate: now.add(Duration(days: 10)),
        status: ProjectStatus.notStarted,
        userId: 1,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // الحصول على مشروع بواسطة المعرف
  Project? getProjectById(int id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // إضافة مشروع جديد
  Future<bool> addProject(Project project) async {
    setLoading(true);
    
    try {
      // محاكاة تأخير العملية
      await Future.delayed(Duration(seconds: 1));
      
      // تعيين معرف جديد للمشروع
      final newProject = project.copyWith(
        id: _projects.isEmpty ? 1 : (_projects.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1),
      );
      
      _projects.add(newProject);
      resetFilters();
      
      return true;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء إضافة المشروع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // تحديث مشروع موجود
  Future<bool> updateProject(Project project) async {
    setLoading(true);
    
    try {
      // محاكاة تأخير العملية
      await Future.delayed(Duration(seconds: 1));
      
      // البحث عن المشروع وتحديثه
      final index = _projects.indexWhere((p) => p.id == project.id);
      
      if (index != -1) {
        _projects[index] = project.copyWith(
          updatedAt: DateTime.now(),
        );
        resetFilters();
        return true;
      } else {
        setErrorMessage('المشروع غير موجود');
        return false;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحديث المشروع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // حذف مشروع
  Future<bool> deleteProject(int id) async {
    setLoading(true);
    
    try {
      // محاكاة تأخير العملية
      await Future.delayed(Duration(seconds: 1));
      
      // حذف المشروع
      final initialLength = _projects.length;
      _projects.removeWhere((project) => project.id == id);
      
      if (_projects.length < initialLength) {
        resetFilters();
        return true;
      } else {
        setErrorMessage('المشروع غير موجود');
        return false;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء حذف المشروع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // الحصول على المشاريع حسب الحالة
  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }
  
  // الحصول على المشاريع المتأخرة
  List<Project> getOverdueProjects() {
    final now = DateTime.now();
    return _projects.where((project) => 
      project.endDate != null && 
      project.endDate!.isBefore(now) &&
      project.status != ProjectStatus.completed &&
      project.status != ProjectStatus.cancelled
    ).toList();
  }
  
  // الحصول على المشاريع التي على وشك الانتهاء
  List<Project> getUpcomingProjects() {
    final now = DateTime.now();
    return _projects.where((project) => 
      project.endDate != null && 
      project.endDate!.isAfter(now) &&
      project.endDate!.difference(now).inDays <= 3 &&
      project.status != ProjectStatus.completed &&
      project.status != ProjectStatus.cancelled
    ).toList();
  }

  // الحصول على إحصاءات المشاريع
  Map<String, int> getProjectsStats() {
    final now = DateTime.now();
    
    // مشاريع متأخرة (تجاوزت الموعد النهائي أو بحالة متأخرة)
    final overdueProjects = _projects.where((p) => 
      p.status == ProjectStatus.delayed || 
      (p.endDate != null && p.endDate!.isBefore(now) && p.status != ProjectStatus.completed && p.status != ProjectStatus.cancelled)
    ).length;
    
    return {
      'total': _projects.length,
      'notStarted': _projects.where((p) => p.status == ProjectStatus.notStarted).length,
      'inProgress': _projects.where((p) => p.status == ProjectStatus.inProgress).length,
      'completed': _projects.where((p) => p.status == ProjectStatus.completed).length,
      'delayed': overdueProjects,
      'cancelled': _projects.where((p) => p.status == ProjectStatus.cancelled).length,
    };
  }

  // تصفية المشاريع حسب الحالة
  void filterByStatus(ProjectStatus? status) {
    if (status == null) {
      _filteredProjects = null; // استعادة جميع المشاريع
    } else {
      _filteredProjects = _projects.where((project) => project.status == status).toList();
    }
    notifyListeners();
  }

  // البحث عن المشاريع حسب الاسم
  void searchProjects(String searchTerm) {
    if (searchTerm.isEmpty) {
      _filteredProjects = null; // استعادة جميع المشاريع
    } else {
      _filteredProjects = _projects.where((project) => 
        project.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
        (project.description != null && 
         project.description!.toLowerCase().contains(searchTerm.toLowerCase()))
      ).toList();
    }
    notifyListeners();
  }

  // استعادة المشاريع من النسخة الاحتياطية
  Future<bool> restoreProjects(List<Project> projects) async {
    setLoading(true);
    
    try {
      // محاكاة تأخير العملية
      await Future.delayed(Duration(seconds: 1));
      
      // استبدال المشاريع الحالية بالمشاريع المستعادة
      _projects = projects;
      resetFilters();
      
      return true;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء استعادة المشاريع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // إعادة ضبط المشاريع (حذف جميع المشاريع)
  Future<bool> resetProjects() async {
    setLoading(true);
    
    try {
      // محاكاة تأخير العملية
      await Future.delayed(Duration(seconds: 1));
      
      // حذف جميع المشاريع
      _projects = [];
      resetFilters();
      
      return true;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء إعادة ضبط المشاريع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // إعادة تعيين التصفية
  void resetFilters() {
    _filteredProjects = null;
    notifyListeners();
  }

  // طرق مساعدة
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}