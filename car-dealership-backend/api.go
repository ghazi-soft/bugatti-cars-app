package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/golang-jwt/jwt/v4"
	"github.com/gorilla/mux"
	"golang.org/x/crypto/bcrypt"
)

// getJWTSecret loads JWT secret from environment variable.
// SECURITY: Never hardcode secrets. Set JWT_SECRET env var in production.
func getJWTSecret() []byte {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Println("[SECURITY WARNING] JWT_SECRET env var not set. Set it in production!")
		secret = "change-this-in-production-use-env-var-min-32-chars!!"
	}
	if len(secret) < 32 {
		log.Fatal("[SECURITY] JWT_SECRET must be at least 32 characters")
	}
	return []byte(secret)
}

type APIServer struct {
	listenAddr string
	store      *PostgresStore
}

func NewAPIServer(addr string, store *PostgresStore) *APIServer {
	return &APIServer{listenAddr: addr, store: store}
}

func (s *APIServer) Run() {
	r := mux.NewRouter()

	s.seedAdmin()

	// Global Middleware Stack
	r.Use(loggingMiddleware)
	r.Use(securityHeadersMiddleware)
	r.Use(requestSizeLimitMiddleware(10 * 1024 * 1024))
	r.Use(corsMiddleware)
	r.Use(rateLimitMiddleware(generalLimiter))

	r.Methods("OPTIONS").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	// Public routes
	r.HandleFunc("/cars", s.handleGetCars).Methods("GET")
	r.HandleFunc("/cars/{id}", s.handleGetCarByID).Methods("GET")
	r.HandleFunc("/auth/register", rateLimitHandler(authLimiter, s.handleRegister)).Methods("POST")
	r.HandleFunc("/auth/login", rateLimitHandler(authLimiter, s.handleLogin)).Methods("POST")
	r.HandleFunc("/cms/{slug}", s.handleGetCMSPage).Methods("GET")
	r.HandleFunc("/contact", rateLimitHandler(contactLimiter, s.handleCreateContactMessage)).Methods("POST")

	// Protected user routes
	r.HandleFunc("/orders", s.withJWT(s.handleCreateOrder)).Methods("POST")
	r.HandleFunc("/orders", s.withJWT(s.handleGetUserOrders)).Methods("GET")
	r.HandleFunc("/chat/messages", s.withJWT(s.handleGetChatMessages)).Methods("GET")
	r.HandleFunc("/chat/messages", s.withJWT(rateLimitHandler(generalLimiter, s.handleCreateChatMessageFixed))).Methods("POST")
	r.HandleFunc("/chat/order/{id}/messages", s.withJWT(s.handleGetOrderChatMessages)).Methods("GET")

	// Admin routes
	r.HandleFunc("/admin/cars", s.withJWT(withAdmin(s.store, s.handleCreateCar))).Methods("POST")
	r.HandleFunc("/admin/cars/{id}", s.withJWT(withAdmin(s.store, s.handleUpdateCar))).Methods("PUT")
	r.HandleFunc("/admin/cars/{id}", s.withJWT(withAdmin(s.store, s.handleDeleteCar))).Methods("DELETE")
	r.HandleFunc("/admin/cars/{id}/images", s.withJWT(withAdmin(s.store, rateLimitHandler(uploadLimiter, s.handleAddCarImage)))).Methods("POST")
	r.HandleFunc("/admin/cars/{id}/images/{imageId}", s.withJWT(withAdmin(s.store, s.handleDeleteCarImage))).Methods("DELETE")
	r.HandleFunc("/admin/cars/{id}/images/delete", s.withJWT(withAdmin(s.store, s.handleDeleteCarImageByURL))).Methods("DELETE")
	r.HandleFunc("/admin/orders", s.withJWT(withAdmin(s.store, s.handleGetAllOrders))).Methods("GET")
	r.HandleFunc("/admin/orders/{id}", s.withJWT(withAdmin(s.store, s.handleDeleteOrder))).Methods("DELETE")
	r.HandleFunc("/admin/users", s.withJWT(withAdmin(s.store, s.handleGetAllUsers))).Methods("GET")
	r.HandleFunc("/admin/users/{id}/role", s.withJWT(withAdmin(s.store, s.handleUpdateUserRole))).Methods("PUT")
	r.HandleFunc("/admin/users/{id}", s.withJWT(withAdmin(s.store, s.handleDeleteUserAdmin))).Methods("DELETE")
	r.HandleFunc("/admin/users/{id}/active", s.withJWT(withAdmin(s.store, s.handleToggleUserActive))).Methods("PUT", "OPTIONS")
	r.HandleFunc("/admin/cms/{slug}", s.withJWT(withAdmin(s.store, s.handleUpdateCMSPage))).Methods("PUT")
	r.HandleFunc("/admin/cms", s.withJWT(withAdmin(s.store, s.handleGetAllCMSPages))).Methods("GET")
	r.HandleFunc("/admin/chat/messages/{id}", s.withJWT(withAdmin(s.store, s.handleDeleteChatMessage))).Methods("DELETE")
	r.HandleFunc("/admin/contact-messages", s.withJWT(withAdmin(s.store, s.handleGetContactMessages))).Methods("GET")

	fmt.Println("Server Running On", s.listenAddr)
	log.Fatal(http.ListenAndServe(s.listenAddr, r))
}

