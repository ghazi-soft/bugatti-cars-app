import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF111827),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('خيارات التطبيق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildOptionTile(context, 'تغيير اللغة', 'العربية', onTap: () {}),
                const Divider(color: Colors.white12),
                _buildOptionTile(context, 'الدعم الفني', 'info@bugatti.cars', onTap: () {}),
                const Divider(color: Colors.white12),
                _buildOptionTile(context, 'سياسة الخصوصية', '', onTap: () {}),
                const Divider(color: Colors.white12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
                  onTap: () async {
  await ref.read(authRepositoryProvider).signOut();

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, String subtitle, {required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
      onTap: onTap,
    );
  }
}
