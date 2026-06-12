/**
 * Footer Component
 * Design Philosophy: Modern Luxury Minimalism
 */
export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-top grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          <div>
            <h3 className="footer-brand">🚗 بوقاتي كار</h3>
            <p className="footer-copy">نصنع تجربة سيارات فاخرة من الطراز الأول، حيث يلتقي الأداء بالعالمية والتصميم بجوهر الفخامة.</p>
          </div>

          <div>
            <h4 className="footer-title">الروابط السريعة</h4>
            <ul className="space-y-2">
              <li><a href="/" className="footer-link">الرئيسية</a></li>
              <li><a href="#cars" className="footer-link">السيارات</a></li>
              <li><a href="/About" className="footer-link">عن الموقع</a></li>
              <li><a href="/Contact" className="footer-link">اتصل بنا</a></li>
            </ul>
          </div>

          <div>
            <h4 className="footer-title">المساعدة</h4>
            <ul className="space-y-2">
              <li><a href="/About" className="footer-link">الأسئلة الشائعة</a></li>
              <li><a href="#" className="footer-link">شروط الخدمة</a></li>
              <li><a href="#" className="footer-link">سياسة الخصوصية</a></li>
              <li><a href="/Contact" className="footer-link">اتصل بالدعم</a></li>
            </ul>
          </div>

          <div>
            <h4 className="footer-title">تابعنا</h4>
            <div className="footer-social">
              <a href="http://www.facebook.com" className="footer-social-link">f</a>
              <a href="http://www.x.com" className="footer-social-link">𝕏</a>
              <a href="http://www.instgram.com" className="footer-social-link">📷</a>
              <a href="http://www.youtube.com" className="footer-social-link">▶️</a>
            </div>
          </div>
        </div>

        <hr className="footer-divider" />

        <div className="footer-bottom">
          <p>&copy; {currentYear} بوقاتي كار. جميع الحقوق محفوظة.</p>
          <p>صُنع بـ ❤️ بفخامة واهتمام كامل</p>
        </div>
      </div>
    </footer>
  );
}