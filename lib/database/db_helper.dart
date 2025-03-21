import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/user.dart';
import '../models/project.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal() {
    // تهيئة العامل مباشرة عند إنشاء الكائن
    initDatabaseFactory();
  }

  static Database? _database;

  // جدول المستخدمين
  static const String usersTable = 'users';
  // جدول المشاريع
  static const String projectsTable = 'projects';

  // تهيئة factory لقاعدة البيانات حسب المنصة
  static void initDatabaseFactory() {
    if (kIsWeb) {
      print('Web platform - SQLite might not be fully supported');
    } else if (!Platform.isAndroid && !Platform.isIOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('Desktop platform - FFI implementation initialized');
    } else {
      print('Mobile platform - Default SQLite implementation');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // تهيئة factory مرة أخرى قبل فتح قاعدة البيانات
    initDatabaseFactory();
    
    _database = await _initDatabase();
    return _database!;
  }

  // بقية الكود كما هو...


  // تهيئة قاعدة البيانات
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'project_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  // إنشاء جداول قاعدة البيانات
  Future<void> _createDb(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        profile_image TEXT,
        created_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    // جدول المشاريع
    await db.execute('''
      CREATE TABLE $projectsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        start_date TEXT,
        end_date TEXT,
        status TEXT NOT NULL,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES $usersTable (id)
      )
    ''');

    // يمكنك إضافة بيانات افتراضية للاختبار
    await _insertDefaultUser(db);
  }

  // إدراج مستخدم افتراضي للاختبار
  Future<void> _insertDefaultUser(Database db) async {
    await db.insert(
      usersTable,
      User(
        name: 'مستخدم تجريبي',
        email: 'test@example.com',
        password: '123456',
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  // ***** عمليات المستخدمين *****

  // إدراج مستخدم جديد
  Future<int> insertUser(User user) async {
    final Database db = await database;
    return await db.insert(usersTable, user.toMap());
  }

  // التحقق من بيانات المستخدم عند تسجيل الدخول
  Future<User?> authenticateUser(String email, String password) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      // تحديث آخر تسجيل دخول
      final user = User.fromMap(result.first);
      await updateUserLastLogin(user.id!);
      // استرجاع المستخدم بعد التحديث
      return await getUserById(user.id!);
    }
    return null;
  }

  // الحصول على مستخدم حسب المعرف
  Future<User?> getUserById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // الحصول على مستخدم حسب البريد الإلكتروني
  Future<User?> getUserByEmail(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // تحديث آخر تسجيل دخول للمستخدم
  Future<int> updateUserLastLogin(int userId) async {
    final Database db = await database;
    return await db.update(
      usersTable,
      {'last_login': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // تحديث بيانات المستخدم
  Future<int> updateUser(User user) async {
    final Database db = await database;
    return await db.update(
      usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // حذف مستخدم
  Future<int> deleteUser(int id) async {
    final Database db = await database;
    return await db.delete(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ***** عمليات المشاريع ***** 
  
  // إدراج مشروع جديد
  Future<int> insertProject(Project project) async {
    final Database db = await database;
    return await db.insert(projectsTable, project.toMap());
  }

  // الحصول على مشروع حسب المعرف
  Future<Project?> getProjectById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Project.fromMap(result.first);
    }
    return null;
  }

  // الحصول على جميع مشاريع المستخدم
  Future<List<Project>> getUserProjects(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      projectsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return result.map((data) => Project.fromMap(data)).toList();
  }

  // الحصول على مشاريع المستخدم حسب الحالة
  Future<List<Project>> getUserProjectsByStatus(int userId, ProjectStatus status) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      projectsTable,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status.toString().split('.').last],
      orderBy: 'created_at DESC',
    );

    return result.map((data) => Project.fromMap(data)).toList();
  }

  // تحديث مشروع
  Future<int> updateProject(Project project) async {
    final Database db = await database;
    return await db.update(
      projectsTable,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  // حذف مشروع
  Future<int> deleteProject(int id) async {
    final Database db = await database;
    return await db.delete(
      projectsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // حذف جميع مشاريع المستخدم
  Future<int> deleteUserProjects(int userId) async {
    final Database db = await database;
    return await db.delete(
      projectsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // البحث عن مشاريع
  Future<List<Project>> searchProjects(int userId, String query) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      projectsTable,
      where: 'user_id = ? AND (title LIKE ? OR description LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return result.map((data) => Project.fromMap(data)).toList();
  }

  // الحصول على المشاريع المتأخرة
  Future<List<Project>> getOverdueProjects(int userId) async {
    final Database db = await database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $projectsTable 
      WHERE user_id = ? 
      AND end_date < ? 
      AND status != ? 
      AND status != ?
      ORDER BY end_date ASC
    ''', [userId, now, ProjectStatus.completed.toString().split('.').last, ProjectStatus.cancelled.toString().split('.').last]);

    return result.map((data) => Project.fromMap(data)).toList();
  }

  // الحصول على المشاريع القادمة (التي تنتهي قريبًا)
  Future<List<Project>> getUpcomingProjects(int userId) async {
    final Database db = await database;
    final now = DateTime.now();
    final threeDaysLater = now.add(Duration(days: 3)).toIso8601String();
    final today = now.toIso8601String();
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM $projectsTable 
      WHERE user_id = ? 
      AND end_date BETWEEN ? AND ? 
      AND status != ? 
      AND status != ?
      ORDER BY end_date ASC
    ''', [userId, today, threeDaysLater, ProjectStatus.completed.toString().split('.').last, ProjectStatus.cancelled.toString().split('.').last]);

    return result.map((data) => Project.fromMap(data)).toList();
  }

  // الحصول على إحصائيات المشاريع
  Future<Map<String, int>> getProjectsStats(int userId) async {
    final Database db = await database;
    
    // إجمالي المشاريع
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ?', 
      [userId]
    );
    
    // المشاريع حسب الحالة
    final notStartedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ? AND status = ?', 
      [userId, ProjectStatus.notStarted.toString().split('.').last]
    );
    
    final inProgressResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ? AND status = ?', 
      [userId, ProjectStatus.inProgress.toString().split('.').last]
    );
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ? AND status = ?', 
      [userId, ProjectStatus.completed.toString().split('.').last]
    );
    
    final delayedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ? AND status = ?', 
      [userId, ProjectStatus.delayed.toString().split('.').last]
    );
    
    final cancelledResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $projectsTable WHERE user_id = ? AND status = ?', 
      [userId, ProjectStatus.cancelled.toString().split('.').last]
    );
    
    // المشاريع المتأخرة (تجاوزت الموعد النهائي)
    final now = DateTime.now().toIso8601String();
    final overdueResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $projectsTable 
      WHERE user_id = ? 
      AND end_date < ? 
      AND status != ? 
      AND status != ?
    ''', [userId, now, ProjectStatus.completed.toString().split('.').last, ProjectStatus.cancelled.toString().split('.').last]);
    
    return {
      'total': Sqflite.firstIntValue(totalResult) ?? 0,
      'notStarted': Sqflite.firstIntValue(notStartedResult) ?? 0,
      'inProgress': Sqflite.firstIntValue(inProgressResult) ?? 0,
      'completed': Sqflite.firstIntValue(completedResult) ?? 0,
      'delayed': (Sqflite.firstIntValue(delayedResult) ?? 0) + (Sqflite.firstIntValue(overdueResult) ?? 0),
      'cancelled': Sqflite.firstIntValue(cancelledResult) ?? 0,
    };
  }
}