import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // بيانات Supabase
  static const String projectUrl =
      'https://kkyvcvlwypdllbbofygq.supabase.co';

  static const String anonKey =
      'sb_publishable_PAF0A2kcC7nWzn1iUwhqLA_6CLwDpnT';

  // تهيئة Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: projectUrl,
      anonKey: anonKey,
    );
  }

  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Headers للـ API
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
      };

  // GET Request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$projectUrl/rest/v1/$endpoint');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$projectUrl/rest/v1/$endpoint');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // UPDATE Request
  Future<dynamic> update(
    String endpoint,
    Map<String, dynamic> body,
    String filter,
  ) async {
    try {
      final url = Uri.parse('$projectUrl/rest/v1/$endpoint?$filter');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // DELETE Request
  Future<void> delete(String endpoint, String filter) async {
    try {
      final url = Uri.parse('$projectUrl/rest/v1/$endpoint?$filter');

      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // Auth - Sign Up
  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final url = Uri.parse('$projectUrl/auth/v1/signup');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userId = data['user']['id'];

        await post('users', {
          'id': userId,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': 'user',
        });

        final prefs = await SharedPreferences.getInstance();

        if (data['session'] != null) {
          await prefs.setString(
            'auth_token',
            data['session']['access_token'],
          );
        }

        await prefs.setString('user_id', userId);
        await prefs.setString('user_role', 'user');

        return data;
      } else {
        throw Exception(
          'Error: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Sign Up Error: $e');
    }
  }

  // Auth - Sign In
  Future<Map<String, dynamic>> signIn(
    String email,
    String password,
  ) async {
    try {
      final url =
          Uri.parse('$projectUrl/auth/v1/token?grant_type=password');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final userId = data['user']['id'];

        final userResponse = await get('users?id=eq.$userId');

        final userData =
            (userResponse is List && userResponse.isNotEmpty)
                ? userResponse.first
                : {};

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'auth_token',
          data['access_token'] ?? '',
        );

        await prefs.setString('user_id', userId);

        await prefs.setString(
          'user_role',
          userData['role'] ?? 'user',
        );

        return Map<String, dynamic>.from(userData);
      } else {
        throw Exception(
          'Login Failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_role');
    } catch (e) {
      throw Exception('Sign Out Error: $e');
    }
  }
}