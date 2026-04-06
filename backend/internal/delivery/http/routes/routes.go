package routes

import (
	"crm_wowin_backend/internal/delivery/http/handlers"
	"crm_wowin_backend/internal/delivery/http/middlewares"

	"github.com/gin-gonic/gin"
)

// SetupRouter initializes application routes
func SetupRouter(
	r *gin.Engine, 
	authHandler *handlers.AuthHandler, 
	customerHandler *handlers.CustomerHandler,
	leadHandler *handlers.LeadHandler,
	dealHandler *handlers.DealHandler,
	productHandler *handlers.ProductHandler,
	visitHandler *handlers.VisitHandler,
	trackingHandler *handlers.TrackingHandler,
	territoryHandler *handlers.TerritoryHandler,
	reportHandler *handlers.ReportHandler,
	attendanceHandler *handlers.AttendanceHandler, 
	notificationHandler *handlers.NotificationHandler,
	targetHandler *handlers.TargetHandler,
	taskHandler *handlers.TaskHandler,
	settingsHandler *handlers.SettingsHandler,
	salesActivityHandler *handlers.SalesActivityHandler,
	warehouseHandler *handlers.WarehouseHandler,
) {

	v1 := r.Group("/api/v1")

	// Pre-requisites for Ping
	v1.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})

	// Unauthenticated Auth block
	authRoutes := v1.Group("/auth")
	{
		authRoutes.POST("/login", authHandler.Login)
		authRoutes.POST("/register", authHandler.Register)
		authRoutes.POST("/logout", middlewares.AuthMiddleware(), authHandler.Logout)
	}

	// Protected routes
	protected := v1.Group("/")
	protected.Use(middlewares.AuthMiddleware())
	{
		usersGroup := protected.Group("/users")
		usersGroup.GET("", authHandler.ListUsers)
		usersGroup.GET("/me", authHandler.GetMe)
		
		// Customer Domain
		customerGroup := protected.Group("/customers")
		customerGroup.POST("", customerHandler.CreateCustomer)
		customerGroup.GET("", customerHandler.ListCustomers)
		customerGroup.GET("/:id", customerHandler.GetCustomer)
		customerGroup.PUT("/:id", customerHandler.UpdateCustomer)
		customerGroup.DELETE("/:id", customerHandler.DeleteCustomer)
		customerGroup.POST("/:id/contacts", customerHandler.AddContact)
		
		// Lead Domain
		leadGroup := protected.Group("/leads")
		leadGroup.POST("", leadHandler.CreateLead)
		leadGroup.GET("", leadHandler.ListLeads)
		leadGroup.GET("/:id", leadHandler.GetLead)
		leadGroup.PUT("/:id", leadHandler.UpdateLead)
		leadGroup.DELETE("/:id", leadHandler.DeleteLead)
		leadGroup.POST("/:id/convert", leadHandler.ConvertLead)
		
		// Deal Pipeline
		dealGroup := protected.Group("/deals")
		dealGroup.POST("", dealHandler.CreateDeal)
		dealGroup.GET("", dealHandler.ListDeals)
		dealGroup.GET("/:id", dealHandler.GetDeal)
		dealGroup.PUT("/:id", dealHandler.UpdateDeal)
		dealGroup.PATCH("/:id/stage", dealHandler.UpdateStage) // Kanban move
		
		dealItemGrp := dealGroup.Group("/:id/items")
		dealItemGrp.GET("", productHandler.ListDealItems)
		
		// Unbound Deal Items manipulation (global)
		productsGroup := protected.Group("/deal-items")
		productsGroup.POST("", productHandler.AddDealItem)
		productsGroup.PUT("/:id", productHandler.UpdateDealItem)
		productsGroup.DELETE("/:id", productHandler.RemoveDealItem)
		
		// Product & Categories Catalogs
		catGroup := protected.Group("/categories")
		catGroup.POST("", productHandler.CreateCategory)
		catGroup.GET("", productHandler.ListCategories)
		catGroup.PUT("/:id", productHandler.UpdateCategory)
		
		prodGroup := protected.Group("/products")
		prodGroup.POST("", productHandler.CreateProduct)
		prodGroup.GET("", productHandler.ListProducts)
		prodGroup.GET("/:id", productHandler.GetProduct)
		prodGroup.PUT("/:id", productHandler.UpdateProduct)
		prodGroup.DELETE("/:id", productHandler.DeleteProduct)
		
		// Sales Field & Visit Executions
		visitGroup := protected.Group("/visits")
		visitGroup.POST("/schedules", visitHandler.CreateSchedule)
		visitGroup.GET("/schedules", visitHandler.ListSchedules)
		visitGroup.PUT("/schedules/:id", visitHandler.UpdateSchedule)
		
		visitGroup.POST("/activities", visitHandler.LogActivity) // Check-in / Checkout
		visitGroup.GET("/activities", visitHandler.ListActivities)
		visitGroup.GET("/schedules/:schedule_id/activities", visitHandler.GetActivitiesBySchedule)
		
		// GPS Tracking & Live Monitoring
		trackingGroup := protected.Group("/tracking")
		trackingGroup.POST("/location", trackingHandler.SyncPoints)
		trackingGroup.GET("/live", trackingHandler.GetLivePositions)
		trackingGroup.GET("/sessions/:sales_id", trackingHandler.GetSessionRoute)
		
		// Territory Management
		territoryGroup := protected.Group("/territories")
		territoryGroup.POST("", territoryHandler.Create)
		territoryGroup.GET("", territoryHandler.List)
		territoryGroup.GET("/:id", territoryHandler.Get)
		territoryGroup.PUT("/:id", territoryHandler.Update)
		territoryGroup.DELETE("/:id", territoryHandler.Delete)
		
		// Reports & Analytics
		reportGroup := protected.Group("/reports")
		reportGroup.GET("/kpi-summary", reportHandler.GetKpiSummary)
		reportGroup.GET("/analytics", reportHandler.GetAnalytics)
		reportGroup.GET("/recommendations", reportHandler.GetVisitRecommendations)
		
		// Attendance
		attendanceGroup := protected.Group("/attendance")
		attendanceGroup.POST("/clock-in", attendanceHandler.ClockIn)
		attendanceGroup.POST("/clock-out", attendanceHandler.ClockOut)
		attendanceGroup.GET("/history", attendanceHandler.GetHistory)
		
		// Notifications
		notifGroup := protected.Group("/notifications")
		notifGroup.GET("", notificationHandler.List)
		notifGroup.GET("/unread-count", notificationHandler.GetUnreadCount)
		notifGroup.GET("/ws", notificationHandler.ServeWS)
		notifGroup.PATCH("/:id/read", notificationHandler.MarkAsRead)
		notifGroup.PATCH("/read-all", notificationHandler.MarkAllAsRead)
		
		// KPI Targets
		targetGroup := protected.Group("/settings/targets")
		targetGroup.GET("", targetHandler.Get)
		targetGroup.PUT("", targetHandler.Update)

		// Tasks
		taskGroup := protected.Group("/tasks")
		taskGroup.POST("", taskHandler.Create)
		taskGroup.GET("", taskHandler.List)
		taskGroup.PUT("/:id", taskHandler.Update)
		taskGroup.PATCH("/:id/complete", taskHandler.Complete)
		taskGroup.DELETE("/:id", taskHandler.Delete)

		// App Settings
		settingsGroup := protected.Group("/settings")
		settingsGroup.GET("", settingsHandler.GetSettings)
		settingsGroup.PATCH("/:key", settingsHandler.UpdateSetting)

		// Sales Activities
		activityGroup := protected.Group("/activities")
		activityGroup.POST("", salesActivityHandler.Create)
		activityGroup.GET("", salesActivityHandler.List)
		activityGroup.PUT("/:id", salesActivityHandler.Update)
		activityGroup.DELETE("/:id", salesActivityHandler.Delete)
		
		// Warehouses
		warehouseHandler.RegisterRoutes(protected)
		
		// Example of RBAC implementation
		// managerOnly := protected.Group("/admin")
		// managerOnly.Use(middlewares.RoleMiddleware(models.RoleManager, models.RoleSuperAdmin))
	}
}
