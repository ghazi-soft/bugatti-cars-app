package main

import "time"

// User represents a user in the system
type User struct {
	ID        int       `json:"id"`
	FirstName string    `json:"firstName"`
	LastName  string    `json:"lastName"`
	Email     string    `json:"email"`
	Password  string    `json:"password,omitempty"` // omitempty — never serialized in responses
	Role      string    `json:"role"`
	IsActive  bool      `json:"isActive"`
	CreatedAt time.Time `json:"createdAt"`
}

// Car represents a car in the dealership
type Car struct {
	ID          int        `json:"id"`
	Model       string     `json:"model"`
	Brand       string     `json:"brand"`
	Year        int        `json:"year"`
	Price       float64    `json:"price"`
	Description string     `json:"description"`
	IsSold      bool       `json:"isSold"`
	Images      []CarImage `json:"images"`
	CreatedAt   time.Time  `json:"createdAt"`
}

// CarImage represents an image associated with a car
type CarImage struct {
	ID       int    `json:"id"`
	CarID    int    `json:"carId"`
	ImageURL string `json:"imageUrl"`
}

// Order represents a purchase order
type Order struct {
	ID        int       `json:"id"`
	UserID    int       `json:"userId"`
	CarID     int       `json:"carId"`
	FirstName string    `json:"firstName"`
	LastName  string    `json:"lastName"`
	Email     string    `json:"email"`
	Phone     string    `json:"phone"`
	Notes     string    `json:"notes"`
	Total     float64   `json:"total"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"createdAt"`
}

// CMSPage represents editable content pages
type CMSPage struct {
	ID        int       `json:"id"`
	Slug      string    `json:"slug"` // "home", "about", "contact"
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	UpdatedAt time.Time `json:"updatedAt"`
}

// LoginRequest is used for login
type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// LoginResponse returns JWT token and user info
type LoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

// OrderRequest is used to create orders
type OrderRequest struct {
	CarID     int    `json:"carId"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	Notes     string `json:"notes"`
}

// ChatMessage represents a chat message
type ChatMessage struct {
	ID         int       `json:"id"`
	OrderID    *int      `json:"orderId,omitempty"`
	UserID     int       `json:"userId"`
	SenderName string    `json:"senderName"`
	Content    string    `json:"content"`
	CreatedAt  time.Time `json:"createdAt"`
}

// ContactMessage represents a contact form submission
type ContactMessage struct {
	ID        int       `json:"id"`
	FullName  string    `json:"fullName"`
	Email     string    `json:"email"`
	Phone     string    `json:"phone"`
	Subject   string    `json:"subject"`
	Message   string    `json:"message"`
	Source    string    `json:"source"`
	CreatedAt time.Time `json:"createdAt"`
}
