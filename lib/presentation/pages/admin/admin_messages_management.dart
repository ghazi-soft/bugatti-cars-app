import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminMessagesManagement extends ConsumerWidget {
  const AdminMessagesManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactRepo = ref.watch(contactRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الرسائل')),
      body: FutureBuilder(
        future: contactRepo.getContactMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const custom.LoadingWidget();
          if (snapshot.hasError) return custom.ErrorWidget(error: snapshot.error.toString());
          
          final messages = snapshot.data as List;
          if (messages.isEmpty) return const custom.EmptyWidget(message: 'لا توجد رسائل حالياً', icon: Icons.mail_outline);

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: const Icon(Icons.mail, color: AppColors.primary),
                  title: Text(msg.fullName, style: AppTextStyles.titleLarge),
                  subtitle: Text(msg.subject ?? 'بدون موضوع', style: AppTextStyles.bodySmall),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('البريد: ${msg.email}', style: AppTextStyles.bodySmall),
                          const SizedBox(height: 8),
                          Text(msg.message, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => contactRepo.deleteContactMessage(msg.id),
                                child: const Text('حذف', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
