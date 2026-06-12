import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService supabase = SupabaseService();

  // تسجيل مستخدم جديد
  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      await supabase.signUp(email, password, firstName, lastName);
      return true;
    } catch (e) {
      throw Exception('Registration Error: $e');
    }
  }

  // تسجيل دخول
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final userData = await supabase.signIn(email, password);
      return userData;
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  // تسجيل خروج
  Future<void> logout() async {
    try {
      await supabase.signOut();
    } catch (e) {
      throw Exception('Logout Error: $e');
    }
  }

  // الحصول على المستخدم الحالي
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) return null;

      final response = await supabase.get('users?id=eq.$userId');
      return response.isNotEmpty ? response[0] : null;
    } catch (e) {
      throw Exception('Get User Error: $e');
    }
  }

  // التحقق من تسجيل الدخول
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') != null;
    } catch (e) {
      return false;
    }
  }

  // الحصول على الدور
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_role');
    } catch (e) {
      return null;
    }
  }

  // هل المستخدم أدمن؟
  Future<bool> isAdmin() async {
    try {
      final role = await getUserRole();
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }
}
