# دليل الاختبار - Flutter Bugatti Cars App

## 🧪 اختبار Auth Flow

### 1. اختبار التسجيل (Register)
```
✅ Test: Valid Input
- Email: test@example.com
- Password: ValidPass123
- First Name: أحمد
- Last Name: محمد
- Expected: ✅ إنشاء حساب بنجاح

✅ Test: Email Already Exists
- Email: existing@example.com
- Expected: ❌ "البريد الإلكتروني مستخدم بالفعل"

✅ Test: Invalid Email
- Email: not-an-email
- Expected: ❌ "البريد الإلكتروني غير صحيح"

✅ Test: Weak Password
- Password: 123
- Expected: ❌ "كلمة المرور يجب أن تكون 8 أحرف على الأقل"

✅ Test: Password Mismatch
- Password: ValidPass123
- Confirm: DifferentPass456
- Expected: ❌ "كلمات المرور غير متطابقة"

✅ Test: SQL Injection
- Name: '; DROP TABLE users; --
- Expected: ❌ "تم اكتشاف محتوى غير آمن"
```

### 2. اختبار الدخول (Login)
```
✅ Test: Valid Credentials
- Email: test@example.com
- Password: ValidPass123
- Expected: ✅ Navigate to home/admin based on role

✅ Test: Invalid Credentials
- Email: wrong@example.com
- Password: WrongPass123
- Expected: ❌ "بيانات الدخول غير صحيحة" (generic message)

✅ Test: Disabled Account
- Setup: User with is_active = false
- Expected: ❌ "حسابك معطل"

✅ Test: Email Validation
- Email: not-valid-email
- Expected: ❌ "البريد الإلكتروني غير صحيح" (before submit)
```

### 3. اختبار استعادة كلمة المرور
```
✅ Test: Valid Email
- Email: test@example.com
- Expected: ✅ "تم إرسال رابط إعادة تعيين كلمة المرور"

✅ Test: Invalid Email
- Email: invalid-email
- Expected: ❌ "البريد الإلكتروني غير صحيح"

✅ Test: Non-existent Email
- Email: notexist@example.com
- Expected: ✅ Generic success (not revealing if exists)
```

---

## 👤 اختبار Profile Screen

### 1. عرض البيانات
```
✅ Test: Load User Data
- Expected: ✅ عرض:
  - الاسم الكامل
  - البريد الإلكتروني
  - رقم الهاتف
  - دور المستخدم (مستخدم/مسؤول)
  - حالة الحساب (نشط)

✅ Test: Admin User Display
- Setup: User with role = 'admin'
- Expected: ✅ عرض "مسؤول" مع لون مختلف
```

### 2. تعديل البيانات
```
✅ Test: Edit Name
- Original: "أحمد محمد"
- New: "علي محمود"
- Expected: ✅ تحديث ناجح

✅ Test: Invalid Name Length
- Input: "" (empty)
- Expected: ❌ "الاسم مطلوب"

✅ Test: Edit Phone
- Phone: "966501234567"
- Expected: ✅ تحديث ناجح

✅ Test: Invalid Phone
- Phone: "123" (too short)
- Expected: ❌ "رقم الهاتف يجب أن يكون بين 7 و 15 رقم"

✅ Test: SQL Injection in Name
- Name: "'; DELETE FROM users; --"
- Expected: ❌ "تم اكتشاف محتوى غير آمن"
```

### 3. تسجيل الخروج
```
✅ Test: Logout Confirmation
- Click logout
- Expected: ✅ ظهور dialog للتأكيد

✅ Test: Confirm Logout
- Click confirm
- Expected: ✅ Navigate to login, clear tokens

✅ Test: Cancel Logout
- Click cancel
- Expected: ✅ remain on profile screen
```

---

## ⚙️ اختبار Settings Screen

