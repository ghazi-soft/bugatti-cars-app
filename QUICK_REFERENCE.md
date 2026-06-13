# Quick Reference - مرجع سريع

## 🚀 الأوامر الأساسية

### تشغيل التطبيق
```bash
# شغيل عام
flutter run

# شغيل مع platform محدد
flutter run -d android
flutter run -d ios

# شغيل مع flavor محدد
flutter run --flavor development

# شغيل بـ release mode
flutter run --release
```

### الصيانة
```bash
# تنظيف و rebuild
flutter clean
flutter pub get
flutter pub upgrade

# تحليل الكود
flutter analyze

# تنسيق الكود
flutter format lib/
```

---

## 📱 الـ Screens المتاحة

| Screen | Route | الوصف |
|--------|-------|--------|
| Login | `/login` | تسجيل الدخول |
| Register | `/register` | إنشاء حساب جديد |
| Profile | `/profile` | الملف الشخصي |
| Settings | `/settings` | الإعدادات |
| About | `/about` | عن التطبيق |
| Contact | `/contact` | نموذج التواصل |
| Forgot Password | `/forgot-password` | استعادة كلمة المرور |
| Home | `/home` | الصفحة الرئيسية |
| Admin | `/admin` | لوحة التحكم |

---

## 🔐 Validation Rules Quick Reference

### Email
```dart
validationService.validateEmail('user@example.com')
// Pattern: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

### Password
```dart
validationService.validatePassword('SecurePass123')
// Length: 8-128 characters
```

### Name
```dart
validationService.validateName('أحمد محمد')
// Length: 1-50 characters
// No SQL patterns
```

### Phone
```dart
validationService.validatePhone('966501234567')
// Length: 7-15 digits
// Optional field
```

### Car Year
```dart
validationService.validateCarYear(2024)
// Range: 1900 to currentYear + 2
```

### Car Price
```dart
validationService.validateCarPrice(150000)
// Range: 0 to 100,000,000
```

### Chat Message
```dart
validationService.validateChatMessage('Hello world')
// Length: 1-2000 characters
```

---

## 🛡️ Sanitization

```dart
// تنظيف المدخلات
String sanitized = validationService.sanitizeInput('Ahmed@#$%');
// Result: "Ahmed"

// كشف SQL Injection
bool hasSQLPattern = validationService
    .containsSQLInjectionPattern("'; DROP TABLE users; --");
// Result: true

// كشف أنماط خطيرة
bool hasSQL = validationService
    .containsSQLInjectionPattern("test -- comment");
// Result: true
```

---

## 📦 Repository Usage

### Auth Repository
```dart
final authRepo = ref.read(authRepositoryProvider);

// تسجيل جديد
User user = await authRepo.signUp(
  firstName: 'أحمد',
  lastName: 'محمد',
  email: 'ahmad@example.com',
  password: 'SecurePass123',
);

// تسجيل دخول
User user = await authRepo.signIn(
  email: 'ahmad@example.com',
  password: 'SecurePass123',
);

// تسجيل خروج
await authRepo.signOut();

// الحصول على المستخدم الحالي
User? user = await authRepo.getCurrentUser();

// تحديث البيانات الشخصية
await authRepo.updateUserProfile(
  fullName: 'أحمد علي',
  phone: '966501234567',
);

// إعادة تعيين كلمة المرور
await authRepo.resetPassword('ahmad@example.com');
```

### Order Repository
```dart
final orderRepo = ref.read(orderRepositoryProvider);

// الحصول على طلبات المستخدم
List<Order> orders = await orderRepo.getUserOrders(userId);

// إنشاء طلب جديد
Order order = await orderRepo.createOrder(
  carId: 1,
  firstName: 'أحمد',
  lastName: 'محمد',
  email: 'ahmad@example.com',
  phone: '966501234567',
  price: 150000,
);

// تحديث حالة الطلب
await orderRepo.updateOrderStatus(orderId, 'confirmed');

// حذف طلب
await orderRepo.deleteOrder(orderId);
```

### Contact Repository
```dart
final contactRepo = ref.read(contactRepositoryProvider);

// إرسال رسالة تواصل
await contactRepo.sendContactMessage(
  name: 'أحمد محمد',
  email: 'ahmad@example.com',
  phone: '966501234567',
  subject: 'استفسار',
  message: 'أود معرفة المزيد',
);

// الحصول على جميع الرسائل (admin)
List<ContactMessage> messages = await contactRepo.getContactMessages();

// عد الرسائل غير المقروءة
int count = await contactRepo.countUnreadMessages();
```

### Car Repository
```dart
final carRepo = ref.read(carRepositoryProvider);

// الحصول على السيارات
List<Car> cars = await carRepo.getAllCars(limit: 10, offset: 0);

// البحث عن سيارات
List<Car> results = await carRepo.searchCars('تويوتا');

// الحصول على سيارة محددة
Car car = await carRepo.getCarById(1);

// إنشاء سيارة (admin)
Car newCar = await carRepo.createCar(
  brand: 'Toyota',
  model: 'Camry',
  year: 2024,
  price: 150000,
  description: 'سيارة رائعة',
);

// تحديث سيارة
await carRepo.updateCar(carId, brand, model, year, price, description);

// حذف سيارة (admin)
await carRepo.deleteCar(carId);
```

### User Repository
```dart
final userRepo = ref.read(userRepositoryProvider);

// الحصول على جميع المستخدمين (admin)
List<User> users = await userRepo.getAllUsers();

