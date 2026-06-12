package main

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func main() {

	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Println("[CONFIG] No .env file found — using system environment variables")
	}

	// Validate environment variables
	validateEnv()

	// Connect database
	store, err := NewPostgresStore()
	if err != nil {
		log.Fatalf("[FATAL] Could not connect to database: %v", err)
	}

	// Seed admin
	store.SeedAdmin()

	// Get PORT from hosting provider
	port := os.Getenv("PORT")

	// If PORT not found use LISTEN_ADDR
	if port == "" {

		listenAddr := os.Getenv("LISTEN_ADDR")

		// Default local port
		if listenAddr == "" {
			listenAddr = ":3000"
		}

		server := NewAPIServer(listenAddr, store)
		server.Run()
		return
	}

	// Production port
	listenAddr := ":" + port

	server := NewAPIServer(listenAddr, store)
	server.Run()
}

// validateEnv checks required environment variables
func validateEnv() {

	required := []string{
		"DB_PASSWORD",
		"JWT_SECRET",
		"ADMIN_EMAIL",
		"ADMIN_PASSWORD",
	}

	missing := []string{}

	for _, key := range required {
		if os.Getenv(key) == "" {
			missing = append(missing, key)
		}
	}

	if len(missing) > 0 {
		log.Printf("[SECURITY WARNING] Missing environment variables: %v", missing)
		log.Println("[SECURITY WARNING] These MUST be set before deploying to production!")
	}

	// JWT validation
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret != "" && len(jwtSecret) < 32 {
		log.Fatal("[SECURITY] JWT_SECRET must be at least 32 characters!")
	}

	// Admin password validation
	adminPass := os.Getenv("ADMIN_PASSWORD")
	if adminPass != "" && len(adminPass) < 12 {
		log.Fatal("[SECURITY] ADMIN_PASSWORD must be at least 12 characters!")
	}
}