// ============================================================
// CORS — restricted to known origins only
// ============================================================
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		allowedOrigin := os.Getenv("ALLOWED_ORIGIN")
		if allowedOrigin == "" {
			allowedOrigin = "http://localhost:5173"
		}
		origin := r.Header.Get("Origin")
		if origin == allowedOrigin {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Max-Age", "86400")
		w.Header().Set("Vary", "Origin")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

// writeError — sanitizes error messages so internal details never leak
func writeError(w http.ResponseWriter, status int, message string) {
	safe := safeMsg(status, message)
	writeJSON(w, status, map[string]string{"error": safe})
}

func safeMsg(status int, original string) string {
	allowed := map[string]bool{
		"missing token": true, "invalid token": true, "invalid claims": true,
		"invalid user_id": true, "user not found": true, "ACCOUNT_DISABLED": true,
		"admin access required": true, "invalid request": true, "missing required fields": true,
		"invalid credentials": true, "email already exists": true, "car not found": true,
		"car already sold": true, "access denied": true, "page not found": true,
			"too many requests, please slow down": true, "invalid id": true,
			"message sent successfully": true, "invalid input": true, "image not allowed": true,
			"image format not allowed": true, "image too large (max 5MB)": true,
		"message too long": true, "invalid email": true, "invalid phone": true,
		"invalid slug": true, "invalid role": true, "name too long": true,
		"field too long": true, "password too short": true, "content too long": true,
		"cannot delete own account": true, "cannot disable own account": true,
		"car deleted": true, "image added": true, "image deleted": true,
		"chat deleted": true, "order deleted": true, "role updated": true,
		"updated successfully": true, "page updated": true,
	}
	if allowed[original] {
		return original
	}
	if status >= 500 {
		log.Printf("[INTERNAL ERROR] %s", original)
		return "internal server error"
	}
	return original
}

// ============================================================
// JWT Middleware — algorithm pinned to HS256, expiry validated
// ============================================================
func (s *APIServer) withJWT(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			writeError(w, http.StatusUnauthorized, "missing token")
			return
		}

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenStr == "" {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		// Pin algorithm to HS256 — prevents alg:none and RS256 confusion attacks
		token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}
			return getJWTSecret(), nil
		})

		if err != nil || !token.Valid {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok || !claims.VerifyExpiresAt(time.Now().Unix(), true) {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		userIDFloat, ok := claims["user_id"].(float64)
		if !ok || userIDFloat <= 0 {
			writeError(w, http.StatusUnauthorized, "invalid user_id")
			return
		}
		userID := int(userIDFloat)

		user, err := s.store.GetUserByID(userID)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "user not found")
			return
		}
		if !user.IsActive {
			writeError(w, http.StatusForbidden, "ACCOUNT_DISABLED")
			return
		}

		// Pass userID via context (tamper-proof) and header
		ctx := contextWithUserID(r.Context(), userID)
		r = r.WithContext(ctx)
		r.Header.Set("X-User-ID", fmt.Sprintf("%d", userID))
		next(w, r)
	}
}

func (s *APIServer) seedAdmin() { s.store.SeedAdmin() }

// ============================================================
// Admin Middleware — double-checks role from DB
// ============================================================
func withAdmin(store *PostgresStore, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, ok := userIDFromContext(r.Context())
		if !ok {
			userIDStr := r.Header.Get("X-User-ID")
			var err error
			userID, err = strconv.Atoi(userIDStr)
			if err != nil || userID <= 0 {
				writeError(w, http.StatusUnauthorized, "user not found")
				return
			}
		}

		user, err := store.GetUserByID(userID)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "user not found")
			return
		}
		if !user.IsActive {
			writeError(w, http.StatusForbidden, "ACCOUNT_DISABLED")
			return
		}
		if user.Role != "admin" {
			log.Printf("[SECURITY] Non-admin access attempt by user %d on %s %s", userID, r.Method, r.URL.Path)
			writeError(w, http.StatusForbidden, "admin access required")
			return
		}
		next(w, r)
	}
}

