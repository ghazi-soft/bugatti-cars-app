import { useState, useCallback } from 'react';
import { register, isLoggedIn } from '../lib/api';
import { showToast, isValidEmail, isValidPassword } from '../lib/utils';
import { clientRateLimit, sanitizeInput } from '../lib/security';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

export default function Register() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  // Redirect if already logged in
  if (isLoggedIn()) {
    window.location.href = '/';
    return null;
  }

  const handleRegister = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();

    // SECURITY: Client-side rate limit
    if (!clientRateLimit('register', 5, 60_000)) {
      showToast('محاولات كثيرة جداً، انتظر قليلاً', 'error');
      return;
    }

    if (!firstName || !lastName || !email || !password || !confirmPassword) {
      showToast('يرجى ملء جميع الحقول', 'warning');
      return;
    }

    if (!isValidEmail(email)) {
      showToast('البريد الإلكتروني غير صحيح', 'error');
      return;
    }

    // SECURITY FIX: 8 chars minimum (was 6)
    if (!isValidPassword(password)) {
      showToast('كلمة المرور يجب أن تكون 8 أحرف على الأقل', 'error');
      return;
    }

    if (password !== confirmPassword) {
      showToast('كلمات المرور غير متطابقة', 'error');
      return;
    }

    if (firstName.trim().length < 2 || firstName.trim().length > 50) {
      showToast('الاسم الأول يجب أن يكون بين 2 و 50 حرفاً', 'error');
      return;
    }

    if (lastName.trim().length < 2 || lastName.trim().length > 50) {
      showToast('الاسم الأخير يجب أن يكون بين 2 و 50 حرفاً', 'error');
      return;
    }

    try {
      setLoading(true);
      // SECURITY: Sanitize names before sending
      await register(
        sanitizeInput(firstName.trim()),
        sanitizeInput(lastName.trim()),
        email.trim().toLowerCase(),
        password
      );
      showToast('تم إنشاء الحساب بنجاح', 'success');
      window.location.href = '/login';
    } catch (error: any) {
      const msg = error?.message || '';
      if (msg.includes('already exists') || msg.includes('email')) {
        showToast('البريد الإلكتروني مستخدم بالفعل', 'error');
      } else if (msg.includes('too many')) {
        showToast('محاولات كثيرة جداً، انتظر قليلاً', 'error');
      } else {
        showToast('خطأ في إنشاء الحساب، حاول مرة أخرى', 'error');
      }
    } finally {
      setLoading(false);
    }
  }, [firstName, lastName, email, password, confirmPassword]);

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mt-32 mb-20">
        <div className="max-w-md mx-auto">
          <div className="card animate-fade-in-up">
            <div className="card-header border-b-0">
              <h1
                className="text-3xl font-bold text-secondary mb-2"
                style={{ fontFamily: "'Playfair Display', serif" }}
              >
                إنشاء حساب
              </h1>
              <p className="text-muted-foreground">انضم إلينا اليوم</p>
            </div>

            <form onSubmit={handleRegister} className="card-body" noValidate>
              <div className="grid grid-cols-2 gap-4">
                <div className="form-group">
                  <label className="form-label">الاسم الأول</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="أحمد"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    disabled={loading}
                    autoComplete="given-name"
                    maxLength={50}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">الاسم الأخير</label>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="محمد"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                    disabled={loading}
                    autoComplete="family-name"
                    maxLength={50}
                  />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">البريد الإلكتروني</label>
                <input
                  type="email"
                  className="form-input"
                  placeholder="your@email.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  disabled={loading}
                  autoComplete="email"
                  maxLength={254}
                />
              </div>

              <div className="form-group">
                <label className="form-label">كلمة المرور</label>
                <input
                  type="password"
                  className="form-input"
                  placeholder="8 أحرف على الأقل"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={loading}
                  autoComplete="new-password"
                  maxLength={128}
                  minLength={8}
                />
              </div>

              <div className="form-group">
                <label className="form-label">تأكيد كلمة المرور</label>
                <input
                  type="password"
                  className="form-input"
                  placeholder="••••••••"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  disabled={loading}
                  autoComplete="new-password"
                  maxLength={128}
                />
              </div>

              <button
                type="submit"
                className="btn btn-primary w-full"
                disabled={loading}
              >
                {loading ? 'جاري التحميل...' : 'إنشاء حساب'}
              </button>

              <div className="mt-6 text-center">
                <p className="text-foreground mb-2">لديك حساب بالفعل؟</p>
                <a href="/login" className="text-primary font-semibold hover:underline">
                  تسجيل الدخول
                </a>
              </div>
            </form>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
