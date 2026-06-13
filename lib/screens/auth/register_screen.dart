import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../services/validation_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthRepository authRepository = AuthRepository();
  final ValidationService validationService = ValidationService();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // =========== التحقق من الحقول ===========
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || 
        password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'يرجى ملء جميع الحقول';
      });
      return;
    }

    // =========== التحقق من البريد الإلكتروني ===========
    if (!validationService.validateEmail(email)) {
      setState(() {
        errorMessage = 'البريد الإلكتروني غير صحيح';
      });
      return;
    }

    // =========== التحقق من كلمة المرور ===========
    if (!validationService.validatePassword(password)) {
      setState(() {
        errorMessage = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
      });
      return;
    }

    // =========== التحقق من تطابق كلمات المرور ===========
    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'كلمات المرور غير متطابقة';
      });
      return;
    }

    // =========== التحقق من الاسم الأول ===========
    if (!validationService.validateName(firstName)) {
      setState(() {
        errorMessage = 'الاسم الأول يجب أن يكون بين 1 و 50 حرفاً';
      });
      return;
    }

    // =========== التحقق من الاسم الأخير ===========
    if (!validationService.validateName(lastName)) {
      setState(() {
        errorMessage = 'الاسم الأخير يجب أن يكون بين 1 و 50 حرفاً';
      });
      return;
    }

    // =========== التحقق من SQL Injection ===========
    if (validationService.containsSQLInjectionPattern(firstName) ||
        validationService.containsSQLInjectionPattern(lastName)) {
      setState(() {
        errorMessage = 'تم اكتشاف محتوى غير آمن في البيانات';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await authRepository.signUp(
        validationService.sanitizeInput(firstName),
        validationService.sanitizeInput(lastName),
        email,
        password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      if (user.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      
      final message = e.toString().replaceAll('Exception: ', '');
      setState(() {
        // لا نكشف تفاصيل الخطأ
        if (message.contains('already exists')) {
          errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
        } else {
          errorMessage = 'خطأ في إنشاء الحساب، حاول مرة أخرى';
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        elevation: 0,
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'أدخل بيانات حسابك الجديد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // رسالة الخطأ
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              if (errorMessage != null) const SizedBox(height: 20),

              // الاسم الأول
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأول',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الاسم الأخير
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأخير',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // البريد الإلكتروني
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // كلمة المرور
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // تأكيد كلمة المرور
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          'إنشاء حساب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // الانتقال لصفحة الدخول
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لديك حساب بالفعل؟ ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'سجل الدخول',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
