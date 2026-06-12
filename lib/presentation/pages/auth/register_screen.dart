import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authRepositoryProvider).signUp(
            _firstNameController.text,
            _lastNameController.text,
            _emailController.text,
            _passwordController.text,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التسجيل بنجاح')));
        if (user.role == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('انضم إلى عالم الفخامة', style: AppTextStyles.displaySmall),
              const SizedBox(height: 32),
              custom.CustomTextField(
                label: 'الاسم الأول',
                controller: _firstNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              custom.CustomTextField(
                label: 'الاسم الأخير',
                controller: _lastNameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              custom.CustomTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              custom.CustomTextField(
                label: 'كلمة المرور',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) => v!.length < 6 ? '6 أحرف على الأقل' : null,
              ),
              const SizedBox(height: 16),
              custom.CustomTextField(
                label: 'تأكيد كلمة المرور',
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              custom.CustomButton(
                label: 'إنشاء حساب',
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
