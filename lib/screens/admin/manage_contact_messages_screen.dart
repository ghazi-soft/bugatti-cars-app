import 'package:flutter/material.dart';
import '../../models/contact_message_model.dart';
import '../../repositories/contact_repository.dart';

class ManageContactMessagesScreen extends StatefulWidget {
  const ManageContactMessagesScreen({Key? key}) : super(key: key);

  @override
  State<ManageContactMessagesScreen> createState() =>
      _ManageContactMessagesScreenState();
}

class _ManageContactMessagesScreenState
    extends State<ManageContactMessagesScreen> {
  final ContactRepository contactRepository = ContactRepository();
  List<ContactMessage> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await contactRepository.getContactMessages();
      setState(() {
        messages = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _showMessageDetails(dynamic message) {
    showDialog(
      context: context,
      builder: (context) => MessageDetailsDialog(message: message),
    );
  }

  Future<void> _deleteMessage(int messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await contactRepository.deleteContactMessage(messageId);
                Navigator.pop(context);
                _loadMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الرسالة بنجاح')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ: $e')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رسائل التواصل'),
        backgroundColor: Colors.red[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
              ? const Center(
                  child: Text('لا توجد رسائل'),
                )
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageItem(message);
                  },
                ),
    );
  }

  Widget _buildMessageItem(dynamic message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['full_name'] ?? 'بدون اسم',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['email'] ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMessage(message['id']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (message['subject'] != null)
              Text(
                'الموضوع: ${message['subject']}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              message['message'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 13,
                color:  Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (message['phone'] != null)
                  Text(
                    'الهاتف: ${message['phone']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                GestureDetector(
                  onTap: () => _showMessageDetails(message),
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog لعرض تفاصيل الرسالة
class MessageDetailsDialog extends StatelessWidget {
  final dynamic message;

  const MessageDetailsDialog({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تفاصيل الرسالة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الاسم:', message['full_name'] ?? '-'),
            _buildDetailRow('البريد:', message['email'] ?? '-'),
            if (message['phone'] != null)
              _buildDetailRow('الهاتف:', message['phone']),
            if (message['subject'] != null)
              _buildDetailRow('الموضوع:', message['subject']),
            _buildDetailRow(
              'التاريخ:',
              message['created_at'] != null
                  ? message['created_at'].toString().split('.')[0]
                  : '-',
            ),
            const SizedBox(height: 15),
            const Text(
              'الرسالة:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message['message'] ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}