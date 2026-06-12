import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نظرة عامة', style: AppTextStyles.displaySmall),
            const SizedBox(height: AppDimensions.spacingLarge),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                custom.InfoCard(
                  title: 'إجمالي السيارات',
                  value: '24',
                  icon: Icons.directions_car,
                  color: AppColors.primary,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminCars),
                ),
                custom.InfoCard(
                  title: 'طلبات جديدة',
                  value: '12',
                  icon: Icons.shopping_cart,
                  color: AppColors.success,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
                ),
                custom.InfoCard(
                  title: 'المستخدمين',
                  value: '150',
                  icon: Icons.people,
                  color: AppColors.info,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                ),
                custom.InfoCard(
                  title: 'الرسائل',
                  value: '5',
                  icon: Icons.message,
                  color: AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminMessages),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text('الإجراءات السريعة', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppDimensions.spacingMedium),
            _buildQuickAction(context, Icons.add_circle_outline, 'إضافة سيارة جديدة', AppRoutes.adminAddCar),
            _buildQuickAction(context, Icons.analytics_outlined, 'عرض التقارير', AppRoutes.adminReports),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTextStyles.titleLarge),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
