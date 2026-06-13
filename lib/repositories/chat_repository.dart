import '../models/chat_message_model.dart';
import '../repositories/supabase_repository.dart';
import '../services/validation_service.dart';

class ChatRepository {
  final supabase = SupabaseRepository.client;

  // ============================================================
  // GET CHAT MESSAGES
  // ============================================================
  
  Future<List<ChatMessage>> getMessages({int? orderId}) async {
    try {
      var query = supabase.from('chat_messages').select('*');
      
      if (orderId != null && orderId > 0) {
        query = query.eq('order_id', orderId);
      }
      
      final data = await query.order('created_at', ascending: true);

      return (data as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الرسائل: $e');
    }
  }

  // ============================================================
  // SEND CHAT MESSAGE - مع التحقق من البيانات
  // ============================================================
  
  Future<ChatMessage> sendMessage({
    int? orderId,
    required int userId,
    required String senderName,
    required String content,
  }) async {
    // ============ التحقق من البيانات (نفس قواعس Go) ============
    
    if (userId <= 0) {
      throw Exception('معرف المستخدم غير صحيح');
    }

    final validationError = ValidationService.validateChatMessage(content);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final cleanSenderName = ValidationService.sanitizeInput(senderName);
    final cleanContent = ValidationService.sanitizeInput(content);

    try {
      final data = await supabase
          .from('chat_messages')
          .insert({
            'order_id': orderId,
            'user_id': userId,
            'sender_name': cleanSenderName,
            'content': cleanContent,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return ChatMessage.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  // ============================================================
  // GET ORDER CHAT MESSAGES
  // ============================================================
  
  Future<List<ChatMessage>> getOrderChatMessages(int orderId) async {
    try {
      if (orderId <= 0) {
        throw Exception('معرف الطلب غير صحيح');
      }

      final data = await supabase
          .from('chat_messages')
          .select('*')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);

      return (data as List)
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception('فشل تحميل الرسائل: $e');
    }
  }

  // ============================================================
  // DELETE CHAT MESSAGE (Admin Only)
  // ============================================================
  
  Future<void> deleteChatMessage(int messageId) async {
    try {
      if (messageId <= 0) {
        throw Exception('معرف الرسالة غير صحيح');
      }

      await supabase
          .from('chat_messages')
          .delete()
          .eq('id', messageId);
    } catch (e) {
      throw Exception('فشل حذف الرسالة: $e');
    }
  }

  // ---------------- STREAM MESSAGES ----------------
  Stream<List<ChatMessage>> streamMessages({int? orderId}) {
    var stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true);

    if (orderId != null) {
      stream = stream.eq('order_id', orderId);
    }

    return stream.map((event) {
      return event
          .map((item) => ChatMessage.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    });
  }
}