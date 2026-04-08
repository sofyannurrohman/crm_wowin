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
	
	adminID := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
	salesID1 := uuid.MustParse("550e8400-e29b-41d4-a716-446655440001")
	salesID2 := uuid.MustParse("550e8400-e29b-41d4-a716-446655440002")

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
				  VALUES ($1, $2, $3, $4, $5, $6, 'active') 
				  ON CONFLICT (email) DO UPDATE SET updated_at = NOW() 
				  RETURNING id`
		var actualID uuid.UUID
		err := db.QueryRow(ctx, query, u.id, u.name, u.email, passHash, u.role, u.code).Scan(&actualID)
		if err != nil {
			log.Printf("    warning: failed to seed user %s: %v", u.email, err)
			continue
		}
		if u.email == "admin@wowin.com" {
			adminID = actualID
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
		{uuid.MustParse("550e8400-e29b-41d4-a716-446655440020"), "Electronics"},
		{uuid.MustParse("550e8400-e29b-41d4-a716-446655440021"), "Office Supplies"},
		{uuid.MustParse("550e8400-e29b-41d4-a716-446655440022"), "Software Services"},
	}

	for _, cat := range categories {
		query := `INSERT INTO product_categories (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING`
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
			pQuery := `INSERT INTO products (category_id, name, code, base_price, is_active) VALUES ($1, $2, $3, $4, true) ON CONFLICT DO NOTHING`
			db.Exec(ctx, pQuery, cat.id, p.name, p.sku, p.price)
		}
	}
}

func seedTerritories(ctx context.Context, db *pgxpool.Pool, adminID uuid.UUID) uuid.UUID {
	log.Println("  -> Seeding Territories...")

	tID := uuid.MustParse("550e8400-e29b-41d4-a716-446655440010")
	// A simple polygon around Jakarta (roughly)
	geom := `{"type":"Polygon","coordinates":[[[106.7,-6.1],[106.9,-6.1],[106.9,-6.3],[106.7,-6.3],[106.7,-6.1]]]}`
	
	query := `INSERT INTO territories (id, name, description, geom, color, created_by) 
			  VALUES ($1, $2, $3, ST_GeomFromGeoJSON($4), $5, $6) 
			  ON CONFLICT (id) DO UPDATE SET updated_at = NOW()
			  RETURNING id`
	err := db.QueryRow(ctx, query, tID, "Jakarta Central", "Core Jakarta business area", geom, "#FF5733", adminID).Scan(&tID)
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
		typeStr string
		lat     float64
		lon     float64
	}{
		{"Budi Santoso", "Warung Makan Indah", "budi@warungindah.com", "warung", -6.2, 106.8},
		{"Siti Aminah", "Catering Berkah", "siti@berkah.com", "company", -6.21, 106.81},
		{"Andi Wijaya", "Cafe Kopi Senja", "andi@kopisenja.com", "cafe", -6.22, 106.82},
		{"Rina Kartika", "Toko Kelontong Rina", "rina@tokorina.com", "toko", -6.18, 106.85},
	}

	for _, c := range customers {
		cID := uuid.New()
		query := `INSERT INTO customers (id, name, company_name, email, type, status, location, territory_id, created_by) 
				  VALUES ($1, $2, $3, $4, $5, 'active', ST_SetSRID(ST_MakePoint($6, $7), 4326), $8, $9) ON CONFLICT DO NOTHING`
		_, err := db.Exec(ctx, query, cID, c.name, c.company, c.email, c.typeStr, c.lon, c.lat, territoryID, adminID)
		if err != nil {
			log.Printf("    warning: failed to seed customer %s (%s): %v", c.name, c.typeStr, err)
			continue
		}

		// Also seed a primary contact
		contactQuery := `INSERT INTO contacts (customer_id, name, email, is_primary) VALUES ($1, $2, $3, true)`
		db.Exec(ctx, contactQuery, cID, c.name, c.email)
	}
}
