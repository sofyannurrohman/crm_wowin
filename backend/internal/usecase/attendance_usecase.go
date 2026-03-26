package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"time"

	"github.com/google/uuid"
)

type AttendanceUseCase interface {
	ClockIn(ctx context.Context, a *models.Attendance) (*models.Attendance, error)
	ClockOut(ctx context.Context, a *models.Attendance) (*models.Attendance, error)
	GetHistory(ctx context.Context, userID uuid.UUID, month, year int) ([]models.DailyAttendance, error)
}

type attendanceUseCaseImpl struct {
	repo          repository.AttendanceRepository
	territoryRepo repository.TerritoryRepository
}

func NewAttendanceUseCase(repo repository.AttendanceRepository, territoryRepo repository.TerritoryRepository) AttendanceUseCase {
	return &attendanceUseCaseImpl{repo: repo, territoryRepo: territoryRepo}
}

func (u *attendanceUseCaseImpl) ClockIn(ctx context.Context, a *models.Attendance) (*models.Attendance, error) {
	// Simple validation: check if already clocked in today
	latest, err := u.repo.GetLatestByUserID(ctx, a.UserID, time.Now())
	if err == nil && latest != nil && latest.Type == models.AttendanceTypeClockIn {
		return nil, errors.New("sudah melakukan clock-in hari ini")
	}

	a.Type = models.AttendanceTypeClockIn
	err = u.repo.Create(ctx, a)
	return a, err
}

func (u *attendanceUseCaseImpl) ClockOut(ctx context.Context, a *models.Attendance) (*models.Attendance, error) {
	// Simple validation: check if clocked in today
	latest, err := u.repo.GetLatestByUserID(ctx, a.UserID, time.Now())
	if err != nil || latest == nil || latest.Type != models.AttendanceTypeClockIn {
		return nil, errors.New("harus melakukan clock-in sebelum clock-out")
	}

	a.Type = models.AttendanceTypeClockOut
	err = u.repo.Create(ctx, a)
	return a, err
}

func (u *attendanceUseCaseImpl) GetHistory(ctx context.Context, userID uuid.UUID, month, year int) ([]models.DailyAttendance, error) {
	// Calculate start and end date of the month
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, -1)
	
	return u.repo.GetDailySummary(ctx, userID, startDate, endDate)
}
