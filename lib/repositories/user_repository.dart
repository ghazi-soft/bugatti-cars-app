import '../models/user_model.dart';
import '../repositories/supabase_repository.dart';

class UserRepository {
  final supabase = SupabaseRepository.client;

  // ---------------- GET ALL USERS ----------------
  Future<List<User>> getAllUsers() async {
    try {
      final data = await supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => User.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // ---------------- UPDATE ACTIVE STATUS ----------------
  Future<void> updateUserActiveStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      await supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}