package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/pkg/jwtutil"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// UserUseCase defines the business logic contract for Users
type UserUseCase interface {
	Login(ctx context.Context, email, password string, ip string, userAgent string) (*models.TokenResponse, error)
	Register(ctx context.Context, req *models.User) (*models.User, error)
	GetProfile(ctx context.Context, userID string) (*models.User, error)
	Logout(ctx context.Context, userID string) error
	ListUsers(ctx context.Context) ([]*models.User, error)
}

type userUseCaseImpl struct {
	userRepo   repository.UserRepository
	jwtSecret  string
	jwtExpHrs  int
	refreshExp int
}

// NewUserUseCase injects dependencies into the core usecase structure
func NewUserUseCase(
	repo repository.UserRepository,
	secret string,
	jwtExpirationHours int,
	refreshTokenExpirationDays int,
) UserUseCase {
	return &userUseCaseImpl{
		userRepo:   repo,
		jwtSecret:  secret,
		jwtExpHrs:  jwtExpirationHours,
		refreshExp: refreshTokenExpirationDays,
	}
}

func (u *userUseCaseImpl) Login(ctx context.Context, email, password, ip, agent string) (*models.TokenResponse, error) {
	user, err := u.userRepo.FindByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, dberrors.ErrNotFound) {
			return nil, dberrors.ErrUnauthorized // don't expose that email isn't exist
		}
		return nil, err
	}

	// Validate bcrypt password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return nil, dberrors.ErrUnauthorized
	}

	// Generate Access Token
	accessToken, err := jwtutil.GenerateAccessToken(user, u.jwtSecret, u.jwtExpHrs)
	if err != nil {
		return nil, err
	}

	// Generate Refresh Token
	refreshToken, err := jwtutil.GenerateRefreshToken()
	if err != nil {
		return nil, err
	}

	// Store Refresh Token in database
	expiresAt := time.Now().AddDate(0, 0, u.refreshExp)
	rtRecord := &models.RefreshToken{
		UserID:    user.ID,
		TokenHash: refreshToken, // We temporarily store plaintext refresh-token hash matching (can be hashed ideally)
		ExpiresAt: expiresAt,
		IPAddress: &ip,
		UserAgent: &agent,
	}

	if err := u.userRepo.CreateRefreshToken(ctx, rtRecord); err != nil {
		return nil, err
	}

	// Update last login
	now := time.Now()
	user.LastLoginAt = &now
	_ = u.userRepo.Update(ctx, user)

	// Populate metadata for frontend
	user.FirstName, user.LastName = splitName(user.Name)

	return &models.TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    u.jwtExpHrs * 3600,
		User:         *user,
	}, nil
}

func (u *userUseCaseImpl) Register(ctx context.Context, req *models.User) (*models.User, error) {
	// By default, system applies secure hash logic to plain passwords embedded initially in request
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.PasswordHash), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	req.PasswordHash = string(hashed)
	
	now := time.Now()
	req.JoinedAt = &now

	if err := u.userRepo.Create(ctx, req); err != nil {
		return nil, err
	}

	if err == nil {
		req.FirstName, req.LastName = splitName(req.Name)
	}
	return req, nil
}

func (u *userUseCaseImpl) GetProfile(ctx context.Context, userID string) (*models.User, error) {
	// Need to parse string to UUID in transport layer, but here we expect parsed UUID.
	// For simplicity in parameter, we'll parse it here.
	importUUID, err := ParseUUID(userID)
	if err != nil {
		return nil, dberrors.ErrInvalidInput
	}
	
	user, err := u.userRepo.FindByID(ctx, importUUID)
	if err == nil && user != nil {
		user.FirstName, user.LastName = splitName(user.Name)
	}
	return user, err
}

func (u *userUseCaseImpl) Logout(ctx context.Context, userID string) error {
	id, err := uuid.Parse(userID)
	if err != nil {
		return dberrors.ErrInvalidInput
	}
	return u.userRepo.RevokeAllUserTokens(ctx, id)
}

func (u *userUseCaseImpl) ListUsers(ctx context.Context) ([]*models.User, error) {
	users, err := u.userRepo.FindAll(ctx)
	if err == nil {
		for _, user := range users {
			user.FirstName, user.LastName = splitName(user.Name)
		}
	}
	return users, err
}

// ParseUUID helper
func ParseUUID(id string) (uuid.UUID, error) {
	return uuid.Parse(id)
}

func splitName(fullName string) (firstName, lastName string) {
	parts := strings.Fields(fullName)
	if len(parts) == 0 {
		return "", ""
	}
	if len(parts) == 1 {
		return parts[0], ""
	}
	return parts[0], strings.Join(parts[1:], " ")
}
