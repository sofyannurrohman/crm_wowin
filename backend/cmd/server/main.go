package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"crm_wowin_backend/internal/delivery/http/handlers"
	"crm_wowin_backend/internal/delivery/http/routes"
	"crm_wowin_backend/internal/repository/postgres"
	"crm_wowin_backend/internal/usecase"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

// Config represents environment variables for initial bootstrapping
type Config struct {
	Port        string
	DatabaseURL string
	RedisURL    string
	UploadsDir  string
}

// loadConfig defines basic env variables lookup with sane local defaults
func loadConfig() Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		// Default fallback for local postgres development
		dbURL = "postgres://postgres:postgres@localhost:5432/wowin_crm?sslmode=disable"
	}

	redisURL := os.Getenv("REDIS_URL")
	if redisURL == "" {
		redisURL = "redis://localhost:6379/0"
	}

	uploadsDir := os.Getenv("UPLOADS_DIR")
	if uploadsDir == "" {
		uploadsDir = "./storage/uploads"
	}

	return Config{
		Port:        port,
		DatabaseURL: dbURL,
		RedisURL:    redisURL,
		UploadsDir:  uploadsDir,
	}
}

func main() {
	// 1. Load application configuration
	cfg := loadConfig()

	// 2. Setup Context for system timeout and database connectivity logic
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	log.Println("🚀 Starting Wowin CRM Backend Engine...")

	// 3. Initialize PostgreSQL (pgxpool)
	// 'pgxpool' is highly recommended over generic 'sql' module for PostGIS & concurrent high-level apps
	dbpool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("❌ Unable to create database connection pool: %v\n", err)
	}
	defer dbpool.Close()

	if err := dbpool.Ping(ctx); err != nil {
		log.Fatalf("❌ Unable to ping PostgreSQL database: %v\n", err)
	}
	log.Println("✅ PostgreSQL connected successfully")

	// 4. Initialize Redis Client
	opts, err := redis.ParseURL(cfg.RedisURL)
	if err != nil {
		log.Fatalf("❌ Unable to parse Redis URL: %v\n", err)
	}
	rdb := redis.NewClient(opts)
	defer rdb.Close()

	if err := rdb.Ping(ctx).Err(); err != nil {
		log.Printf("⚠️ Redis connection warning (check if Redis is running): %v\n", err)
	} else {
		log.Println("✅ Redis connected successfully")
	}

	// 5. Ensure System Upload Directory Exists for Photo Submissions
	if err := os.MkdirAll(cfg.UploadsDir, os.ModePerm); err != nil {
		log.Fatalf("❌ Unable to create upload directory %s: %v\n", cfg.UploadsDir, err)
	}

	// 6. Bootstrap Gin Framework Router
	// Enable release mode in production env
	if os.Getenv("GIN_MODE") == "release" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()

	// Disable automatic trailing-slash redirect — it strips CORS headers on 301
	router.RedirectTrailingSlash = false
	router.RedirectFixedPath = false

	// Core application middlewares
	router.Use(gin.Recovery())
	router.Use(gin.Logger())

	// CORS Middleware
	router.Use(func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		if origin != "" {
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			allowedOrigin := os.Getenv("CORS_ORIGIN")
			if allowedOrigin == "" {
				allowedOrigin = "http://localhost:8081"
			}
			c.Writer.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
		}

		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, PATCH, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// Dependency Injection Layers
	userRepo := postgres.NewUserRepository(dbpool)
	customerRepo := postgres.NewCustomerRepository(dbpool)
	leadRepo := postgres.NewLeadRepository(dbpool)
	dealRepo := postgres.NewDealRepository(dbpool)
	productRepo := postgres.NewProductRepository(dbpool)
	dealItemRepo := postgres.NewDealItemRepository(dbpool)
	visitRepo := postgres.NewVisitRepository(dbpool)
	trackingRepo := postgres.NewTrackingRepository(dbpool)
	territoryRepo := postgres.NewTerritoryRepository(dbpool)
	reportRepo := postgres.NewReportRepository(dbpool)
	attendanceRepo := postgres.NewAttendanceRepository(dbpool)
	notificationRepo := postgres.NewNotificationRepository(dbpool)
	targetRepo := postgres.NewTargetRepository(dbpool)
	taskRepo := postgres.NewTaskRepository(dbpool)
	settingsRepo := postgres.NewSettingsRepository(dbpool)
	salesActivityRepo := postgres.NewSalesActivityRepository(dbpool)
	warehouseRepo := postgres.NewWarehouseRepository(dbpool)
	
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "super_secret_jwt_key_please_change_this_in_production"
	}
	
	uploadDir := os.Getenv("UPLOADS_DIR")
	if uploadDir == "" {
		uploadDir = "./storage/uploads"
	}
	
	userUC := usecase.NewUserUseCase(userRepo, jwtSecret, 24, 7) // 24hrs JWT, 7 days Refresh (or taken from Env later)
	customerUC := usecase.NewCustomerUseCase(customerRepo, dealRepo, visitRepo)
	leadUC := usecase.NewLeadUseCase(leadRepo, customerRepo)
	dealUC := usecase.NewDealUseCase(dealRepo, customerRepo)
	productUC := usecase.NewProductUseCase(productRepo, dealItemRepo, dealRepo)
	visitUC := usecase.NewVisitUseCase(visitRepo, customerRepo, taskRepo, salesActivityRepo, leadRepo)
	trackingUC := usecase.NewTrackingUseCase(trackingRepo)
	territoryUC := usecase.NewTerritoryUseCase(territoryRepo)
	reportUC := usecase.NewReportUseCase(reportRepo, targetRepo, taskRepo)
	attendanceUC := usecase.NewAttendanceUseCase(attendanceRepo, territoryRepo)
	notificationUC := usecase.NewNotificationUseCase(notificationRepo)
	targetUC := usecase.NewTargetUseCase(targetRepo)
	taskUC := usecase.NewTaskUseCase(taskRepo)
	settingsUC := usecase.NewSettingsUseCase(settingsRepo)
	warehouseUC := usecase.NewWarehouseUseCase(warehouseRepo)
	
	authHandler := handlers.NewAuthHandler(userUC)
	customerHandler := handlers.NewCustomerHandler(customerUC)
	leadHandler := handlers.NewLeadHandler(leadUC)
	dealHandler := handlers.NewDealHandler(dealUC)
	productHandler := handlers.NewProductHandler(productUC)
	visitHandler := handlers.NewVisitHandler(visitUC, uploadDir)
	trackingHandler := handlers.NewTrackingHandler(trackingUC)
	territoryHandler := handlers.NewTerritoryHandler(territoryUC)
	reportHandler := handlers.NewReportHandler(reportUC)
	attendanceHandler := handlers.NewAttendanceHandler(attendanceUC, uploadDir)
	notificationHandler := handlers.NewNotificationHandler(notificationUC)
	targetHandler := handlers.NewTargetHandler(targetUC)
	taskHandler := handlers.NewTaskHandler(taskUC)
	settingsHandler := handlers.NewSettingsHandler(settingsUC)
	salesActivityHandler := handlers.NewSalesActivityHandler(salesActivityRepo)
	warehouseHandler := handlers.NewWarehouseHandler(warehouseUC)

	// Setup Routes
	routes.SetupRouter(router, authHandler, customerHandler, leadHandler, dealHandler, productHandler, visitHandler, trackingHandler, territoryHandler, reportHandler, attendanceHandler, notificationHandler, targetHandler, taskHandler, settingsHandler, salesActivityHandler, warehouseHandler)

	// Additionally inject basic health check underneath v1
	router.GET("/api/v1/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "up",
			"timestamp": time.Now().Format(time.RFC3339),
			"message":   "Wowin CRM system operational",
		})
	})

	// 7. Static File Serving Configuration
	// As discussed in the technical architecture plan, serving large files through Gin
	// memory in a production environment should be delegated to NGINX. Yet, this allows local env tests.
	absUploadsDir, _ := filepath.Abs(cfg.UploadsDir)
	router.Static("/uploads", absUploadsDir)
	log.Printf("📁 Static file server registered mapping route '/uploads' to directory '%s'\n", absUploadsDir)

	// 8. Construct HTTP Server and Attach with Gin Handler
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%s", cfg.Port),
		Handler: router,
	}

	// Operate server in a goroutine so it acts non-blocking, supporting graceful termination
	go func() {
		log.Printf("🌐 Server is actively serving HTTP on port %s\n", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Listen error: %s\n", err)
		}
	}()

	// 9. Graceful Shutdown Implementations
	// Channel traps SIGINT or SIGTERM flags generated by `docker stop` or traditional CMD+C.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	
	// Server thread gets blocked here until an interrupt passes by
	<-quit
	log.Println("🛑 Shutdown signal received, initiating graceful termination procedures...")

	// Providing the server a limited 10-second timeout window to complete active network responses
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Fatalf("❌ Server faced forceful shutdown issues: %v\n", err)
	}

	log.Println("👋 Graceful shutdown logic successfully completed. See you next time!")
}
