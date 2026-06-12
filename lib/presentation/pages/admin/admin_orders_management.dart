import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminOrdersManagement extends ConsumerWidget {
  const AdminOrdersManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الطلبات')),
      body: ordersAsync.when(
        data: (orders) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('طلب #${order.id} - ${order.firstName}', style: AppTextStyles.titleLarge),
                  subtitle: Text('إجمالي: \$${order.total} | ${order.status}', style: AppTextStyles.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrderDetails, arguments: order.id),
                ),
              );
            },
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }
}
