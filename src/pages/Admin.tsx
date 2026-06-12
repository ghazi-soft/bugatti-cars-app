import { useState, useEffect, useMemo, useRef } from 'react';
import type { Car, Order, User, CMSPage, CarImage, ChatMessage } from '../types';
import {
  getCars,
  getAllOrders,
  getUsers,
  deleteCar,
  createCar,
  updateCar,
  deleteOrder,
  isAdmin,
  addCarImage,
  deleteCarImage,
  getAllCMSPages,
  updateCMSPage,
  getContactMessages,
  updateUserRole,
  deleteUser,
  apiCall,
  getCurrentUser,
  getOrderChatMessages,
  getChatMessages,
  sendChatMessage,
  deleteChatMessage
} from '../lib/api';

import { showToast, formatPrice } from '../lib/utils';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

type CarForm = {
  id?: number;
  brand: string;
  model: string;
  year: number;
  price: number;
  description: string;
  images?: string[];
  isSold?: boolean;
};

// ============ IMAGE COMPRESSION UTILITY ============
async function compressImage(file: File, maxWidth: number = 800, maxHeight: number = 600, quality: number = 0.7): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = (event) => {
      const img = new Image();
      
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;

        // حساب الحجم الجديد مع الحفاظ على النسبة
        if (width > height) {
          if (width > maxWidth) {
            height = Math.round((height * maxWidth) / width);
            width = maxWidth;
          }
        } else {
          if (height > maxHeight) {
            width = Math.round((width * maxHeight) / height);
            height = maxHeight;
          }
        }

        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext('2d');
        if (!ctx) {
          reject(new Error('Failed to get canvas context'));
          return;
        }

        ctx.drawImage(img, 0, 0, width, height);

        // تحويل إلى Base64 مع ضغط
        const compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
        resolve(compressedDataUrl);
      };

      img.onerror = () => {
        reject(new Error('Failed to load image'));
      };

      img.src = event.target?.result as string;
    };

    reader.onerror = () => {
      reject(new Error('Failed to read file'));
    };

    reader.readAsDataURL(file);
  });
}

// دالة لحساب حجم Base64
function getBase64Size(base64: string): number {
  return Math.round((base64.length * 3) / 4 / 1024); // بالـ KB
}

