/**
 * Frontend Security Utilities
 * Enterprise-grade input sanitization and validation for the client side.
 * Note: All of these MUST also be validated server-side. Client validation
 * is UX-only — never rely on it for security.
 */

// ── Sanitization ─────────────────────────────────────────────

/**
 * Strip dangerous HTML/script content from a string.
 * Prevents XSS when rendering user-provided content.
 */
export function sanitizeInput(input: string): string {
  if (typeof input !== 'string') return '';
  return input
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;')
    .replace(/\//g, '&#x2F;')
    .replace(/\x00/g, '') // null bytes
    .trim();
}

/**
 * Strip HTML tags entirely (for plain-text fields).
 */
export function stripHTML(input: string): string {
  if (typeof input !== 'string') return '';
  return input.replace(/<[^>]*>/g, '').trim();
}

// ── Validation ────────────────────────────────────────────────

export function isValidEmail(email: string): boolean {
  const re = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;
  return re.test(email.trim()) && email.length <= 254;
}

export function isValidPassword(password: string): boolean {
  return password.length >= 8 && password.length <= 128;
}

export function isValidPhone(phone: string): boolean {
  if (!phone) return true; // optional
  return /^[+]?[\d\s\-().]{7,20}$/.test(phone);
}

export function isValidName(name: string): boolean {
  return name.trim().length >= 1 && name.trim().length <= 50;
}

export function isValidMessage(msg: string, maxLen = 5000): boolean {
  return msg.trim().length >= 1 && msg.trim().length <= maxLen;
}

// ── Token Security ────────────────────────────────────────────

/**
 * Parse JWT payload without verifying signature.
 * Use ONLY for reading expiry / display info — never for auth decisions.
 * Real verification happens on the server.
 */
export function parseJWTPayload(token: string): Record<string, unknown> | null {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
    return payload;
  } catch {
    return null;
  }
}

/**
 * Returns true if the JWT token is expired (client-side check only).
 */
export function isTokenExpired(token: string): boolean {
  const payload = parseJWTPayload(token);
  if (!payload || typeof payload.exp !== 'number') return true;
  return Date.now() / 1000 > payload.exp;
}

// ── Storage Security ──────────────────────────────────────────

const STORAGE_PREFIX = 'cds_'; // namespace prefix to avoid collisions

export const secureStorage = {
  set(key: string, value: unknown): void {
    try {
      localStorage.setItem(STORAGE_PREFIX + key, JSON.stringify(value));
    } catch {
      // Quota exceeded or private mode — fail silently
    }
  },
  get<T>(key: string): T | null {
    try {
      const item = localStorage.getItem(STORAGE_PREFIX + key);
      return item ? (JSON.parse(item) as T) : null;
    } catch {
      return null;
    }
  },
  remove(key: string): void {
    localStorage.removeItem(STORAGE_PREFIX + key);
    sessionStorage.removeItem(STORAGE_PREFIX + key);
    // Also remove legacy unprefixed keys (migration)
    localStorage.removeItem(key);
    sessionStorage.removeItem(key);
  },
  clear(): void {
    // Remove only our app's keys
    Object.keys(localStorage)
      .filter(k => k.startsWith(STORAGE_PREFIX))
      .forEach(k => localStorage.removeItem(k));
    Object.keys(sessionStorage)
      .filter(k => k.startsWith(STORAGE_PREFIX))
      .forEach(k => sessionStorage.removeItem(k));
    // Also clear legacy keys
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    sessionStorage.removeItem('token');
    sessionStorage.removeItem('user');
  },
};

// ── Admin Guard ───────────────────────────────────────────────

/**
 * Check if the current user has admin role from stored data.
 * This is client-side UX only — server enforces real authorization.
 */
export function clientIsAdmin(): boolean {
  try {
    const userStr = localStorage.getItem('user') || sessionStorage.getItem('user');
    if (!userStr) return false;
    const user = JSON.parse(userStr);
    return user?.role === 'admin';
  } catch {
    return false;
  }
}

// ── URL Safety ────────────────────────────────────────────────

/**
 * Check if a URL is safe to display/use (no javascript: etc).
 */
export function isSafeURL(url: string): boolean {
  if (!url) return false;
  const lower = url.toLowerCase().trim();
  const dangerous = ['javascript:', 'vbscript:', 'data:text', 'data:application', 'file:'];
  return !dangerous.some(d => lower.startsWith(d));
}

// ── Rate limiting (client-side UX only) ──────────────────────

const actionTimestamps: Record<string, number[]> = {};

/**
 * Simple client-side rate limit for UX feedback.
 * Real rate limiting is enforced by the server.
 */
export function clientRateLimit(action: string, maxAttempts: number, windowMs: number): boolean {
  const now = Date.now();
  if (!actionTimestamps[action]) actionTimestamps[action] = [];
  
  // Clean old timestamps
  actionTimestamps[action] = actionTimestamps[action].filter(t => now - t < windowMs);
  
  if (actionTimestamps[action].length >= maxAttempts) {
    return false; // Rate limited
  }
  
  actionTimestamps[action].push(now);
  return true; // Allowed
}
