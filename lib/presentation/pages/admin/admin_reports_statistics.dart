import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../widgets/glass_container.dart';

class AdminReportsStatistics extends StatelessWidget {
  const AdminReportsStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('إجمالي المبيعات', '\$12,450,000', Icons.monetization_on, AppColors.success),
            const SizedBox(height: 16),
            _buildStatCard('الطلبات المكتملة', '45', Icons.check_circle, AppColors.info),
            const SizedBox(height: 16),
            _buildStatCard('أكثر سيارة طلباً', 'Chiron Super Sport', Icons.star, AppColors.primary),
            const SizedBox(height: 24),
            Text('النمو الشهري', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            GlassContainer(
              height: 200,
              width: double.infinity,
              child: const Center(child: Text('مخطط بياني (قريباً)', style: TextStyle(color: AppColors.textTertiary))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(value, style: AppTextStyles.displaySmall.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