// الحصول على مستخدم محدد
User user = await userRepo.getUserById(userId);

// تحديث دور المستخدم (admin)
await userRepo.updateUserRole(userId, 'admin');

// تحديث حالة النشاط (admin)
await userRepo.updateUserActiveStatus(userId, false);

// حذف مستخدم (admin)
await userRepo.deleteUser(userId);

// عد المستخدمين
int total = await userRepo.countUsers();
int active = await userRepo.countActiveUsers();
int admins = await userRepo.countAdminUsers();
```

---

## 🎨 Theme Colors

```dart
// الألوان الأساسية
primaryColor: Colors.red[700]  // #ff0000
secondaryColor: Colors.amber[700]
accentColor: Colors.yellow[300]

// الخلفيات
backgroundColor: Colors.white
surfaceColor: Colors.grey[50]
errorColor: Colors.red

// النصوص
textPrimary: Colors.black87
textSecondary: Colors.grey[600]
mutedText: Colors.grey[400]
```

---

## 🌍 Localization (Arabic)

```dart
// جميع الرسائل بالعربية
'البريد الإلكتروني غير صحيح' // Invalid email
'كلمة المرور يجب أن تكون 8 أحرف على الأقل' // Password too short
'الاسم مطلوب' // Name required
'تم إرسال الرسالة بنجاح' // Message sent successfully
'خطأ في الحفظ، حاول مرة أخرى' // Error saving, try again
```

---

## 🔔 Providers Usage

```dart
// الحصول على بيانات المستخدم
final user = ref.watch(userProvider);

// مراقبة قائمة السيارات
final cars = ref.watch(carListProvider);

// مراقبة قائمة الطلبات
final orders = ref.watch(orderListProvider);

// الوصول للمفضلات
final favorites = ref.watch(favoritesProvider);

// تحديث بيانات المستخدم
await ref.read(userProvider.notifier).refresh();

// إضافة طلب جديد
await ref.read(orderListProvider.notifier).addOrder(order);

// تحديث حالة الطلب
await ref.read(orderListProvider.notifier).updateOrderStatus(id, status);

// تبديل المفضلة
await ref.read(favoritesProvider.notifier).toggleFavorite(carId);
```

---

## 🚨 Error Handling Pattern

```dart
// Pattern عام للـ error handling
try {
  // أداء العملية
  final result = await repository.doSomething();
  
  setState(() {
    successMessage = 'تم النجاح!';
    errorMessage = null;
  });
} catch (e) {
  setState(() {
    errorMessage = 'حدث خطأ، حاول مرة أخرى';
    successMessage = null;
  });
} finally {
  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
}
```

---

## 💾 SharedPreferences Usage

```dart
final prefs = await SharedPreferences.getInstance();

// الحفظ
await prefs.setString('key', 'value');
await prefs.setInt('number', 42);
await prefs.setBool('flag', true);

// القراءة
String? value = prefs.getString('key');
int? number = prefs.getInt('number');
bool? flag = prefs.getBool('flag');

// الحذف
await prefs.remove('key');

// حذف جميع البيانات
await prefs.clear();

// مثال: حفظ المفضلات
await prefs.setString(
  'favorite_car_ids',
  jsonEncode([1, 2, 3]),
);
```

---

## 🧪 Common Test Scenarios

### Auth Tests
- ✅ Valid register data
- ✅ Invalid email format
- ✅ Weak password
- ✅ Email already exists
- ✅ Valid login
- ✅ Invalid credentials
- ✅ Disabled account

### Form Tests
- ✅ All fields required
- ✅ Email validation
- ✅ Phone validation
- ✅ Character limits
- ✅ SQL injection attempt
- ✅ Special characters

### Navigation Tests
- ✅ Navigate to profile
- ✅ Navigate to settings
- ✅ Navigate to contact
- ✅ Navigate to about
- ✅ Logout and redirect

---

## 📋 Debugging Tips

### Enable Debug Logging
```dart
// في repositories
print('DEBUG: ${variable}');

// أو استخدم debugPrint للـ long strings
import 'package:flutter/foundation.dart';
debugPrint('Long debug info: $longString');
```

### Check Supabase Queries
```dart
// في terminal
flutter logs | grep "Supabase"
```

### Flutter DevTools
```bash
flutter pub global activate devtools
devtools
```

### Hot Reload
```bash
r       # hot reload
R       # hot restart
q       # quit
```

---

## 📞 Getting Help

### Common Issues

**Issue:** ValidationService not found
```dart
// ✅ Solution
import 'package:bugatti_cars/services/validation_service.dart';
```

**Issue:** Type mismatch (String vs int)
```dart
// ✅ Solution
// استخدم _parseId() helper في models
```

**Issue:** Supabase connection error
```dart
// ✅ Solution
// تحقق من URL و Key
// تأكد من الـ internet connection
```

**Issue:** Navigation not working
```dart
// ✅ Solution
// تأكد من إضافة الـ route في main.dart
// استخدم MaterialPageRoute أو Navigator.pushNamed
```

---

## 📚 Resources

- Flutter Docs: https://flutter.dev/docs
- Supabase Docs: https://supabase.io/docs
- Riverpod Docs: https://riverpod.dev
- Flutter Arabic Guide: https://arabic.flutter.dev

---

**آخر تحديث:** اليوم  
**الإصدار:** 1.0.0  
**الحالة:** جاهز للاستخدام ✅
