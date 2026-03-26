package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
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

type VisitHandler struct {
	uc     usecase.VisitUseCase
	upldir string
}

func NewVisitHandler(uc usecase.VisitUseCase, uploadDir string) *VisitHandler {
	// Guard uploads dir existence
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		_ = os.MkdirAll(uploadDir, 0755)
	}
	return &VisitHandler{uc: uc, upldir: uploadDir}
}

// === SCHEDULES ===

func (h *VisitHandler) CreateSchedule(c *gin.Context) {
	var req models.VisitSchedule
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	// Always assign to current authenticated user by default if not set by an admin payload
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	// An admin might re-assign the schedule. but typical flow defaults to requester.
	if req.SalesID == uuid.Nil {
		req.SalesID = userID
	}

	schedule, err := h.uc.CreateSchedule(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, schedule)
}

func (h *VisitHandler) ListSchedules(c *gin.Context) {
	var filter repository.ScheduleFilter
	filter.Status = c.Query("status")

	if sID := c.Query("sales_id"); sID != "" {
		if u, err := uuid.Parse(sID); err == nil {
			filter.SalesID = &u
		}
	}
	if cID := c.Query("customer_id"); cID != "" {
		if u, err := uuid.Parse(cID); err == nil {
			filter.CustomerID = &u
		}
	}

	if startStr := c.Query("start_date"); startStr != "" {
		if t, err := time.Parse("2006-01-02", startStr); err == nil {
			filter.StartDate = &t
		}
	}
	if endStr := c.Query("end_date"); endStr != "" {
		if t, err := time.Parse("2006-01-02", endStr); err == nil {
			filter.EndDate = &t
		}
	}

	schedules, err := h.uc.ListSchedules(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, schedules)
}

func (h *VisitHandler) UpdateSchedule(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid schedule id")
		return
	}

	var req models.VisitSchedule
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload formatter")
		return
	}
	req.ID = id

	schedule, err := h.uc.UpdateSchedule(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, schedule, "schedule updated")
}


// === EXECUTION FOOTPRINTS (ACTIVITIES) ===

func (h *VisitHandler) LogActivity(c *gin.Context) {
	// 1. Bound the maximum memory of parsed form multipart items to ~8MB (rest goes to temp disk)
	err := c.Request.ParseMultipartForm(8 << 20)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "failed to parse multipart request payload")
		return
	}

	// 2. Extract strictly structured File and Form attributes
	file, fileHeader, err := c.Request.FormFile("photo")
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "photo is required for check in/out")
		return
	}
	defer file.Close()

	if fileHeader.Size > 5*1024*1024 { // 5MB limit
		response.Fail(c, http.StatusRequestEntityTooLarge, "uploaded photo size exceeds 5MB")
		return
	}
	
	lat, _ := strconv.ParseFloat(c.Request.FormValue("latitude"), 64)
	lon, _ := strconv.ParseFloat(c.Request.FormValue("longitude"), 64)
	if lat == 0 || lon == 0 {
		response.Fail(c, http.StatusBadRequest, "valid latitude and longitude coordinates are required")
		return
	}
	
	salesIDStr := c.GetString("user_id")
	salesID, _ := uuid.Parse(salesIDStr)

	customerID, err := uuid.Parse(c.Request.FormValue("customer_id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid customer_id")
		return
	}

	var activity models.VisitActivity
	activity.Type = models.VisitType(c.Request.FormValue("type"))
	if activity.Type != models.VisitTypeCheckIn && activity.Type != models.VisitTypeCheckOut {
		response.Fail(c, http.StatusBadRequest, "activity type must be check-in or check-out")
		return
	}

	activity.SalesID = salesID
	activity.CustomerID = customerID
	activity.Latitude = lat
	activity.Longitude = lon
	// Notes and Offline status are optional overrides
	notesParams := c.Request.FormValue("notes")
	if notesParams != "" {
		activity.Notes = &notesParams
	}
	if c.Request.FormValue("is_offline") == "true" {
		activity.IsOffline = true
	}

	if sID := c.Request.FormValue("schedule_id"); sID != "" {
		if u, err := uuid.Parse(sID); err == nil {
			activity.ScheduleID = &u
		}
	}

	// 3. Persist incoming physical file to local disk (Phase 1 Storage implementation)
	savePath := filepath.Join(h.upldir, "visits", uuid.New().String()+filepath.Ext(fileHeader.Filename))
	os.MkdirAll(filepath.Dir(savePath), 0755)

	if err := c.SaveUploadedFile(fileHeader, savePath); err != nil {
		response.Fail(c, http.StatusInternalServerError, "failed saving photo on server disk")
		return
	}
	
	// Map internal logical path for the DB, separating from filesystem abstraction
	// Usually returned via '/static/visits/...' url mapping later in nginx/gin config.
	activity.PhotoPath = "/uploads/visits/" + filepath.Base(savePath)

	// 4. Register logical algorithm mapping
	respAct, err := h.uc.LogActivity(c.Request.Context(), &activity)
	if err != nil {
		// Clean up photo on DB transaction fail
		_ = os.Remove(savePath)
		response.Fail(c, http.StatusForbidden, err.Error())
		return
	}

	response.Created(c, respAct)
}

func (h *VisitHandler) GetActivitiesBySchedule(c *gin.Context) {
	sID, err := uuid.Parse(c.Param("schedule_id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid schedule id")
		return
	}

	acts, err := h.uc.GetActivitiesBySchedule(c.Request.Context(), sID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, acts)
}
