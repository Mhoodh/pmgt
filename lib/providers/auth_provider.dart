import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import '../database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // الحصول على المستخدم الحالي
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // تهيئة حالة المستخدم عند بدء التطبيق
  Future<bool> initializeUser() async {
    setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId != null) {
        _currentUser = await _dbHelper.getUserById(userId);
        setLoading(false);
        return _currentUser != null;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تهيئة المستخدم: $e');
    }
    
    setLoading(false);
    return false;
  }

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      print("محاولة تسجيل الدخول: $email");
      
      // للويب، استخدم تحقق بسيط
      if (kIsWeb) {
        if (email == "test@example.com" && password == "123456") {
          _currentUser = User(
            id: 1,
            name: 'مستخدم تجريبي',
            email: email,
            password: password,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );
          
          // حفظ معرف المستخدم في التخزين المحلي للجهاز
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', 1);
          } catch (e) {
            print("تعذر حفظ البيانات في التخزين المحلي: $e");
          }
          
          notifyListeners();
          setLoading(false);
          return true;
        } else {
          setErrorMessage('البريد الإلكتروني أو كلمة المرور غير صحيحة');
          setLoading(false);
          return false;
        }
      }
      
      // التحقق من صحة البريد الإلكتروني وكلمة المرور في قاعدة البيانات
      try {
        final user = await _dbHelper.authenticateUser(email, password);
        
        if (user != null) {
          _currentUser = user;
          
          // حفظ معرف المستخدم في التخزين المحلي للجهاز
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', user.id!);
          } catch (e) {
            print("تعذر حفظ البيانات في التخزين المحلي: $e");
          }
          
          notifyListeners();
          setLoading(false);
          return true;
        }
      } catch (e) {
        print("خطأ أثناء التحقق من قاعدة البيانات: $e");
        setErrorMessage('خطأ في الاتصال بقاعدة البيانات');
        setLoading(false);
        return false;
      }
      
      setErrorMessage('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      setLoading(false);
      return false;
    } catch (e) {
      print("خطأ غير متوقع أثناء تسجيل الدخول: $e");
      setErrorMessage('حدث خطأ أثناء تسجيل الدخول: $e');
      setLoading(false);
      return false;
    }
  }

  // تسجيل مستخدم جديد
  Future<bool> register(String name, String email, String password) async {
    setLoading(true);
    clearError();
    
    try {
      // التحقق من عدم وجود مستخدم بنفس البريد الإلكتروني
      final existingUser = await _dbHelper.getUserByEmail(email);
      
      if (existingUser != null) {
        setErrorMessage('البريد الإلكتروني مسجل بالفعل');
        setLoading(false);
        return false;
      }
      
      // إنشاء مستخدم جديد
      final user = User(
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      // إدراج المستخدم في قاعدة البيانات
      final userId = await _dbHelper.insertUser(user);
      
      if (userId > 0) {
        // الحصول على المستخدم بعد الإدراج
        _currentUser = await _dbHelper.getUserById(userId);
        
        // حفظ معرف المستخدم في التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', userId);
        
        notifyListeners();
        setLoading(false);
        return true;
      } else {
        setErrorMessage('فشل في تسجيل المستخدم');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء التسجيل: $e');
      setLoading(false);
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تسجيل الخروج: $e');
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile(User updatedUser) async {
    setLoading(true);
    clearError();
    
    try {
      final result = await _dbHelper.updateUser(updatedUser);
      
      if (result > 0) {
        _currentUser = updatedUser;
        notifyListeners();
        setLoading(false);
        return true;
      } else {
        setErrorMessage('فشل في تحديث الملف الشخصي');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تحديث الملف الشخصي: $e');
      setLoading(false);
      return false;
    }
  }

  // تغيير كلمة المرور
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    setLoading(true);
    clearError();
    
    try {
      if (_currentUser == null) {
        setErrorMessage('يجب تسجيل الدخول أولاً');
        setLoading(false);
        return false;
      }
      
      // التحقق من صحة كلمة المرور الحالية
      final user = await _dbHelper.authenticateUser(_currentUser!.email, currentPassword);
      
      if (user == null) {
        setErrorMessage('كلمة المرور الحالية غير صحيحة');
        setLoading(false);
        return false;
      }
      
      // تحديث كلمة المرور
      final updatedUser = _currentUser!.copyWith(password: newPassword);
      final result = await _dbHelper.updateUser(updatedUser);
      
      if (result > 0) {
        _currentUser = updatedUser;
        notifyListeners();
        setLoading(false);
        return true;
      } else {
        setErrorMessage('فشل في تحديث كلمة المرور');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setErrorMessage('حدث خطأ أثناء تغيير كلمة المرور: $e');
      setLoading(false);
      return false;
    }
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