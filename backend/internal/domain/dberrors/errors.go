package dberrors

import "errors"

// Standardized Database Errors
var (
	ErrNotFound       = errors.New("record not found")
	ErrConflict       = errors.New("record already exists (conflict)")
	ErrInvalidInput   = errors.New("invalid input parameters")
	ErrUnauthorized   = errors.New("unauthorized access")
	ErrInternalServer = errors.New("internal server error")
)
