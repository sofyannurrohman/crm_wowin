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
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid registration payload", err.Error())
		return
	}

	// Map RegisterRequest → User domain model
	role := models.RoleSales
	if req.Role != "" {
		role = models.UserRole(req.Role)
	}

	user := &models.User{
		Name:         req.Name,
		Email:        req.Email,
		PasswordHash: req.Password, // usecase will bcrypt-hash this
		Role:         role,
		Status:       models.UserStatusActive,
	}

	createdUser, err := h.userUC.Register(c.Request.Context(), user)
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

// Logout revokes user tokens
func (h *AuthHandler) Logout(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		response.Fail(c, http.StatusUnauthorized, "missing user context")
		return
	}

	if err := h.userUC.Logout(c.Request.Context(), userID); err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, nil, "logout successful")
}

// ListUsers retrieves all registered users
func (h *AuthHandler) ListUsers(c *gin.Context) {
	users, err := h.userUC.ListUsers(c.Request.Context())
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, users)
}
// UpdateProfile allows an authenticated user to change their basic info
func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		response.Fail(c, http.StatusUnauthorized, "missing user context")
		return
	}

	var req struct {
		Name  string `json:"name"`
		Phone string `json:"phone"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid update payload", err.Error())
		return
	}

	updated, err := h.userUC.UpdateProfile(c.Request.Context(), userID, req.Name, req.Phone)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, updated, "profile updated successfully")
}
