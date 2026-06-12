import type { User, Car, Order, CMSPage, LoginResponse, OrderRequest, ChatMessage } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL;

export async function apiCall<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = localStorage.getItem('token') || sessionStorage.getItem('token');
  
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(options.headers as Record<string, string>),
  };

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    logout();
    window.location.href = '/login';
    throw new Error('Session expired. Please login again.');
  }

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    if (response.status === 403 && data.error === 'ACCOUNT_DISABLED') {
      logout();
      window.location.href = '/login?error=disabled';
      throw new Error('Your account has been disabled. Please contact support.');
    }
    throw new Error(data.error || `HTTP error! status: ${response.status}`);
  }

  return data as T;
}

// ============ AUTH ENDPOINTS ============
export async function register(
  firstName: string,
  lastName: string,
  email: string,
  password: string
): Promise<User> {
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

export async function login(email: string, password: string): Promise<LoginResponse> {
  const response = await apiCall<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });

  if (response.token) {
    localStorage.setItem('token', response.token);
    localStorage.setItem('user', JSON.stringify(response.user));
  }

  return response;
}

export function logout(): void {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  sessionStorage.removeItem('token');
  sessionStorage.removeItem('user');
}

export function getCurrentUser(): User | null {
  const userStr = localStorage.getItem('user') || sessionStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
}

export function getToken(): string | null {
  return localStorage.getItem('token') || sessionStorage.getItem('token');
}

export function isLoggedIn(): boolean {
  return !!getToken();
}

export function isAdmin(): boolean {
  const user = getCurrentUser();
  return user?.role === 'admin' || false;
}

// ============ CAR ENDPOINTS ============
export async function getCars(): Promise<Car[]> {
  return apiCall('/cars');
}

export async function getCarById(id: number): Promise<Car> {
  return apiCall(`/cars/${id}`);
}

export async function createCar(carData: Partial<Car>): Promise<Car> {
  return apiCall('/admin/cars', {
    method: 'POST',
    body: JSON.stringify(carData),
  });
}

export async function updateCar(id: number, carData: Partial<Car>): Promise<Car> {
  return apiCall(`/admin/cars/${id}`, {
    method: 'PUT',
    body: JSON.stringify(carData),
  });
}

export async function deleteCar(id: number): Promise<{ message: string }> {
  return apiCall(`/admin/cars/${id}`, {
    method: 'DELETE',
  });
}

export async function addCarImage(carId: number, imageUrl: string): Promise<{ message: string }> {
  return apiCall(`/admin/cars/${carId}/images`, {
    method: 'POST',
    body: JSON.stringify({ imageUrl }),
  });
}

export async function deleteCarImage(carId: number, imageId: number): Promise<{ message: string }> {
  return apiCall(`/admin/cars/${carId}/images/${imageId}`, {
    method: 'DELETE',
  });
}

export async function deleteCarImageByURL(carId: number, imageUrl: string): Promise<{ message: string }> {
  return apiCall(`/admin/cars/${carId}/images/delete`, {
    method: 'DELETE',
    body: JSON.stringify({ imageUrl }),
  });
}

// ============ ORDER ENDPOINTS ============
export async function createOrder(orderData: OrderRequest): Promise<Order> {
  return apiCall('/orders', {
    method: 'POST',
    body: JSON.stringify(orderData),
  });
}

export async function getUserOrders(): Promise<Order[]> {
  return apiCall('/orders');
}

export async function getAllOrders(): Promise<Order[]> {
  return apiCall('/admin/orders');
}

export async function deleteOrder(id: number): Promise<{ message: string }> {
  return apiCall(`/admin/orders/${id}`, {
    method: 'DELETE',
  });
}

// ============ CHAT ENDPOINTS ============
export async function getChatMessages(): Promise<ChatMessage[]> {
  return apiCall('/chat/messages');
}

export async function getOrderChatMessages(orderId: number): Promise<ChatMessage[]> {
  return apiCall(`/chat/order/${orderId}/messages`);
}

export async function sendChatMessage(content: string, orderId?: number): Promise<ChatMessage> {
  return apiCall('/chat/messages', {
    method: 'POST',
    body: JSON.stringify({ content, orderId }),
  });
}

export async function deleteChatMessage(id: number): Promise<{ message: string }> {
  return apiCall(`/admin/chat/messages/${id}`, {
    method: 'DELETE',
  });
}

// ============ USER ENDPOINTS ============
export async function getUsers(): Promise<User[]> {
  return apiCall('/admin/users');
}

export async function updateUserRole(userId: number, role: string): Promise<{ message: string }> {
  return apiCall(`/admin/users/${userId}/role`, {
    method: 'PUT',
    body: JSON.stringify({ role }),
  });
}

export async function deleteUser(id: number): Promise<{ message: string }> {
  return apiCall(`/admin/users/${id}`, {
    method: 'DELETE',
  });
}

export async function toggleUserActive(userId: number, isActive: boolean): Promise<{ message: string }> {
  return apiCall(`/admin/users/${userId}/active`, {
    method: 'PUT',
    body: JSON.stringify({ isActive }),
  });
}

// ============ CMS ENDPOINTS ============
export async function getCMSPage(slug: string): Promise<CMSPage> {
  return apiCall(`/cms/${slug}`);
}

export async function getAllCMSPages(): Promise<CMSPage[]> {
  return apiCall('/admin/cms');
}

export async function updateCMSPage(
  slug: string,
  title: string,
  content: string
): Promise<{ message: string }> {
  return apiCall(`/admin/cms/${slug}`, {
    method: 'PUT',
    body: JSON.stringify({ title, content }),
  });
}

// ============ CONTACT ENDPOINTS ============
export async function sendContactMessage(messageData: any): Promise<{ message: string }> {
  return apiCall('/contact', {
    method: 'POST',
    body: JSON.stringify({ ...messageData, source: 'contact_page' }),
  });
}

export async function getContactMessages(): Promise<any[]> {
  return apiCall('/admin/contact-messages');
}
