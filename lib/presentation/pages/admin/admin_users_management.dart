import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminUsersManagement extends ConsumerWidget {
  const AdminUsersManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we would have a usersProvider
    final userRepository = ref.watch(userRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: FutureBuilder(
        future: userRepository.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const custom.LoadingWidget();
          if (snapshot.hasError) return custom.ErrorWidget(error: snapshot.error.toString());
          
          final users = snapshot.data as List;
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(user.firstName[0].toUpperCase(), style: const TextStyle(color: AppColors.dark)),
                  ),
                  title: Text('${user.firstName} ${user.lastName}', style: AppTextStyles.titleLarge),
                  subtitle: Text(user.email, style: AppTextStyles.bodySmall),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (val) async {
                      await userRepository.updateUserActiveStatus(user.id, val);
                      // Trigger rebuild
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
