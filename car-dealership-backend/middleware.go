package main

import (
	"context"
	"encoding/json"
	"log"
	"net"
	"net/http"
	"regexp"
	"strings"
	"sync"
	"time"
	"unicode/utf8"
)

// ============================================================
// SECURITY MIDDLEWARE - Enterprise Grade
// ============================================================

// ─── Rate Limiter ────────────────────────────────────────────

type rateLimitEntry struct {
	count     int
	windowEnd time.Time
	blocked   bool
	blockEnd  time.Time
}

type RateLimiter struct {
	mu      sync.Mutex
	entries map[string]*rateLimitEntry
	// config
	maxRequests int
	window      time.Duration
	blockFor    time.Duration
}

func NewRateLimiter(maxRequests int, window, blockFor time.Duration) *RateLimiter {
	rl := &RateLimiter{
		entries:     make(map[string]*rateLimitEntry),
		maxRequests: maxRequests,
		window:      window,
		blockFor:    blockFor,
	}
	// Cleanup goroutine
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		for range ticker.C {
			rl.cleanup()
		}
	}()
	return rl
}

func (rl *RateLimiter) cleanup() {
	rl.mu.Lock()
	defer rl.mu.Unlock()
	now := time.Now()
	for k, e := range rl.entries {
		if now.After(e.windowEnd) && now.After(e.blockEnd) {
			delete(rl.entries, k)
		}
	}
}

// Allow returns true if the request should proceed
func (rl *RateLimiter) Allow(key string) bool {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	now := time.Now()
	entry, exists := rl.entries[key]

	if !exists {
		rl.entries[key] = &rateLimitEntry{
			count:     1,
			windowEnd: now.Add(rl.window),
		}
		return true
	}

	// Check if currently hard-blocked
	if entry.blocked && now.Before(entry.blockEnd) {
		return false
	}

	// Reset window
	if now.After(entry.windowEnd) {
		entry.count = 1
		entry.windowEnd = now.Add(rl.window)
		entry.blocked = false
		return true
	}

	entry.count++
	if entry.count > rl.maxRequests {
		entry.blocked = true
		entry.blockEnd = now.Add(rl.blockFor)
		return false
	}

	return true
}

// Global rate limiters
var (
	generalLimiter = NewRateLimiter(100, time.Minute, 10*time.Minute)
	authLimiter    = NewRateLimiter(10, time.Minute, 15*time.Minute)
	uploadLimiter  = NewRateLimiter(20, time.Minute, 5*time.Minute)
	contactLimiter = NewRateLimiter(5, time.Minute, 30*time.Minute)
)

func getClientIP(r *http.Request) string {
	// Check X-Forwarded-For first (behind proxy/load balancer)
	xff := r.Header.Get("X-Forwarded-For")
	if xff != "" {
		parts := strings.Split(xff, ",")
		ip := strings.TrimSpace(parts[0])
		if net.ParseIP(ip) != nil {
			return ip
		}
	}
	// X-Real-IP
	xri := r.Header.Get("X-Real-IP")
	if xri != "" && net.ParseIP(xri) != nil {
		return xri
	}
	// RemoteAddr fallback
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

// rateLimitMiddleware wraps a specific limiter around a handler
func rateLimitMiddleware(limiter *RateLimiter) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip := getClientIP(r)
			if !limiter.Allow(ip) {
				log.Printf("[RATE-LIMIT] IP blocked: %s %s %s", ip, r.Method, r.URL.Path)
				w.Header().Set("Retry-After", "60")
				writeError(w, http.StatusTooManyRequests, "too many requests, please slow down")
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

// HandlerFunc version (for use with specific routes)
func rateLimitHandler(limiter *RateLimiter, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ip := getClientIP(r)
		if !limiter.Allow(ip) {
			log.Printf("[RATE-LIMIT] IP blocked: %s %s %s", ip, r.Method, r.URL.Path)
			w.Header().Set("Retry-After", "60")
			writeError(w, http.StatusTooManyRequests, "too many requests, please slow down")
			return
		}
		next(w, r)
	}
}

// ─── Security Headers Middleware ─────────────────────────────

func securityHeadersMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Prevent MIME type sniffing
		w.Header().Set("X-Content-Type-Options", "nosniff")
		// Prevent clickjacking
		w.Header().Set("X-Frame-Options", "DENY")
		// XSS protection (legacy browsers)
		w.Header().Set("X-XSS-Protection", "1; mode=block")
		// HSTS (enable in production with HTTPS)
		// w.Header().Set("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload")
		// Referrer policy
		w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
		// Content Security Policy
		w.Header().Set("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'")
		// Remove server info
		w.Header().Del("Server")
		w.Header().Del("X-Powered-By")
		// Permissions policy
		w.Header().Set("Permissions-Policy", "geolocation=(), microphone=(), camera=()")

		next.ServeHTTP(w, r)
	})
}

// ─── Request Size Limiter ─────────────────────────────────────

func requestSizeLimitMiddleware(maxBytes int64) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			r.Body = http.MaxBytesReader(w, r.Body, maxBytes)
			next.ServeHTTP(w, r)
		})
	}
}

// ─── Request Logging Middleware ───────────────────────────────

type contextKey string

const requestIDKey contextKey = "requestID"

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		ip := getClientIP(r)

		// Wrap response writer to capture status
		lrw := &loggingResponseWriter{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(lrw, r)

		// Safe logging: never log Authorization header or body content
		duration := time.Since(start)
		log.Printf("[ACCESS] %s %s %s %d %s ip=%s",
			r.Method,
			r.URL.Path,
			r.Proto,
			lrw.statusCode,
			duration,
			ip,
		)
	})
}

type loggingResponseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (lrw *loggingResponseWriter) WriteHeader(code int) {
	lrw.statusCode = code
	lrw.ResponseWriter.WriteHeader(code)
}

