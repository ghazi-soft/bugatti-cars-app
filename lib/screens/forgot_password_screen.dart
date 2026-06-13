import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../services/validation_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthRepository authRepository = AuthRepository();
  final ValidationService validationService = ValidationService();
  final emailController = TextEditingController();

  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim().toLowerCase();

    // =========== التحقق من الحقل ===========
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'يرجى إدخال البريد الإلكتروني';
        successMessage = null;
      });
      return;
    }

    // =========== التحقق من صحة البريد ===========
    if (!validationService.validateEmail(email)) {
      setState(() {
        errorMessage = 'البريد الإلكتروني غير صحيح';
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
      await authRepository.resetPassword(email);

      if (!mounted) return;

      setState(() {
        successMessage = 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني';
        errorMessage = null;
        emailController.clear();
      });

      // إغلاق الشاشة بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'حدث خطأ أثناء معالجة الطلب، حاول لاحقاً';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة كلمة المرور'),
        elevation: 0,
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // =========== Header ===========
              const Text(
                'استعادة كلمة المرور',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'أدخل البريد الإلكتروني المرتبط بحسابك وسنرسل لك رابط لإعادة تعيين كلمة المرور',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 30),

              // =========== Success Message ===========
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

              // =========== Error Message ===========
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

              // =========== Email Input ===========
              TextField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'your@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========== Submit Button ===========
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
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
                          'إرسال رابط الاستعادة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // =========== Back to Login ===========
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(
                    'العودة لتسجيل الدخول',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // =========== Additional Info ===========
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تحقق من مجلد البريد العشوائي (Spam) إذا لم تستقبل الرسالة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
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
