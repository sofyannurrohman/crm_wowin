package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"time"

	"github.com/google/uuid"
)

type AttendanceRepository interface {
	Create(ctx context.Context, attendance *models.Attendance) error
	GetLatestByUserID(ctx context.Context, userID uuid.UUID, date time.Time) (*models.Attendance, error)
	ListByUser(ctx context.Context, userID uuid.UUID, startDate, endDate time.Time) ([]models.Attendance, error)
	GetDailySummary(ctx context.Context, userID uuid.UUID, startDate, endDate time.Time) ([]models.DailyAttendance, error)
}
