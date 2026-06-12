import { useState, useEffect, useCallback } from 'react';
import { login, isLoggedIn } from '../lib/api';
import { showToast, isValidEmail } from '../lib/utils';
import { clientRateLimit } from '../lib/security';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [attempts, setAttempts] = useState(0);

  useEffect(() => {
    // Redirect already logged-in users
    if (isLoggedIn()) {
      window.location.href = '/';
      return;
    }
    const params = new URLSearchParams(window.location.search);
    if (params.get('error') === 'disabled') {
      showToast('عذراً، تم تعطيل حسابك. يرجى التواصل مع الإدارة.', 'error');
    }
  }, []);

  const handleLogin = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();

    // SECURITY: Client-side rate limit (server also enforces its own)
    if (!clientRateLimit('login', 10, 60_000)) {
      showToast('محاولات كثيرة جداً، انتظر قليلاً', 'error');
      return;
    }

    if (!email || !password) {
      showToast('يرجى ملء جميع الحقول', 'warning');
      return;
    }

    if (!isValidEmail(email)) {
      showToast('البريد الإلكتروني غير صحيح', 'error');
      return;
    }

    if (password.length < 8) {
      showToast('كلمة المرور يجب أن تكون 8 أحرف على الأقل', 'error');
      return;
    }

    try {
      setLoading(true);
      await login(email.trim().toLowerCase(), password);
      showToast('تم تسجيل الدخول بنجاح', 'success');
      window.location.href = '/';
    } catch (error: any) {
      setAttempts(prev => prev + 1);
      const msg = error?.message || '';
      if (msg === 'ACCOUNT_DISABLED' || msg.includes('disabled')) {
        showToast('عذراً، تم تعطيل حسابك. يرجى التواصل مع الإدارة.', 'error');
      } else if (msg.includes('too many')) {
        showToast('محاولات كثيرة جداً، يرجى الانتظار قبل المحاولة مرة أخرى', 'error');
      } else {
        // SECURITY: Generic message — don't reveal if email exists or not
        showToast('بيانات الدخول غير صحيحة', 'error');
      }
    } finally {
      setLoading(false);
    }
  }, [email, password]);

  // Show lockout warning after multiple attempts
  const showWarning = attempts >= 5;

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
                تسجيل الدخول
              </h1>
              <p className="text-muted-foreground">أدخل بيانات حسابك للمتابعة</p>
            </div>

            {showWarning && (
              <div className="mx-6 mb-2 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-lg text-yellow-400 text-sm text-center">
                ⚠️ محاولات متعددة فاشلة — تأكد من بياناتك
              </div>
            )}

            <form onSubmit={handleLogin} className="card-body" noValidate>
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
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={loading}
                  autoComplete="current-password"
                  maxLength={128}
                />
              </div>

              <button
                type="submit"
                className="btn btn-primary w-full"
                disabled={loading}
              >
                {loading ? 'جاري التحميل...' : 'دخول'}
              </button>

              <div className="mt-6 text-center">
                <p className="text-foreground mb-2">ليس لديك حساب؟</p>
                <a href="/register" className="text-primary font-semibold hover:underline">
                  إنشاء حساب جديد
                </a>
              </div>

              <div className="mt-6 pt-6 border-t border-border">
                <p className="text-xs text-muted-foreground text-center">
                  @ جميع حقوق النشر محفوظة لدى @ شركة غازي سوفت
                </p>
              </div>
            </form>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
