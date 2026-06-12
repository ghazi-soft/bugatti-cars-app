import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const custom.EmptyWidget(message: 'يجب تسجيل الدخول');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: AppDimensions.spacingLarge),
                _buildMenuSection(context),
              ],
            ),
          );
        },
        loading: () => const custom.LoadingWidget(),
        error: (err, stack) => custom.ErrorWidget(error: err.toString()),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.surface,
            child: Text(
              user.firstName[0].toUpperCase(),
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Text('${user.firstName} ${user.lastName}', style: AppTextStyles.displaySmall),
        Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline, 'تعديل الملف الشخصي', () {}),
        _buildMenuItem(Icons.favorite_border, 'المفضلة', () => Navigator.pushNamed(context, AppRoutes.favorites)),
        _buildMenuItem(Icons.shopping_bag_outlined, 'طلباتي', () => Navigator.pushNamed(context, AppRoutes.orders)),
        _buildMenuItem(Icons.notifications_none, 'الإشعارات', () => Navigator.pushNamed(context, AppRoutes.notifications)),
        _buildMenuItem(Icons.settings_outlined, 'الإعدادات', () => Navigator.pushNamed(context, AppRoutes.settings)),
        _buildMenuItem(Icons.help_outline, 'اتصل بنا', () => Navigator.pushNamed(context, AppRoutes.contactUs)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: AppTextStyles.titleLarge),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