export default function Admin() {
  const [messages, setMessages] = useState<any[]>([]); // لحفظ رسائل اتصل بنا
  const [selectedOrderChat, setSelectedOrderChat] = useState<number | 'public' | null>(null);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [activeTab, setActiveTab] = useState('cars');
  const [cars, setCars] = useState<Car[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [cmsPages, setCmsPages] = useState<CMSPage[]>([]);
  const [loading, setLoading] = useState(true);

  const [showModal, setShowModal] = useState(false);
  const [editingCar, setEditingCar] = useState<CarForm | null>(null);
  const [uploadingImages, setUploadingImages] = useState(false);
  const [imagePreview, setImagePreview] = useState<{ url: string; size: number; id?: number }[]>([]);
  const [compressingImage, setCompressingImage] = useState(false);
  const [originalImages, setOriginalImages] = useState<CarImage[]>([]);

  // CMS States
  const [editingCMSPage, setEditingCMSPage] = useState<CMSPage | null>(null);
  const [showCMSModal, setShowCMSModal] = useState(false);
  const [savingCMS, setSavingCMS] = useState(false);

  // Chat States
  const [newMessage, setNewMessage] = useState('');
  const [sendingChat, setSendingChat] = useState(false);
  const chatEndRef = useRef<HTMLDivElement>(null);
  const user = getCurrentUser();

  useEffect(() => {
    if (!isAdmin()) {
      window.location.href = '/';
      return;
    }
    loadData();
  }, []);

  // تم إلغاء التمرير التلقائي عند وصول رسائل جديدة - لا يتم التمرير إلا عند الإرسال
  // useEffect(() => {
  //   const chatContainer = chatEndRef.current?.parentElement;
  //   if (chatContainer) {
  //     const isAtBottom = chatContainer.scrollHeight - chatContainer.scrollTop - chatContainer.clientHeight < 50;
  //     if (isAtBottom) {
  //       chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  //     }
  //   }
  // }, [chatMessages]);

  // تحديث تلقائي للدردشة
  useEffect(() => {
    let intervalId: number;
    if (activeTab === 'chat' && selectedOrderChat) {
      intervalId = window.setInterval(() => {
        if (selectedOrderChat === 'public') {
          getChatMessages().then(data => {
             if (Array.isArray(data)) setChatMessages(data.filter(m => !m.orderId));
          });
        } else {
          getOrderChatMessages(selectedOrderChat).then(data => {
            if (Array.isArray(data)) setChatMessages(data);
          });
        }
      }, 4000);
    }
    return () => {
      if (intervalId) window.clearInterval(intervalId);
    };
  }, [activeTab, selectedOrderChat]);

  async function loadData() {
    try {
      setLoading(true);

      const [carsData, ordersData, usersData, cmsData, messagesData] = await Promise.all([
        getCars(),
        getAllOrders(),
        getUsers(),
        getAllCMSPages(),
        getContactMessages(),
      ]);

      setMessages(messagesData || []);
      setCars(carsData || []);
      setOrders(ordersData || []);
      setUsers(usersData || []);
      setCmsPages(cmsData || []);
    } catch (err) {
      showToast('خطأ في تحميل البيانات', 'error');
    } finally {
      setLoading(false);
    }
  }

  async function loadOrderChat(orderId: number | 'public') {
    try {
      let data;
      if (orderId === 'public') {
        data = await getChatMessages();
        data = Array.isArray(data) ? data.filter(m => !m.orderId) : [];
      } else {
        data = await getOrderChatMessages(orderId);
      }

      setChatMessages(data || []);
      setSelectedOrderChat(orderId);
    } catch (err) {
      console.error(err);
      showToast('فشل تحميل الدردشة', 'error');
    }
  }

  async function handleSendChat() {
    if (!user) return;
    const trimmed = newMessage.trim();
    if (!trimmed) return;

    setSendingChat(true);
    try {
      const orderId = selectedOrderChat === 'public' ? undefined : (selectedOrderChat as number);
      await sendChatMessage(trimmed, orderId);
      setNewMessage('');
      if (selectedOrderChat) await loadOrderChat(selectedOrderChat);
      // تمرير للأسفل عند الإرسال
      setTimeout(() => {
        chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    } catch (error) {
      console.error(error);
      showToast('فشل إرسال الرسالة', 'error');
    } finally {
      setSendingChat(false);
    }
  }

  async function handleDeleteChatMessage(id: number) {
    if (!confirm('هل أنت متأكد من حذف هذه الرسالة؟')) return;
    try {
      await deleteChatMessage(id);
      setChatMessages(prev => prev.filter(m => m.id !== id));
      showToast('تم حذف الرسالة', 'success');
    } catch (error) {
      showToast('فشل حذف الرسالة', 'error');
    }
  }

  const sortedChatMessages = useMemo(
    () => [...(chatMessages || [])].sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()),
    [chatMessages]
  );

  // ================= CAR =================

  function openAddModal() {
    setEditingCar({
      brand: '',
      model: '',
      year: new Date().getFullYear(),
      price: 0,
      description: '',
      images: [],
      isSold: false,
    });

    setOriginalImages([]);
    setImagePreview([]);
    setShowModal(true);
  }

  function openEditModal(car: Car) {
    const carImages = car.images || [];

    setOriginalImages(carImages);

    setEditingCar({
      id: car.id,
      brand: car.brand,
      model: car.model,
      year: car.year,
      price: car.price,
      description: car.description || '',
      images: carImages.map(img => img.imageUrl),
      isSold: car.isSold || false,
    });

    setImagePreview(
      carImages.map((img) => ({
        url: img.imageUrl,
        size: getBase64Size(img.imageUrl),
        id: img.id,
      }))
    );

    setShowModal(true);
  }

  async function handleImageSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const files = e.target.files;

    if (!files || !editingCar) return;

    const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/svg+xml'];
    const maxFileSize = 5 * 1024 * 1024;

    setCompressingImage(true);

    try {
      const addedImages: string[] = [];
      const addedPreview: { url: string; size: number }[] = [];

      for (const file of Array.from(files)) {
        if (!validTypes.includes(file.type)) {
          showToast(`صيغة ${file.name} غير مدعومة`, 'warning');
          continue;
        }

        if (file.size > maxFileSize) {
          showToast(`حجم ${file.name} كبير جداً`, 'warning');
          continue;
        }

        try {
          let compressed = await compressImage(file, 800, 600, 0.75);
          let size = getBase64Size(compressed);

          if (size > 500) {
            compressed = await compressImage(file, 600, 400, 0.5);
            size = getBase64Size(compressed);
          }

          const alreadyExists = editingCar.images?.includes(compressed) || addedImages.includes(compressed);
          if (alreadyExists) continue;

          addedImages.push(compressed);
          addedPreview.push({ url: compressed, size });
        } catch (err) {
          showToast(`خطأ في ضغط ${file.name}`, 'error');
        }
      }

      setEditingCar((prev) => {
        if (!prev) return prev;
        return {
          ...prev,
          images: [...(prev.images || []), ...addedImages],
        };
      });

      setImagePreview((prev) => [...prev, ...addedPreview]);
    } finally {
      setCompressingImage(false);
    }
  }

  async function removeImage(index: number) {
    if (!editingCar) return;
    setImagePreview((prev) => prev.filter((_, i) => i !== index));
    setEditingCar({
      ...editingCar,
      images: editingCar.images?.filter((_, i) => i !== index) || [],
    });
    showToast('سيتم حذف الصورة عند الحفظ', 'info');
  }

  async function handleSaveCar() {
    if (!editingCar) return;
    if (!editingCar.brand || !editingCar.model || editingCar.price === 0) {
      showToast('يرجى ملء جميع الحقول المطلوبة', 'warning');
      return;
    }

    try {
      setUploadingImages(true);
      const carData = {
        brand: editingCar.brand,
        model: editingCar.model,
        year: editingCar.year,
        price: editingCar.price,
        description: editingCar.description,
        isSold: editingCar.isSold,
      };

      if (editingCar.id) {
        const updated = await updateCar(editingCar.id, carData);
        const removedImages = originalImages.filter(img => !editingCar.images?.includes(img.imageUrl));
        
        for (const image of removedImages) {
          try {
            await deleteCarImage(editingCar.id, image.id);
          } catch (err) {
            console.error('Failed to delete image:', image.id, err);
          }
        }

        const newImages = (editingCar.images || []).filter((img) => {
          if (!img.startsWith('data:')) return false;
          if (originalImages.some(orig => orig.imageUrl === img)) return false;
          return true;
        });

        const uniqueImages = newImages.filter((img, index, self) => self.indexOf(img) === index);
        for (const image of uniqueImages) {
          await addCarImage(editingCar.id, image);
        }

        setCars(cars.map((c) => c.id === updated.id ? updated : c));
        showToast('تم تحديث السيارة بنجاح', 'success');
      } else {
        const newCar = await createCar(carData);
        const uniqueImages = (editingCar.images || []).filter(
          (img, index, self) => img.startsWith('data:') && self.indexOf(img) === index
        );

        for (const image of uniqueImages) {
          await addCarImage(newCar.id, image);
        }

        setCars([newCar, ...cars]);
        showToast('تم إضافة السيارة بنجاح', 'success');
      }

      setShowModal(false);
      setEditingCar(null);
      setImagePreview([]);
      await loadData();
    } catch (err) {
      console.error(err);
      showToast('خطأ في حفظ السيارة', 'error');
    } finally {
      setUploadingImages(false);
    }
  }

  async function handleDeleteCar(carId: number) {
    if (!confirm('هل أنت متأكد من حذف هذه السيارة؟')) return;
    try {
      await deleteCar(carId);
      setCars(cars.filter((c) => c.id !== carId));
      showToast('تم حذف السيارة بنجاح', 'success');
    } catch (err) {
      showToast('خطأ في حذف السيارة', 'error');
    }
  }

  async function handleDeleteOrder(orderId: number) {
    if (!confirm('هل أنت متأكد من حذف هذا الطلب؟')) return;
    try {
      await deleteOrder(orderId);
      setOrders(orders.filter((o) => o.id !== orderId));
      showToast('تم حذف الطلب بنجاح', 'success');
    } catch (err) {
      showToast('خطأ في حذف الطلب', 'error');
    }
  }

  // ================= CMS HANDLERS =================

  function openEditCMSModal(page: CMSPage) {
    setEditingCMSPage({ ...page });
    setShowCMSModal(true);
  }

  async function handleSaveCMSPage() {
    if (!editingCMSPage) return;
    if (!editingCMSPage.title || !editingCMSPage.content) {
      showToast('يرجى ملء جميع الحقول المطلوبة', 'warning');
      return;
    }

    try {
      setSavingCMS(true);
      await updateCMSPage(editingCMSPage.slug, editingCMSPage.title, editingCMSPage.content);
      setCmsPages(cmsPages.map((p) => p.slug === editingCMSPage.slug ? editingCMSPage : p));
      showToast('تم تحديث الصفحة بنجاح', 'success');
      setEditingCMSPage(null);
      setShowCMSModal(false);
    } catch (err) {
      console.error(err);
      showToast('خطأ في حفظ الصفحة', 'error');
    } finally {
      setSavingCMS(false);
    }
  }

  async function handleDeleteUser(id: number) {
    if (!confirm('هل أنت متأكد من حذف المستخدم؟')) return;
    try {
      await deleteUser(id);
      setUsers(users.filter((u) => u.id !== id));
      showToast('تم حذف المستخدم بنجاح', 'success');
    } catch (err) {
      console.error(err);
      showToast('فشل حذف المستخدم', 'error');
    }
  }

  async function handleChangeRole(userId: number, role: string) {
    try {
      await updateUserRole(userId, role);
      setUsers(users.map((u) => u.id === userId ? { ...u, role: role as 'user' | 'admin' } : u));
      showToast('تم تحديث الصلاحية', 'success');
    } catch (err) {
      console.error(err);
      showToast('فشل تحديث الصلاحية', 'error');
    }
  }

  async function handleToggleActive(userId: number, current: boolean) {
    try {
      const newStatus = !current;
      await apiCall(`/admin/users/${userId}/active`, {
        method: 'PUT',
        body: JSON.stringify({ isActive: newStatus }),
      });
      setUsers(users.map((u) => u.id === userId ? { ...u, isActive: newStatus } : u));
      showToast(newStatus ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم', 'success');
    } catch (err) {
      console.error(err);
      showToast('فشل تحديث الحالة', 'error');
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mt-32 text-center">
          <div className="animate-pulse flex flex-col items-center">
            <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mb-4"></div>
            <p className="text-muted-foreground font-bold text-xl">جاري تحميل لوحة التحكم...</p>
          </div>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <div className="container mt-12 md:mt-24 mb-20 px-3 md:px-0 animate-fade-in-up">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-10 gap-2 md:gap-4 glass-card-premium p-4 md:p-8">
          <div>
            <h1 className="text-2xl md:text-4xl lg:text-5xl font-black text-white mb-2 glow-text" style={{ fontFamily: "'Playfair Display', serif" }}>
              لوحة التحكم الملكية
            </h1>
            <p className="text-cyan-400/80 font-medium tracking-wide">أهلاً بك في مركز القيادة، حيث تلتقي الفخامة بالإدارة.</p>
          </div>
          <div className="bg-linear-to-r from-primary/20 to-accent-2/20 text-white px-8 py-4 rounded-2xl border border-primary/30 shadow-glow animate-pulse-glow">
            <span className="font-bold opacity-70 ml-2">المسؤول التنفيذي: </span>
            <span className="font-black text-lg">{user?.firstName} {user?.lastName}</span>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex flex-wrap gap-2 md:gap-2 md:gap-4 mb-4 md:mb-8 md:mb-12 p-1.5 md:p-2 overflow-x-auto bg-white/5 rounded-3xl backdrop-blur-md border border-white/10">
          {[
            { id: 'cars', label: 'الأسطول', count: cars.length, icon: '🏎️' },
            { id: 'orders', label: 'المبيعات', count: orders.length, icon: '💎' },
            { id: 'chat', label: 'المحادثات', count: 'LIVE', icon: '💬' },
            { id: 'users', label: 'الأعضاء', count: users.length, icon: '👑' },
            { id: 'cms', label: 'المحتوى', count: cmsPages.length, icon: '📝' },
            { id: 'messages', label: 'البريد', count: messages.length, icon: '📧' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`admin-tab-button flex items-center gap-3 px-2 md:px-6 py-2 md:py-4 rounded-2xl text-xs md:text-base whitespace-nowrap font-bold transition-all ${
                activeTab === tab.id 
                ? 'active bg-linear-to-r from-cyan-500 to-blue-600 text-white shadow-lg' 
                : 'text-white/60 hover:bg-white/10 hover:text-white'
              }`}
            >
              <span className="text-xl">{tab.icon}</span>
              <span>{tab.label}</span>
              <span className={`text-[10px] px-2 py-1 rounded-lg font-black ${activeTab === tab.id ? 'bg-white/30' : 'bg-white/10'}`}>
                {tab.count}
              </span>
            </button>
          ))}
        </div>

        {/* Content Area */}
        <div className="animate-fade-in">
          {/* CARS TAB */}
          {activeTab === 'cars' && (
            <div className="space-y-3 md:space-y-6 animate-fade-in">
              <div className="flex justify-between items-center">
                <h2 className="text-lg md:text-2xl font-bold gradient-text">🚗 إدارة أسطول السيارات</h2>
                <button onClick={openAddModal} className="admin-btn-primary">
                  ✨ إضافة سيارة جديدة
                </button>
              </div>

              <div className="overflow-x-auto admin-card-enhanced -mx-3 md:mx-0">
                <table className="admin-table w-full text-xs md:text-sm">
                  <thead>
                    <tr className="bg-slate-50">
                      <th className="p-2 md:p-4 text-right rounded-tr-xl">السيارة</th>
                      <th className="p-2 md:p-4 text-right">الموديل والسنة</th>
                      <th className="p-2 md:p-4 text-right">السعر</th>
                      <th className="p-2 md:p-4 text-right">الحالة</th>
                      <th className="p-2 md:p-4 text-center rounded-tl-xl">الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {cars.map((car) => (
                      <tr key={car.id} className="border-b border-border/50 hover:bg-slate-50/50 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-2 md:gap-4">
                            <div className="w-16 h-12 rounded-lg overflow-hidden border border-border shadow-sm">
                              {car.images && car.images.length > 0 ? (
                                <img src={car.images[0].imageUrl} className="w-full h-full object-cover" alt="" />
                              ) : (
                                <div className="w-full h-full bg-slate-100 flex items-center justify-center text-xs">🖼️</div>
                              )}
                            </div>
                            <span className="font-bold text-secondary">{car.brand}</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <div className="text-sm font-semibold">{car.model}</div>
                          <div className="text-xs text-muted-foreground">{car.year}</div>
                        </td>
                        <td className="p-4 font-bold text-primary">{formatPrice(car.price)}</td>
                        <td className="p-4">
                          <span className={`text-[10px] font-bold px-3 py-1 rounded-full ${car.isSold ? 'bg-red-100 text-red-600' : 'bg-green-100 text-green-600'}`}>
                            {car.isSold ? 'تم البيع' : 'متاحة'}
                          </span>
                        </td>
                        <td className="p-4">
                          <div className="flex justify-center gap-2">
                            <button onClick={() => openEditModal(car)} className="p-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-600 hover:text-white transition-all shadow-sm">
                              ✏️
                            </button>
                            <button onClick={() => handleDeleteCar(car.id)} className="p-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-600 hover:text-white transition-all shadow-sm">
                              🗑️
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ORDERS TAB */}
          {activeTab === 'orders' && (
            <div className="space-y-3 md:space-y-6 animate-fade-in">
              <h2 className="text-lg md:text-2xl font-bold gradient-text">📋 طلبات العملاء</h2>
              <div className="overflow-x-auto admin-card-enhanced -mx-3 md:mx-0">
                <table className="admin-table w-full text-xs md:text-sm">
                  <thead>
                    <tr className="bg-slate-50">
                      <th className="p-2 md:p-4 text-right rounded-tr-xl">رقم الطلب</th>
                      <th className="p-2 md:p-4 text-right">العميل</th>
                      <th className="p-2 md:p-4 text-right">السيارة</th>
                      <th className="p-2 md:p-4 text-right">الإجمالي</th>
                      <th className="p-2 md:p-4 text-right">التاريخ</th>
                      <th className="p-2 md:p-4 text-center rounded-tl-xl">الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {orders.map((order) => (
                      <tr key={order.id} className="border-b border-border/50 hover:bg-slate-50/50 transition-colors">
                        <td className="p-4 font-bold text-secondary">#{order.id}</td>
                        <td className="p-4">
                          <div className="font-semibold">{order.firstName} {order.lastName}</div>
                          <div className="text-xs text-muted-foreground">{order.email}</div>
                        </td>
                        <td className="p-4 text-sm font-medium">
                               {cars.find(c => c.id === order.carId)?.brand || 'سيارة محذوفة'} #{order.carId}
                            </td>
                        <td className="p-4 font-bold text-primary">{formatPrice(order.total)}</td>
                        <td className="p-4 text-xs text-muted-foreground">{new Date(order.createdAt).toLocaleDateString('ar-SA')}</td>
                        <td className="p-4">
                          <div className="flex justify-center gap-2">
                            <button 
                              onClick={() => {
                                setActiveTab('chat');
                                loadOrderChat(order.id);
                              }} 
                              className="p-2 bg-primary/10 text-primary rounded-lg hover:bg-primary hover:text-white transition-all shadow-sm flex items-center gap-1 text-xs font-bold"
                            >
                              💬 دردشة
                            </button>
                            <button onClick={() => handleDeleteOrder(order.id)} className="p-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-600 hover:text-white transition-all shadow-sm">
                              🗑️
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* CHAT TAB (New) */}
          {activeTab === 'chat' && (
            <div className="grid grid-cols-1 lg:grid-cols-4 gap-3 md:gap-6 h-auto md:h-175 animate-fade-in">
              {/* Sidebar: Chat List */}
              <div className="lg:col-span-1 glass-card flex flex-col overflow-hidden border-r border-white/10">
                <div className="p-3 md:p-6 border-b border-white/10 bg-white/5">
                  <h3 className="font-black text-white text-xl flex items-center gap-3">
                    <span className="animate-bounce">💬</span> غرف الدردشة
                  </h3>
                </div>
                <div className="flex-1 overflow-scroll p-4 space-y-3 no-scrollbar">
                  <button
                    onClick={() => loadOrderChat('public')}
                    className={`w-full text-right p-3 md:p-5 rounded-2xl text-xs md:text-base transition-all duration-500 flex flex-col gap-2 border group ${
                      selectedOrderChat === 'public' 
                      ? 'bg-linear-to-br from-cyan-500 to-blue-600 text-white shadow-glow border-cyan-400' 
                      : 'bg-white/5 border-white/5 text-white/60 hover:bg-white/10 hover:border-white/20'
                    }`}
                  >
                    <div className="font-black flex items-center gap-3 text-lg">
                      <span className="text-2xl group-hover:rotate-12 transition-transform">📢</span> الدردشة العامة
                    </div>
                    <div className="text-[11px] font-medium opacity-70 tracking-wider">بث مباشر لجميع الأعضاء</div>
                  </button>

                  <div className="pt-6 pb-2">
                    <p className="text-[10px] font-black text-cyan-400 uppercase tracking-[0.2em] px-3 mb-4">طلبات كبار الشخصيات</p>
                    <div className="space-y-3">
                      {orders.map(order => (
                        <button
                          key={order.id}
                          onClick={() => loadOrderChat(order.id)}
                          className={`w-full text-right p-3 md:p-5 rounded-2xl text-xs md:text-base transition-all duration-500 flex flex-col gap-2 border ${
                            selectedOrderChat === order.id 
                            ? 'bg-linear-to-br from-purple-600 to-blue-700 text-white shadow-glow border-purple-400' 
                            : 'bg-white/5 border-white/5 text-white/60 hover:bg-white/10 hover:border-white/20'
                          }`}
                        >
                          <div className="font-black text-base flex justify-between items-center">
                            <span>💎 طلب #{order.id}</span>
                            <span className={`text-[9px] px-2 py-1 rounded-md font-black uppercase ${selectedOrderChat === order.id ? 'bg-white/20' : 'bg-cyan-500/20 text-cyan-400'}`}>
                              VIP
                            </span>
                          </div>
                          <div className="text-[11px] font-medium opacity-70 truncate">
                            العميل الموقر: {order.firstName} {order.lastName}
                          </div>
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Chat Area */}
              <div className="lg:col-span-3 glass-card-premium flex flex-col min-h-[500px] md:h-full overflow-hidden relative border border-white/10">
                {!selectedOrderChat ? (
                  <div className="flex-1 flex flex-col items-center justify-center text-white/40 p-10 text-center">
                    <div className="w-40 h-40 bg-white/5 rounded-full flex items-center justify-center text-7xl mb-4 md:mb-8 animate-float shadow-glow-lg">💬</div>
                    <h3 className="text-xl md:text-3xl font-black text-white mb-4 glow-text">مركز العمليات المباشرة</h3>
                    <p className="max-w-md text-sm md:text-lg font-medium leading-relaxed">اختر مساراً للتواصل من القائمة الجانبية لتبدأ تجربة المحادثة الفاخرة.</p>
                  </div>
                ) : (
                  <>
                    <div className="p-4 md:p-8 border-b border-white/10 bg-white/5 flex items-center justify-between sticky top-0 z-10 backdrop-blur-xl">
                      <div>
                        <h3 className="font-black text-white text-2xl glow-text">
                          {selectedOrderChat === 'public' ? '📢 القناة العامة' : `💎 محادثة الطلب الملكي #${selectedOrderChat}`}
                        </h3>
                        <p className="text-sm text-cyan-400/70 font-bold mt-2 tracking-wide">
                          {selectedOrderChat === 'public' ? 'بث مباشر لجميع أعضاء المنصة' : 'قناة مشفرة وآمنة مع العميل'}
                        </p>
                      </div>
                      <div className="flex items-center gap-2 md:gap-4 bg-green-500/10 px-4 py-2 rounded-full border border-green-500/20">
                        <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse shadow-[0_0_10px_rgba(34,197,94,0.8)]"></div>
                        <span className="text-xs font-black text-green-400 uppercase tracking-widest">Active Now</span>
                      </div>
                    </div>

                    <div className="flex-1 overflow-y-auto p-3 md:p-8 min-h-[400px] space-y-3 md:space-y-6 bg-black/20 no-scrollbar">
                      {sortedChatMessages.length === 0 ? (
                        <div className="h-full flex flex-col items-center justify-center text-white/20">
                          <div className="text-5xl mb-4 opacity-20">📭</div>
                          <p className="font-bold tracking-widest uppercase text-xs">لا توجد مراسلات ملكية حتى الآن</p>
                        </div>
                      ) : (
                        sortedChatMessages.map((msg) => {
                          const isMe = msg.userId === user?.id;
                          return (
                            <div
                              key={msg.id}
                              className={`max-w-[88%] md:max-w-[75%] p-3 md:p-5 rounded-2xl md:rounded-3xl shadow-xl relative group animate-slide-in-right ${
                                isMe
                                  ? 'self-start chat-bubble-me text-white rounded-tr-none'
                                  : 'self-end chat-bubble-other text-white rounded-tl-none'
                              }`}
                            >
                              <div className="flex items-center justify-between gap-2 md:gap-6 mb-1 md:mb-2">
                                <p className={`text-[11px] font-black uppercase tracking-tighter ${isMe ? 'text-cyan-200' : 'text-cyan-400'}`}>
                                  {isMe ? '👑 المسؤول التنفيذي' : `👤 ${msg.senderName}`}
                                </p>
                                <button
                                  onClick={() => handleDeleteChatMessage(msg.id)}
                                  className="text-[10px] bg-red-500/20 text-red-400 px-2 py-1 rounded-md opacity-0 group-hover:opacity-100 transition-all hover:bg-red-500 hover:text-white"
                                >
                                  إزالة
                                </button>
                              </div>
                              <p className="text-sm leading-relaxed font-medium">{msg.content}</p>
                              <div className="flex items-center justify-between mt-3 opacity-60">
                                <span className="text-[9px] font-black uppercase tracking-widest">
                                  {new Date(msg.createdAt).toLocaleTimeString('ar-SA', {
                                    hour: '2-digit',
                                    minute: '2-digit',
                                  })}
                                </span>
                                {isMe && <span className="text-[10px]">✓✓</span>}
                              </div>
                            </div>
                          );
                        })
                      )}
                      <div ref={chatEndRef} />
                    </div>

                    <div className="p-3 md:p-4 md:p-8 border-t border-white/10 bg-white/5 flex gap-2 md:gap-2 md:gap-4 flex-col md:flex-row items-center backdrop-blur-xl">
                      <div className="relative flex-1">
                        <textarea
                          className="w-full bg-white/5 border border-white/10 rounded-2xl px-3 md:px-6 py-2 md:py-4 text-white text-sm md:text-base placeholder:text-white/20 focus:outline-none focus:border-cyan-500/50 focus:ring-1 focus:ring-cyan-500/50 transition-all resize-none min-h-15 max-h-30"
                          placeholder="أدخل رسالتك الملكية هنا..."
                          value={newMessage}
                          onChange={(e) => setNewMessage(e.target.value)}
                          onKeyDown={(e) => {
                            if (e.key === 'Enter' && !e.shiftKey) {
                              e.preventDefault();
                              handleSendChat();
                            }
                          }}
                          disabled={sendingChat}
                        />
                        <div className="absolute left-4 bottom-4 flex gap-2">
                          <span className="text-[10px] text-white/20 font-bold uppercase">Press Enter to Send</span>
                        </div>
                      </div>
                      <button
                        onClick={handleSendChat}
                        className="bg-linear-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-black px-4 md:px-10 py-2 md:py-4 rounded-2xl text-xs md:text-base shadow-glow transition-all active:scale-95 disabled:opacity-50 disabled:scale-100"
                        disabled={sendingChat || !newMessage.trim()}
                      >
                        {sendingChat ? 'جاري الإرسال...' : 'إرسال 🚀'}
                      </button>
                    </div>
                  </>
                )}
              </div>
            </div>
          )}

          {/* USERS TAB */}
          {activeTab === 'users' && (
            <div className="space-y-3 md:space-y-6 animate-fade-in">
              <h2 className="text-lg md:text-2xl font-bold gradient-text">👥 إدارة المستخدمين</h2>
              <div className="overflow-x-auto admin-card-enhanced -mx-3 md:mx-0">
                <table className="admin-table w-full text-xs md:text-sm">
                  <thead>
                    <tr className="bg-slate-800">
                      <th className="p-2 md:p-4 text-right rounded-tr-xl">المستخدم</th>
                      <th className="p-2 md:p-4 text-right">البريد الإلكتروني</th>
                      <th className="p-2 md:p-4 text-right">الصلاحية</th>
                      <th className="p-2 md:p-4 text-right">الحالة</th>
                      <th className="p-2 md:p-4 text-center rounded-tl-xl">الإجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map((u) => (
                      <tr key={u.id} className="border-b border-border/50 hover:bg-slate-50/50 transition-colors">
                        <td className="p-4 font-bold text-secondary">{u.firstName} {u.lastName}</td>
                        <td className="p-4 text-sm">{u.email}</td>
                        <td className="p-4">
                          <select
                            value={u.role}
                            onChange={(e) => handleChangeRole(u.id, e.target.value)}
                            className="text-xs font-bold bg-slate-800 border-none rounded-lg p-2 focus:ring-2 focus:ring-primary/20"
                          >
                            <option value="user">مستخدم</option>
                            <option value="admin">مسؤول</option>
                          </select>
                        </td>
                        <td className="p-4">
                          <button
                            onClick={() => handleToggleActive(u.id, u.isActive)}
                            className={`text-[10px] font-bold px-3 py-1 rounded-full transition-all ${
                              u.isActive ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'
                            }`}
                          >
                            {u.isActive ? 'نشط' : 'معطل'}
                          </button>
                        </td>
                        <td className="p-4">
                          <div className="flex justify-center">
                            <button onClick={() => handleDeleteUser(u.id)} className="p-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-600 hover:text-white transition-all shadow-sm">
                              🗑️
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* CMS TAB */}
          {activeTab === 'cms' && (
            <div className="space-y-3 md:space-y-6 animate-fade-in">
              <h2 className="text-lg md:text-2xl font-bold gradient-text">📄 إدارة محتوى الصفحات</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {cmsPages.map((page) => (
                  <div key={page.slug} className="admin-card-enhanced p-6 hover:scale-[1.02] transition-all group">
                    <div className="flex justify-between items-start mb-4">
                      <div className="bg-primary/10 p-3 rounded-2xl text-2xl group-hover:bg-primary group-hover:text-white transition-colors">📄</div>
                      <button onClick={() => openEditCMSModal(page)} className="text-sm font-bold text-primary hover:underline">تعديل المحتوى</button>
                    </div>
                    <h3 className="font-bold text-secondary text-lg mb-2">{page.title}</h3>
                    <p className="text-xs text-muted-foreground line-clamp-3 mb-4">{page.content.replace(/<[^>]*>/g, '')}</p>
                    <div className="text-[10px] font-bold text-slate-400">الرابط الثابت: /{page.slug}</div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* MESSAGES TAB */}
          {activeTab === 'messages' && (
  <div className="space-y-3 md:space-y-6 animate-fade-in">
    <h2 className="text-lg md:text-2xl font-bold gradient-text">
      ✉️ رسائل "اتصل بنا"
    </h2>

    <div className="grid grid-cols-1 gap-2 md:gap-4">
      {messages.length === 0 ? (
        <div className="admin-card-enhanced p-10 text-center text-muted-foreground">
          لا توجد رسائل حالياً
        </div>
      ) : (
        messages.map((msg, idx) => (
          <div
            key={idx}
            className="admin-card-enhanced p-6 flex flex-col gap-2 md:gap-4"
          >
            {/* Header */}
            <div className="flex justify-between items-start flex-wrap gap-2 md:gap-4">
              <div className="flex items-start gap-2 md:gap-4">
                <div className="bg-secondary/10 text-secondary p-4 rounded-2xl font-bold text-xl">
                  ✉️
                </div>

                <div className="space-y-1">
                  <h3 className="font-bold text-secondary text-lg">
                    {msg.fullName || msg.name || 'بدون اسم'}
                  </h3>

                  <p className="text-sm text-primary">
                    📧 {msg.email || 'لا يوجد بريد'}
                  </p>

                  {msg.phone && (
                    <p className="text-sm text-muted-foreground">
                      📱 {msg.phone}
                    </p>
                  )}

                  {msg.subject && (
                    <p className="text-sm text-yellow-500">
                      📌 {msg.subject}
                    </p>
                  )}

                  {msg.source && (
                    <p className="text-xs text-green-400">
                      🌐 المصدر: {msg.source}
                    </p>
                  )}
                </div>
              </div>

              <span className="text-[11px] text-muted-foreground">
                {new Date(
                  msg.createdAt || Date.now()
                ).toLocaleString('ar-SA')}
              </span>
            </div>

            {/* Message */}
            <div className="bg-slate-800 border border-slate-700 rounded-2xl p-4">
              <p className="text-sm text-slate-200 whitespace-pre-wrap leading-7">
                {msg.message || msg.notes || 'لا توجد رسالة'}
              </p>
            </div>
          </div>
        ))
      )}
    </div>
  </div>
)}
        </div>

        {/* Car Modal */}
        {showModal && (
          <div className="fixed inset-0 admin-modal-backdrop flex items-center justify-center z-100 p-4 animate-fade-in">
            <div className="admin-modal-content max-w-2xl w-full max-h-[90vh] md:max-h-[95vh] overflow-y-auto animate-scale-in">
              <div className="p-4 md:p-8">
                <div className="flex justify-between items-center mb-4 md:mb-8">
                  <h2 className="text-xl md:text-3xl font-bold text-secondary">
                    {editingCar?.id ? 'تعديل السيارة' : 'إضافة سيارة جديدة'}
                  </h2>
                  <button onClick={() => setShowModal(false)} className="w-10 h-10 flex items-center justify-center rounded-full bg-slate-100 hover:bg-red-50 hover:text-red-500 transition-all">✕</button>
                </div>

                <div className="space-y-3 md:space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
                    <div className="space-y-1 md:space-y-2">
                      <label className="text-xs font-bold text-muted-foreground px-1">الماركة</label>
                      <input
                        type="text"
                        placeholder="مثال: تويوتا"
                        className="admin-input-enhanced"
                        value={editingCar?.brand || ''}
                        onChange={(e) => setEditingCar({ ...editingCar!, brand: e.target.value })}
                      />
                    </div>
                    <div className="space-y-1 md:space-y-2">
                      <label className="text-xs font-bold text-muted-foreground px-1">الموديل</label>
                      <input
                        type="text"
                        placeholder="مثال: كامري"
                        className="admin-input-enhanced"
                        value={editingCar?.model || ''}
                        onChange={(e) => setEditingCar({ ...editingCar!, model: e.target.value })}
                      />
                    </div>
                    <div className="space-y-1 md:space-y-2">
                      <label className="text-xs font-bold text-muted-foreground px-1">السنة</label>
                      <input
                        type="number"
                        className="admin-input-enhanced"
                        value={editingCar?.year || 2024}
                        onChange={(e) => setEditingCar({ ...editingCar!, year: parseInt(e.target.value) })}
                      />
                    </div>
                    <div className="space-y-1 md:space-y-2">
                      <label className="text-xs font-bold text-muted-foreground px-1">السعر</label>
                      <input
                        type="number"
                        className="admin-input-enhanced font-bold text-primary"
                        value={editingCar?.price || 0}
                        onChange={(e) => setEditingCar({ ...editingCar!, price: parseFloat(e.target.value) })}
                      />
                    </div>
                  </div>
                  
                  <div className="space-y-1 md:space-y-2">
                    <label className="text-xs font-bold text-muted-foreground px-1">حالة السيارة</label>
                    <select
                      className="admin-input-enhanced"
                      value={editingCar?.isSold ? 'sold' : 'available'}
                      onChange={(e) => setEditingCar({ ...editingCar!, isSold: e.target.value === 'sold' })}
                    >
                      <option value="available">متاحة للبيع</option>
                      <option value="sold">تم البيع</option>
                    </select>
                  </div>

                  <div className="space-y-1 md:space-y-2">
                    <label className="text-xs font-bold text-muted-foreground px-1">الوصف</label>
                    <textarea
                      placeholder="اكتب تفاصيل السيارة هنا..."
                      className="admin-input-enhanced min-h-32"
                      value={editingCar?.description || ''}
                      onChange={(e) => setEditingCar({ ...editingCar!, description: e.target.value })}
                    />
                  </div>

                  {/* Image Upload */}
                  <div className="p-3 md:p-6 bg-linear-to-br from-slate-50 to-slate-100 rounded-2xl border-2 border-dashed border-slate-300 text-center group hover:border-primary/70 hover:from-primary/5 hover:to-primary/10 transition-all">
                    <label className="cursor-pointer block">
                      <div className="text-4xl mb-2 group-hover:scale-110 transition-transform">📸</div>
                      <p className="text-sm font-bold text-secondary mb-1">اسحب الصور هنا أو اضغط للاختيار</p>
                      <p className="text-[10px] text-muted-foreground">JPG, PNG, WebP (سيتم ضغطها تلقائياً)</p>
                      <input
                        type="file"
                        multiple
                        accept="image/*"
                        onChange={handleImageSelect}
                        className="hidden"
                        disabled={uploadingImages || compressingImage}
                      />
                    </label>
                  </div>

                  {compressingImage && (
                    <div className="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-center gap-3 animate-pulse">
                      <div className="w-4 h-4 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
                      <p className="text-xs text-blue-700 font-bold">جاري معالجة وضغط الصور...</p>
                    </div>
                  )}

                  {/* Image Preview */}
                  {imagePreview.length > 0 && (
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-2 md:gap-2 md:gap-4">
                      {imagePreview.map((img, idx) => (
                        <div key={idx} className="relative group aspect-square rounded-xl overflow-hidden border border-border shadow-sm">
                          <img src={img.url} className="w-full h-full object-cover" alt="" />
                          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <button
                              onClick={() => removeImage(idx)}
                              className="bg-red-500 text-white w-8 h-8 rounded-full flex items-center justify-center hover:scale-110 transition-all"
                            >✕</button>
                          </div>
                          <div className="absolute bottom-1 left-1 bg-black/60 text-white text-[8px] px-1.5 py-0.5 rounded">
                            {img.size}KB
                          </div>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="flex gap-2 md:gap-4 pt-4">
                    <button
                      onClick={handleSaveCar}
                      disabled={uploadingImages || compressingImage}
                      className="admin-btn-primary flex-1 py-2 md:py-4 rounded-xl font-bold text-xs md:text-lg"
                    >
                      {uploadingImages ? 'جاري الحفظ...' : '💾 حفظ البيانات'}
                    </button>
                    <button
                      onClick={() => setShowModal(false)}
                      disabled={uploadingImages || compressingImage}
                      className="btn btn-outline flex-1 py-2 md:py-4 rounded-xl font-bold text-xs md:text-lg"
                    >
                      إلغاء
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* CMS Modal */}
        {showCMSModal && editingCMSPage && (
          <div className="fixed inset-0 admin-modal-backdrop flex items-center justify-center z-100 p-4 animate-fade-in">
            <div className="admin-modal-content max-w-4xl w-full max-h-[90vh] overflow-y-auto animate-scale-in">
              <div className="p-4 md:p-8">
                <div className="flex justify-between items-center mb-4 md:mb-8">
                  <h2 className="text-xl md:text-3xl font-bold text-secondary">تعديل صفحة: {editingCMSPage.title}</h2>
                  <button onClick={() => setShowCMSModal(false)} className="w-10 h-10 flex items-center justify-center rounded-full bg-slate-100 hover:bg-red-50 hover:text-red-500 transition-all">✕</button>
                </div>

                <div className="space-y-3 md:space-y-6">
                  <div className="space-y-1 md:space-y-2">
                    <label className="text-xs font-bold text-muted-foreground px-1">عنوان الصفحة</label>
                    <input
                      type="text"
                      className="admin-input-enhanced font-bold"
                      value={editingCMSPage.title}
                      onChange={(e) => setEditingCMSPage({ ...editingCMSPage, title: e.target.value })}
                    />
                  </div>

                  <div className="space-y-1 md:space-y-2">
                    <label className="text-xs font-bold text-muted-foreground px-1">محتوى الصفحة (يدعم HTML)</label>
                    <textarea
                      className="admin-input-enhanced min-h-100 font-mono text-sm leading-relaxed"
                      value={editingCMSPage.content}
                      onChange={(e) => setEditingCMSPage({ ...editingCMSPage, content: e.target.value })}
                    />
                  </div>

                  <div className="flex gap-2 md:gap-4">
                    <button
                      onClick={handleSaveCMSPage}
                      disabled={savingCMS}
                      className="admin-btn-primary flex-1 py-4 rounded-xl font-bold"
                    >
                      {savingCMS ? 'جاري الحفظ...' : '💾 حفظ التعديلات'}
                    </button>
                    <button
                      onClick={() => setShowCMSModal(false)}
                      className="btn btn-outline flex-1 py-4 rounded-xl font-bold"
                    >
                      إلغاء
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      <Footer />
    </div>
  );
}
