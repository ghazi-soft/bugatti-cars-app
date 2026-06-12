export interface User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: 'user' | 'admin';
  isActive: boolean;   // 👈 مهم
  createdAt: string;
}

export interface CarImage {
  id: number;
  carId: number;
  imageUrl: string;
}

export interface Car {
  id: number;
  model: string;
  brand: string;
  year: number;
  price: number;
  description: string;
  isSold: boolean;
  images: CarImage[];
  createdAt: string;
}

export interface Order {
  id: number;
  userId: number;
  carId: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  notes: string;
  total: number;
  createdAt: string;
}

export interface CMSPage {
  id: number;
  slug: string;
  title: string;
  content: string;
  updatedAt: string;
}

export interface ChatMessage {
  id: number;
  orderId?: number;
  userId: number;
  senderName: string;
  content: string;
  createdAt: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
}

export interface OrderRequest {
  carId: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  notes: string;
}
export interface ContactMessage {
  id: number;
  fullName: string;
  email: string;
  subject: string;
  message: string;
  source: string;
  createdAt: string;
}