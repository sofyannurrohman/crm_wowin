package jwtutil

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"crm_wowin_backend/internal/domain/models"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

// CustomClaims defines the JWT payload structure
type CustomClaims struct {
	UserID uuid.UUID       `json:"id"`
	Email  string          `json:"email"`
	Role   models.UserRole `json:"role"`
	jwt.RegisteredClaims
}

var (
	ErrInvalidToken = errors.New("invalid token")
	ErrExpiredToken = errors.New("token has expired")
)

// GenerateAccessToken creates a new JWT access token
func GenerateAccessToken(user *models.User, secretKey string, expHours int) (string, error) {
	expirationTime := time.Now().Add(time.Duration(expHours) * time.Hour)

	claims := &CustomClaims{
		UserID: user.ID,
		Email:  user.Email,
		Role:   user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Subject:   user.ID.String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secretKey))
}

// GenerateRefreshToken creates a securely random string for refresh token purposes
func GenerateRefreshToken() (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}

// ValidateToken parses and validates a JWT token
func ValidateToken(tokenStr, secretKey string) (*CustomClaims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Ensure the signing method is what we expect
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secretKey), nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrExpiredToken
		}
		return nil, ErrInvalidToken
	}

	if claims, ok := token.Claims.(*CustomClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, ErrInvalidToken
}
