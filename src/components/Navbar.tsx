import { useState } from 'react';
import { isLoggedIn, getCurrentUser, logout } from '../lib/api';
import { showToast } from '../lib/utils';

/**
 * Navbar Component
 * Design Philosophy: Modern Luxury Minimalism with Enhanced Mobile Experience
 * Fixed navigation with responsive menu and smooth animations
 */
export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const user = getCurrentUser();

  function handleLogout() {
    logout();
    showToast('تم تسجيل الخروج بنجاح', 'success');
    window.location.href = '/';
  }

  return (
    <nav className="navbar">
      <div className="container navbar-content">
        <a href="/" className="navbar-brand flex items-center gap-2">
          <span className="text-2xl">🚗</span>
          <span className="font-bold tracking-tighter" style={{ fontFamily: "'Playfair Display', serif" }}>بوقاتي كار</span>
        </a>

        {/* Desktop Links */}
        <div className="navbar-links hidden lg:flex">
          <a href="/" className="navbar-link">الرئيسية</a>
          <a href="/chat" className="navbar-link">الدردشة</a>
          <a href="/About" className="navbar-link">عن الموقع</a>
          <a href="/Contact" className="navbar-link">اتصل بنا</a>
        </div>

        {/* Auth Buttons / User Info - Desktop */}
        <div className="hidden lg:flex gap-3 items-center">
          {isLoggedIn() ? (
            <>
              <div className="flex flex-col items-end mr-2">
                <span className="text-primary text-xs font-bold uppercase tracking-widest">مرحباً بك</span>
                <span className="text-foreground text-sm font-semibold">{user?.firstName} {user?.lastName}</span>
              </div>
              {user?.role === 'admin' && (
                <a href="/admin" className="btn btn-small btn-outline hover:shadow-lg transition-shadow">
                  ⚙️ لوحة التحكم
                </a>
              )}
              <button
                onClick={handleLogout}
                className="btn btn-small btn-secondary hover:shadow-lg transition-shadow"
              >
                تسجيل الخروج
              </button>
            </>
          ) : (
            <>
              <a href="/login" className="btn btn-small btn-outline hover:shadow-lg transition-shadow">
                دخول
              </a>
              <a href="/register" className="btn btn-small btn-primary hover:shadow-lg transition-shadow">
                إنشاء حساب
              </a>
            </>
          )}
        </div>

        {/* Mobile Menu Toggle */}
        <button
          className="lg:hidden text-foreground text-3xl focus:outline-none transition-all duration-300 hover:scale-110 hover:text-primary"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          aria-label="تبديل القائمة"
          aria-expanded={mobileMenuOpen}
        >
          {mobileMenuOpen ? '✕' : '☰'}
        </button>
      </div>

      {/* Mobile Menu Overlay */}
      <div
        className={`fixed inset-0 z-[9999] lg:hidden transition-all duration-300 ease-in-out ${
          mobileMenuOpen ? 'opacity-100 visible' : 'opacity-0 invisible'
        }`}
        style={{ pointerEvents: mobileMenuOpen ? 'auto' : 'none' }}
      >
        {/* Background */}
        <div
          className="absolute inset-0 bg-black/70 backdrop-blur-md transition-all duration-300"
          onClick={() => setMobileMenuOpen(false)}
          role="presentation"
        />

        {/* Drawer Panel */}
        <div
          className={`absolute right-0 top-0 bottom-0 h-screen overflow-y-auto
          w-[100%] sm:w-[85%] lg:w-[75%]
          bg-gradient-to-b from-[#050b18] via-[#0a1120] to-[#050b18]
          border-l-4 border-primary/30
          shadow-2xl shadow-black/60
          transform transition-transform duration-300 ease-out
          ${mobileMenuOpen ? 'translate-x-0' : 'translate-x-full'}`}
          style={{ maxHeight: '100vh' }}
        >
          {/* Inner wrapper with improved spacing */}
          <div className="w-full p-5 sm:p-6 md:p-8 flex flex-col min-h-screen">

            {/* Header with Logo */}
            <div className="flex justify-between items-center mb-8 pb-6 border-b border-white/10 flex-shrink-0">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🚗</span>
                <span
                  className="text-lg font-bold text-primary tracking-widest"
                  style={{ fontFamily: "'Playfair Display', serif" }}
                >
                  بوقاتي
                </span>
              </div>

              <button
                onClick={() => setMobileMenuOpen(false)}
                className="text-white text-2xl w-10 h-10 flex items-center justify-center rounded-full hover:bg-primary/20 hover:text-primary transition-all duration-200 active:scale-95 flex-shrink-0"
                aria-label="إغلاق القائمة"
              >
                ✕
              </button>
            </div>

            {/* Scrollable Content */}
            <div className="flex-1 overflow-y-auto">
              {/* Navigation Links */}
              <div className="flex flex-col gap-2 mb-8">
                {[
                  { label: 'الرئيسية', href: '/', icon: '🏠' },
                  { label: 'الدردشة', href: '/chat', icon: '💬' },
                  { label: 'عن الموقع', href: '/About', icon: 'ℹ️' },
                  { label: 'اتصل بنا', href: '/Contact', icon: '📞' },
                ].map((item, i) => (
                  <a
                    key={i}
                    href={item.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className="text-base sm:text-lg font-semibold text-white/90 py-3 sm:py-4 px-4 rounded-lg
                    hover:bg-primary/20 hover:text-primary hover:pl-6
                    active:bg-primary/30
                    transition-all duration-200 flex items-center gap-3"
                  >
                    <span className="text-xl">{item.icon}</span>
                    {item.label}
                  </a>
                ))}
              </div>

              {/* Divider */}
              <div className="h-px bg-gradient-to-r from-transparent via-white/20 to-transparent my-6" />

              {/* Auth Section */}
              {isLoggedIn() ? (
                <div className="flex flex-col gap-3">
                  {/* User Welcome */}
                  <div className="bg-primary/10 rounded-lg p-4 mb-2 border border-primary/20">
                    <div className="text-white text-sm opacity-90">
                      مرحباً،
                    </div>
                    <div className="text-primary font-bold text-base sm:text-lg">
                      {user?.firstName} {user?.lastName}
                    </div>
                  </div>

                  {/* Admin Dashboard Button */}
                  {user?.role === 'admin' && (
                    <a
                      href="/admin"
                      onClick={() => setMobileMenuOpen(false)}
                      className="bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary text-black font-bold py-3 sm:py-4 rounded-lg text-center transition-all duration-200 active:scale-95 shadow-lg shadow-primary/30 text-sm sm:text-base"
                    >
                      ⚙️ لوحة التحكم
                    </a>
                  )}

                  {/* Logout Button */}
                  <button
                    onClick={handleLogout}
                    className="border-2 border-white/30 text-white py-3 sm:py-4 rounded-lg
                    hover:border-primary hover:bg-primary/10 hover:text-primary
                    active:bg-primary/20
                    font-semibold transition-all duration-200 text-sm sm:text-base"
                  >
                    تسجيل الخروج
                  </button>
                </div>
              ) : (
                <div className="flex flex-col gap-3">
                  {/* Login Button */}
                  <a
                    href="/login"
                    onClick={() => setMobileMenuOpen(false)}
                    className="border-2 border-white/30 text-white py-3 sm:py-4 rounded-lg text-center font-semibold
                    hover:border-primary hover:bg-primary/10 hover:text-primary
                    active:bg-primary/20
                    transition-all duration-200 text-sm sm:text-base"
                  >
                    🔐 دخول
                  </a>

                  {/* Register Button */}
                  <a
                    href="/register"
                    onClick={() => setMobileMenuOpen(false)}
                    className="bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary text-black font-bold py-3 sm:py-4 rounded-lg text-center transition-all duration-200 active:scale-95 shadow-lg shadow-primary/30 text-sm sm:text-base"
                  >
                    ✨ إنشاء حساب
                  </a>
                </div>
              )}
            </div>

            {/* Footer Info */}
            <div className="border-t border-white/10 mt-6 pt-4 text-center text-white/50 text-xs flex-shrink-0">
              <p>بوقاتي كار © 2024</p>
            </div>
          </div>
        </div>
      </div>
    </nav>


  );
}
