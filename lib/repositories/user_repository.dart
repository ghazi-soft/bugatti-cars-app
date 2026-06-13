import '../models/user_model.dart';
import '../repositories/supabase_repository.dart';

class UserRepository {
  final supabase = SupabaseRepository.client;

  // ============================================================
  // GET ALL USERS (Admin Only)
  // ============================================================
  
  Future<List<User>> getAllUsers() async {
    try {
      final data = await supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => User.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل المستخدمين: $e');
    }
  }

  // ============================================================
  // GET USER BY ID (Admin Only)
  // ============================================================
  
  Future<User> getUserById(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception('معرف المستخدم غير صحيح');
      }

      final data = await supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return User.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل تحميل المستخدم: $e');
    }
  }

  // ============================================================
  // UPDATE USER ROLE (Admin Only)
  // ============================================================
  
  Future<void> updateUserRole(int userId, String role) async {
    try {
      if (userId <= 0) {
        throw Exception('معرف المستخدم غير صحيح');
      }

      const validRoles = ['user', 'admin'];
      if (!validRoles.contains(role)) {
        throw Exception('دور غير صحيح');
      }

      await supabase
          .from('users')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل تحديث الدور: $e');
    }
  }

  // ============================================================
  // UPDATE USER ACTIVE STATUS (Admin Only)
  // ============================================================
  
  Future<void> updateUserActiveStatus(int userId, bool isActive) async {
    try {
      if (userId <= 0) {
        throw Exception('معرف المستخدم غير صحيح');
      }

      await supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل تحديث حالة الحساب: $e');
    }
  }

  // ============================================================
  // DELETE USER (Admin Only)
  // ============================================================
  
  Future<void> deleteUser(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception('معرف المستخدم غير صحيح');
      }

      // حذف الطلبات أولاً
      await supabase
          .from('orders')
          .delete()
          .eq('user_id', userId);

      // ثم حذف الرسائل
      await supabase
          .from('chat_messages')
          .delete()
          .eq('user_id', userId);

      // ثم حذف المستخدم
      await supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل حذف المستخدم: $e');
    }
  }

  // ============================================================
  // COUNT USERS
  // ============================================================
  
  Future<int> countUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('*', const FetchOptions(count: CountOption.exact));

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // COUNT ACTIVE USERS
  // ============================================================
  
  Future<int> countActiveUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('is_active', true);

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // COUNT ADMIN USERS
  // ============================================================
  
  Future<int> countAdminUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('role', 'admin');

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}