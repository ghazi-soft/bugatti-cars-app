import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/design_system.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final team = [
      {
        'name': 'المهندس: عبدالله غازي',
        'role': 'المدير العام',
        'icon': '👨‍💻',
        'color': AppColors.primary,
      },
      {
        'name': 'المهندس: محمد غازي',
        'role': 'مدير المبيعات',
        'icon': '👨‍💼',
        'color': AppColors.accent,
      },
      {
        'name': 'المصمم: علي الصماط',
        'role': 'المصمم المتألق',
        'icon': '👨‍💻',
        'color': AppColors.primary,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge, vertical: AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildHighlightsSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildStatsSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTeamSection(team),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.18), AppColors.dark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اكتشف عالم التميز', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(
            'هنا في بوقاتي كار، ندمج الأناقة التقنية مع تجربة مستخدم رائعة لتقديم رحلة شراء سيارات فخمة وسلسة.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          Row(
            children: [
              _buildHeroBadge('🚀 أداء فائق'),
              const SizedBox(width: 12),
              _buildHeroBadge('✨ تصميم متألق'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.6)),
        color: AppColors.dark.withOpacity(0.5),
      ),
      child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
    );
  }

  Widget _buildHighlightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نقاط القوة', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(child: _buildHighlightCard('شغف في كل رحلة', 'أفضل الخيارات مع رحلة شراء سلسة', AppColors.primary)),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(child: _buildHighlightCard('خدمة بخبرة', 'فريقنا يضمن لك تجربة شراء موثوقة', AppColors.accent)),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightCard(String title, String subtitle, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Icon(Icons.star_outline, color: color),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('أرقامنا', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(child: _buildStatCard('5000+', 'عميل راضٍ')),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(child: _buildStatCard('2000+', 'سيارة مباعة')),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Row(
          children: [
            Expanded(child: _buildStatCard('100+', 'ماركة عالمية')),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(child: _buildStatCard('24/7', 'دعم فني')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTeamSection(List<Map<String, dynamic>> team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نخبة القيادة', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppDimensions.spacingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3,
            mainAxisSpacing: AppDimensions.spacingMedium,
          ),
          itemCount: team.length,
          itemBuilder: (context, index) {
            final member = team[index];
            return Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: (member['color'] as Color).withOpacity(0.2),
                    child: Text(member['icon'] as String, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: AppDimensions.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(member['name'] as String, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(member['role'] as String, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
