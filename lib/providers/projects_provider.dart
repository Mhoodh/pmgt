import 'package:flutter/material.dart';
import '../models/project.dart';
import '../database/db_helper.dart';

class ProjectsProvider with ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  
  List<Project> _projects = [];
  List<Project>? _filteredProjects; // للمشاريع المصفّاة
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;

  List<Project> get projects => _filteredProjects ?? [..._projects];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // تعيين المستخدم الحالي
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    print("تم تعيين معرف المستخدم في مزود المشاريع: $_currentUserId");
    loadProjects();
  }

  // الحصول على معرف المستخدم الحالي
  int? getCurrentUserId() {
    return _currentUserId;
  }

  // تحميل مشاريع المستخدم
  Future<void> loadProjects() async {
    if (_currentUserId == null) {
      setErrorMessage('لا يوجد مستخدم حالي');
      return;
    }
    
    setLoading(true);
    
    try {
      _projects = await _dbHelper.getUserProjects(_currentUserId!);
      resetFilters();
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحميل المشاريع: $e');
    } finally {
      setLoading(false);
    }
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
      // تأكيد أن المشروع مرتبط بالمستخدم الحالي
      final userId = _currentUserId ?? 1; // استخدام معرف 1 كاحتياطي
      
      final newProject = project.copyWith(
        userId: userId,
      );
      
      // إدراج المشروع في قاعدة البيانات
      final projectId = await _dbHelper.insertProject(newProject);
      
      if (projectId > 0) {
        // إعادة تحميل المشاريع
        await loadProjects();
        return true;
      } else {
        setErrorMessage('فشل في إضافة المشروع');
        return false;
      }
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
      // تحديث المشروع في قاعدة البيانات
      final result = await _dbHelper.updateProject(project);
      
      if (result > 0) {
        // إعادة تحميل المشاريع
        await loadProjects();
        return true;
      } else {
        setErrorMessage('فشل في تحديث المشروع');
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
      // حذف المشروع من قاعدة البيانات
      final result = await _dbHelper.deleteProject(id);
      
      if (result > 0) {
        // إعادة تحميل المشاريع
        await loadProjects();
        return true;
      } else {
        setErrorMessage('فشل في حذف المشروع');
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
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    if (_currentUserId == null) {
      return [];
    }
    
    try {
      return await _dbHelper.getUserProjectsByStatus(_currentUserId!, status);
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحميل المشاريع: $e');
      return [];
    }
  }
  
  // الحصول على المشاريع المتأخرة
  Future<List<Project>> getOverdueProjects() async {
    if (_currentUserId == null) {
      return [];
    }
    
    try {
      return await _dbHelper.getOverdueProjects(_currentUserId!);
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحميل المشاريع المتأخرة: $e');
      return [];
    }
  }
  
  // الحصول على المشاريع التي على وشك الانتهاء
  Future<List<Project>> getUpcomingProjects() async {
    if (_currentUserId == null) {
      return [];
    }
    
    try {
      return await _dbHelper.getUpcomingProjects(_currentUserId!);
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحميل المشاريع القادمة: $e');
      return [];
    }
  }

  // الحصول على إحصاءات المشاريع
  Future<Map<String, int>> getProjectsStats() async {
    if (_currentUserId == null) {
      return {
        'total': 0,
        'notStarted': 0,
        'inProgress': 0,
        'completed': 0,
        'delayed': 0,
        'cancelled': 0,
      };
    }
    
    try {
      return await _dbHelper.getProjectsStats(_currentUserId!);
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحميل إحصاءات المشاريع: $e');
      return {
        'total': 0,
        'notStarted': 0,
        'inProgress': 0,
        'completed': 0,
        'delayed': 0,
        'cancelled': 0,
      };
    }
  }

  // تصفية المشاريع حسب الحالة
  void filterByStatus(ProjectStatus? status) async {
    if (status == null) {
      _filteredProjects = null; // استعادة جميع المشاريع
    } else {
      if (_currentUserId != null) {
        setLoading(true);
        try {
          _filteredProjects = await _dbHelper.getUserProjectsByStatus(_currentUserId!, status);
        } catch (e) {
          setErrorMessage('حدث خطأ أثناء تصفية المشاريع: $e');
        } finally {
          setLoading(false);
        }
      }
    }
    notifyListeners();
  }

  // البحث عن المشاريع حسب الاسم
  void searchProjects(String searchTerm) async {
    if (_currentUserId == null) {
      return;
    }
    
    if (searchTerm.isEmpty) {
      _filteredProjects = null; // استعادة جميع المشاريع
    } else {
      setLoading(true);
      try {
        _filteredProjects = await _dbHelper.searchProjects(_currentUserId!, searchTerm);
      } catch (e) {
        setErrorMessage('حدث خطأ أثناء البحث عن المشاريع: $e');
      } finally {
        setLoading(false);
      }
    }
    notifyListeners();
  }

  // استعادة المشاريع من النسخة الاحتياطية
  Future<bool> restoreProjects(List<Project> projects) async {
    if (_currentUserId == null) {
      setErrorMessage('لا يوجد مستخدم حالي');
      return false;
    }
    
    setLoading(true);
    
    try {
      // حذف جميع المشاريع الحالية للمستخدم
      await _dbHelper.deleteUserProjects(_currentUserId!);
      
      // إضافة المشاريع المستعادة
      for (final project in projects) {
        // تأكيد أن المشروع مرتبط بالمستخدم الحالي
        final restoredProject = project.copyWith(
          userId: _currentUserId,
        );
        
        await _dbHelper.insertProject(restoredProject);
      }
      
      // إعادة تحميل المشاريع
      await loadProjects();
      
      return true;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء استعادة المشاريع: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // حذف كل مشاريع المستخدم
  Future<bool> resetProjects() async {
    if (_currentUserId == null) {
      setErrorMessage('لا يوجد مستخدم حالي');
      return false;
    }
    
    setLoading(true);
    
    try {
      // حذف جميع مشاريع المستخدم الحالي
      await _dbHelper.deleteUserProjects(_currentUserId!);
      
      // إعادة تحميل المشاريع
      await loadProjects();
      
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