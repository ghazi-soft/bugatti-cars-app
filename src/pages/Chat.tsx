import { useEffect, useMemo, useState, useCallback } from 'react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import {
  getCurrentUser,
  getChatMessages,
  getOrderChatMessages,
  isAdmin,
  isLoggedIn,
  sendChatMessage,
  deleteChatMessage,
  getUserOrders,
  getAllOrders,
} from '../lib/api';
import { showToast } from '../lib/utils';
import { sanitizeInput, clientRateLimit } from '../lib/security';
import type { ChatMessage, Order } from '../types';

const MAX_MESSAGE_LENGTH = 2000;

export default function Chat() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [selectedOrderId, setSelectedOrderId] = useState<number | 'public'>(() => {
    const params = new URLSearchParams(window.location.search);
    const orderId = params.get('orderId');
    return orderId ? parseInt(orderId) : 'public';
  });
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);

  const user = getCurrentUser();
  const userName = useMemo(
    () => (user ? `${user.firstName} ${user.lastName}`.trim() : ''),
    [user]
  );

  // Auth guard
  useEffect(() => {
    if (!isLoggedIn()) {
      window.location.href = '/login';
    }
  }, []);

  const loadData = useCallback(async () => {
    try {
      const ordersData = isAdmin() ? await getAllOrders() : await getUserOrders();
      setOrders(ordersData || []);

      let chatMessages: ChatMessage[];
      if (selectedOrderId === 'public') {
        chatMessages = await getChatMessages();
      } else {
        chatMessages = await getOrderChatMessages(selectedOrderId);
      }

      if (Array.isArray(chatMessages)) {
        setMessages(
          selectedOrderId === 'public'
            ? chatMessages.filter((m) => !m.orderId)
            : chatMessages
        );
      } else {
        setMessages([]);
      }
    } catch {
      // Silent refresh errors — avoid spamming user with toasts
    }
  }, [selectedOrderId]);

  useEffect(() => {
    loadData().finally(() => setLoading(false));
    const intervalId = window.setInterval(loadData, 4000);
    return () => window.clearInterval(intervalId);
  }, [loadData]);

  const handleSend = useCallback(async () => {
    if (!user) {
      showToast('يرجى تسجيل الدخول لإرسال رسالة', 'warning');
      return;
    }

    const trimmed = newMessage.trim();
    if (!trimmed) {
      showToast('اكتب رسالة قبل الإرسال', 'warning');
      return;
    }

    // SECURITY: Enforce max length client-side
    if (trimmed.length > MAX_MESSAGE_LENGTH) {
      showToast(`الرسالة طويلة جداً (${MAX_MESSAGE_LENGTH} حرف كحد أقصى)`, 'error');
      return;
    }

    // SECURITY: Client-side rate limit for chat
    if (!clientRateLimit('chat', 20, 60_000)) {
      showToast('أرسلت رسائل كثيرة جداً، انتظر قليلاً', 'error');
      return;
    }

    setSending(true);
    try {
      const orderId = selectedOrderId === 'public' ? undefined : selectedOrderId;
      // SECURITY: Sanitize before sending
      await sendChatMessage(sanitizeInput(trimmed), orderId);
      setNewMessage('');
      await loadData();
    } catch (error: any) {
      showToast(error?.message || 'فشل إرسال الرسالة', 'error');
    } finally {
      setSending(false);
    }
  }, [user, newMessage, selectedOrderId, loadData]);

  const handleDelete = useCallback(async (id: number) => {
    if (!confirm('هل أنت متأكد أنك تريد حذف هذه الرسالة؟')) return;
    try {
      await deleteChatMessage(id);
      setMessages((prev) => prev.filter((m) => m.id !== id));
      showToast('تم حذف الرسالة', 'success');
    } catch {
      showToast('فشل حذف الرسالة', 'error');
    }
  }, []);

  const sortedMessages = useMemo(
    () =>
      [...(messages || [])].sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
      ),
    [messages]
  );

  if (loading || !user) {
    return (
      <div className="min-h-screen bg-background">
        <Navbar />
        <div className="container mt-32 text-center">
          <p className="text-muted-foreground">جارٍ إعداد صفحة الدردشة...</p>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <div className="container mt-24 mb-20 px-3 md:px-0">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-4 md:gap-8 h-auto lg:h-[750px] flex flex-col lg:flex-row">

          {/* Sidebar */}
          <div className="lg:col-span-1 glass-card flex flex-col overflow-hidden border border-white/10 max-h-96 lg:max-h-none">
            <div className="p-6 border-b border-white/10 bg-white/5">
              <h2 className="font-black text-white text-xl flex items-center gap-3">
                <span className="animate-pulse">💬</span> المحادثات
              </h2>
            </div>
            <div className="flex-1 overflow-y-auto p-3 md:p-4 space-y-2 md:space-y-3 no-scrollbar">
              <button
                onClick={() => setSelectedOrderId('public')}
                className={`w-full text-right p-2 md:p-4 rounded-2xl transition-all duration-500 flex flex-col gap-1 md:gap-2 border text-xs md:text-base ${
                  selectedOrderId === 'public'
                    ? 'bg-gradient-to-br from-cyan-500 to-blue-600 text-white shadow-glow border-cyan-400'
                    : 'bg-white/5 border-white/5 text-white/60 hover:bg-white/10 hover:border-white/20'
                }`}
              >
                <div className="font-black flex items-center gap-2 md:gap-3 text-sm md:text-lg">
                  <span>📢</span> <span className="hidden sm:inline">الدردشة العامة</span><span className="sm:hidden">عام</span>
                </div>
                <div className="text-[9px] md:text-[11px] font-medium opacity-70 tracking-wider hidden sm:block">تواصل مع الجميع</div>
              </button>

              {orders.length > 0 && (
                <div className="mt-6">
                  <h3 className="text-[10px] font-black text-cyan-400 uppercase tracking-[0.2em] px-3 mb-4">
                    طلباتك الخاصة
                  </h3>
                  <div className="space-y-2 md:space-y-3">
                    {orders.map((order) => (
                      <button
                        key={order.id}
                        onClick={() => setSelectedOrderId(order.id)}
                        className={`w-full text-right p-2 md:p-4 rounded-2xl transition-all duration-500 flex flex-col gap-1 md:gap-2 border text-xs md:text-base ${
                          selectedOrderId === order.id
                            ? 'bg-gradient-to-br from-purple-600 to-blue-700 text-white shadow-glow border-purple-400'
                            : 'bg-white/5 border-white/5 text-white/60 hover:bg-white/10 hover:border-white/20'
                        }`}
                      >
                        <div className="font-black text-sm md:text-base flex justify-between items-center">
                          <span>💎 #{order.id}</span>
                          <span
                            className={`text-[7px] md:text-[9px] px-1.5 md:px-2 py-0.5 md:py-1 rounded-md font-black uppercase ${
                              selectedOrderId === order.id
                                ? 'bg-white/20'
                                : 'bg-cyan-500/20 text-cyan-400'
                            }`}
                          >
                            VIP
                          </span>
                        </div>
                        <div className="text-[9px] md:text-[11px] font-medium opacity-70 truncate hidden sm:block">
                          {isAdmin() ? `العميل: ${order.firstName}` : `سيارة: ${order.carId}`}
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Chat Area */}
          <div className="lg:col-span-3 glass-card-premium flex flex-col overflow-hidden relative border border-white/10 min-h-96 lg:min-h-auto">
            <div className="p-3 md:p-8 border-b border-white/10 bg-white/5 flex flex-col md:flex-row items-start md:items-center justify-between sticky top-0 z-10 backdrop-blur-xl gap-3 md:gap-0">
              <div>
                <h1 className="text-base md:text-2xl font-black text-white glow-text">
                  {selectedOrderId === 'public' ? '📢 القناة العامة' : `💎 الطلب #${selectedOrderId}`}
                </h1>
                <p className="text-[10px] md:text-sm text-cyan-400/70 font-bold mt-1 md:mt-2 tracking-wide hidden sm:block">
                  {selectedOrderId === 'public'
                    ? 'هذه المحادثة يراها جميع مستخدمي النظام'
                    : 'محادثة خاصة بخصوص هذا الطلب'}
                </p>
              </div>
              <div className="text-left">
                <span className="text-[9px] md:text-xs bg-gradient-to-r from-cyan-500/20 to-blue-500/20 text-cyan-400 px-2 md:px-4 py-1 md:py-2 rounded-full font-black border border-cyan-500/30 shadow-glow-sm whitespace-nowrap">
                  {userName}
                </span>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-3 md:p-8 space-y-3 md:space-y-6 bg-black/20 no-scrollbar flex flex-col">
              {sortedMessages.length === 0 ? (
                <div className="flex-1 flex flex-col items-center justify-center text-white/20">
                  <div className="text-6xl mb-6 opacity-20 animate-float">💬</div>
                  <p className="font-black tracking-widest uppercase text-xs">ابدأ المحادثة الآن</p>
                </div>
              ) : (
                sortedMessages.map((message) => {
                  const isMe = message.userId === user.id;
                  return (
                    <div
                      key={message.id}
                      className={`max-w-[85%] sm:max-w-[75%] p-2.5 md:p-5 rounded-3xl shadow-xl relative group animate-slide-in-right ${
                        isMe
                          ? 'self-start chat-bubble-me text-white rounded-tr-none'
                          : 'self-end chat-bubble-other text-white rounded-tl-none'
                      }`}
                    >
                      <div className="flex items-center justify-between gap-2 md:gap-6 mb-1 md:mb-2">
                        <p
                          className={`text-[9px] md:text-[11px] font-black uppercase tracking-tighter ${isMe ? 'text-cyan-200' : 'text-cyan-400'}`}
                        >
                          {/* SECURITY: Display senderName as text — safe from XSS */}
                          {isMe ? 'أنا' : message.senderName}
                        </p>
                        {isAdmin() && (
                          <button
                            onClick={() => handleDelete(message.id)}
                            className="text-[8px] md:text-[10px] bg-red-500/20 text-red-400 px-1 md:px-2 py-0.5 md:py-1 rounded-md opacity-0 group-hover:opacity-100 transition-all hover:bg-red-500 hover:text-white whitespace-nowrap"
                          >
                            حذف
                          </button>
                        )}
                      </div>
                      {/* SECURITY: Use textContent-equivalent rendering — no dangerouslySetInnerHTML */}
                      <p className="text-xs md:text-sm leading-relaxed font-medium break-words">{message.content}</p>
                      <div className="flex items-center justify-between mt-1.5 md:mt-3 opacity-60">
                        <span className="text-[8px] md:text-[9px] font-black uppercase tracking-widest">
                          {new Date(message.createdAt).toLocaleTimeString('ar-SA', {
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </span>
                        {isMe && <span className="text-[8px] md:text-[10px]">✓✓</span>}
                      </div>
                    </div>
                  );
                })
              )}
              <div />
            </div>

            <div className="p-3 md:p-8 border-t border-white/10 bg-white/5 flex gap-2 md:gap-4 items-end backdrop-blur-xl">
              <div className="relative flex-1">
                <textarea
                  className="w-full bg-white/5 border border-white/10 rounded-2xl px-3 md:px-6 py-2 md:py-4 text-white placeholder:text-white/20 focus:outline-none focus:border-cyan-500/50 focus:ring-1 focus:ring-cyan-500/50 transition-all resize-none min-h-[45px] md:min-h-[60px] max-h-[120px] text-sm md:text-base"
                  placeholder="اكتب رسالتك هنا..."
                  value={newMessage}
                  onChange={(e) => {
                    // SECURITY: Enforce max length in textarea
                    if (e.target.value.length <= MAX_MESSAGE_LENGTH) {
                      setNewMessage(e.target.value);
                    }
                  }}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && !e.shiftKey) {
                      e.preventDefault();
                      handleSend();
                    }
                  }}
                  disabled={sending}
                  maxLength={MAX_MESSAGE_LENGTH}
                />
                {newMessage.length > MAX_MESSAGE_LENGTH * 0.9 && (
                  <span className="absolute bottom-1 md:bottom-2 left-2 md:left-3 text-[8px] md:text-[10px] text-yellow-400">
                    {newMessage.length}/{MAX_MESSAGE_LENGTH}
                  </span>
                )}
              </div>
              <button
                onClick={handleSend}
                className="bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 text-white font-black px-4 md:px-10 py-2 md:py-4 rounded-2xl shadow-glow transition-all active:scale-95 disabled:opacity-50 disabled:scale-100 text-xs md:text-base whitespace-nowrap"
                disabled={sending || !newMessage.trim()}
              >
                {sending ? '...' : <><span className="hidden sm:inline">إرسال 🚀</span><span className="sm:hidden">إرسال</span></>}
              </button>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}
