import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;
import '../../../models/order_model.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const custom.EmptyWidget(
              message: 'لم تقم بإجراء أي طلبات بعد',
              icon: Icons.shopping_bag_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(orderListProvider.notifier).loadOrders(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMedium),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طلب #${order.id}', style: AppTextStyles.titleLarge),
                _buildStatusBadge(order.status),
              ],
            ),
            const Divider(color: AppColors.borderLight, height: 24),
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('السيارة: ${order.carId}', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('الإجمالي: \$${order.total.toStringAsFixed(0)}', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to order details
                  },
                  child: const Text('عرض التفاصيل'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.chat, arguments: order.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.dark,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('تواصل معنا'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = AppColors.warning;
        text = 'قيد الانتظار';
        break;
      case 'completed':
        color = AppColors.success;
        text = 'مكتمل';
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'ملغي';
        break;
      default:
        color = AppColors.info;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