### 1. التفضيلات
```
✅ Test: Toggle Notifications
- Switch to OFF
- Expected: ✅ تغيير الحالة

✅ Test: Toggle Email Notifications
- Switch to OFF
- Expected: ✅ تغيير الحالة

✅ Test: Toggle Dark Mode
- Switch to ON
- Expected: ✅ تغيير الثيم (إذا كان مطبق)
```

### 2. الروابط
```
✅ Test: Navigate to Profile
- Expected: ✅ Open profile screen

✅ Test: Navigate to About
- Expected: ✅ Open about screen

✅ Test: Navigate to Contact
- Expected: ✅ Open contact screen

✅ Test: Change Password Link
- Expected: ✅ Open forgot password screen
```

---

## 📝 اختبار Contact Screen

### 1. تقديم النموذج الصحيح
```
✅ Test: Valid Form
- Name: "أحمد محمد"
- Email: "ahmad@example.com"
- Phone: "966501234567"
- Subject: "استفسار عن السيارات"
- Message: "أود معرفة المزيد عن السيارات المتاحة"
- Expected: ✅ "تم إرسال رسالتك بنجاح"
```

### 2. التحقق من الحقول المطلوبة
```
✅ Test: Missing Name
- Expected: ❌ "الاسم مطلوب"

✅ Test: Missing Email
- Expected: ❌ "البريد الإلكتروني مطلوب"

✅ Test: Missing Subject
- Expected: ❌ "الموضوع مطلوب"

✅ Test: Missing Message
- Expected: ❌ "الرسالة مطلوبة"

✅ Test: Short Message (< 10 chars)
- Message: "Hi there"
- Expected: ❌ "الرسالة يجب أن تكون بين 10 و 2000 حرف"
```

### 3. التحقق من الصحة
```
✅ Test: Invalid Email
- Email: "not-an-email"
- Expected: ❌ "البريد الإلكتروني غير صحيح"

✅ Test: Invalid Phone (too short)
- Phone: "123"
- Expected: ❌ "رقم الهاتف يجب أن يكون بين 7 و 15 رقم"

✅ Test: Message Too Long (> 2000)
- Message: (2001 characters)
- Expected: ❌ MaxLength indicator

✅ Test: SQL Injection Detection
- Name: "'; DROP TABLE contact_messages; --"
- Expected: ❌ "تم اكتشاف محتوى غير آمن"
```

---

## ℹ️ اختبار About Screen

### 1. المحتوى
```
✅ Test: Hero Section
- Expected: ✅ عرض:
  - العنوان الرئيسي
  - الوصف
  - الوسوم (3 وسوم)

✅ Test: Highlights Cards
- Expected: ✅ عرض 3 بطاقات:
  - "شغف في كل رحلة"
  - "خدمة بخبرة"
  - "رحلة غير منتهية"

✅ Test: Statistics
- Expected: ✅ عرض 4 إحصائيات:
  - +5000 عميل راضي
  - +2000 سيارة مباعة
  - +100 ماركة عالمية
  - 24/7 دعم فني

✅ Test: Team Section
- Expected: ✅ عرض 3 أعضاء فريق
  - عبدالله غازي - المدير العام
  - محمد غازي - مدير المبيعات
  - علي الصماط - المصمم المتألق
```

---

## 🛡️ اختبارات الأمان

### 1. Input Sanitization
```
✅ Test: Special Characters Removal
- Input: "Ahmed@#$%^&*()"
- Expected: ✅ Sanitized to "Ahmed"

✅ Test: Preserve Arabic
- Input: "أحمد محمد"
- Expected: ✅ احفظ كما هو

✅ Test: Remove SQL Keywords
- Input: "DROP TABLE users"
- Expected: ❌ رفع الطلب

✅ Test: Double Dash Detection
- Input: "Test -- comment"
- Expected: ❌ "تم اكتشاف محتوى غير آمن"
```

