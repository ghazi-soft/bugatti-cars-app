import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/validation_service.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final ValidationService validationService = ValidationService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  bool isLoading = false;
  String? successMessage;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _submitContact() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    // =========== التحقق من الحقول المطلوبة ===========
    if (name.isEmpty) {
      setState(() {
        errorMessage = 'الاسم مطلوب';
        successMessage = null;
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'البريد الإلكتروني مطلوب';
        successMessage = null;
      });
      return;
    }

    if (subject.isEmpty) {
      setState(() {
        errorMessage = 'الموضوع مطلوب';
        successMessage = null;
      });
      return;
    }

    if (message.isEmpty) {
      setState(() {
        errorMessage = 'الرسالة مطلوبة';
        successMessage = null;
      });
      return;
    }

    // =========== التحقق من صحة البريد الإلكتروني ===========
    if (!validationService.validateEmail(email)) {
      setState(() {
        errorMessage = 'البريد الإلكتروني غير صحيح';
        successMessage = null;
      });
      return;
    }

    // =========== التحقق من رقم الهاتف إن وجد ===========
    if (phone.isNotEmpty && !validationService.validatePhone(phone)) {
      setState(() {
        errorMessage = 'رقم الهاتف يجب أن يكون بين 7 و 15 رقم';
        successMessage = null;
      });
      return;
    }

    // =========== التحقق من الرسالة ===========
    if (!validationService.validateChatMessage(message)) {
      setState(() {
        errorMessage = 'الرسالة يجب أن تكون بين 10 و 2000 حرف';
        successMessage = null;
      });
      return;
    }

    // =========== التحقق من SQL Injection ===========
    if (validationService.containsSQLInjectionPattern(name) ||
        validationService.containsSQLInjectionPattern(subject) ||
        validationService.containsSQLInjectionPattern(message)) {
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
      final contactRepo = ref.read(contactRepositoryProvider);
      
      await contactRepo.sendContactMessage(
        name: validationService.sanitizeInput(name),
        email: email,
        phone: phone.isEmpty ? null : phone,
        subject: validationService.sanitizeInput(subject),
        message: validationService.sanitizeInput(message),
      );

      if (!mounted) return;

      // تنظيف النماذج
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      subjectController.clear();
      messageController.clear();

      setState(() {
        successMessage = 'تم إرسال رسالتك بنجاح، شكراً لتواصلك معنا!';
        errorMessage = null;
      });

      // إخفاء الرسالة بعد 5 ثواني
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'حدث خطأ أثناء إرسال الرسالة، حاول مرة أخرى';
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
        title: const Text('اتصل بنا'),
        elevation: 0,
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // =========== Header ===========
              const Text(
                'نحن هنا لخدمتك',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'إذا كان لديك أي استفسار أو تعليق، لا تتردد في التواصل معنا',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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

              // =========== Contact Form ===========

              // الاسم
              TextField(
                controller: nameController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'الاسم *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              TextField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني *',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // رقم الهاتف (اختياري)
              TextField(
                controller: phoneController,
                enabled: !isLoading,
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
                ),
              ),
              const SizedBox(height: 16),

              // الموضوع
              TextField(
                controller: subjectController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'الموضوع *',
                  prefixIcon: const Icon(Icons.subject),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الرسالة
              TextField(
                controller: messageController,
                enabled: !isLoading,
                maxLines: 6,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: 'الرسالة *',
                  prefixIcon: const Icon(Icons.message, alignment: Alignment.topLeft),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // زر الإرسال
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                          'إرسال الرسالة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // =========== Contact Info ===========
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'معلومات التواصل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // البريد
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.email, color: Colors.red[700], size: 24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'البريد الإلكتروني',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'info@bugattiksa.com',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // الهاتف
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone, color: Colors.red[700], size: 24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رقم الهاتف',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '+966 12 345 6789',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // الموقع
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red[700], size: 24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الموقع',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'جدة، المملكة العربية السعودية',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
