package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type AttendanceHandler struct {
	uc      usecase.AttendanceUseCase
	upldir  string
}

func NewAttendanceHandler(uc usecase.AttendanceUseCase, uploadDir string) *AttendanceHandler {
	return &AttendanceHandler{uc: uc, upldir: uploadDir}
}

func (h *AttendanceHandler) ClockIn(c *gin.Context) {
	h.handleAttendance(c, models.AttendanceTypeClockIn)
}

func (h *AttendanceHandler) ClockOut(c *gin.Context) {
	h.handleAttendance(c, models.AttendanceTypeClockOut)
}

func (h *AttendanceHandler) handleAttendance(c *gin.Context, aType models.AttendanceType) {
	err := c.Request.ParseMultipartForm(5 << 20) // 5MB
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "failed to parse multipart request")
		return
	}

	file, fileHeader, err := c.Request.FormFile("photo")
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "photo is required")
		return
	}
	defer file.Close()

	lat, _ := strconv.ParseFloat(c.Request.FormValue("latitude"), 64)
	lon, _ := strconv.ParseFloat(c.Request.FormValue("longitude"), 64)
	
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	// Save photo
	subDir := filepath.Join("attendance", time.Now().Format("2006/01"))
	saveDir := filepath.Join(h.upldir, subDir)
	os.MkdirAll(saveDir, 0755)
	
	fileName := uuid.New().String() + filepath.Ext(fileHeader.Filename)
	savePath := filepath.Join(saveDir, fileName)

	if err := c.SaveUploadedFile(fileHeader, savePath); err != nil {
		response.Fail(c, http.StatusInternalServerError, "failed saving photo")
		return
	}

	attendance := &models.Attendance{
		UserID:    userID,
		Type:      aType,
		Latitude:  lat,
		Longitude: lon,
		Address:   c.Request.FormValue("address"),
		PhotoPath: "/uploads/" + filepath.Join(subDir, fileName),
		Notes:     c.Request.FormValue("notes"),
	}

	var result *models.Attendance
	if aType == models.AttendanceTypeClockIn {
		result, err = h.uc.ClockIn(c.Request.Context(), attendance)
	} else {
		result, err = h.uc.ClockOut(c.Request.Context(), attendance)
	}

	if err != nil {
		os.Remove(savePath) // Cleanup on error
		response.Fail(c, http.StatusForbidden, err.Error())
		return
	}

	response.OK(c, result)
}

func (h *AttendanceHandler) GetHistory(c *gin.Context) {
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)
	
	month, _ := strconv.Atoi(c.DefaultQuery("month", time.Now().Format("01")))
	year, _ := strconv.Atoi(c.DefaultQuery("year", time.Now().Format("2006")))

	history, err := h.uc.GetHistory(c.Request.Context(), userID, month, year)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, history)
}