// ─── Input Sanitization & Validation ─────────────────────────

var (
	// Dangerous HTML/script patterns
	scriptPattern  = regexp.MustCompile(`(?i)<\s*script[^>]*>.*?<\s*/\s*script\s*>`)
	onEventPattern = regexp.MustCompile(`(?i)\bon\w+\s*=`)
	jsProtoPattern = regexp.MustCompile(`(?i)javascript\s*:`)
	sqlPattern     = regexp.MustCompile(`(?i)(union\s+select|drop\s+table|insert\s+into|delete\s+from|update\s+set|exec\s*\(|xp_cmdshell|information_schema)`)
	pathTraversal  = regexp.MustCompile(`(\.\.[\\/]|%2e%2e[\\/]|%252e%252e[\\/])`)

	// Valid patterns
	emailRegex    = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	phoneRegex    = regexp.MustCompile(`^[+]?[\d\s\-().]{7,20}$`)
	slugRegex     = regexp.MustCompile(`^[a-z0-9\-]{1,100}$`)
	allowedRoles  = map[string]bool{"user": true, "admin": true}
)

// SanitizeString removes dangerous content from strings
func SanitizeString(s string) string {
	// Remove null bytes
	s = strings.ReplaceAll(s, "\x00", "")
	// Remove script tags
	s = scriptPattern.ReplaceAllString(s, "")
	// Remove on* event handlers
	s = onEventPattern.ReplaceAllString(s, "")
	// Remove javascript: protocol
	s = jsProtoPattern.ReplaceAllString(s, "")
	// Trim whitespace
	s = strings.TrimSpace(s)
	return s
}

// ValidateEmail checks email format
func ValidateEmail(email string) bool {
	email = strings.TrimSpace(email)
	return len(email) <= 254 && emailRegex.MatchString(email)
}

// ValidatePhone checks phone format (optional field)
func ValidatePhone(phone string) bool {
	if phone == "" {
		return true // optional
	}
	return phoneRegex.MatchString(phone)
}

// ValidateSlug checks CMS slug
func ValidateSlug(slug string) bool {
	return slugRegex.MatchString(slug)
}

// ContainsSQLInjection checks for common SQL injection patterns
func ContainsSQLInjection(s string) bool {
	return sqlPattern.MatchString(s)
}

// ContainsPathTraversal checks for path traversal attempts
func ContainsPathTraversal(s string) bool {
	return pathTraversal.MatchString(s)
}

// ValidateStringLength checks string length within bounds
func ValidateStringLength(s string, min, max int) bool {
	length := utf8.RuneCountInString(s)
	return length >= min && length <= max
}

// ─── JSON Body Decoder with validation ───────────────────────

// DecodeJSONBody safely decodes JSON with a size limit
func DecodeJSONBody(r *http.Request, dst interface{}) error {
	r.Body = http.MaxBytesReader(nil, r.Body, 1*1024*1024) // 1MB max
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(dst)
}

// ─── File Upload Security ─────────────────────────────────────

const (
	maxImageSize    = 5 * 1024 * 1024 // 5MB
	maxBase64Size   = 7 * 1024 * 1024 // ~5MB in base64 overhead
)

// Allowed MIME type magic bytes
var allowedMagicBytes = map[string][]byte{
	"image/jpeg": {0xFF, 0xD8, 0xFF},
	"image/png":  {0x89, 0x50, 0x4E, 0x47},
	"image/gif":  {0x47, 0x49, 0x46, 0x38},
	"image/webp": {0x52, 0x49, 0x46, 0x46},
}

// ValidateImageURL validates that an image URL is safe
// (For this project images are stored as URLs/base64)
func ValidateImageURL(url string) bool {
	if url == "" {
		return false
	}

	// Prevent path traversal in URLs
	if ContainsPathTraversal(url) {
		return false
	}

	// Prevent javascript: protocol
	lower := strings.ToLower(strings.TrimSpace(url))
	if strings.HasPrefix(lower, "javascript:") ||
		strings.HasPrefix(lower, "data:text") ||
		strings.HasPrefix(lower, "data:application") ||
		strings.HasPrefix(lower, "vbscript:") ||
		strings.HasPrefix(lower, "file:") {
		return false
	}

	// Check length
	if len(url) > 10*1024*1024 { // max 10MB for base64
		return false
	}

	// If it's a base64 image, validate it starts with allowed type
	if strings.HasPrefix(lower, "data:image/") {
			allowedDataTypes := []string{
				"data:image/jpeg;base64,",
				"data:image/jpg;base64,",
				"data:image/png;base64,",
				"data:image/gif;base64,",
				"data:image/webp;base64,",
			}
		valid := false
		for _, allowed := range allowedDataTypes {
			if strings.HasPrefix(lower, allowed) {
				valid = true
				break
			}
		}
		if !valid {
			return false
		}
			// Check for SVG in the MIME type header only, not the whole base64 content
			// Searching for "svg" in the entire base64 string causes false positives
			header := lower
			if commaIdx := strings.Index(lower, ","); commaIdx != -1 {
				header = lower[:commaIdx]
			}
			if strings.Contains(header, "svg") {
				return false
			}
		return true
	}

	// If it's a regular URL, it should be http/https
	if !strings.HasPrefix(lower, "http://") && !strings.HasPrefix(lower, "https://") {
		return false
	}

	return true
}

// ─── Context helpers ──────────────────────────────────────────

type userContextKey struct{}

func contextWithUserID(ctx context.Context, userID int) context.Context {
	return context.WithValue(ctx, userContextKey{}, userID)
}

func userIDFromContext(ctx context.Context) (int, bool) {
	id, ok := ctx.Value(userContextKey{}).(int)
	return id, ok
}
