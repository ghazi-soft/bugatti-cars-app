import 'package:flutter/material.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final int? orderId;

  const ChatScreen({Key? key, this.orderId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository chatRepository = ChatRepository();
  final AuthRepository authRepository = AuthRepository();
  final messageController = TextEditingController();

  List<ChatMessage> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = await authRepository.getCurrentUser();
      setState(() {
        userName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
      });
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await chatRepository.getMessages(orderId: widget.orderId);
      setState(() {
        messages = response;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الرسائل: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      isSending = true;
    });

    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('يجب تسجيل الدخول لإرسال الرسائل');
      }

      await chatRepository.sendMessage(
        orderId: widget.orderId,
        userId: user.id,
        senderName: userName.isNotEmpty ? userName : user.fullName,
        content: text,
      );

      messageController.clear();
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إرسال الرسالة: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text(
          widget.orderId != null ? 'الطلب #${widget.orderId}' : 'الدردشة العامة',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages List
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('لا توجد رسائل بعد'),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - 1 - index];
                            return _buildMessageBubble(message);
                          },
                        ),
                ),

                // Input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        onPressed: isSending ? null : _sendMessage,
                        backgroundColor: Colors.red[700],
                        child: isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isMe = message['sender_name'] == userName;
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.red[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message['sender_name'] ?? 'مستخدم',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['content'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateTime.parse(message['created_at'])
                  .toLocal()
                  .toString()
                  .split('.')[0],
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}