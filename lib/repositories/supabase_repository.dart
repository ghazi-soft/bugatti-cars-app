import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository {
  static const String supabaseUrl =
      'https://kkyvcvlwypdllbbofygq.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_PAF0A2kcC7nWzn1iUwhqLA_6CLwDpnT';
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
