import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../providers/app_providers.dart';
import '../services/validation_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ValidationService validationService = ValidationService();
  late TextEditingController fullNameController;
  late TextEditingController phoneController;

  bool isEditing = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _loadUserData(User user) {
    fullNameController.text = user.fullName;
    phoneController.text = user.phone ?? '';
  }

  Future<void> _updateProfile() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();

    // =========== التحقق من البيانات ===========
    if (fullName.isEmpty) {
      setState(() {
        errorMessage = 'الاسم مطلوب';
        successMessage = null;
      });
      return;
    }

    if (!validationService.validateName(fullName)) {
      setState(() {
        errorMessage = 'الاسم يجب أن يكون بين 1 و 50 حرفاً';
        successMessage = null;
      });
      return;
    }

    if (phone.isNotEmpty && !validationService.validatePhone(phone)) {
      setState(() {
        errorMessage = 'رقم الهاتف يجب أن يكون بين 7 و 15 رقم';
        successMessage = null;
      });
      return;
    }

    if (validationService.containsSQLInjectionPattern(fullName)) {
      setState(() {
        errorMessage = 'تم اكتشاف محتوى غير آمن';
        successMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      
      await authRepo.updateUserProfile(
        fullName: validationService.sanitizeInput(fullName),
        phone: phone.isEmpty ? null : phone,
      );

      if (!mounted) return;

      // تحديث بيانات المستخدم
      await ref.read(userProvider.notifier).refresh();

      setState(() {
        successMessage = 'تم تحديث البيانات بنجاح';
        errorMessage = null;
        isEditing = false;
      });

      // إخفاء الرسالة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'حدث خطأ أثناء تحديث البيانات';
        successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        elevation: 0,
        backgroundColor: Colors.red[700],
        actions: [
          if (userAsync.value != null)
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        if (isEditing) {
                          _loadUserData(userAsync.value!);
                        }
                        isEditing = !isEditing;
                        errorMessage = null;
                        successMessage = null;
                      });
                    },
              child: Text(
                isEditing ? 'إلغاء' : 'تحرير',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('حدث خطأ في تحميل البيانات'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(userProvider);
                },
                child: const Text('إعادة محاولة'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('لم يتم تسجيل الدخول'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('الذهاب لتسجيل الدخول'),
                  ),
                ],
              ),
            );
          }

          // تحميل بيانات المستخدم عند أول مرة
          if (!isEditing && fullNameController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadUserData(user);
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========== Messages ===========
                  if (successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              successMessage!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (successMessage != null) const SizedBox(height: 20),

                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (errorMessage != null) const SizedBox(height: 20),

                  // =========== Profile Picture ===========
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red[700]?.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user.isAdmin
                                ? Colors.red[700]
                                : Colors.green[700],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.isAdmin ? 'مسؤول' : 'مستخدم',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========== Profile Info Section ===========
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات الحساب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Full Name
                        TextField(
                          controller: fullNameController,
                          enabled: isEditing && !isLoading,
                          decoration: InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email (Read-only)
                        TextField(
                          enabled: false,
                          controller: TextEditingController(text: user.email),
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Phone
                        TextField(
                          controller: phoneController,
                          enabled: isEditing && !isLoading,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف (اختياري)',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========== Account Status ===========
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'حالة الحساب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الحالة:'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[700]?.withOpacity(0.2),
                                border: Border.all(color: Colors.green[700]!),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'نشط',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========== Save Button ===========
                  if (isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ التغييرات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // =========== Logout Button ===========
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('تسجيل الخروج'),
                                  content: const Text(
                                    'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'تسجيل الخروج',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final authRepo =
                                    ref.read(authRepositoryProvider);
                                await authRepo.signOut();
                                if (mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
