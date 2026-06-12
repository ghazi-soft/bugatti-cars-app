import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        children: [
          _buildSectionHeader('عام'),
          _buildSettingItem(Icons.language, 'اللغة', 'العربية', () {}),
          _buildSettingItem(Icons.dark_mode_outlined, 'المظهر', 'داكن', () {}),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildSectionHeader('الحساب والأمان'),
          _buildSettingItem(Icons.lock_outline, 'تغيير كلمة المرور', '', () {}),
          _buildSettingItem(Icons.privacy_tip_outlined, 'سياسة الخصوصية', '', () {}),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildSectionHeader('عن التطبيق'),
          _buildSettingItem(Icons.info_outline, 'الإصدار', '1.0.0', () {}),
          _buildSettingItem(Icons.star_outline, 'تقييم التطبيق', '', () {}),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String value, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: AppColors.textSecondary),
          title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.isNotEmpty)
                Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
