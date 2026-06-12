import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Format currency
 */
export function formatPrice(price: number, currency = 'SAR'): string {
  const formatter = new Intl.NumberFormat('ar-SA', {
    style: 'currency',
    currency: currency,
  });
  return formatter.format(price);
}

/**
 * Format date to readable Arabic format
 */
export function formatDate(dateString: string): string {
  const date = new Date(dateString);
  return date.toLocaleDateString('ar-SA', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

/**
 * Show toast notification
 * SECURITY: Uses textContent (not innerHTML) — no XSS risk
 */
export function showToast(
  message: string,
  type: 'info' | 'success' | 'error' | 'warning' = 'info',
  duration = 3000
): void {
  const toastId = `toast-${Date.now()}`;
  const toast = document.createElement('div');
  toast.id = toastId;
  toast.className = `toast toast-${type}`;
  toast.textContent = message; // textContent — safe from XSS

  const container = document.getElementById('toast-container') || createToastContainer();
  container.appendChild(toast);

  setTimeout(() => toast.classList.add('show'), 10);
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, duration);
}

function createToastContainer(): HTMLElement {
  const container = document.createElement('div');
  container.id = 'toast-container';
  container.className = 'toast-container';
  document.body.appendChild(container);
  return container;
}

export function showLoading(message = 'جاري التحميل...'): HTMLElement {
  const loader = document.createElement('div');
  loader.id = 'global-loader';
  loader.className = 'global-loader';
  // SECURITY: Use textContent for user-supplied text, not innerHTML
  const content = document.createElement('div');
  content.className = 'loader-content';
  const spinner = document.createElement('div');
  spinner.className = 'spinner';
  const p = document.createElement('p');
  p.textContent = message;
  content.appendChild(spinner);
  content.appendChild(p);
  loader.appendChild(content);
  document.body.appendChild(loader);
  return loader;
}

export function hideLoading(): void {
  const loader = document.getElementById('global-loader');
  if (loader) {
    loader.classList.add('fade-out');
    setTimeout(() => loader.remove(), 300);
  }
}

/**
 * SECURITY FIX: Stronger email validation (RFC 5321 compliant)
 * Old regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/ — too permissive
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;
  return emailRegex.test(email.trim()) && email.length <= 254;
}

/**
 * SECURITY FIX: Minimum 8 characters (was 6 — too weak)
 */
export function isValidPassword(password: string): boolean {
  return typeof password === 'string' && password.length >= 8 && password.length <= 128;
}

/**
 * Phone validation — accepts international formats
 */
export function isValidPhone(phone: string): boolean {
  if (!phone) return true; // optional
  return /^[+]?[\d\s\-().]{7,20}$/.test(phone);
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  delay = 300
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout>;
  return function (...args: Parameters<T>) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
}

export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit = 300
): (...args: Parameters<T>) => void {
  let inThrottle: boolean;
  return function (...args: Parameters<T>) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

export function redirect(path: string): void {
  window.location.href = path;
}

export function getQueryParam(param: string): string | null {
  const searchParams = new URLSearchParams(window.location.search);
  return searchParams.get(param);
}

export function setQueryParam(param: string, value: string): void {
  const searchParams = new URLSearchParams(window.location.search);
  searchParams.set(param, value);
  const newUrl = `${window.location.pathname}?${searchParams.toString()}`;
  window.history.replaceState(null, '', newUrl);
}

export function formatCarModel(brand: string, model: string, year: number): string {
  return `${brand} ${model} (${year})`;
}

export function getCarStatusBadge(isSold: boolean): string {
  return isSold ? 'مباع' : 'متاح';
}

export function getCarStatusClass(isSold: boolean): string {
  return isSold ? 'status-sold' : 'status-available';
}
