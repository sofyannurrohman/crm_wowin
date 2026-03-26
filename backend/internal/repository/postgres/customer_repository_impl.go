package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type customerRepoImpl struct {
	db *pgxpool.Pool
}

// NewCustomerRepository initiates the PostgreSQL repository for CRM core data
func NewCustomerRepository(db *pgxpool.Pool) repository.CustomerRepository {
	return &customerRepoImpl{db: db}
}

func (r *customerRepoImpl) Create(ctx context.Context, c *models.Customer) error {
	query := `
		INSERT INTO customers (
			code, type, name, company_name, industry, website, email, phone, phone_alt, 
			status, address, city, province, postal_code, country, 
			location, checkin_radius, territory_id, assigned_to, created_by, 
			credit_limit, payment_terms, notes
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, 
			$10, $11, $12, $13, $14, $15, 
			NULLIF(ST_SetSRID(ST_MakePoint($16, $17), 4326), ST_SetSRID(ST_MakePoint(0,0), 4326)), 
			$18, $19, $20, $21, $22, $23, $24
		) RETURNING id, created_at, updated_at
	`

	// Defaults to 0 if no coordinates are supplied, the NULLIF sets it to NULL natively
	var lat, lon float64
	if c.Latitude != nil && c.Longitude != nil {
		lat = *c.Latitude
		lon = *c.Longitude
	}

	err := r.db.QueryRow(ctx, query,
		c.Code, c.Type, c.Name, c.CompanyName, c.Industry, c.Website, c.Email, c.Phone, c.PhoneAlt,
		c.Status, c.Address, c.City, c.Province, c.PostalCode, c.Country,
		lon, lat, // PostGIS MakePoint signature is (Longitude, Latitude)
		c.CheckinRadius, c.TerritoryID, c.AssignedTo, c.CreatedBy,
		c.CreditLimit, c.PaymentTerms, c.Notes,
	).Scan(&c.ID, &c.CreatedAt, &c.UpdatedAt)

	if err != nil {
		if strings.Contains(err.Error(), "duplicate key") {
			return dberrors.ErrConflict
		}
		return err
	}
	return nil
}

func (r *customerRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Customer, error) {
	query := `
		SELECT 
			id, code, type, name, company_name, industry, website, email, phone, phone_alt, 
			status, address, city, province, postal_code, country, 
			ST_Y(location::geometry) as lat, ST_X(location::geometry) as lon, 
			checkin_radius, territory_id, assigned_to, created_by, 
			credit_limit, payment_terms, notes, created_at, updated_at, deleted_at
		FROM customers
		WHERE id = $1 AND deleted_at IS NULL
	`
	var c models.Customer
	err := r.db.QueryRow(ctx, query, id).Scan(
		&c.ID, &c.Code, &c.Type, &c.Name, &c.CompanyName, &c.Industry, &c.Website, &c.Email, &c.Phone, &c.PhoneAlt,
		&c.Status, &c.Address, &c.City, &c.Province, &c.PostalCode, &c.Country,
		&c.Latitude, &c.Longitude,
		&c.CheckinRadius, &c.TerritoryID, &c.AssignedTo, &c.CreatedBy,
		&c.CreditLimit, &c.PaymentTerms, &c.Notes, &c.CreatedAt, &c.UpdatedAt, &c.DeletedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, err
	}
	return &c, nil
}

