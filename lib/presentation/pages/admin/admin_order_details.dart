import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminOrderDetailsScreen extends ConsumerWidget {
  final int orderId;

  const AdminOrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #$orderId'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == orderId,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppDimensions.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  'معلومات العميل',
                  [
                    _buildInfoRow(
                      'الاسم',
                      '${order.firstName} ${order.lastName}',
                    ),
                    _buildInfoRow(
                      'البريد',
                      order.email,
                    ),
                    _buildInfoRow(
                      'الهاتف',
                      order.phone,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSection(
                  'تفاصيل الطلب',
                  [
                    _buildInfoRow(
                      'رقم السيارة',
                      order.carId.toString(),
                    ),
                    _buildInfoRow(
                      'الإجمالي',
                      '\$${order.total}',
                    ),
                    _buildInfoRow(
                      'التاريخ',
                      order.createdAt
                          .toString()
                          .split(' ')[0],
                    ),
                    _buildInfoRow(
                      'الحالة',
                      order.status,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildSection(
                  'ملاحظات',
                  [
                    Text(
                      order.notes ?? 'لا توجد ملاحظات',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: custom.CustomButton(
                        label: 'قبول الطلب',
                        backgroundColor: AppColors.success,
                        onPressed: () => _updateStatus(
                          ref,
                          context,
                          'completed',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: custom.CustomButton(
                        label: 'إلغاء الطلب',
                        backgroundColor: AppColors.error,
                        onPressed: () => _updateStatus(
                          ref,
                          context,
                          'cancelled',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) =>
            custom.ErrorWidget(error: err.toString()),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _updateStatus(
    WidgetRef ref,
    BuildContext context,
    String status,
  ) async {
    try {
      await ref
          .read(orderRepositoryProvider)
          .updateOrderStatus(orderId, status);

      ref
          .read(orderListProvider.notifier)
          .loadOrders();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
        ),
      );
    }
  }
}