// ============================================================
// JWT Creation
// ============================================================
func createJWT(userID int) (string, error) {
	now := time.Now()
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     now.Add(time.Hour * 24 * 7).Unix(),
		"iat":     now.Unix(),
		"nbf":     now.Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(getJWTSecret())
}

// ============================================================
// AUTH HANDLERS
// ============================================================
func (s *APIServer) handleRegister(w http.ResponseWriter, r *http.Request) {
	var req struct {
		FirstName string `json:"firstName"`
		LastName  string `json:"lastName"`
		Email     string `json:"email"`
		Password  string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}

	req.FirstName = SanitizeString(req.FirstName)
	req.LastName = SanitizeString(req.LastName)
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))

	if req.Email == "" || req.Password == "" || req.FirstName == "" || req.LastName == "" {
		writeError(w, http.StatusBadRequest, "missing required fields")
		return
	}
	if !ValidateEmail(req.Email) {
		writeError(w, http.StatusBadRequest, "invalid email")
		return
	}
	if utf8.RuneCountInString(req.Password) < 8 {
		writeError(w, http.StatusBadRequest, "password too short")
		return
	}
	if !ValidateStringLength(req.FirstName, 1, 50) || !ValidateStringLength(req.LastName, 1, 50) {
		writeError(w, http.StatusBadRequest, "name too long")
		return
	}
	if !ValidateStringLength(req.Password, 8, 128) {
		writeError(w, http.StatusBadRequest, "field too long")
		return
	}
	if ContainsSQLInjection(req.FirstName) || ContainsSQLInjection(req.LastName) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "error hashing password")
		return
	}

	user := &User{
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Email:     req.Email,
		Password:  string(hashedPassword),
		Role:      "user", // Force role — never trust client
		IsActive:  true,
	}
	if err := s.store.CreateUser(user); err != nil {
		writeError(w, http.StatusBadRequest, "email already exists")
		return
	}
	user.Password = ""
	writeJSON(w, http.StatusCreated, user)
}

func (s *APIServer) handleLogin(w http.ResponseWriter, r *http.Request) {
	var loginReq LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&loginReq); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	loginReq.Email = strings.ToLower(strings.TrimSpace(loginReq.Email))

	if !ValidateEmail(loginReq.Email) {
		// Timing-safe: run dummy bcrypt to equalize response time
		bcrypt.CompareHashAndPassword([]byte("$2a$10$dummyhashfortimingprotection000"), []byte(loginReq.Password))
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	if loginReq.Password == "" || len(loginReq.Password) > 128 {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	dbUser, err := s.store.GetUserByEmail(loginReq.Email)
	if err != nil {
		bcrypt.CompareHashAndPassword([]byte("$2a$10$dummyhashfortimingprotection000"), []byte(loginReq.Password))
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	if !dbUser.IsActive {
		writeError(w, http.StatusForbidden, "ACCOUNT_DISABLED")
		return
	}
	if err := bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(loginReq.Password)); err != nil {
		writeError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	token, err := createJWT(dbUser.ID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "error creating token")
		return
	}
	dbUser.Password = ""
	writeJSON(w, http.StatusOK, LoginResponse{Token: token, User: *dbUser})
}

// ============================================================
// CAR HANDLERS
// ============================================================
func (s *APIServer) handleGetCars(w http.ResponseWriter, r *http.Request) {
	cars, err := s.store.GetCars()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, cars)
}

func (s *APIServer) handleGetCarByID(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	car, err := s.store.GetCarByID(id)
	if err != nil {
		writeError(w, http.StatusNotFound, "car not found")
		return
	}
	writeJSON(w, http.StatusOK, car)
}

