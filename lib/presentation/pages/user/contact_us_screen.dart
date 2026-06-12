import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../core/constants.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/custom_widgets.dart' as custom;

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await ref.read(contactRepositoryProvider).sendContactMessage(
            fullName: _nameController.text,
            email: _emailController.text,
            phone: '',
            subject: _subjectController.text,
            message: _messageController.text,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رسالتك بنجاح')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اتصل بنا')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تواصل معنا', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              Text('نحن هنا لمساعدتك، أرسل لنا استفسارك وسنرد عليك في أقرب وقت.', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppDimensions.spacingLarge),
              custom.CustomTextField(
                label: 'الاسم الكامل',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              custom.CustomTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              custom.CustomTextField(
                label: 'الموضوع',
                controller: _subjectController,
                prefixIcon: Icons.subject,
              ),
              const SizedBox(height: AppDimensions.spacingMedium),
              custom.CustomTextField(
                label: 'الرسالة',
                controller: _messageController,
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'يرجى إدخال رسالتك' : null,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              custom.CustomButton(
                label: 'إرسال الرسالة',
                isLoading: _isSending,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
