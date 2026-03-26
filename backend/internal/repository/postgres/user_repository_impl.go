package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type userRepositoryImpl struct {
	db *pgxpool.Pool
}

// NewUserRepository creates a fresh Postgres implementation of the UserRepository
func NewUserRepository(db *pgxpool.Pool) repository.UserRepository {
	return &userRepositoryImpl{db: db}
}

func (r *userRepositoryImpl) Create(ctx context.Context, user *models.User) error {
	query := `
		INSERT INTO users (name, email, phone, password_hash, role, status, avatar_path, manager_id, employee_code, joined_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		user.Name, user.Email, user.Phone, user.PasswordHash,
		user.Role, user.Status, user.AvatarPath, user.ManagerID,
		user.EmployeeCode, user.JoinedAt,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		// Basic check for unique constraints
		// Ideally we would inspect the pgconn.PgError code for "23505"
		return dberrors.ErrConflict
	}
	return nil
}

func (r *userRepositoryImpl) FindByEmail(ctx context.Context, email string) (*models.User, error) {
	query := `
		SELECT id, name, email, phone, password_hash, role, status, avatar_path, manager_id, employee_code, joined_at, last_login_at, created_at, updated_at
		FROM users
		WHERE email = $1 AND status != 'suspended'
	`
	var usr models.User
	err := r.db.QueryRow(ctx, query, email).Scan(
		&usr.ID, &usr.Name, &usr.Email, &usr.Phone, &usr.PasswordHash,
		&usr.Role, &usr.Status, &usr.AvatarPath, &usr.ManagerID,
		&usr.EmployeeCode, &usr.JoinedAt, &usr.LastLoginAt,
		&usr.CreatedAt, &usr.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, dberrors.ErrInternalServer
	}
	return &usr, nil
}

func (r *userRepositoryImpl) FindByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	query := `
		SELECT id, name, email, phone, password_hash, role, status, avatar_path, manager_id, employee_code, joined_at, last_login_at, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	var usr models.User
	err := r.db.QueryRow(ctx, query, id).Scan(
		&usr.ID, &usr.Name, &usr.Email, &usr.Phone, &usr.PasswordHash,
		&usr.Role, &usr.Status, &usr.AvatarPath, &usr.ManagerID,
		&usr.EmployeeCode, &usr.JoinedAt, &usr.LastLoginAt,
		&usr.CreatedAt, &usr.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, dberrors.ErrInternalServer
	}
	return &usr, nil
}

func (r *userRepositoryImpl) Update(ctx context.Context, user *models.User) error {
	query := `
		UPDATE users
		SET name = $1, phone = $2, role = $3, status = $4, avatar_path = $5, last_login_at = $6, updated_at = NOW()
		WHERE id = $7
		RETURNING updated_at
	`
	err := r.db.QueryRow(ctx, query,
		user.Name, user.Phone, user.Role, user.Status, user.AvatarPath, user.LastLoginAt, user.ID,
	).Scan(&user.UpdatedAt)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return dberrors.ErrNotFound
		}
		return dberrors.ErrInternalServer
	}
	return nil
}

func (r *userRepositoryImpl) CreateRefreshToken(ctx context.Context, token *models.RefreshToken) error {
	query := `
		INSERT INTO refresh_tokens (user_id, token_hash, expires_at, revoked, ip_address, user_agent)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`
	err := r.db.QueryRow(ctx, query,
		token.UserID, token.TokenHash, token.ExpiresAt, token.Revoked, token.IPAddress, token.UserAgent,
	).Scan(&token.ID, &token.CreatedAt)

	if err != nil {
		return dberrors.ErrInternalServer
	}
	return nil
}

func (r *userRepositoryImpl) FindRefreshToken(ctx context.Context, tokenHash string) (*models.RefreshToken, error) {
	query := `
		SELECT id, user_id, token_hash, expires_at, revoked, ip_address, user_agent, created_at
		FROM refresh_tokens
		WHERE token_hash = $1
	`
	var rt models.RefreshToken
	err := r.db.QueryRow(ctx, query, tokenHash).Scan(
		&rt.ID, &rt.UserID, &rt.TokenHash, &rt.ExpiresAt, &rt.Revoked, &rt.IPAddress, &rt.UserAgent, &rt.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, dberrors.ErrInternalServer
	}
	return &rt, nil
}

func (r *userRepositoryImpl) RevokeRefreshToken(ctx context.Context, tokenHash string) error {
	query := `UPDATE refresh_tokens SET revoked = true WHERE token_hash = $1`
	cmd, err := r.db.Exec(ctx, query, tokenHash)
	if err != nil {
		return dberrors.ErrInternalServer
	}
	if cmd.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

func (r *userRepositoryImpl) RevokeAllUserTokens(ctx context.Context, userID uuid.UUID) error {
	query := `UPDATE refresh_tokens SET revoked = true WHERE user_id = $1`
	_, err := r.db.Exec(ctx, query, userID)
	if err != nil {
		return dberrors.ErrInternalServer
	}
	return nil
}
