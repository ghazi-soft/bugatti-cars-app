import { useState, useEffect } from 'react';
import type { Car } from '../types';
import { getCars, isLoggedIn, getCurrentUser } from '../lib/api';
import { showToast, formatPrice, showLoading, hideLoading } from '../lib/utils';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

/**
 * Home Page - Car Dealership
 * Design Philosophy: Modern Luxury Minimalism
 * Displays hero section and car listings
 */
export default function Home() {
  const [cars, setCars] = useState<Car[]>([]);
  const [loading, setLoading] = useState(true);
  const [filteredCars, setFilteredCars] = useState<Car[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState('newest');

  const user = getCurrentUser();

  useEffect(() => {
    loadCars();
  }, []);

  useEffect(() => {
    filterAndSortCars();
  }, [cars, searchTerm, sortBy]);

  async function loadCars() {
    try {
      setLoading(true);
      const data = await getCars();
      setCars(data || []);
    } catch (error) {
      showToast('خطأ في تحميل السيارات', 'error');
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  function filterAndSortCars() {
  const term = searchTerm.toLowerCase();

  let filtered = cars.filter(car =>
    (car.brand || '').toLowerCase().includes(term) ||
    (car.model || '').toLowerCase().includes(term) ||
    String(car.year || '').includes(term)
  );

    // Sort
    if (sortBy === 'price-low') {
      filtered.sort((a, b) => a.price - b.price);
    } else if (sortBy === 'price-high') {
      filtered.sort((a, b) => b.price - a.price);
    } else if (sortBy === 'newest') {
      filtered.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    }

    setFilteredCars(filtered);
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      {/* Hero Section */}
      <section className="hero px-4 md:px-0">
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden opacity-10 pointer-events-none">
  <div className="animate-pulse text-4xl md:text-6xl absolute top-5 md:top-10 left-5 md:left-10">🚗</div>
  <div className="animate-bounce text-3xl md:text-5xl absolute top-24 md:top-40 right-5 md:right-20">🚙</div>
  <div className="animate-pulse text-5xl md:text-7xl absolute bottom-5 md:bottom-10 left-1/3">🏎️</div>
</div>
        <div className="hero-content">
          <div className="hero-text flex-1 animate-fade-in-up">
            <span className="hero-badge text-xs md:text-sm">بوقاتي كار</span>
            <h1 className="hero-title text-2xl md:text-4xl lg:text-5xl">أقوى تجربة لشراء السيارات الفاخرة بثقة كاملة</h1>
            <p className="hero-copy text-sm md:text-base lg:text-lg">سيارتك القادمة هنا. تصميم راقٍ، أداء قوي، وعروض مميزة تمنحك قيادة فخمة من اللحظة الأولى.</p>
            <div className="hero-actions flex-wrap">
              <button
  onClick={() => {
    document.getElementById('cars')?.scrollIntoView({
      behavior: 'smooth'
    });
  }}
  className="relative px-4 md:px-8 py-2 md:py-3 rounded-2xl bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-bold overflow-hidden group text-sm md:text-base"
>
  <span className="relative z-10">ابدأ رحلتك الآن 🚗</span>

  <span className="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition duration-700"></span>
</button>
            </div>
          </div>
          <div className="hero-image hidden lg:block" />
        </div>
      </section>

      {/* Search and Filter */}
      <section id="cars" className="container py-8 md:py-12 px-3 md:px-0">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3 md:gap-6 mb-6 md:mb-8">
          <div className="form-group">
            <label className="form-label">البحث عن سيارة</label>
            <input
              type="text"
              className="form-input"
              placeholder="ابحث عن الماركة أو الموديل..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label className="form-label">الترتيب</label>
            <select
              className="form-select"
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
            >
              <option value="newest">الأحدث</option>
              <option value="price-low">السعر: من الأقل للأعلى</option>
              <option value="price-high">السعر: من الأعلى للأقل</option>
            </select>
          </div>

          <div className="form-group flex items-end">
            <button className="btn btn-secondary w-full">
              تصفية متقدمة
            </button>
          </div>
        </div>

        {/* Results Count */}
        <div className="mb-4 md:mb-6 text-foreground text-sm md:text-base">
          <p>عدد النتائج: <strong>{filteredCars.length}</strong> سيارة</p>
        </div>

        {/* Cars Grid */}
        {loading ? (
          <div className="text-center py-12">
            <div className="spinner mx-auto"></div>
            <p className="text-muted-foreground mt-4">جاري تحميل السيارات...</p>
          </div>
        ) : filteredCars.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-muted-foreground text-lg">لم يتم العثور على سيارات</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            {filteredCars.map((car) => (
              <div key={car.id} className="glass-card rounded-2xl overflow-hidden hover:border-primary/50 transition-all duration-500 animate-fade-in-up flex flex-col">
                <div className="w-full h-40 sm:h-48 md:h-56 overflow-hidden rounded-t-2xl">
                  {car.images && car.images.length > 0 ? (
                    <img src={car.images[0].imageUrl} alt={`${car.brand} ${car.model}`} className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center bg-linear-to-br from-gray-700 to-gray-900 text-gray-500">
                      <div className="text-center">
                        <div className="text-3xl mb-1">📷</div>
                        <p className="text-xs">بدون صورة</p>
                      </div>
                    </div>
                  )}
                </div>
                <div className="p-4 md:p-6 flex-1 flex flex-col justify-between">

  <div className={`inline-block mb-3 px-2 py-1 rounded-lg text-xs font-bold ${car.isSold ? 'bg-red-500/20 text-red-400' : 'bg-green-500/20 text-green-400'}`}>
    {car.isSold ? '❌ مباع' : '✅ متاح'}
  </div>

  {/* العنوان */}
  <h3 className="text-lg md:text-xl font-bold text-white mb-3">
    🚗 {car.brand} <span className="text-primary">{car.model}</span>
  </h3>

  {/* تقسيم البيانات بشكل جميل */}
  <div className="grid grid-cols-2 gap-2 md:gap-3 mb-4">
    <div className="bg-white/5 p-2 md:p-3 rounded-lg border border-white/10">
      <p className="text-[10px] md:text-xs text-muted-foreground mb-1">🏷️ الماركة</p>
      <p className="text-xs md:text-sm font-bold text-white">{car.brand}</p>
    </div>

    <div className="bg-white/5 p-2 md:p-3 rounded-lg border border-white/10">
      <p className="text-[10px] md:text-xs text-muted-foreground mb-1">🚘 الموديل</p>
      <p className="text-xs md:text-sm font-bold text-white">{car.model}</p>
    </div>

    <div className="bg-white/5 p-2 md:p-3 rounded-lg border border-white/10">
      <p className="text-[10px] md:text-xs text-muted-foreground mb-1">📅 السنة</p>
      <p className="text-xs md:text-sm font-bold text-white">{car.year}</p>
    </div>

    <div className="bg-primary/10 p-2 md:p-3 rounded-lg border border-primary/20">
      <p className="text-[10px] md:text-xs text-muted-foreground mb-1">💵 السعر</p>
      <p className="text-xs md:text-sm font-bold text-primary">{formatPrice(car.price)}</p>
    </div>
  </div>

  {/* الوصف / المواصفات */}
  <div className="mb-4">
    <p className="text-xs font-bold text-white mb-1">⚙️ المواصفات:</p>
    <p className="text-[11px] text-muted-foreground line-clamp-2">
      {car.description || 'لا توجد مواصفات إضافية'}
    </p>
  </div>

  <div className="flex gap-2 mt-auto">
    <button
      className="flex-1 px-3 py-2 bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-bold rounded-lg text-xs md:text-sm transition-all disabled:opacity-50 disabled:cursor-not-allowed"
      disabled={car.isSold}
      onClick={() => {
        if (isLoggedIn()) {
          window.location.href = `/car/${car.id}`;
        } else {
          showToast('يجب تسجيل الدخول أولاً', 'info');
          window.location.href = '/login';
        }
      }}
    >
      {car.isSold ? 'مباع' : '🔍 التفاصيل'}
    </button>

    {!car.isSold && (
      <button className="flex-1 px-3 py-2 bg-white/10 hover:bg-white/20 border border-white/20 text-white font-bold rounded-lg text-xs md:text-sm transition-all">
        ❤️
      </button>
    )}
  </div>

</div>
              </div>
            ))}
          </div>
        )}
      </section>

      <Footer />
    </div>
  );
}
