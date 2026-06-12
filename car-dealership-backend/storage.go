package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type PostgresStore struct {
	db *sql.DB
}

// NewPostgresStore creates a new database connection.
// SECURITY FIX: Credentials loaded from environment variables — never hardcoded.
// Set DATABASE_URL in your .env file or server environment.
func NewPostgresStore() (*PostgresStore, error) {
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		// Fallback: build from individual env vars
		host := getEnvOrDefault("DB_HOST", "localhost")
		port := getEnvOrDefault("DB_PORT", "5432")
		user := getEnvOrDefault("DB_USER", "postgres")
		password := os.Getenv("DB_PASSWORD")
		dbname := getEnvOrDefault("DB_NAME", "car-dealership-backend")
		sslmode := getEnvOrDefault("DB_SSLMODE", "disable")

		if password == "" {
			log.Fatal("[SECURITY] DB_PASSWORD environment variable is required — never hardcode credentials!")
		}

		connStr = fmt.Sprintf(
			"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
			host, port, user, password, dbname, sslmode,
		)
	}

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Connection pool settings
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	log.Println("[DB] Database connection established successfully")
	return &PostgresStore{db: db}, nil
}

func getEnvOrDefault(key, defaultVal string) string {
	val := os.Getenv(key)
	if val == "" {
		return defaultVal
	}
	return val
}

// ============================================================
// USERS
// ============================================================

func (s *PostgresStore) CreateUser(user *User) error {
	query := `INSERT INTO users (first_name, last_name, email, password, role, is_active, created_at)
VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id`

	err := s.db.QueryRow(query,
		user.FirstName,
		user.LastName,
		user.Email,
		user.Password,
		"user", // Default role — SECURITY: always force, never trust caller
		true,
		time.Now(),
	).Scan(&user.ID)

	return err
}

func (s *PostgresStore) UpdateUser(user *User) error {
	_, err := s.db.Exec(`
		UPDATE users 
		SET first_name=$1, last_name=$2, email=$3
		WHERE id=$4
		`, user.FirstName, user.LastName, user.Email, user.ID)
	return err
}