func (s *APIServer) handleCreateCar(w http.ResponseWriter, r *http.Request) {
	var car Car
	if err := json.NewDecoder(r.Body).Decode(&car); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	car.Model = SanitizeString(car.Model)
	car.Brand = SanitizeString(car.Brand)
	car.Description = SanitizeString(car.Description)

	if !ValidateStringLength(car.Model, 1, 100) || !ValidateStringLength(car.Brand, 1, 100) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	if !ValidateStringLength(car.Description, 0, 5000) {
		writeError(w, http.StatusBadRequest, "content too long")
		return
	}
	if car.Year < 1900 || car.Year > time.Now().Year()+2 {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	if car.Price < 0 || car.Price > 100_000_000 {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	car.ID = 0
	car.IsSold = false

	if err := s.store.CreateCar(&car); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, car)
}

func (s *APIServer) handleUpdateCar(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	var car Car
	if err := json.NewDecoder(r.Body).Decode(&car); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	car.Model = SanitizeString(car.Model)
	car.Brand = SanitizeString(car.Brand)
	car.Description = SanitizeString(car.Description)

	if !ValidateStringLength(car.Model, 1, 100) || !ValidateStringLength(car.Brand, 1, 100) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	if !ValidateStringLength(car.Description, 0, 5000) {
		writeError(w, http.StatusBadRequest, "content too long")
		return
	}
	if car.Year < 1900 || car.Year > time.Now().Year()+2 {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	if car.Price < 0 || car.Price > 100_000_000 {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	car.ID = id
	if err := s.store.UpdateCar(&car); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, car)
}

func (s *APIServer) handleDeleteCar(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := s.store.DeleteCarImages(id); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	if err := s.store.DeleteCar(id); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "car deleted"})
}

func (s *APIServer) handleAddCarImage(w http.ResponseWriter, r *http.Request) {
	carID, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || carID <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	var req struct {
		ImageURL string `json:"imageUrl"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
		if !ValidateImageURL(req.ImageURL) {
			prefix := ""
			if len(req.ImageURL) > 50 {
				prefix = req.ImageURL[:50]
			} else {
				prefix = req.ImageURL
			}
			log.Printf("[SECURITY] Invalid image upload attempt for car %d: format or content rejected. Prefix: %s", carID, prefix)
			writeError(w, http.StatusBadRequest, "image format not allowed")
			return
		}
		if len(req.ImageURL) > maxBase64Size {
			log.Printf("[SECURITY] Image too large for car %d: %d bytes", carID, len(req.ImageURL))
			writeError(w, http.StatusBadRequest, "image too large (max 5MB)")
			return
		}
	if _, err := s.store.GetCarByID(carID); err != nil {
		writeError(w, http.StatusNotFound, "car not found")
		return
	}
	if err := s.store.AddCarImage(carID, req.ImageURL); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"message": "image added"})
}

func (s *APIServer) handleDeleteCarImage(w http.ResponseWriter, r *http.Request) {
	imageID, err := strconv.Atoi(mux.Vars(r)["imageId"])
	if err != nil || imageID <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := s.store.DeleteCarImage(imageID); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "image deleted"})
}

func (s *APIServer) handleDeleteCarImageByURL(w http.ResponseWriter, r *http.Request) {
	carID, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || carID <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	var req struct {
		ImageURL string `json:"imageUrl"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	if ContainsPathTraversal(req.ImageURL) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	if err := s.store.DeleteCarImageByURL(carID, req.ImageURL); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "image deleted"})
}

// ============================================================
// ORDER HANDLERS
// ============================================================
func (s *APIServer) handleCreateOrder(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r.Context())
	if !ok {
		userIDStr := r.Header.Get("X-User-ID")
		userID, _ = strconv.Atoi(userIDStr)
	}

	var orderReq OrderRequest
	if err := json.NewDecoder(r.Body).Decode(&orderReq); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}

	orderReq.FirstName = SanitizeString(orderReq.FirstName)
	orderReq.LastName = SanitizeString(orderReq.LastName)
	orderReq.Email = strings.ToLower(strings.TrimSpace(orderReq.Email))
	orderReq.Phone = strings.TrimSpace(orderReq.Phone)
	orderReq.Notes = SanitizeString(orderReq.Notes)

	if !ValidateEmail(orderReq.Email) {
		writeError(w, http.StatusBadRequest, "invalid email")
		return
	}
	if !ValidatePhone(orderReq.Phone) {
		writeError(w, http.StatusBadRequest, "invalid phone")
		return
	}
	if !ValidateStringLength(orderReq.FirstName, 1, 50) || !ValidateStringLength(orderReq.LastName, 1, 50) {
		writeError(w, http.StatusBadRequest, "name too long")
		return
	}
	if !ValidateStringLength(orderReq.Notes, 0, 1000) {
		writeError(w, http.StatusBadRequest, "message too long")
		return
	}
	if orderReq.CarID <= 0 {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}

	car, err := s.store.GetCarByID(orderReq.CarID)
	if err != nil {
		writeError(w, http.StatusNotFound, "car not found")
		return
	}
	if car.IsSold {
		writeError(w, http.StatusBadRequest, "car already sold")
		return
	}

	order := &Order{
		UserID:    userID,
		CarID:     orderReq.CarID,
		FirstName: orderReq.FirstName,
		LastName:  orderReq.LastName,
		Email:     orderReq.Email,
		Phone:     orderReq.Phone,
		Notes:     orderReq.Notes,
		Total:     car.Price, // Price always from DB — never from client
	}
	if err := s.store.CreateOrder(order); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, order)
}