func (r *customerRepoImpl) List(ctx context.Context, filter repository.CustomerFilter) ([]*models.Customer, int, error) {
	baseQuery := `
		FROM customers
		WHERE deleted_at IS NULL 
	`
	args := []interface{}{}
	argCount := 1
	var conditions []string

	if filter.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(name ILIKE $%d OR company_name ILIKE $%d)", argCount, argCount+1))
		args = append(args, "%"+filter.Search+"%", "%"+filter.Search+"%")
		argCount += 2
	}
	
	if filter.Status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argCount))
		args = append(args, filter.Status)
		argCount++
	}

	if filter.AssignedTo != nil {
		conditions = append(conditions, fmt.Sprintf("assigned_to = $%d", argCount))
		args = append(args, *filter.AssignedTo)
		argCount++
	}

	if len(conditions) > 0 {
		baseQuery += " AND " + strings.Join(conditions, " AND ")
	}

	// 1. Get total count
	var total int
	countQuery := "SELECT COUNT(id) " + baseQuery
	if err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total); err != nil {
		return nil, 0, err
	}

	// 2. Add pagination constraints
	limit := 50
	if filter.Limit > 0 {
		limit = filter.Limit
	}
	// Secure order by
	selectQuery := `
		SELECT 
			id, code, type, name, company_name, industry, website, email, phone, phone_alt, 
			status, address, city, province, postal_code, country, 
			ST_Y(location::geometry) as lat, ST_X(location::geometry) as lon, 
			checkin_radius, territory_id, assigned_to, created_by, 
			notes, created_at, updated_at
	` + baseQuery + fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", argCount, argCount+1)
	
	args = append(args, limit, filter.Offset)

	rows, err := r.db.Query(ctx, selectQuery, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var results []*models.Customer
	for rows.Next() {
		var c models.Customer
		err := rows.Scan(
			&c.ID, &c.Code, &c.Type, &c.Name, &c.CompanyName, &c.Industry, &c.Website, &c.Email, &c.Phone, &c.PhoneAlt,
			&c.Status, &c.Address, &c.City, &c.Province, &c.PostalCode, &c.Country,
			&c.Latitude, &c.Longitude,
			&c.CheckinRadius, &c.TerritoryID, &c.AssignedTo, &c.CreatedBy,
			&c.Notes, &c.CreatedAt, &c.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		results = append(results, &c)
	}

	return results, total, nil
}

func (r *customerRepoImpl) Update(ctx context.Context, c *models.Customer) error {
	query := `
		UPDATE customers SET
			code = $1, type = $2, name = $3, company_name = $4, industry = $5, website = $6, email = $7, phone = $8, phone_alt = $9, 
			status = $10, address = $11, city = $12, province = $13, postal_code = $14, country = $15, 
			checkin_radius = $16, territory_id = $17, assigned_to = $18, 
			credit_limit = $19, payment_terms = $20, notes = $21, updated_at = NOW()
		WHERE id = $22 AND deleted_at IS NULL
		RETURNING updated_at
	`
	err := r.db.QueryRow(ctx, query,
		c.Code, c.Type, c.Name, c.CompanyName, c.Industry, c.Website, c.Email, c.Phone, c.PhoneAlt,
		c.Status, c.Address, c.City, c.Province, c.PostalCode, c.Country,
		c.CheckinRadius, c.TerritoryID, c.AssignedTo,
		c.CreditLimit, c.PaymentTerms, c.Notes, c.ID,
	).Scan(&c.UpdatedAt)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return dberrors.ErrNotFound
		}
		return err
	}
	return nil
}

func (r *customerRepoImpl) UpdateLocation(ctx context.Context, id uuid.UUID, lat, lon float64) error {
	// PostGIS automatically re-assigns territory via trigger fn_auto_assign_territory on UPDATE of location
	query := `
		UPDATE customers 
		SET location = ST_SetSRID(ST_MakePoint($1, $2), 4326), updated_at = NOW()
		WHERE id = $3 AND deleted_at IS NULL
	`
	// Remember PostGIS takes (Longitude, Latitude)
	cmd, err := r.db.Exec(ctx, query, lon, lat, id)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

func (r *customerRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	// Soft delete mechanism
	query := `UPDATE customers SET deleted_at = NOW() WHERE id = $1 AND deleted_at IS NULL`
	cmd, err := r.db.Exec(ctx, query, id)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

// Contact Respository methods incorporated inside for context relation
func (r *customerRepoImpl) AddContact(ctx context.Context, contact *models.Contact) error {
	query := `
		INSERT INTO contacts (customer_id, name, title, department, email, phone, phone_alt, is_primary, notes)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		contact.CustomerID, contact.Name, contact.Title, contact.Department,
		contact.Email, contact.Phone, contact.PhoneAlt, contact.IsPrimary, contact.Notes,
	).Scan(&contact.ID, &contact.CreatedAt, &contact.UpdatedAt)

	if err != nil {
		return err
	}
	return nil
}

func (r *customerRepoImpl) GetContactsByCustomer(ctx context.Context, customerID uuid.UUID) ([]*models.Contact, error) {
	query := `
		SELECT id, customer_id, name, title, department, email, phone, phone_alt, is_primary, notes, created_at, updated_at
		FROM contacts
		WHERE customer_id = $1
		ORDER BY is_primary DESC, created_at ASC
	`
	rows, err := r.db.Query(ctx, query, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.Contact
	for rows.Next() {
		var c models.Contact
		err := rows.Scan(
			&c.ID, &c.CustomerID, &c.Name, &c.Title, &c.Department, &c.Email, &c.Phone, &c.PhoneAlt,
			&c.IsPrimary, &c.Notes, &c.CreatedAt, &c.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, &c)
	}

	return results, nil
}
