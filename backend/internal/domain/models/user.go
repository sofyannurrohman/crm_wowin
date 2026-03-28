package models

import (
	"time"

	"github.com/google/uuid"
)

// UserRole defines the access level for RBAC
type UserRole string

const (
	RoleSuperAdmin UserRole = "super_admin"
	RoleManager    UserRole = "manager"
	RoleSupervisor UserRole = "supervisor"
	RoleSales      UserRole = "sales"
)

// UserStatus controls user access state
type UserStatus string

const (
	UserStatusActive    UserStatus = "active"
	UserStatusInactive  UserStatus = "inactive"
	UserStatusSuspended UserStatus = "suspended"
)

// User represents the users table in the database
type User struct {
	ID           uuid.UUID   `json:"id"`
	Name         string      `json:"name"`
	FirstName    string      `json:"first_name"`
	LastName     string      `json:"last_name"`
	Email        string      `json:"email"`
	Phone        *string     `json:"phone,omitempty"`
	PasswordHash string      `json:"-"` // Never expose via JSON
	Role         UserRole    `json:"role"`
	Status       UserStatus  `json:"status"`
	AvatarPath   *string     `json:"avatar_path,omitempty"`
	ManagerID    *uuid.UUID  `json:"manager_id,omitempty"`
	EmployeeCode *string     `json:"employee_code,omitempty"`
	JoinedAt     *time.Time  `json:"joined_at,omitempty"`
	LastLoginAt  *time.Time  `json:"last_login_at,omitempty"`
	CreatedAt    time.Time   `json:"created_at"`
	UpdatedAt    time.Time   `json:"updated_at"`
}

// RefreshToken maps the active JWT refresh sessions
type RefreshToken struct {
	ID        uuid.UUID  `json:"id"`
	UserID    uuid.UUID  `json:"user_id"`
	TokenHash string     `json:"-"`
	ExpiresAt time.Time  `json:"expires_at"`
	Revoked   bool       `json:"revoked"`
	IPAddress *string    `json:"ip_address,omitempty"`
	UserAgent *string    `json:"user_agent,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
}

// LoginRequest defines the expected payload for user login
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

// RegisterRequest defines the expected payload for user registration
type RegisterRequest struct {
	Name        string `json:"name" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=8"`
	CompanyName string `json:"company_name"`
	Role        string `json:"role"`
}

// TokenResponse defines the auth payload given back to clients
type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"` // seconds
	User         User   `json:"user"`
}

// AuthUser defines the JWT payload standard
type AuthUser struct {
	ID    uuid.UUID `json:"id"`
	Email string    `json:"email"`
	Role  UserRole  `json:"role"`
}
