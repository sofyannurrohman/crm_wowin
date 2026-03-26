package response

import (
	"crm_wowin_backend/internal/domain/dberrors"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Success structure standardizes successful API payloads
type Success struct {
	Code    int         `json:"code"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Meta    interface{} `json:"meta,omitempty"`
}

// Error structure standardizes failed API responses
type Error struct {
	Code    int         `json:"code"`
	Error   string      `json:"error"`
	Details interface{} `json:"details,omitempty"`
}

func OK(c *gin.Context, data interface{}, msg ...string) {
	message := "success"
	if len(msg) > 0 {
		message = msg[0]
	}

	c.JSON(http.StatusOK, Success{
		Code:    http.StatusOK,
		Message: message,
		Data:    data,
	})
}

func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, Success{
		Code:    http.StatusCreated,
		Message: "created successfully",
		Data:    data,
	})
}

// MapDBError converts domain database errors to appropriate HTTP responses
func MapDBError(c *gin.Context, err error) {
	code := http.StatusInternalServerError
	msg := "internal server error"

	if errors.Is(err, dberrors.ErrNotFound) {
		code = http.StatusNotFound
		msg = err.Error()
	} else if errors.Is(err, dberrors.ErrConflict) {
		code = http.StatusConflict
		msg = err.Error()
	} else if errors.Is(err, dberrors.ErrInvalidInput) {
		code = http.StatusBadRequest
		msg = err.Error()
	} else if errors.Is(err, dberrors.ErrUnauthorized) {
		code = http.StatusUnauthorized
		msg = err.Error()
	}

	c.JSON(code, Error{
		Code:  code,
		Error: msg,
	})
}

// Fail is used for generic client-side errors (e.g. invalid JSON, bad request)
func Fail(c *gin.Context, code int, err string, details ...interface{}) {
	res := Error{
		Code:  code,
		Error: err,
	}
	if len(details) > 0 {
		res.Details = details[0]
	}
	c.JSON(code, res)
}
