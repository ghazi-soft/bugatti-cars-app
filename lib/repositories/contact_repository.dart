import '../models/contact_message_model.dart';
import '../repositories/supabase_repository.dart';

class ContactRepository {
  final supabase = SupabaseRepository.client;

  // ---------------- SEND MESSAGE ----------------
  Future<ContactMessage> sendContactMessage({
    required String fullName,
    required String email,
    required String phone,
    String? subject,
    required String message,
  }) async {
    try {
      final data = await supabase
          .from('contact_messages')
          .insert({
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'subject': subject,
            'message': message,
            'source': 'mobile_app',
          })
          .select()
          .single();

      return ContactMessage.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception('Failed to send contact message: $e');
    }
  }

  // ---------------- GET MESSAGES ----------------
  Future<List<ContactMessage>> getContactMessages() async {
    try {
      final data = await supabase
          .from('contact_messages')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => ContactMessage.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to load contact messages: $e');
    }
  }

  // ---------------- DELETE MESSAGE ----------------
  Future<void> deleteContactMessage(int messageId) async {
    try {
      await supabase
          .from('contact_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}