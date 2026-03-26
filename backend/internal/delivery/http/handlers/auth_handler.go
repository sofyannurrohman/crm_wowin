package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	userUC usecase.UserUseCase
}

func NewAuthHandler(uc usecase.UserUseCase) *AuthHandler {
	return &AuthHandler{userUC: uc}
}

// Login validates user logic and issues JWT
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid login payload", err.Error())
		return
	}

	ip := c.ClientIP()
	agent := c.Request.UserAgent()

	tokenRes, err := h.userUC.Login(c.Request.Context(), req.Email, req.Password, ip, agent)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, tokenRes, "login successful")
}

// Register creates a new active user
func (h *AuthHandler) Register(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid registration payload")
		return
	}

	// For initial system setup logic, standard signup provides Active status & 'sales' role.
	// Production variant might require approval cycles.
	user.Status = models.UserStatusActive // Uses models.UserStatus ("active") instead of customer one
	if user.Role == "" {
		user.Role = models.RoleSales
	}

	createdUser, err := h.userUC.Register(c.Request.Context(), &user)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, createdUser)
}

// GetMe retrieves the authenticated user's profile
func (h *AuthHandler) GetMe(c *gin.Context) {
	// Value is guaranteed by AuthMiddleware
	userID := c.GetString("user_id")

	profile, err := h.userUC.GetProfile(c.Request.Context(), userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, profile)
}
