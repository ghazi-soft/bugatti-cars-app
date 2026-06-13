import '../models/contact_message_model.dart';
import '../repositories/supabase_repository.dart';
import '../services/validation_service.dart';

class ContactRepository {
  final supabase = SupabaseRepository.client;

  // ============================================================
  // SEND CONTACT MESSAGE - مع التحقق من البيانات
  // ============================================================
  
  Future<ContactMessage> sendContactMessage({
    required String fullName,
    required String email,
    required String phone,
    String? subject,
    required String message,
  }) async {
    // ============ التحقق من البيانات (نفس قواعس Go) ============
    
    final validationError = ValidationService.validateContactMessage(
      fullName,
      email,
      phone,
      subject ?? '',
      message,
    );

    if (validationError != null) {
      throw Exception(validationError);
    }

    // تنظيف البيانات
    final cleanName = ValidationService.sanitizeInput(fullName);
    final cleanEmail = email.toLowerCase().trim();
    final cleanPhone = phone.trim();
    final cleanSubject = subject != null 
        ? ValidationService.sanitizeInput(subject) 
        : '';
    final cleanMessage = ValidationService.sanitizeInput(message);

    try {
      final data = await supabase
          .from('contact_messages')
          .insert({
            'full_name': cleanName,
            'email': cleanEmail,
            'phone': cleanPhone,
            'subject': cleanSubject.isEmpty ? null : cleanSubject,
            'message': cleanMessage,
            'source': 'mobile_app',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return ContactMessage.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  // ============================================================
  // GET ALL CONTACT MESSAGES (Admin Only)
  // ============================================================
  
  Future<List<ContactMessage>> getContactMessages() async {
    try {
      final data = await supabase
          .from('contact_messages')
          .select('*')
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => ContactMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الرسائل: $e');
    }
  }

  // ============================================================
  // GET CONTACT MESSAGES BY SOURCE
  // ============================================================
  
  Future<List<ContactMessage>> getContactMessagesBySource(String source) async {
    try {
      final validSources = ['mobile_app', 'web_app', 'email'];
      if (!validSources.contains(source)) {
        throw Exception('مصدر غير صحيح');
      }

      final data = await supabase
          .from('contact_messages')
          .select('*')
          .eq('source', source)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => ContactMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الرسائل: $e');
    }
  }

  // ============================================================
  // GET CONTACT MESSAGE BY ID (Admin Only)
  // ============================================================
  
  Future<ContactMessage> getContactMessageById(int messageId) async {
    try {
      if (messageId <= 0) {
        throw Exception('معرف الرسالة غير صحيح');
      }

      final data = await supabase
          .from('contact_messages')
          .select('*')
          .eq('id', messageId)
          .single();

      return ContactMessage.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل تحميل الرسالة: $e');
    }
  }

  // ============================================================
  // DELETE CONTACT MESSAGE (Admin Only)
  // ============================================================
  
  Future<void> deleteContactMessage(int messageId) async {
    try {
      if (messageId <= 0) {
        throw Exception('معرف الرسالة غير صحيح');
      }

      await supabase
          .from('contact_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('فشل حذف الرسالة: $e');
    }
  }

  // ============================================================
  // COUNT CONTACT MESSAGES
  // ============================================================
  
  Future<int> countContactMessages() async {
    try {
      final response = await supabase
          .from('contact_messages')
          .select('*', const FetchOptions(count: CountOption.exact));

      return response.count;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // COUNT UNREAD MESSAGES (optional)
  // ============================================================
  
  Future<int> countUnreadMessages() async {
    try {
      // إذا كان لديك حقل is_read في قاعدة البيانات
      final response = await supabase
          .from('contact_messages')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('is_read', false);

      return response.count;
    } catch (e) {
      return 0;
    }
  }
}