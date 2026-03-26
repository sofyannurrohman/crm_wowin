package main

import (
	"context"
	"log"
	"os"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/wowin_crm?sslmode=disable"
	}

	ctx := context.Background()
	dbpool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer dbpool.Close()

	log.Println("🌱 Seeding database...")

	// 1. Seed Users
	adminID := seedUsers(ctx, dbpool)

	// 2. Seed Product Categories & Products
	seedProducts(ctx, dbpool)

	// 3. Seed Territories
	territoryID := seedTerritories(ctx, dbpool, adminID)

	// 4. Seed Customers & Contacts
	seedCustomers(ctx, dbpool, adminID, territoryID)

	log.Println("✅ Seeding completed!")
}

func hashPassword(password string) string {
	bytes, _ := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes)
}

func seedUsers(ctx context.Context, db *pgxpool.Pool) uuid.UUID {
	log.Println("  -> Seeding Users...")
	
	adminID := uuid.New()
	salesID1 := uuid.New()
	salesID2 := uuid.New()

	passHash := hashPassword("password123")

	users := []struct {
		id    uuid.UUID
		name  string
		email string
		role  string
		code  string
	}{
		{adminID, "Super Admin", "admin@wowin.com", "super_admin", "EMP001"},
		{salesID1, "John Sales", "john@wowin.com", "sales", "EMP002"},
		{salesID2, "Jane Sales", "jane@wowin.com", "sales", "EMP003"},
	}

	for _, u := range users {
		query := `INSERT INTO users (id, name, email, password_hash, role, employee_code, status) 
				  VALUES ($1, $2, $3, $4, $5, $6, 'active') ON CONFLICT (email) DO NOTHING`
		_, err := db.Exec(ctx, query, u.id, u.name, u.email, passHash, u.role, u.code)
		if err != nil {
			log.Printf("    warning: failed to seed user %s: %v", u.email, err)
		}
	}

	return adminID
}

func seedProducts(ctx context.Context, db *pgxpool.Pool) {
	log.Println("  -> Seeding Products...")

	categories := []struct {
		id   uuid.UUID
		name string
	}{
		{uuid.New(), "Electronics"},
		{uuid.New(), "Office Supplies"},
		{uuid.New(), "Software Services"},
	}

	for _, cat := range categories {
		query := `INSERT INTO product_categories (id, name, is_active) VALUES ($1, $2, true) ON CONFLICT DO NOTHING`
		db.Exec(ctx, query, cat.id, cat.name)

		// Seed some products for each category
		products := []struct {
			name  string
			sku   string
			price float64
		}{
			{cat.name + " Plan A", cat.name[:3] + "-001", 1000000},
			{cat.name + " Plan B", cat.name[:3] + "-002", 2500000},
		}

		for _, p := range products {
			pQuery := `INSERT INTO products (category_id, name, sku, price, is_active) VALUES ($1, $2, $3, $4, true) ON CONFLICT DO NOTHING`
			db.Exec(ctx, pQuery, cat.id, p.name, p.sku, p.price)
		}
	}
}

func seedTerritories(ctx context.Context, db *pgxpool.Pool, adminID uuid.UUID) uuid.UUID {
	log.Println("  -> Seeding Territories...")

	tID := uuid.New()
	// A simple polygon around Jakarta (roughly)
	geom := `{"type":"Polygon","coordinates":[[[106.7,-6.1],[106.9,-6.1],[106.9,-6.3],[106.7,-6.3],[106.7,-6.1]]]}`
	
	query := `INSERT INTO territories (id, name, description, geom, color, created_by) 
			  VALUES ($1, $2, $3, ST_GeomFromGeoJSON($4), $5, $6) ON CONFLICT DO NOTHING`
	_, err := db.Exec(ctx, query, tID, "Jakarta Central", "Core Jakarta business area", geom, "#FF5733", adminID)
	if err != nil {
		log.Printf("    warning: failed to seed territory: %v", err)
	}

	return tID
}

func seedCustomers(ctx context.Context, db *pgxpool.Pool, adminID, territoryID uuid.UUID) {
	log.Println("  -> Seeding Customers...")

	customers := []struct {
		name    string
		company string
		email   string
		lat     float64
		lon     float64
	}{
		{"Budi Santoso", "PT Maju Terus", "budi@maju.com", -6.2, 106.8},
		{"Siti Aminah", "Catering Berkah", "siti@berkah.com", -6.21, 106.81},
	}

	for _, c := range customers {
		cID := uuid.New()
		query := `INSERT INTO customers (id, name, company_name, email, type, status, location, territory_id, created_by) 
				  VALUES ($1, $2, $3, $4, 'company', 'active', ST_SetSRID(ST_MakePoint($5, $6), 4326), $7, $8) ON CONFLICT DO NOTHING`
		_, err := db.Exec(ctx, query, cID, c.name, c.company, c.email, c.lon, c.lat, territoryID, adminID)
		if err != nil {
			log.Printf("    warning: failed to seed customer %s: %v", c.name, err)
			continue
		}

		// Also seed a primary contact
		contactQuery := `INSERT INTO contacts (customer_id, name, email, is_primary) VALUES ($1, $2, $3, true)`
		db.Exec(ctx, contactQuery, cID, c.name, c.email)
	}
}
