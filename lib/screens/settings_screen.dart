import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import 'forgot_password_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;
  bool emailNotificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        elevation: 0,
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========== Account Section ===========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الحساب',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('الملف الشخصي'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('تغيير كلمة المرور'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('البريد الإلكتروني'),
                            subtitle: user.value?.email ?? 'جاري التحميل...',
                            trailing: const Icon(Icons.lock_outline, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========== Preferences Section ===========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التفضيلات',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('الإخطارات'),
                            subtitle: const Text('اسمح بالإخطارات من التطبيق'),
                            leading: const Icon(Icons.notifications),
                            value: notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                notificationsEnabled = value;
                              });
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          SwitchListTile(
                            title: const Text('إخطارات البريد الإلكتروني'),
                            subtitle: const Text('تلقي تحديثات عبر البريد الإلكتروني'),
                            leading: const Icon(Icons.mail_outline),
                            value: emailNotificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                emailNotificationsEnabled = value;
                              });
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          SwitchListTile(
                            title: const Text('الوضع الليلي'),
                            subtitle: const Text('استخدم الوضع الليلي'),
                            leading: const Icon(Icons.dark_mode),
                            value: darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                darkModeEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========== Help Section ===========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المساعدة والدعم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text('الأسئلة الشائعة'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // TODO: Implement FAQ screen
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: const Text('اتصل بنا'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/contact');
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('سياسة الخصوصية'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // TODO: Implement privacy policy screen
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.article),
                            title: const Text('شروط الخدمة'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // TODO: Implement terms of service screen
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========== About Section ===========
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'عن التطبيق',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('عن بوقاتي كار'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(context, '/about');
                            },
                          ),
                          Divider(color: Colors.grey[300]),
                          ListTile(
                            leading: const Icon(Icons.code),
                            title: const Text('إصدار التطبيق'),
                            trailing: const Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========== Danger Zone ===========
              if (user.value?.isAdmin == false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'منطقة الخطر',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: Colors.red[700]),
                          title: Text(
                            'حذف الحساب',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.red[700]),
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد أنك تريد حذف حسابك؟',
            ),
            const SizedBox(height: 10),
            Text(
              'سيؤدي هذا الإجراء إلى حذف جميع بيانات حسابك وطلباتك بشكل دائم.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب حذف الحساب'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'حذف',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
