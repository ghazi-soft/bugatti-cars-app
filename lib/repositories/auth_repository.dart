import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/supabase_repository.dart';
import '../models/user_model.dart';

class AuthRepository {
  final supabase.SupabaseClient _client = SupabaseRepository.client;

  // ---------------- SIGN UP ----------------
  Future<User> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': 'user',
      },
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw Exception('فشل التسجيل');
    }

    await _client.from('users').insert({
      'id': user.id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': 'user',
      'is_active': true,
    });

    await _saveSession(session.accessToken, user.id, 'user');

    return User(
      id: user.id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: '',
      role: 'user',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // ---------------- SIGN IN ----------------
  Future<User> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw Exception('بيانات الدخول غير صحيحة');
    }

    final data =
        await _client.from('users').select('*').eq('id', user.id).single();

    await _saveSession(
      session.accessToken,
      user.id,
      data['role'] ?? 'user',
    );

    return User.fromJson(Map<String, dynamic>.from(data));
  }

  // ---------------- SIGN OUT ----------------
  Future<void> signOut() async {
    await _client.auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
  }

  // ---------------- CURRENT USER ----------------
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      final data =
          await _client.from('users').select('*').eq('id', userId).single();

      return User.fromJson(Map<String, dynamic>.from(data));
    }

    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data =
        await _client.from('users').select('*').eq('id', user.id).single();

    return User.fromJson(Map<String, dynamic>.from(data));
  }

  // ---------------- CHECK LOGIN ----------------
  Future<bool> isLoggedIn() async {
    return _client.auth.currentSession != null;
  }

  // ---------------- RESET PASSWORD ----------------
  Future<void> sendResetPasswordEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> resetPassword(String email) async {
    await sendResetPasswordEmail(email);
  }

  // ---------------- SAVE SESSION ----------------
  Future<void> _saveSession(String token, String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
  }
}