### 2. Password Security
```
✅ Test: Strong Password
- Password: "C0mpl3x!P@ssw0rd"
- Expected: ✅ قبول

✅ Test: Weak Password
- Password: "123456"
- Expected: ❌ "كلمة المرور يجب أن تكون 8 أحرف على الأقل"

✅ Test: Password Max Length
- Password: (128+ characters)
- Expected: ✅ قبول حتى 128

✅ Test: Password Beyond Max
- Password: (129+ characters)
- Expected: ❌ رفع الطلب
```

### 3. Email Validation
```
✅ Test: Valid Emails
- test@example.com ✅
- user+tag@domain.co.uk ✅
- name.surname@company.com ✅

✅ Test: Invalid Emails
- test@.com ❌
- test@domain ❌
- test..email@domain.com ❌
```

---

## 🔄 اختبارات التدفق المتكامل

### 1. Sign Up -> Login -> Profile
```
1. Register with:
   - Email: newuser@test.com
   - Password: SecurePass123
   - Name: محمد أحمد

2. Expected: ✅ Account created

3. Login with same credentials
   - Expected: ✅ Navigate to home

4. Go to Profile
   - Expected: ✅ Show all user data

5. Edit name to "علي محمود"
   - Expected: ✅ Update successful

6. Logout
   - Expected: ✅ Redirect to login
```

### 2. Contact Form Submission
```
1. Open Contact Screen
2. Fill form:
   - Name: test user
   - Email: test@example.com
   - Subject: test inquiry
   - Message: This is a test message

3. Submit
   - Expected: ✅ "تم إرسال رسالتك بنجاح"

4. Verify in Supabase:
   - Expected: ✅ Record in contact_messages table
   - source: 'mobile_app'
   - is_read: false
```

---

## 📊 Checklist للتطوير

### قبل الـ Release
- [ ] جميع input fields تحتوي على validation
- [ ] جميع error messages بالعربية
- [ ] جميع رسائل النجاح واضحة
- [ ] لا توجد رسائل خطأ تكشف معلومات حساسة
- [ ] جميع الـ screens تحمل البيانات بشكل صحيح
- [ ] الـ navigation يعمل بين جميع الـ screens
- [ ] الـ logout يمسح جميع البيانات المحلية
- [ ] الـ dark mode يعمل (إن كان مطبق)
- [ ] الـ accessibility جيدة (text sizes, colors)

### Supabase Verification
- [ ] جميع الـ RLS policies صحيحة
- [ ] جميع الـ tables موجودة ولديها البيانات الصحيحة
- [ ] الـ auth مفعل بشكل صحيح
- [ ] الـ foreign keys علاقات صحيحة

### Performance
- [ ] لا توجد infinite loops
- [ ] الـ loading states تظهر بشكل صحيح
- [ ] الـ network calls محسنة
- [ ] الـ local storage يعمل بشكل صحيح

---

## 🐛 أشياء للمراقبة

1. **Type Safety**: تأكد من عدم وجود null safety issues
2. **Memory Leaks**: تأكد من dispose جميع controllers
3. **Network Errors**: تعامل مع جميع الـ edge cases
4. **Offline Mode**: تعامل مع الـ offline scenarios
5. **Concurrent Requests**: تجنب duplicate requests

---

## 📞 في حالة الأخطاء

### Common Issues

#### "تم اكتشاف محتوى غير آمن"
- المدخلات تحتوي على SQL keywords أو dangerous characters
- استخدم `sanitizeInput()` قبل الإرسال

#### "البريد الإلكتروني مستخدم بالفعل"
- البريد موجود في النظام
- استخدم بريد آخر

#### "بيانات الدخول غير صحيحة"
- تحقق من البريد والكلمة المرور
- تأكد من عدم وجود مسافات إضافية

#### "حسابك معطل"
- الحساب محظور من قبل الإدارة
- تواصل مع فريق الدعم

---

**ملاحظة أخيرة:**
جميع الاختبارات يجب أن تجري على:
- ✅ Physical device
- ✅ Multiple Android versions
- ✅ Multiple screen sizes
- ✅ Real Supabase instance
- ✅ Offline & Online scenarios
