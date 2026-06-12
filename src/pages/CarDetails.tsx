import { useState, useEffect } from 'react';
import { useRoute } from 'wouter';
import type { Car } from '../types';
import { getCarById, createOrder, isLoggedIn, getCurrentUser } from '../lib/api';
import { showToast, formatPrice } from '../lib/utils';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

export default function CarDetails() {
  const [, params] = useRoute('/car/:id');
  // params may have numeric keys, so extract the first value
  const carIdValue = params ? Object.values(params)[0] : undefined;
  const carId = carIdValue ? parseInt(carIdValue) : null;

  const [car, setCar] = useState<Car | null>(null);
  const [loading, setLoading] = useState(true);
  const [ordering, setOrdering] = useState(false);
  const [showOrderForm, setShowOrderForm] = useState(false);
  const [lastOrderId, setLastOrderId] = useState<number | null>(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [orderData, setOrderData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    notes: '',
  });

  const user = getCurrentUser();

  useEffect(() => {
    if (carId) {
      loadCar();
    }
  }, [carId]);

  async function loadCar() {
    try {
      setLoading(true);
      if (carId) {
        const data = await getCarById(carId);
        setCar(data);
        if (user) {
          setOrderData(prev => ({
            ...prev,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
          }));
        }
      }
    } catch (error) {
      showToast('خطأ في تحميل تفاصيل السيارة', 'error');
    } finally {
      setLoading(false);
    }
  }

  async function handleOrderSubmit(e: React.FormEvent) {
    e.preventDefault();

    if (!isLoggedIn()) {
      showToast('يجب تسجيل الدخول أولاً', 'warning');
      window.location.href = '/login';
      return;
    }

    if (!orderData.firstName || !orderData.lastName || !orderData.email || !orderData.phone) {
      showToast('يرجى ملء جميع الحقول', 'warning');
      return;
    }

    try {
      setOrdering(true);
      if (carId) {
        const order = await createOrder({
          carId,
          ...orderData,
        });
        showToast('تم إرسال طلب الشراء بنجاح', 'success');
        setLastOrderId(order.id);
        setShowOrderForm(false);
        setOrderData({
          firstName: user?.firstName || '',
          lastName: user?.lastName || '',
          email: user?.email || '',
          phone: '',
          notes: '',
        });
      }
    } catch (error) {
      showToast('خطأ في إرسال الطلب', 'error');
    } finally {
      setOrdering(false);
    }
  }

  function nextImage() {
    if (car && car.images) {
      setCurrentImageIndex((prev) => (prev + 1) % car.images.length);
    }
  }

  function prevImage() {
    if (car && car.images) {
      setCurrentImageIndex((prev) => (prev - 1 + car.images.length) % car.images.length);
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mt-32 text-center">
          <p className="text-muted-foreground mt-4">جاري تحميل التفاصيل...</p>
        </div>
        <Footer />
      </div>
    );
  }

  if (!car) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mt-32 text-center">
          <p className="text-muted-foreground text-lg">السيارة غير موجودة</p>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mt-20 mb-20 px-3 md:px-0">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-8">
          {/* Images Section */}
          <div className="lg:col-span-2">
            <div className="card overflow-hidden">
              {car.images && car.images.length > 0 ? (
                <div className="relative detail-image-container">
                  <img
                    src={car.images[currentImageIndex].imageUrl}
                    alt={`${car.brand} ${car.model}`}
                    className="w-full h-full object-contain"
                  />
                  {car.images.length > 1 && (
                    <>
                      <button
                        onClick={prevImage}
                        className="absolute left-2 md:left-4 top-1/2 -translate-y-1/2 bg-black/60 hover:bg-black/80 text-white p-2 md:p-3 rounded-full transition-all hover:scale-110 z-10 text-sm md:text-base"
                        title="الصورة السابقة"
                      >
                        ❮
                      </button>
                      <button
                        onClick={nextImage}
                        className="absolute right-2 md:right-4 top-1/2 -translate-y-1/2 bg-black/60 hover:bg-black/80 text-white p-2 md:p-3 rounded-full transition-all hover:scale-110 z-10 text-sm md:text-base"
                        title="الصورة التالية"
                      >
                        ❯
                      </button>
                      <div className="absolute bottom-3 md:bottom-6 left-1/2 -translate-x-1/2 flex gap-1 md:gap-2 bg-black/40 px-2 md:px-4 py-1 md:py-2 rounded-full backdrop-blur-sm">
                        {car.images.map((_, idx) => (
                          <button
                            key={idx}
                            onClick={() => setCurrentImageIndex(idx)}
                            className={`transition-all ${
                              idx === currentImageIndex
                                ? 'w-2 md:w-3 h-2 md:h-3 bg-white rounded-full'
                                : 'w-1.5 md:w-2 h-1.5 md:h-2 bg-white/50 rounded-full hover:bg-white/70'
                            }`}
                            title={`الصورة ${idx + 1}`}
                          />
                        ))}
                      </div>
                      <div className="absolute top-2 md:top-4 right-2 md:right-4 bg-black/60 text-white px-2 md:px-3 py-0.5 md:py-1 rounded-full text-xs md:text-sm font-semibold">
                        {currentImageIndex + 1} / {car.images.length}
                      </div>
                    </>
                  )}
                </div>
              ) : (
                <div className="w-full h-64 md:h-96 flex items-center justify-center bg-linear-to-br from-gray-800 to-gray-900 text-gray-500">
                  <div className="text-center">
                    <div className="text-4xl mb-2">📷</div>
                    <p>بدون صورة</p>
                  </div>
                </div>
              )}
            </div>

            {/* Thumbnail Gallery */}
            {car.images && car.images.length > 1 && (
              <div className="card mt-4 md:mt-6 p-3 md:p-4">
                <div className="flex gap-2 md:gap-3 overflow-x-auto pb-2">
                  {car.images.map((image, idx) => (
                    <button
                      key={idx}
                      onClick={() => setCurrentImageIndex(idx)}
                      className={`shrink-0 w-16 md:w-20 h-16 md:h-20 rounded-lg overflow-hidden border-2 transition-all hover:scale-110 ${
                        idx === currentImageIndex
                          ? 'border-primary shadow-lg shadow-primary/50'
                          : 'border-border hover:border-primary/50'
                      }`}
                    >
                      <img
                        src={image.imageUrl}
                        alt={`thumbnail-${idx}`}
                        className="w-full h-full object-cover"
                      />
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Specifications */}
            <div className="card mt-6 md:mt-8">
              <div className="card-header">
                <h2 className="text-lg md:text-2xl font-bold text-secondary" style={{ fontFamily: "'Playfair Display', serif" }}>
                  📊 المواصفات
                </h2>
              </div>
              <div className="card-body">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-6">
                  <div className="bg-primary/10 p-2 md:p-4 rounded-lg border border-primary/20">
                    <p className="text-muted-foreground text-[10px] md:text-xs mb-1 md:mb-2 font-semibold">الماركة</p>
                    <p className="text-sm md:text-lg font-bold text-primary">{car.brand}</p>
                  </div>
                  <div className="bg-primary/10 p-2 md:p-4 rounded-lg border border-primary/20">
                    <p className="text-muted-foreground text-[10px] md:text-xs mb-1 md:mb-2 font-semibold">الموديل</p>
                    <p className="text-sm md:text-lg font-bold text-primary">{car.model}</p>
                  </div>
                  <div className="bg-accent/10 p-2 md:p-4 rounded-lg border border-accent/20">
                    <p className="text-muted-foreground text-[10px] md:text-xs mb-1 md:mb-2 font-semibold">السنة</p>
                    <p className="text-sm md:text-lg font-bold text-accent">{car.year}</p>
                  </div>
                  <div className={`p-2 md:p-4 rounded-lg border ${
                    car.isSold
                      ? 'bg-red-500/10 border-red-500/20'
                      : 'bg-green-500/10 border-green-500/20'
                  }`}>
                    <p className="text-muted-foreground text-[10px] md:text-xs mb-1 md:mb-2 font-semibold">الحالة</p>
                    <p className={`text-sm md:text-lg font-bold ${
                      car.isSold ? 'text-red-400' : 'text-green-400'
                    }`}>
                      {car.isSold ? '❌ مباع' : '✅ متاح'}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Description */}
            <div className="space-y-2 md:space-y-4 mt-6 md:mt-8">
  {(car.description || '')
    .split('\n')
    .reduce((acc: any[], line) => {
      if (!line.trim()) return acc;

      if (!line.includes(':')) {
        acc.push({ type: 'title', value: line });
      } else {
        const [key, value] = line.split(':');
        acc.push({
          type: 'row',
          key: key.trim(),
          value: value?.trim() || '',
        });
      }

      return acc;
    }, [])
    .map((item, i) =>
      item.type === 'title' ? (
        <div key={i} className="text-primary font-bold text-base md:text-lg mt-3 md:mt-4 border-b border-primary/30 pb-2">
          {item.value}
        </div>
      ) : (
        <div
          key={i}
          className="flex flex-col sm:flex-row sm:justify-between bg-black/30 px-3 md:px-4 py-2 md:py-3 rounded-lg border border-border gap-2"
        >
          <span className="text-gray-400 text-sm">{item.key}</span>
          <span className="text-white font-semibold text-right text-sm break-words">
            {item.value}
          </span>
        </div>
      )
    )}
</div>
          </div>

          {/* Sidebar - Price and Order */}
          <div>
            <div className="card sticky top-24 md:top-32">
              <div className="card-header border-b-0">
                <h2 className="text-2xl md:text-3xl font-bold text-primary">{formatPrice(car.price)}</h2>
              </div>
              <div className="card-body space-y-4">
                <p className="text-sm text-muted-foreground">
                  {car.isSold ? 'هذه السيارة تم بيعها' : 'السيارة متاحة للشراء الآن'}
                </p>
                <button
                  className="w-full px-4 py-2 bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-bold rounded-lg text-sm md:text-base transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={car.isSold}
                  onClick={() => setShowOrderForm(!showOrderForm)}
                >
                  {car.isSold ? '💵 مباع' : '💳 طلب الآن'}
                </button>

                {lastOrderId && (
                  <div className="mt-4 p-4 bg-primary/10 border border-primary/30 rounded-xl animate-pulse-glow">
                    <p className="text-sm text-white font-bold mb-3">
                      تم فتح غرفة دردشة خاصة بطلبك! هذه الغرفة خاصة بك وبمالك النظام للاستفسار على طلبك.
                    </p>
                    <a 
                      href={`/chat?orderId=${lastOrderId}`}
                      className="inline-block w-full text-center py-2 bg-primary text-secondary font-black rounded-lg hover:bg-white transition-colors"
                    >
                      انقر هنا للذهاب للدردشة
                    </a>
                  </div>
                )}

                {showOrderForm && !lastOrderId && (
                  <form onSubmit={handleOrderSubmit} className="space-y-3 md:space-y-4 mt-4 md:mt-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 md:gap-4">
                      <div className="form-group">
                        <label className="form-label text-xs md:text-sm">الاسم الأول</label>
                        <input
                          type="text"
                          className="form-input text-sm"
                          value={orderData.firstName}
                          onChange={(e) => setOrderData(prev => ({ ...prev, firstName: e.target.value }))}
                        />
                      </div>
                      <div className="form-group">
                        <label className="form-label text-xs md:text-sm">الاسم الأخير</label>
                        <input
                          type="text"
                          className="form-input text-sm"
                          value={orderData.lastName}
                          onChange={(e) => setOrderData(prev => ({ ...prev, lastName: e.target.value }))}
                        />
                      </div>
                    </div>

                    <div className="form-group">
                      <label className="form-label text-xs md:text-sm">البريد الإلكتروني</label>
                      <input
                        type="email"
                        className="form-input text-sm"
                        value={orderData.email}
                        onChange={(e) => setOrderData(prev => ({ ...prev, email: e.target.value }))}
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label text-xs md:text-sm">رقم الهاتف</label>
                      <input
                        type="tel"
                        className="form-input text-sm"
                        value={orderData.phone}
                        onChange={(e) => setOrderData(prev => ({ ...prev, phone: e.target.value }))}
                      />
                    </div>

                    <div className="form-group">
                      <label className="form-label text-xs md:text-sm">ملاحظات</label>
                      <textarea
                        className="form-input resize-none min-h-[80px] md:min-h-[100px] text-sm"
                        value={orderData.notes}
                        onChange={(e) => setOrderData(prev => ({ ...prev, notes: e.target.value }))}
                      />
                    </div>

                    <button
                      type="submit"
                      disabled={ordering}
                      className="w-full px-4 py-2 bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-bold rounded-lg text-sm md:text-base transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {ordering ? 'جاري الإرسال...' : 'إرسال طلب الشراء'}
                    </button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
