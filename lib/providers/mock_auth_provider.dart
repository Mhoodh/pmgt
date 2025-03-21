import 'package:flutter/material.dart';
import '../models/user.dart';

/// مزود مصادقة وهمي للاختبار دون الحاجة إلى قاعدة بيانات
class MockAuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // بيانات مستخدم وهمية للاختبار
  final Map<String, User> _mockUsers = {
    'test@example.com': User(
      id: 1,
      name: 'مستخدم تجريبي',
      email: 'test@example.com',
      password: '123456',
      createdAt: DateTime.now(),
    ),
    'admin@app.com': User(
      id: 2,
      name: 'مدير النظام',
      email: 'admin@app.com',
      password: 'admin123',
      createdAt: DateTime.now(),
    ),
  };

  // الحصول على المستخدم الحالي
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // تهيئة حالة المستخدم عند بدء التطبيق
  Future<bool> initializeUser() async {
    print("تهيئة مزود المصادقة الوهمي");
    setLoading(true);
    
    // محاكاة تأخير قاعدة البيانات
    await Future.delayed(Duration(milliseconds: 500));
    
    // اختياريًا: يمكننا تسجيل دخول مستخدم افتراضي للاختبار
    // _currentUser = _mockUsers['test@example.com'];
    
    setLoading(false);
    return _currentUser != null;
  }

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    print("محاولة تسجيل الدخول (وهمي): $email");
    setLoading(true);
    clearError();
    
    // محاكاة تأخير التحقق
    await Future.delayed(Duration(seconds: 1));
    
    try {
      // التحقق من وجود المستخدم وصحة كلمة المرور
      final user = _mockUsers[email];
      
      if (user != null && user.password == password) {
        print("تم تسجيل الدخول بنجاح (وهمي)");
        
        // تعيين المستخدم الحالي وتحديث آخر تسجيل دخول
        _currentUser = user.copyWith(
          lastLogin: DateTime.now(),
        );
        
        notifyListeners();
        return true;
      } else {
        print("فشل تسجيل الدخول (وهمي): بيانات خاطئة");
        setErrorMessage('البريد الإلكتروني أو كلمة المرور غير صحيحة');
        return false;
      }
    } catch (e) {
      print("خطأ في تسجيل الدخول (وهمي): $e");
      setErrorMessage('حدث خطأ أثناء تسجيل الدخول');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // تسجيل مستخدم جديد
  Future<bool> register(String name, String email, String password) async {
    setLoading(true);
    clearError();
    
    // محاكاة تأخير التسجيل
    await Future.delayed(Duration(seconds: 1));
    
    try {
      // التحقق من عدم وجود المستخدم بالفعل
      if (_mockUsers.containsKey(email)) {
        setErrorMessage('البريد الإلكتروني مسجل بالفعل');
        return false;
      }
      
      // إنشاء مستخدم جديد
      final newUserId = _mockUsers.length + 1;
      final newUser = User(
        id: newUserId,
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      // إضافة المستخدم الجديد إلى قائمة المستخدمين الوهمية
      _mockUsers[email] = newUser;
      
      // تعيين المستخدم الحالي
      _currentUser = newUser;
      
      notifyListeners();
      return true;
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء التسجيل: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    _currentUser = null;
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
  }
}