func (s *APIServer) handleGetUserOrders(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r.Context())
	if !ok {
		userIDStr := r.Header.Get("X-User-ID")
		userID, _ = strconv.Atoi(userIDStr)
	}
	orders, err := s.store.GetOrdersByUserID(userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, orders)
}

func (s *APIServer) handleGetAllOrders(w http.ResponseWriter, r *http.Request) {
	orders, err := s.store.GetOrders()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, orders)
}

func (s *APIServer) handleDeleteOrder(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := s.store.DeleteOrder(id); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "order deleted"})
}

// ============================================================
// USER HANDLERS
// ============================================================
func (s *APIServer) handleGetAllUsers(w http.ResponseWriter, r *http.Request) {
	users, err := s.store.GetUsers()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	for _, user := range users {
		user.Password = ""
	}
	writeJSON(w, http.StatusOK, users)
}

func (s *APIServer) handleUpdateUserRole(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	var req struct {
		Role string `json:"role"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	if !allowedRoles[req.Role] {
		writeError(w, http.StatusBadRequest, "invalid role")
		return
	}
	if err := s.store.UpdateUserRole(id, req.Role); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "role updated"})
}

func (s *APIServer) handleDeleteUserAdmin(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	adminID, ok := userIDFromContext(r.Context())
	if !ok {
		adminIDStr := r.Header.Get("X-User-ID")
		adminID, _ = strconv.Atoi(adminIDStr)
	}
	if id == adminID {
		writeError(w, http.StatusBadRequest, "cannot delete own account")
		return
	}
	if err := s.store.DeleteUser(id); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "user deleted"})
}

func (s *APIServer) handleToggleUserActive(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	adminID, ok := userIDFromContext(r.Context())
	if !ok {
		adminIDStr := r.Header.Get("X-User-ID")
		adminID, _ = strconv.Atoi(adminIDStr)
	}
	if id == adminID {
		writeError(w, http.StatusBadRequest, "cannot disable own account")
		return
	}
	var body struct {
		IsActive bool `json:"isActive"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}
	if err := s.store.UpdateUserActive(id, body.IsActive); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "updated successfully"})
}

// ============================================================
// CHAT HANDLERS
// ============================================================
func (s *APIServer) handleGetChatMessages(w http.ResponseWriter, r *http.Request) {
	messages, err := s.store.GetChatMessages()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, messages)
}

func (s *APIServer) handleGetOrderChatMessages(w http.ResponseWriter, r *http.Request) {
	orderID, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || orderID <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	userID, ok := userIDFromContext(r.Context())
	if !ok {
		userIDStr := r.Header.Get("X-User-ID")
		userID, _ = strconv.Atoi(userIDStr)
	}
	user, err := s.store.GetUserByID(userID)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "user not found")
		return
	}
	// IDOR protection: only admin or order owner can read messages
	if user.Role != "admin" {
		orders, _ := s.store.GetOrdersByUserID(userID)
		isOwner := false
		for _, o := range orders {
			if o.ID == orderID {
				isOwner = true
				break
			}
		}
		if !isOwner {
			log.Printf("[SECURITY] IDOR attempt: user %d tried to access order %d chat", userID, orderID)
			writeError(w, http.StatusForbidden, "access denied")
			return
		}
	}
	messages, err := s.store.GetChatMessagesByOrderID(orderID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, messages)
}

func (s *APIServer) handleCreateChatMessage(w http.ResponseWriter, r *http.Request) {
	s.handleCreateChatMessageFixed(w, r)
}

