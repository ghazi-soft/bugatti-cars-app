import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        elevation: 0,
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =========== Hero Section ===========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[700],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'أثناء القيادة نحو المستقبل',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'اكتشف عالم التميز',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'الخيالي',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[300],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'هنا في بوقاتي كار، ندمج الأناقة التقنية مع تجربة مستخدم سريعة وممتعة، ونبني لكل عميل رحلة مميزة في عالم السيارات الفاخرة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // الوسوم
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white20,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🚀 أداء فائق',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white20,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✨ تصميم متألق',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white20,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🔒 ضمان الثقة',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // =========== Highlights Section ===========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                children: [
                  _HighlightCard(
                    title: 'شغف في كل رحلة',
                    description: 'نقدّم أفضل الخيارات المستوردة والمحلية مع تجربة شراء سلسة تبدأ من أول نقرة.',
                    color: Colors.red[700]!,
                    delay: 0,
                  ),
                  const SizedBox(height: 15),
                  _HighlightCard(
                    title: 'خدمة بخبرة',
                    description: 'فريقنا يجد لك السيارة المناسبة ويضمن لك شروط بيع واضحة وأسعار تنافسية.',
                    color: Colors.amber[700]!,
                    delay: 100,
                  ),
                  const SizedBox(height: 15),
                  _HighlightCard(
                    title: 'رحلة غير منتهية',
                    description: 'تصميم الصفحة والتفاعل هنا مصنوع ليجعل تجربة الزائر أكثر إشراقًا وحيوية.',
                    color: Colors.red[700]!,
                    delay: 200,
                  ),
                ],
              ),
            ),

            // =========== Stats Section ===========
            Container(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _StatCard(
                        number: '+5000',
                        label: 'عميل راضي',
                        delay: 100,
                      ),
                      _StatCard(
                        number: '+2000',
                        label: 'سيارة مباعة',
                        delay: 200,
                      ),
                      _StatCard(
                        number: '+100',
                        label: 'ماركة عالمية',
                        delay: 300,
                      ),
                      _StatCard(
                        number: '24/7',
                        label: 'دعم فني',
                        delay: 400,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========== Team Section ===========
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'نخبة القيادة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'الفريق الذي يقود بوقاتي كار نحو مستقبل أكثر تألقًا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      _TeamMemberCard(
                        name: 'المهندس: عبدالله غازي',
                        role: 'المدير العام',
                        icon: '👨‍💻',
                        color: Colors.red[700]!,
                      ),
                      const SizedBox(height: 15),
                      _TeamMemberCard(
                        name: 'المهندس: محمد غازي',
                        role: 'مدير المبيعات',
                        icon: '👨‍💼',
                        color: Colors.amber[700]!,
                      ),
                      const SizedBox(height: 15),
                      _TeamMemberCard(
                        name: 'المصمم: علي الصماط',
                        role: 'المصمم المتألق',
                        icon: '👨‍💻',
                        color: Colors.red[700]!,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// =========== Highlight Card Widget ===========
class _HighlightCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final int delay;

  const _HighlightCard({
    required this.title,
    required this.description,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// =========== Stat Card Widget ===========
class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final int delay;

  const _StatCard({
    required this.number,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[700]?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[700]!.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// =========== Team Member Card Widget ===========
class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String icon;
  final Color color;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              icon,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
