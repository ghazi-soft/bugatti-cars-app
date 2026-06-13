import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/supabase_repository.dart';
import '../models/user_model.dart';
import '../services/validation_service.dart';

class AuthRepository {
  final supabase.SupabaseClient _client = SupabaseRepository.client;

  // ============================================================
  // SIGN UP - مع تطبيق نفس القواعد من Go Backend
  // ============================================================
  
  Future<User> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    // ============ التحقق من البيانات ============
    
    // إزالة المسافات
    final cleanFirstName = ValidationService.sanitizeInput(firstName);
    final cleanLastName = ValidationService.sanitizeInput(lastName);
    final cleanEmail = email.toLowerCase().trim();

    // التحقق من وجود البيانات المطلوبة
    if (cleanFirstName.isEmpty || cleanLastName.isEmpty || 
        cleanEmail.isEmpty || password.isEmpty) {
      throw Exception('جميع الحقول مطلوبة');
    }

    // التحقق من البريد الإلكتروني
    if (!ValidationService.isValidEmail(cleanEmail)) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    // التحقق من كلمة المرور
    if (!ValidationService.isValidPassword(password)) {
      throw Exception('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }

    // التحقق من أسماء الأحرف
    if (!ValidationService.isValidName(cleanFirstName)) {
      throw Exception('الاسم الأول غير صحيح');
    }
    if (!ValidationService.isValidName(cleanLastName)) {
      throw Exception('اسم العائلة غير صحيح');
    }

    try {
      // إنشاء المستخدم في Supabase Auth
      final response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'first_name': cleanFirstName,
          'last_name': cleanLastName,
          'role': 'user',
        },
      );

      final session = response.session;
      final user = response.user;

      if (session == null || user == null) {
        throw Exception('فشل التسجيل');
      }

      // إنشاء سجل المستخدم في قاعدة البيانات
      try {
        await _client.from('users').insert({
          'id': user.id,
          'email': cleanEmail,
          'first_name': cleanFirstName,
          'last_name': cleanLastName,
          'phone': '',
          'role': 'user',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // إذا كان البريد موجود بالفعل
        await _client.auth.signOut();
        throw Exception('البريد الإلكتروني موجود بالفعل');
      }

      // حفظ الجلسة
      await _saveSession(session.accessToken, user.id, 'user');

      return User(
        id: int.parse(user.id),
        email: cleanEmail,
        firstName: cleanFirstName,
        lastName: cleanLastName,
        phone: '',
        role: 'user',
        isActive: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('خطأ في التسجيل: $e');
    }
  }

  // ============================================================
  // SIGN IN - مع تطبيق نفس القواعد من Go Backend
  // ============================================================
  
  Future<User> signIn(String email, String password) async {
    // ============ التحقق من البيانات ============
    
    final cleanEmail = email.toLowerCase().trim();

    if (!ValidationService.isValidEmail(cleanEmail)) {
      throw Exception('البريد الإلكتروني غير صحيح');
    }

    if (password.isEmpty || password.length > 128) {
      throw Exception('بيانات الدخول غير صحيحة');
    }

    try {
      // محاولة تسجيل الدخول
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final session = response.session;
      final user = response.user;

      if (session == null || user == null) {
        throw Exception('بيانات الدخول غير صحيحة');
      }

      // الحصول على بيانات المستخدم من قاعدة البيانات
      final data = await _client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();

      // ============ التحقق من حالة الحساب ============
      
      final userData = Map<String, dynamic>.from(data);
      final isActive = userData['is_active'] ?? true;

      if (!isActive) {
        // الحساب معطل
        await _client.auth.signOut();
        throw Exception('ACCOUNT_DISABLED');
      }

      // حفظ الجلسة
      await _saveSession(
        session.accessToken,
        user.id,
        userData['role'] ?? 'user',
      );

      return User.fromJson(userData);
    } on supabase.AuthException catch (e) {
      // رسالة آمنة - لا نكشف إذا كان البريد موجود أم لا
      throw Exception('بيانات الدخول غير صحيحة');
    } catch (e) {
      if (e.toString().contains('ACCOUNT_DISABLED')) {
        rethrow;
      }
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================
  
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_role');
    } catch (e) {
      throw Exception('خطأ في تسجيل الخروج: $e');
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================
  
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null) {
        final data = await _client
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        final userData = Map<String, dynamic>.from(data);
        
        // ============ التحقق من حالة الحساب ============
        final isActive = userData['is_active'] ?? true;
        if (!isActive) {
          // الحساب معطل - قم بتسجيل الخروج
          await signOut();
          return null;
        }

        return User.fromJson(userData);
      }

      // محاولة الحصول على المستخدم الحالي من Supabase Auth
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();

      return User.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================
  
  Future<bool> isLoggedIn() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return false;

      // التحقق من أن المستخدم فعال
      final user = await getCurrentUser();
      return user != null && user.isActive;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CHECK ADMIN
  // ============================================================
  
  Future<bool> isAdmin() async {
    try {
      final user = await getCurrentUser();
      return user != null && user.isAdmin;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================
  
  Future<void> sendResetPasswordEmail(String email) async {
    try {
      final cleanEmail = email.toLowerCase().trim();

      if (!ValidationService.isValidEmail(cleanEmail)) {
        throw Exception('البريد الإلكتروني غير صحيح');
      }

      await _client.auth.resetPasswordForEmail(cleanEmail);
    } catch (e) {
      throw Exception('خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    await sendResetPasswordEmail(email);
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================
  
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!ValidationService.isValidPassword(newPassword)) {
        throw Exception('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      }

      await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('خطأ في تحديث كلمة المرور: $e');
    }
  }

  // ============================================================
  // UPDATE USER PROFILE
  // ============================================================
  
  Future<User> updateUserProfile(
    String firstName,
    String lastName,
    String phone,
  ) async {
    try {
      final cleanFirstName = ValidationService.sanitizeInput(firstName);
      final cleanLastName = ValidationService.sanitizeInput(lastName);
      final cleanPhone = phone.trim();

      // التحقق من البيانات
      if (!ValidationService.isValidName(cleanFirstName)) {
        throw Exception('الاسم الأول غير صحيح');
      }
      if (!ValidationService.isValidName(cleanLastName)) {
        throw Exception('اسم العائلة غير صحيح');
      }
      if (!ValidationService.isValidPhone(cleanPhone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }

      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // تحديث البيانات
      await _client.from('users').update({
        'first_name': cleanFirstName,
        'last_name': cleanLastName,
        'phone': cleanPhone,
      }).eq('id', user.id);

      // الحصول على البيانات المحدثة
      final data = await _client
          .from('users')
          .select('*')
          .eq('id', user.id)
          .single();

      return User.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('خطأ في تحديث البيانات: $e');
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  
  Future<void> _saveSession(String token, String userId, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userId);
      await prefs.setString('user_role', role);
    } catch (e) {
      throw Exception('خطأ في حفظ الجلسة: $e');
    }
  }

  /// الحصول على التوكن المحفوظ
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  /// الحصول على دور المستخدم
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_role');
    } catch (e) {
      return null;
    }
  }
}