func (s *APIServer) handleCreateChatMessageFixed(w http.ResponseWriter, r *http.Request) {
	userID, ok := userIDFromContext(r.Context())
	if !ok {
		userIDStr := r.Header.Get("X-User-ID")
		userID, _ = strconv.Atoi(userIDStr)
	}
	user, err := s.store.GetUserByID(userID)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "user not found")
		return
	}

	var req struct {
		OrderID *int   `json:"orderId"`
		Content string `json:"content"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}

	req.Content = SanitizeString(req.Content)
	if req.Content == "" {
		writeError(w, http.StatusBadRequest, "missing required fields")
		return
	}
	if !ValidateStringLength(req.Content, 1, 2000) {
		writeError(w, http.StatusBadRequest, "message too long")
		return
	}

	// Verify order ownership when orderId is provided
	if req.OrderID != nil && *req.OrderID > 0 && user.Role != "admin" {
		orders, _ := s.store.GetOrdersByUserID(userID)
		isOwner := false
		for _, o := range orders {
			if o.ID == *req.OrderID {
				isOwner = true
				break
			}
		}
		if !isOwner {
			writeError(w, http.StatusForbidden, "access denied")
			return
		}
	}

	msg := &ChatMessage{
		OrderID:    req.OrderID,
		UserID:     userID,
		SenderName: user.FirstName + " " + user.LastName, // From DB — not from client
		Content:    req.Content,
	}
	if err := s.store.CreateChatMessage(msg); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, msg)
}

func (s *APIServer) handleDeleteChatMessage(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(mux.Vars(r)["id"])
	if err != nil || id <= 0 {
		writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := s.store.DeleteChatMessage(id); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "chat deleted"})
}

// ============================================================
// CMS HANDLERS
// ============================================================
func (s *APIServer) handleGetCMSPage(w http.ResponseWriter, r *http.Request) {
	slug := mux.Vars(r)["slug"]
	if !ValidateSlug(slug) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	page, err := s.store.GetCMSPage(slug)
	if err != nil {
		writeError(w, http.StatusNotFound, "page not found")
		return
	}
	writeJSON(w, http.StatusOK, page)
}

func (s *APIServer) handleGetAllCMSPages(w http.ResponseWriter, r *http.Request) {
	pages, err := s.store.GetAllCMSPages()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, pages)
}

func (s *APIServer) handleUpdateCMSPage(w http.ResponseWriter, r *http.Request) {
	slug := mux.Vars(r)["slug"]
	if !ValidateSlug(slug) {
		writeError(w, http.StatusBadRequest, "invalid input")
		return
	}
	var req struct {
		Title   string `json:"title"`
		Content string `json:"content"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	req.Title = SanitizeString(req.Title)
	req.Content = SanitizeString(req.Content)

	if !ValidateStringLength(req.Title, 1, 200) {
		writeError(w, http.StatusBadRequest, "field too long")
		return
	}
	if !ValidateStringLength(req.Content, 0, 50000) {
		writeError(w, http.StatusBadRequest, "content too long")
		return
	}
	if err := s.store.UpdateCMSPage(slug, req.Title, req.Content); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "page updated"})
}

// ============================================================
// CONTACT HANDLERS
// ============================================================
func (s *APIServer) handleCreateContactMessage(w http.ResponseWriter, r *http.Request) {
	var req ContactMessage
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request")
		return
	}
	req.FullName = SanitizeString(req.FullName)
	req.Email = strings.ToLower(strings.TrimSpace(req.Email))
	req.Phone = strings.TrimSpace(req.Phone)
	req.Subject = SanitizeString(req.Subject)
	req.Message = SanitizeString(req.Message)

	if req.FullName == "" || req.Email == "" || req.Message == "" {
		writeError(w, http.StatusBadRequest, "missing required fields")
		return
	}
	if !ValidateEmail(req.Email) {
		writeError(w, http.StatusBadRequest, "invalid email")
		return
	}
	if !ValidatePhone(req.Phone) {
		writeError(w, http.StatusBadRequest, "invalid phone")
		return
	}
	if !ValidateStringLength(req.FullName, 1, 100) {
		writeError(w, http.StatusBadRequest, "name too long")
		return
	}
	if !ValidateStringLength(req.Message, 1, 5000) {
		writeError(w, http.StatusBadRequest, "message too long")
		return
	}
	if !ValidateStringLength(req.Subject, 0, 200) {
		writeError(w, http.StatusBadRequest, "field too long")
		return
	}
	req.Source = "contact_page" // Force source — never trust client
	if err := s.store.CreateContactMessage(&req); err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"message": "message sent successfully"})
}

func (s *APIServer) handleGetContactMessages(w http.ResponseWriter, r *http.Request) {
	messages, err := s.store.GetContactMessages()
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, messages)
}