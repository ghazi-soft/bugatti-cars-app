import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;
import '../../../models/chat_message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int? orderId;
  const ChatScreen({Key? key, this.orderId}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(chatMessagesProvider.notifier).loadMessages(orderId: widget.orderId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(userProvider).value;
    if (user == null) return;

    _messageController.clear();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            orderId: widget.orderId,
            userId: user.id,
            senderName: '${user.firstName} ${user.lastName}',
            content: content,
          );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الإرسال: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderId != null ? 'دردشة الطلب #${widget.orderId}' : 'الدعم الفني'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const custom.EmptyWidget(message: 'ابدأ المحادثة الآن', icon: Icons.chat_bubble_outline);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.userId == ref.read(userProvider).value?.id;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
              loading: () => const custom.LoadingWidget(),
              error: (err, stack) => custom.ErrorWidget(error: err.toString()),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(message.senderName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              ),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              backgroundColor: isMe ? AppColors.primary.withOpacity(0.2) : AppColors.surface.withOpacity(0.5),
              child: Text(message.content, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${message.createdAt.hour}:${message.createdAt.minute}',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.dark,
        border: Border(top: BorderSide(color: AppColors.borderLight.withOpacity(0.5))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: custom.CustomTextField(
                label: 'اكتب رسالتك...',
                controller: _messageController,
                hint: 'اكتب هنا...',
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: AppColors.primary,
              mini: true,
              child: const Icon(Icons.send, color: AppColors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
