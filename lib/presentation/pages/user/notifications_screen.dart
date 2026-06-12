import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'مرحباً بك في بوقاتي كارز',
        'body': 'استكشف أحدث السيارات الفاخرة المتاحة الآن في صالة العرض.',
        'time': 'منذ ساعتين',
        'isRead': false,
      },
      {
        'title': 'تحديث حالة الطلب',
        'body': 'تم قبول طلبك رقم #1024، سيتواصل معك فريقنا قريباً.',
        'time': 'منذ يوم',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: notifications.isEmpty
          ? const custom.EmptyWidget(message: 'لا توجد إشعارات جديدة', icon: Icons.notifications_none)
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    borderRadius: BorderRadius.circular(16),
                    backgroundColor: notif['isRead'] ? null : AppColors.primary.withOpacity(0.1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif['title'], style: AppTextStyles.titleLarge),
                              const SizedBox(height: 4),
                              Text(notif['body'], style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 8),
                              Text(notif['time'], style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        if (!notif['isRead'])
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
