const API_BASE_URL = import.meta.env.VITE_API_URL; // Backend API URL

// Helper function to make API calls
export async function apiCall(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`;

  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  const token = localStorage.getItem('token');
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(url, {
    ...options,
    headers,
  });

  let errorData = null;

  if (!response.ok) {
    try {
      errorData = await response.json();
    } catch {}

    const message = errorData?.error || `HTTP ${response.status}`;

    // 🔴 فقط هذا يطردك (توكن فعلاً انتهى)
    if (response.status === 401) {
      logout();
      window.location.href = '/login';
      return;
    }

    // 🔴 حساب مقفل من السيرفر (اختياري)
    if (response.status === 403 && errorData?.error === "ACCOUNT_DISABLED") {
      logout();
      window.location.href = '/login';
      return;
    }

    // ❌ مهم: لا تسوي logout في أي 403 ثاني
    throw new Error(message);
  }

  return await response.json();
}

// ============ AUTH ENDPOINTS ============
export async function register(firstName, lastName, email, password) {
  return apiCall('/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      firstName,
      lastName,
      email,
      password,
    }),
  });
}

export async function login(email, password) {
  const response = await apiCall('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });

  // Store token and user info
  if (response.token) {
    localStorage.setItem('token', response.token);
    localStorage.setItem('user', JSON.stringify(response.user));
  }

  return response;
}

export function logout() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
}

export function getCurrentUser() {
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
}

export function getToken() {
  return localStorage.getItem('token');
}

export function isLoggedIn() {
  return !!getToken();
}

export function isAdmin() {
  const user = getCurrentUser();
  return user && user.role === 'admin';
}

// ============ CAR ENDPOINTS ============
export async function getCars() {
  return apiCall('/cars');
}

export async function getCarById(id) {
  return apiCall(`/cars/${id}`);
}

export async function createCar(carData) {
  return apiCall('/admin/cars', {
    method: 'POST',
    body: JSON.stringify(carData),
  });
}

export async function updateCar(id, carData) {
  return apiCall(`/admin/cars/${id}`, {
    method: 'PUT',
    body: JSON.stringify(carData),
  });
}

export async function deleteCar(id) {
  return apiCall(`/admin/cars/${id}`, {
    method: 'DELETE',
  });
}

export async function addCarImage(carId, imageUrl) {
  return apiCall(`/admin/cars/${carId}/images`, {
    method: 'POST',
    body: JSON.stringify({ imageUrl }),
  });
}

export async function deleteCarImage(carId, imageId) {
  return apiCall(`/admin/cars/${carId}/images/${imageId}`, {
    method: 'DELETE',
  });
}

// ============ ORDER ENDPOINTS ============
export async function createOrder(orderData) {
  return apiCall('/orders', {
    method: 'POST',
    body: JSON.stringify(orderData),
  });
}

export async function getUserOrders() {
  return apiCall('/orders');
}

export async function getAllOrders() {
  return apiCall('/admin/orders');
}

export async function deleteOrder(id) {
  return apiCall(`/admin/orders/${id}`, {
    method: 'DELETE',
  });
}

// ============ CHAT ENDPOINTS ============
export async function getChatMessages() {
  return apiCall('/chat/messages');
}
export async function getOrderChatMessages(orderId) {
  return apiCall(`/chat/order/${orderId}/messages`);
}

export async function sendChatMessage(content, orderId = null) {
  return apiCall('/chat/messages', {
    method: 'POST',
    body: JSON.stringify({
      content,
      orderId,
    }),
  });
}

export async function deleteChatMessage(id) {
  return apiCall(`/admin/chat/messages/${id}`, {
    method: 'DELETE',
  });
}

// ============ USER ENDPOINTS ============
export async function getUsers() {
  return apiCall('/admin/users');
}

export async function updateUserRole(userId, role) {
  return apiCall(`/admin/users/${userId}/role`, {
    method: 'PUT',
    body: JSON.stringify({ role }),
  });
}

export async function deleteUser(id) {
  return apiCall(`/admin/users/${id}`, {
    method: 'DELETE',
  });
}

// ============ CMS ENDPOINTS ============
export async function getCMSPage(slug) {
  return apiCall(`/cms/${slug}`);
}

export async function getAllCMSPages() {
  return apiCall('/admin/cms');
}

export async function updateCMSPage(slug, title, content) {
  return apiCall(`/admin/cms/${slug}`, {
    method: 'PUT',
    body: JSON.stringify({ title, content }),
  });
}
export async function getContactMessages() {
  return apiCall('/admin/contact-messages');
}
export async function sendContactMessage(contactData) {
  return apiCall('/contact', {
    method: 'POST',
    body: JSON.stringify(contactData),
  });
}