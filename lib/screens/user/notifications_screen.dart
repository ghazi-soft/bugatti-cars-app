import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'تم تحديث حالة الطلب',
        'subtitle': 'طلبك رقم 12 أصبح قيد التنفيذ.',
        'time': 'قبل 3 ساعات',
      },
      {
        'title': 'رسالة جديدة من الدعم',
        'subtitle': 'فريقنا أرسل لك رسالة جديدة.',
        'time': 'قبل 5 ساعات',
      },
      {
        'title': 'عرض خاص على سيارة Bugatti',
        'subtitle': 'احصل على خصم على عدد محدد من المركبات.',
        'time': 'أمس',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF111827),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(item['subtitle']!, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text(item['time']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: notifications.length,
      ),
    );
  }
}
