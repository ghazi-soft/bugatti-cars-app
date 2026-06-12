import '../models/chat_message_model.dart';
import '../repositories/supabase_repository.dart';

class ChatRepository {
  final supabase = SupabaseRepository.client;

  // ---------------- GET MESSAGES ----------------
  Future<List<ChatMessage>> getMessages({int? orderId}) async {
  try {
    var query = supabase.from('chat_messages').select('*');
    
    if (orderId != null) {
      query = query.eq('order_id', orderId);
    }
    
    final data = await query.order('created_at', ascending: true);
    final list = (data as List);
    final filtered = list;

    return filtered
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  } catch (e) {
    throw Exception('Failed to load messages: $e');
  }
}

  // ---------------- SEND MESSAGE ----------------
  Future<ChatMessage> sendMessage({
    int? orderId,
    required String userId,
    required String senderName,
    required String content,
  }) async {
    try {
      final data = await supabase
          .from('chat_messages')
          .insert({
            'order_id': orderId,
            'user_id': userId,
            'sender_name': senderName,
            'content': content,
          })
          .select()
          .single();

      return ChatMessage.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
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