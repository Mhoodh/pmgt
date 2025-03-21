import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../providers/projects_provider.dart';

class BackupProvider with ChangeNotifier {
  String? _lastBackupDate;
  bool _isLoading = false;

  String? get lastBackupDate => _lastBackupDate;
  bool get isLoading => _isLoading;

  BackupProvider() {
    _loadLastBackupDate();
  }

  // تحميل تاريخ آخر نسخة احتياطية
  Future<void> _loadLastBackupDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastBackupDate = prefs.getString('last_backup_date');
      notifyListeners();
    } catch (e) {
      print('خطأ في تحميل تاريخ آخر نسخة احتياطية: $e');
    }
  }

  // تحديث تاريخ آخر نسخة احتياطية
  Future<void> _updateLastBackupDate() async {
    try {
      final now = DateTime.now();
      _lastBackupDate = now.toIso8601String();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_date', _lastBackupDate!);
      notifyListeners();
    } catch (e) {
      print('خطأ في تحديث تاريخ آخر نسخة احتياطية: $e');
    }
  }

  // إنشاء نسخة احتياطية
  Future<String?> createBackup(ProjectsProvider projectsProvider) async {
    _setLoading(true);
    
    try {
      // الحصول على البيانات
      final projects = projectsProvider.projects;
      
      // تحويل البيانات إلى JSON
      final data = {
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'projects': projects.map((p) => p.toMap()).toList(),
      };
      
      final jsonData = jsonEncode(data);
      
      // حفظ البيانات في ملف
      final backupFile = await _writeBackupFile(jsonData);
      
      // تحديث تاريخ آخر نسخة احتياطية
      await _updateLastBackupDate();
      
      return backupFile.path;
    } catch (e) {
      print('خطأ في إنشاء النسخة الاحتياطية: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // استعادة النسخة الاحتياطية
  Future<bool> restoreBackup(String path, ProjectsProvider projectsProvider) async {
    _setLoading(true);
    
    try {
      // قراءة ملف النسخة الاحتياطية
      final file = File(path);
      if (!await file.exists()) {
        return false;
      }
      
      final jsonData = await file.readAsString();
      final data = jsonDecode(jsonData);
      
      // استعادة المشاريع
      final projects = (data['projects'] as List)
          .map((item) => Project.fromMap(item as Map<String, dynamic>))
          .toList();
      
      // تحديث مزود المشاريع
      await projectsProvider.restoreProjects(projects);
      
      return true;
    } catch (e) {
      print('خطأ في استعادة النسخة الاحتياطية: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // كتابة ملف النسخة الاحتياطية
  Future<File> _writeBackupFile(String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/backup_$timestamp.json';
    final file = File(path);
    return await file.writeAsString(data);
  }

  // الحصول على قائمة ملفات النسخ الاحتياطية
  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().where((entity) => 
          entity.path.endsWith('.json') && 
          entity.path.contains('backup_')).toList();
      
      // ترتيب الملفات من الأحدث إلى الأقدم
      files.sort((a, b) => b.path.compareTo(a.path));
      
      return files;
    } catch (e) {
      print('خطأ في الحصول على ملفات النسخ الاحتياطية: $e');
      return [];
    }
  }

  // حذف ملف نسخة احتياطية
  Future<bool> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في حذف ملف النسخة الاحتياطية: $e');
      return false;
    }
  }

  // طرق مساعدة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}