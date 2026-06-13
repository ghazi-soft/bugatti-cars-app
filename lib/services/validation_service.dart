import 'package:intl/intl.dart';

/// خدمة التحقق من البيانات
/// تطبق نفس قواعد التحقق من Go Backend
class ValidationService {
  // ============================================================
  // EMAIL VALIDATION
  // ============================================================
  
  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // نفس الـ Regex المستخدم في Go
    const String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);
    
    return regex.hasMatch(email.toLowerCase().trim());
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================
  
  /// التحقق من قوة كلمة المرور
  /// الحد الأدنى: 8 أحرف
  /// الحد الأقصى: 128 حرف
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 8) return false;
    if (password.length > 128) return false;
    return true;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (password.length > 128) {
      return 'كلمة المرور طويلة جداً (128 حرف كحد أقصى)';
    }
    return null;
  }

  // ============================================================
  // NAME VALIDATION
  // ============================================================
  
  /// التحقق من صحة الاسم (الاسم الأول أو الأخير)
  /// الحد الأدنى: 1 حرف
  /// الحد الأقصى: 50 حرف
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    if (name.length > 50) return false;
    // تجنب SQL Injection
    if (_containsSQLInjection(name)) return false;
    return true;
  }

  static String? validateName(String name, String fieldName) {
    if (name.isEmpty) {
      return '$fieldName مطلوب';
    }
    if (name.length > 50) {
      return '$fieldName طويل جداً (50 حرف كحد أقصى)';
    }
    if (_containsSQLInjection(name)) {
      return 'المدخل يحتوي على أحرف غير مسموحة';
    }
    return null;
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================
  
  /// التحقق من صحة رقم الهاتف
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return true; // اختياري
    
    // إزالة المسافات والشرطات
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // التحقق من الطول (معظم الأرقام 7-15 أرقام)
    if (cleaned.length < 7 || cleaned.length > 15) return false;
    
    return true;
  }

  static String? validatePhone(String phone) {
    if (phone.isEmpty) return null; // اختياري
    
    if (!isValidPhone(phone)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  // ============================================================
  // CAR VALIDATION
  // ============================================================
  
  /// التحقق من صحة اسم الماركة أو الموديل
  /// الحد الأدنى: 1 حرف
  /// الحد الأقصى: 100 حرف
  static bool isValidCarName(String name) {
    if (name.isEmpty) return false;
    if (name.length > 100) return false;
    if (_containsSQLInjection(name)) return false;
    return true;
  }

  static String? validateCarName(String name, String fieldName) {
    if (name.isEmpty) {
      return '$fieldName مطلوب';
    }
    if (name.length > 100) {
      return '$fieldName طويل جداً (100 حرف كحد أقصى)';
    }
    if (_containsSQLInjection(name)) {
      return 'المدخل يحتوي على أحرف غير مسموحة';
    }
    return null;
  }

  /// التحقق من وصف السيارة
  /// الحد الأدنى: 0 أحرف
  /// الحد الأقصى: 5000 حرف
  static bool isValidCarDescription(String description) {
    if (description.isEmpty) return true; // اختياري
    if (description.length > 5000) return false;
    return true;
  }

  static String? validateCarDescription(String description) {
    if (!isValidCarDescription(description)) {
      return 'الوصف طويل جداً (5000 حرف كحد أقصى)';
    }
    return null;
  }

  /// التحقق من سنة السيارة
  /// الحد الأدنى: 1900
  /// الحد الأقصى: السنة الحالية + 2
  static bool isValidCarYear(int year) {
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 2) return false;
    return true;
  }

  static String? validateCarYear(int year) {
    if (!isValidCarYear(year)) {
      final currentYear = DateTime.now().year;
      return 'السنة يجب أن تكون بين 1900 و ${currentYear + 2}';
    }
    return null;
  }

  /// التحقق من سعر السيارة
  /// الحد الأدنى: 0
  /// الحد الأقصى: 100,000,000
  static bool isValidCarPrice(double price) {
    if (price < 0 || price > 100_000_000) return false;
    return true;
  }

  static String? validateCarPrice(double price) {
    if (!isValidCarPrice(price)) {
      return 'السعر يجب أن يكون بين 0 و 100,000,000';
    }
    return null;
  }

  // ============================================================
  // CHAT MESSAGE VALIDATION
  // ============================================================
  
  /// التحقق من طول الرسالة
  /// الحد الأقصى: 2000 حرف
  static bool isValidChatMessage(String message) {
    if (message.isEmpty) return false;
    if (message.length > 2000) return false;
    return true;
  }

  static String? validateChatMessage(String message) {
    if (message.isEmpty) {
      return 'الرسالة مطلوبة';
    }
    if (message.length > 2000) {
      return 'الرسالة طويلة جداً (2000 حرف كحد أقصى)';
    }
    return null;
  }

  // ============================================================
  // CONTACT MESSAGE VALIDATION
  // ============================================================
  
  static String? validateContactMessage(
    String name,
    String email,
    String? phone,
    String subject,
    String message,
  ) {
    // التحقق من الاسم
    if (name.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (name.length > 100) {
      return 'الاسم طويل جداً';
    }

    // التحقق من البريد
    if (email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValidEmail(email)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    // التحقق من الهاتف
    if (phone != null && !isValidPhone(phone)) {
      return 'رقم الهاتف غير صحيح';
    }

    // التحقق من الموضوع
    if (subject.isEmpty) {
      return 'الموضوع مطلوب';
    }
    if (subject.length > 200) {
      return 'الموضوع طويل جداً';
    }

    // التحقق من الرسالة
    if (message.isEmpty) {
      return 'الرسالة مطلوبة';
    }
    if (message.length < 10) {
      return 'الرسالة قصيرة جداً (10 أحرف على الأقل)';
    }
    if (message.length > 5000) {
      return 'الرسالة طويلة جداً (5000 حرف كحد أقصى)';
    }

    return null;
  }

  // ============================================================
  // ORDER VALIDATION
  // ============================================================
  
  static String? validateOrderRequest(
    int carId,
    String firstName,
    String lastName,
    String email,
    String phone,
  ) {
    // التحقق من معرف السيارة
    if (carId <= 0) {
      return 'اختر سيارة صحيحة';
    }

    // التحقق من الأسماء
    final firstNameError = validateName(firstName, 'الاسم الأول');
    if (firstNameError != null) return firstNameError;

    final lastNameError = validateName(lastName, 'اسم العائلة');
    if (lastNameError != null) return lastNameError;

    // التحقق من البريد
    if (!isValidEmail(email)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    // التحقق من الهاتف
    if (!isValidPhone(phone)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  // ============================================================
  // SECURITY HELPERS
  // ============================================================
  
  /// التحقق من SQL Injection
  static bool _containsSQLInjection(String input) {
    // كلمات مفتاحية خطرة في SQL
    final sqlKeywords = [
      'DROP',
      'DELETE',
      'INSERT',
      'UPDATE',
      'SELECT',
      'UNION',
      'EXEC',
      'EXECUTE',
      'ALTER',
      'CREATE',
      'TRUNCATE',
      'REPLACE',
    ];

    final upperInput = input.toUpperCase();
    for (final keyword in sqlKeywords) {
      if (upperInput.contains(keyword)) {
        return true;
      }
    }

    // الأحرف الخطرة
    final dangerousChars = ['--', '/*', '*/', ';', "'", '"'];
    for (final char in dangerousChars) {
      if (input.contains(char)) {
        return true;
      }
    }

    return false;
  }

  /// تنظيف المدخل من الأحرف الخطرة
  static String sanitizeInput(String input) {
    // إزالة المسافات الزائدة
    String cleaned = input.trim();
    
    // إزالة الأحرف الخطرة (مع الحفاظ على الكلمات العربية)
    cleaned = cleaned.replaceAll(RegExp(r'[<>"\';`]'), '');
    
    return cleaned;
  }

  // ============================================================
  // FORMAT HELPERS
  // ============================================================
  
  /// تنسيق السعر
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'ر.س ',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  /// تنسيق التاريخ
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'ar');
    return formatter.format(date);
  }

  /// تنسيق الوقت
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm', 'ar');
    return formatter.format(dateTime);
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'ar');
    return formatter.format(dateTime);
  }
}