func (s *PostgresStore) GetUsers() ([]*User, error) {
	// SECURITY: Never select password in user list queries
	rows, err := s.db.Query(`SELECT id, first_name, last_name, email, role, is_active, created_at FROM users ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*User
	for rows.Next() {
		user := new(User)
		err := rows.Scan(
			&user.ID,
			&user.FirstName,
			&user.LastName,
			&user.Email,
			&user.Role,
			&user.IsActive,
			&user.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}

func (s *PostgresStore) GetUserByID(id int) (*User, error) {
	row := s.db.QueryRow(
		`SELECT id, first_name, last_name, email, password, role, is_active, created_at FROM users WHERE id=$1`,
		id,
	)
	user := new(User)
	err := row.Scan(
		&user.ID,
		&user.FirstName,
		&user.LastName,
		&user.Email,
		&user.Password,
		&user.Role,
		&user.IsActive,
		&user.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (s *PostgresStore) GetUserByEmail(email string) (*User, error) {
	row := s.db.QueryRow(
		`SELECT id, first_name, last_name, email, password, role, is_active, created_at FROM users WHERE email=$1`,
		email,
	)
	user := new(User)
	err := row.Scan(
		&user.ID,
		&user.FirstName,
		&user.LastName,
		&user.Email,
		&user.Password,
		&user.Role,
		&user.IsActive,
		&user.CreatedAt,
	)
	return user, err
}

// SeedAdmin creates the default admin account on first run.
// SECURITY FIX: Admin email and password loaded from environment variables.
// Set ADMIN_EMAIL and ADMIN_PASSWORD in your .env file.
func (s *PostgresStore) SeedAdmin() {
	adminEmail := os.Getenv("ADMIN_EMAIL")
	adminPassword := os.Getenv("ADMIN_PASSWORD")
	adminFirstName := getEnvOrDefault("ADMIN_FIRST_NAME", "Admin")
	adminLastName := getEnvOrDefault("ADMIN_LAST_NAME", "System")

	// SECURITY: Both must be set via environment — refuse to use defaults in production
	if adminEmail == "" || adminPassword == "" {
		log.Println("[SECURITY WARNING] ADMIN_EMAIL and ADMIN_PASSWORD env vars not set — skipping admin seed.")
		log.Println("[SECURITY WARNING] Set them in your .env file to create the admin account.")
		return
	}

	if len(adminPassword) < 12 {
		log.Fatal("[SECURITY] ADMIN_PASSWORD must be at least 12 characters!")
	}

	var exists bool
	err := s.db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, adminEmail).Scan(&exists)
	if err != nil {
		log.Printf("[DB] SeedAdmin check error: %v", err)
		return
	}

	if exists {
		return // Admin already exists — do nothing
	}

	// SECURITY: bcrypt cost 12 (higher than default 10)
	hashed, err := bcrypt.GenerateFromPassword([]byte(adminPassword), 12)
	if err != nil {
		log.Printf("[ERROR] Failed to hash admin password: %v", err)
		return
	}

	_, err = s.db.Exec(`
		INSERT INTO users (first_name, last_name, email, password, role, is_active, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7)
		`,
		adminFirstName,
		adminLastName,
		adminEmail,
		string(hashed),
		"admin",
		true,
		time.Now(),
	)

	if err != nil {
		log.Printf("[DB] Insert admin error: %v", err)
	} else {
		log.Printf("[INIT] Admin account created for: %s", adminEmail)
	}
}

func (s *PostgresStore) UpdateUserActive(id int, isActive bool) error {
	_, err := s.db.Exec(`UPDATE users SET is_active=$1 WHERE id=$2`, isActive, id)
	return err
}

func (s *PostgresStore) UpdateUserRole(userID int, role string) error {
	_, err := s.db.Exec(`UPDATE users SET role=$1 WHERE id=$2`, role, userID)
	return err
}

func (s *PostgresStore) DeleteUser(id int) error {
	_, err := s.db.Exec(`DELETE FROM users WHERE id=$1`, id)
	return err
}

// ============================================================
// CARS
// ============================================================

func (s *PostgresStore) CreateCar(car *Car) error {
	query := `INSERT INTO cars (model, brand, year, price, description, is_sold, created_at)
	VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id`

	err := s.db.QueryRow(query,
		car.Model,
		car.Brand,
		car.Year,
		car.Price,
		car.Description,
		false,
		time.Now(),
	).Scan(&car.ID)

	return err
}

func (s *PostgresStore) GetCars() ([]*Car, error) {
	rows, err := s.db.Query(`SELECT id, model, brand, year, price, description, is_sold, created_at FROM cars ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cars []*Car
	for rows.Next() {
		car := new(Car)
		err := rows.Scan(
			&car.ID,
			&car.Model,
			&car.Brand,
			&car.Year,
			&car.Price,
			&car.Description,
			&car.IsSold,
			&car.CreatedAt,
		)
		if err != nil {
			return nil, err
		}

		images, err := s.GetCarImages(car.ID)
		if err == nil {
			car.Images = images
		}

		cars = append(cars, car)
	}
	return cars, nil
}

func (s *PostgresStore) GetCarByID(id int) (*Car, error) {
	row := s.db.QueryRow(
		`SELECT id, model, brand, year, price, description, is_sold, created_at FROM cars WHERE id=$1`,
		id,
	)

	car := new(Car)
	err := row.Scan(
		&car.ID,
		&car.Model,
		&car.Brand,
		&car.Year,
		&car.Price,
		&car.Description,
		&car.IsSold,
		&car.CreatedAt,
	)
	if err != nil {
		return nil, err
	}

	images, err := s.GetCarImages(car.ID)
	if err == nil {
		car.Images = images
	}

	return car, nil
}

func (s *PostgresStore) UpdateCar(car *Car) error {
	query := `
	UPDATE cars 
	SET model=$1, brand=$2, year=$3, price=$4, description=$5, is_sold=$6
	WHERE id=$7
	`
	_, err := s.db.Exec(query,
		car.Model,
		car.Brand,
		car.Year,
		car.Price,
		car.Description,
		car.IsSold,
		car.ID,
	)
	return err
}

func (s *PostgresStore) DeleteCar(id int) error {
	_, err := s.db.Exec(`DELETE FROM cars WHERE id=$1`, id)
	return err
}

// ============================================================
// CAR IMAGES
// ============================================================

func (s *PostgresStore) AddCarImage(carID int, imageURL string) error {
	_, err := s.db.Exec(`INSERT INTO car_images (car_id, image_url) VALUES ($1, $2)`, carID, imageURL)
	return err
}

func (s *PostgresStore) GetCarImages(carID int) ([]CarImage, error) {
	rows, err := s.db.Query(
		`SELECT id, image_url FROM car_images WHERE car_id=$1 ORDER BY id`,
		carID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var images []CarImage
	for rows.Next() {
		var img CarImage
		if err := rows.Scan(&img.ID, &img.ImageURL); err != nil {
			return nil, err
		}
		img.CarID = carID
		images = append(images, img)
	}
	return images, nil
}

func (s *PostgresStore) DeleteCarImage(imageID int) error {
	_, err := s.db.Exec(`DELETE FROM car_images WHERE id=$1`, imageID)
	return err
}

func (s *PostgresStore) DeleteCarImageByURL(carID int, imageURL string) error {
	// SECURITY FIX: Removed debug fmt.Printf that logged image URLs to console
	result, err := s.db.Exec(
		`DELETE FROM car_images WHERE car_id=$1 AND image_url=$2`,
		carID,
		imageURL,
	)
	if err != nil {
		log.Printf("[DB] DeleteCarImageByURL error for car %d: %v", carID, err)
		return err
	}
	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		log.Printf("[DB] No image found to delete for car %d", carID)
	}
	return nil
}

func (s *PostgresStore) DeleteCarImages(carID int) error {
	_, err := s.db.Exec(`DELETE FROM car_images WHERE car_id=$1`, carID)
	return err
}

// ============================================================
// ORDERS
// ============================================================

func (s *PostgresStore) CreateOrder(order *Order) error {
	query := `INSERT INTO orders (user_id, car_id, first_name, last_name, email, phone, notes, total, status, created_at)
	VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING id`

	err := s.db.QueryRow(query,
		order.UserID,
		order.CarID,
		order.FirstName,
		order.LastName,
		order.Email,
		order.Phone,
		order.Notes,
		order.Total,
		"pending",
		time.Now(),
	).Scan(&order.ID)

	if err != nil {
		return fmt.Errorf("create order failed: %w", err)
	}

	// Mark car as sold
	_, err = s.db.Exec(`UPDATE cars SET is_sold=true WHERE id=$1`, order.CarID)
	if err != nil {
		return fmt.Errorf("update car sold status failed: %w", err)
	}

	return nil
}

func (s *PostgresStore) GetOrders() ([]*Order, error) {
	rows, err := s.db.Query(`
		SELECT id, user_id, car_id, first_name, last_name, email, phone, notes, total, status, created_at 
		FROM orders ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []*Order
	for rows.Next() {
		order := new(Order)
		err := rows.Scan(
			&order.ID, &order.UserID, &order.CarID,
			&order.FirstName, &order.LastName, &order.Email,
			&order.Phone, &order.Notes, &order.Total,
			&order.Status, &order.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, order)
	}
	return orders, nil
}

func (s *PostgresStore) GetOrdersByUserID(userID int) ([]*Order, error) {
	rows, err := s.db.Query(`
		SELECT id, user_id, car_id, first_name, last_name, email, phone, notes, total, status, created_at 
		FROM orders WHERE user_id=$1 ORDER BY created_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []*Order
	for rows.Next() {
		order := new(Order)
		err := rows.Scan(
			&order.ID, &order.UserID, &order.CarID,
			&order.FirstName, &order.LastName, &order.Email,
			&order.Phone, &order.Notes, &order.Total,
			&order.Status, &order.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		orders = append(orders, order)
	}
	return orders, nil
}

func (s *PostgresStore) DeleteOrder(id int) error {
	row := s.db.QueryRow(`SELECT car_id FROM orders WHERE id=$1`, id)
	var carID int
	if err := row.Scan(&carID); err != nil {
		return err
	}

	_, err := s.db.Exec(`DELETE FROM orders WHERE id=$1`, id)
	if err != nil {
		return err
	}

	_, err = s.db.Exec(`UPDATE cars SET is_sold=false WHERE id=$1`, carID)
	return err
}

// ============================================================
// CMS PAGES
// ============================================================

func (s *PostgresStore) GetCMSPage(slug string) (*CMSPage, error) {
	row := s.db.QueryRow(
		`SELECT id, slug, title, content, updated_at FROM cms_pages WHERE slug=$1`,
		slug,
	)
	page := new(CMSPage)
	err := row.Scan(&page.ID, &page.Slug, &page.Title, &page.Content, &page.UpdatedAt)
	return page, err
}

func (s *PostgresStore) GetAllCMSPages() ([]*CMSPage, error) {
	rows, err := s.db.Query(`SELECT id, slug, title, content, updated_at FROM cms_pages`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var pages []*CMSPage
	for rows.Next() {
		page := new(CMSPage)
		err := rows.Scan(&page.ID, &page.Slug, &page.Title, &page.Content, &page.UpdatedAt)
		if err != nil {
			return nil, err
		}
		pages = append(pages, page)
	}
	return pages, nil
}

func (s *PostgresStore) UpdateCMSPage(slug, title, content string) error {
	_, err := s.db.Exec(
		`UPDATE cms_pages SET title=$1, content=$2, updated_at=$3 WHERE slug=$4`,
		title, content, time.Now(), slug,
	)
	return err
}

// ============================================================
// CHAT
// ============================================================

func (s *PostgresStore) GetChatMessages() ([]*ChatMessage, error) {
	rows, err := s.db.Query(`
		SELECT id, order_id, user_id, sender_name, content, created_at
		FROM chat_messages
		ORDER BY created_at ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*ChatMessage
	for rows.Next() {
		msg := new(ChatMessage)
		err := rows.Scan(
			&msg.ID, &msg.OrderID, &msg.UserID,
			&msg.SenderName, &msg.Content, &msg.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		messages = append(messages, msg)
	}
	return messages, nil
}

func (s *PostgresStore) GetChatMessagesByOrderID(orderID int) ([]*ChatMessage, error) {
	rows, err := s.db.Query(`
		SELECT id, order_id, user_id, sender_name, content, created_at
		FROM chat_messages
		WHERE order_id=$1
		ORDER BY created_at ASC
	`, orderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*ChatMessage
	for rows.Next() {
		msg := new(ChatMessage)
		err := rows.Scan(
			&msg.ID, &msg.OrderID, &msg.UserID,
			&msg.SenderName, &msg.Content, &msg.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		messages = append(messages, msg)
	}
	return messages, nil
}

func (s *PostgresStore) CreateChatMessage(msg *ChatMessage) error {
	return s.db.QueryRow(`
		INSERT INTO chat_messages (order_id, user_id, sender_name, content, created_at)
		VALUES ($1,$2,$3,$4,$5)
		RETURNING id
		`,
		msg.OrderID,
		msg.UserID,
		msg.SenderName,
		msg.Content,
		time.Now(),
	).Scan(&msg.ID)
}

func (s *PostgresStore) DeleteChatMessage(id int) error {
	_, err := s.db.Exec(`DELETE FROM chat_messages WHERE id=$1`, id)
	return err
}

// ============================================================
// CONTACT
// ============================================================

func (s *PostgresStore) CreateContactMessage(msg *ContactMessage) error {
	return s.db.QueryRow(`
		INSERT INTO contact_messages (full_name, email, phone, subject, message, source, created_at)
		VALUES ($1,$2,$3,$4,$5,$6,$7)
		RETURNING id
		`,
		msg.FullName,
		msg.Email,
		msg.Phone,
		msg.Subject,
		msg.Message,
		msg.Source,
		time.Now(),
	).Scan(&msg.ID)
}

func (s *PostgresStore) GetContactMessages() ([]*ContactMessage, error) {
	rows, err := s.db.Query(`
		SELECT id, full_name, email, phone, subject, message, source, created_at
		FROM contact_messages
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []*ContactMessage
	for rows.Next() {
		msg := new(ContactMessage)
		err := rows.Scan(
			&msg.ID, &msg.FullName, &msg.Email,
			&msg.Phone, &msg.Subject, &msg.Message,
			&msg.Source, &msg.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		messages = append(messages, msg)
	}
	return messages, nil
}
