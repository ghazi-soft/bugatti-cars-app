export function formatPrice(price, currency = 'SAR') {
  const formatter = new Intl.NumberFormat('ar-SA', {
    style: 'currency',
    currency: currency,
  });
  return formatter.format(price);
}

/**
 * Format date to readable format
 */
export function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('ar-SA', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

/**
 * Show toast notification
 */
export function showToast(message, type = 'info', duration = 3000) {
  const toastId = `toast-${Date.now()}`;
  const toast = document.createElement('div');
  toast.id = toastId;
  toast.className = `toast toast-${type}`;
  toast.textContent = message;
  
  // Add to DOM
  const container = document.getElementById('toast-container') || createToastContainer();
  container.appendChild(toast);

  // Animate in
  setTimeout(() => toast.classList.add('show'), 10);

  // Remove after duration
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, duration);
}

/**
 * Create toast container if it doesn't exist
 */
function createToastContainer() {
  const container = document.createElement('div');
  container.id = 'toast-container';
  container.className = 'toast-container';
  document.body.appendChild(container);
  return container;
}

/**
 * Show loading spinner
 */
export function showLoading(message = 'جاري التحميل...') {
  const loader = document.createElement('div');
  loader.id = 'global-loader';
  loader.className = 'global-loader';
  loader.innerHTML = `
    <div class="loader-content">
      <div class="spinner"></div>
      <p>${message}</p>
    </div>
  `;
  document.body.appendChild(loader);
  return loader;
}

/**
 * Hide loading spinner
 */
export function hideLoading() {
  const loader = document.getElementById('global-loader');
  if (loader) {
    loader.classList.add('fade-out');
    setTimeout(() => loader.remove(), 300);
  }
}

/**
 * Validate email format
 */
export function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validate password strength
 */
export function isValidPassword(password) {
  // At least 6 characters
  return password && password.length >= 6;
}

/**
 * Validate phone number (Saudi format)
 */
export function isValidPhone(phone) {
  const phoneRegex = /^(\+966|0)[0-9]{9}$/;
  return phoneRegex.test(phone);
}

/**
 * Debounce function for search inputs
 */
export function debounce(func, delay = 300) {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func(...args), delay);
  };
}

/**
 * Throttle function for scroll events
 */
export function throttle(func, limit = 300) {
  let inThrottle;
  return function (...args) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

/**
 * Redirect to page
 */
export function redirect(path) {
  window.location.href = path;
}

/**
 * Get query parameter from URL
 */
export function getQueryParam(param) {
  const searchParams = new URLSearchParams(window.location.search);
  return searchParams.get(param);
}

/**
 * Set query parameter in URL
 */
export function setQueryParam(param, value) {
  const searchParams = new URLSearchParams(window.location.search);
  searchParams.set(param, value);
  window.history.replaceState(null, null, `?${searchParams.toString()}`);
}

/**
 * Format car model display
 */
export function formatCarModel(brand, model, year) {
  return `${brand} ${model} (${year})`;
}

/**
 * Get car status badge
 */
export function getCarStatusBadge(isSold) {
  return isSold ? 'مباع' : 'متاح';
}

/**
 * Get car status class
 */
export function getCarStatusClass(isSold) {
  return isSold ? 'status-sold' : 'status-available';
}