import { useState, useCallback } from 'react';
import { showToast } from '../lib/utils';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { sendContactMessage } from '../lib/api';
import { isValidEmail, isValidPhone, sanitizeInput, clientRateLimit } from '../lib/security';

export default function Contact() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    subject: '',
    message: '',
  });
  const [sending, setSending] = useState(false);

  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();

    // SECURITY: Client-side rate limit for contact form
    if (!clientRateLimit('contact', 3, 60_000)) {
      showToast('يرجى الانتظار قبل إرسال رسالة أخرى', 'error');
      return;
    }

    const name = formData.name.trim();
    const email = formData.email.trim().toLowerCase();
    const phone = formData.phone.trim();
    const subject = formData.subject.trim();
    const message = formData.message.trim();

    if (!name || !email || !message) {
      showToast('يرجى ملء الحقول المطلوبة (الاسم، البريد، الرسالة)', 'warning');
      return;
    }

    // Validate email
    if (!isValidEmail(email)) {
      showToast('البريد الإلكتروني غير صحيح', 'error');
      return;
    }

    // Validate phone if provided
    if (phone && !isValidPhone(phone)) {
      showToast('رقم الهاتف غير صحيح', 'error');
      return;
    }

    // Validate lengths
    if (name.length > 100) {
      showToast('الاسم طويل جداً', 'error');
      return;
    }
    if (message.length < 10) {
      showToast('الرسالة قصيرة جداً — اكتب على الأقل 10 أحرف', 'error');
      return;
    }
    if (message.length > 5000) {
      showToast('الرسالة طويلة جداً (5000 حرف كحد أقصى)', 'error');
      return;
    }

    try {
      setSending(true);
      await sendContactMessage({
        fullName: sanitizeInput(name),
        email,
        phone: sanitizeInput(phone),
        subject: sanitizeInput(subject),
        message: sanitizeInput(message),
      });
      showToast('تم إرسال رسالتك بنجاح! سنتواصل معك قريباً.', 'success');
      setFormData({ name: '', email: '', phone: '', subject: '', message: '' });
    } catch (error: any) {
      const msg = error?.message || '';
      if (msg.includes('too many')) {
        showToast('محاولات كثيرة جداً، حاول لاحقاً', 'error');
      } else {
        showToast('خطأ في إرسال الرسالة، حاول مرة أخرى', 'error');
      }
    } finally {
      setSending(false);
    }
  }, [formData]);

  const update = (field: keyof typeof formData) =>
    (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setFormData(prev => ({ ...prev, [field]: e.target.value }));

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mt-20 mb-20">
        {/* Header */}
        <div className="text-center mb-16 animate-fade-in-up">
          <h1
            className="text-6xl md:text-7xl font-black mb-6 tracking-tighter"
            style={{ fontFamily: "'Playfair Display', serif" }}
          >
            تواصل <span className="text-primary italic">معنا</span>
          </h1>
          <div className="w-32 h-1.5 bg-linear-to-r from-primary to-accent mx-auto rounded-full mb-8"></div>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
            نحن هنا للإجابة على جميع استفساراتك وتوفير الدعم اللازم لك في رحلة البحث عن سيارتك المثالية.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start">
          {/* Contact Info */}
          <div className="space-y-6">
            <div className="card p-8 group hover:border-primary/50 transition-all duration-500 flex items-center gap-6">
              <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center text-3xl group-hover:scale-110 transition-transform">📍</div>
              <div>
                <h3 className="text-xl font-bold text-primary mb-1">العنوان</h3>
                <p className="text-muted-foreground">اليمن، صنعاء، ارتل، جامع الغيل، شركة غازي سوفت</p>
              </div>
            </div>

            <div className="card p-8 group hover:border-accent/50 transition-all duration-500 flex items-center gap-6">
              <div className="w-16 h-16 rounded-2xl bg-accent/10 flex items-center justify-center text-3xl group-hover:scale-110 transition-transform">📞</div>
              <div>
                <h3 className="text-xl font-bold text-accent mb-1">الهاتف</h3>
                <p className="text-muted-foreground" dir="ltr">+967 777 338 538</p>
                <p className="text-muted-foreground" dir="ltr">+967 777 795 197</p>
              </div>
            </div>

            <div className="card p-8 group hover:border-primary/50 transition-all duration-500 flex items-center gap-6">
              <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center text-3xl group-hover:scale-110 transition-transform">📧</div>
              <div>
                <h3 className="text-xl font-bold text-primary mb-1">البريد الإلكتروني</h3>
                <p className="text-muted-foreground">abdullehghazu076@gmail.com</p>
                <p className="text-muted-foreground text-xs">darkwebing9@gmail.com</p>
              </div>
            </div>

            <div className="card p-8 group hover:border-accent/50 transition-all duration-500 flex items-center gap-6">
              <div className="w-16 h-16 rounded-2xl bg-accent/10 flex items-center justify-center text-3xl group-hover:scale-110 transition-transform">🕒</div>
              <div>
                <h3 className="text-xl font-bold text-accent mb-1">ساعات العمل</h3>
                <p className="text-muted-foreground">السبت - الخميس: 9:00 ص - 6:00 م</p>
                <p className="text-muted-foreground text-sm italic">الجمعة: مغلق</p>
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <div className="card p-10 relative overflow-hidden shadow-2xl">
            <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 rounded-full blur-3xl -mr-16 -mt-16"></div>
            <div className="absolute bottom-0 left-0 w-32 h-32 bg-accent/10 rounded-full blur-3xl -ml-16 -mb-16"></div>

            <h2 className="text-3xl font-bold mb-8 relative z-10" style={{ fontFamily: "'Playfair Display', serif" }}>
              أرسل لنا رسالة
            </h2>

            <form onSubmit={handleSubmit} className="space-y-6 relative z-10" noValidate>
              <div className="form-group">
                <label className="form-label">الاسم الكامل *</label>
                <input
                  type="text"
                  required
                  className="form-input"
                  placeholder="أدخل اسمك..."
                  value={formData.name}
                  onChange={update('name')}
                  disabled={sending}
                  maxLength={100}
                  autoComplete="name"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="form-group">
                  <label className="form-label">البريد الإلكتروني *</label>
                  <input
                    type="email"
                    required
                    className="form-input"
                    placeholder="name@example.com"
                    value={formData.email}
                    onChange={update('email')}
                    disabled={sending}
                    maxLength={254}
                    autoComplete="email"
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">رقم الهاتف</label>
                  <input
                    type="tel"
                    className="form-input"
                    placeholder="+967..."
                    value={formData.phone}
                    onChange={update('phone')}
                    disabled={sending}
                    maxLength={20}
                    autoComplete="tel"
                  />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label text-xs md:text-sm">الموضوع</label>
                <input
                  type="text"
                  className="form-input text-sm"
                  placeholder="كيف يمكننا مساعدتك؟"
                  value={formData.subject}
                  onChange={update('subject')}
                  disabled={sending}
                  maxLength={200}
                />
              </div>

              <div className="form-group">
                <label className="form-label text-xs md:text-sm">الرسالة *</label>
                <textarea
                  required
                  rows={4}
                  className="form-input min-h-[120px] md:min-h-[150px] text-sm"
                  placeholder="اكتب رسالتك هنا..."
                  value={formData.message}
                  onChange={update('message')}
                  disabled={sending}
                  maxLength={5000}
                />
                <p className="text-[10px] md:text-xs text-muted-foreground mt-1 text-left">
                  {formData.message.length} / 5000
                </p>
              </div>

              <button
                type="submit"
                disabled={sending}
                className="w-full px-4 py-2 md:py-4 bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-bold rounded-lg text-sm md:text-base transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-xl shadow-primary/30 hover:shadow-primary/50"
              >
                {sending ? '⏳ جاري الإرسال...' : '🚀 إرسال'}
              </button>
            </form>
          </div>
        </div>

        {/* FAQ */}
        <div className="mt-12 md:mt-24">
          <div className="text-center mb-6 md:mb-12">
            <h2 className="text-2xl md:text-4xl font-bold mb-2 md:mb-4" style={{ fontFamily: "'Playfair Display', serif" }}>
              الأسئلة الشائعة
            </h2>
            <div className="w-24 h-1 bg-primary mx-auto rounded-full"></div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {[
              { q: 'كم وقت يستغرق الرد على استفساري؟', a: 'نحاول الرد على جميع الاستفسارات خلال 24 ساعة عمل كحد أقصى.' },
              { q: 'هل يمكنني حجز سيارة؟', a: 'نعم، يمكنك حجز السيارة من خلال صفحة تفاصيل السيارة أو بالتواصل المباشر معنا.' },
              { q: 'هل توفرون خدمة التوصيل؟', a: 'نعم، نوفر خدمة التوصيل الاحترافية إلى جميع مناطق اليمن وبأعلى معايير الأمان.' },
              { q: 'ما هي طرق الدفع المتاحة؟', a: 'نقبل التحويلات البنكية، الدفع النقدي، وجميع خدمات الصرافة المعتمدة.' },
            ].map((faq, i) => (
              <div key={i} className="card p-6 hover:bg-primary/5 transition-colors border-l-4 border-l-primary">
                <h3 className="font-bold text-foreground mb-3 text-lg">🤔 {faq.q}</h3>
                <p className="text-muted-foreground leading-relaxed">{faq.a}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
