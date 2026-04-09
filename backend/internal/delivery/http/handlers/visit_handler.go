package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"crm_wowin_backend/pkg/utils"
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

	// Role-aware enforcement
	userRole, _ := c.Get("user_role")
	userID, _ := uuid.Parse(c.GetString("user_id"))

	if sID := c.Query("sales_id"); sID != "" {
		if u, err := uuid.Parse(sID); err == nil {
			filter.SalesID = &u
		}
	} else if userRole == models.RoleSales {
		// Sales role restricted to their own data
		filter.SalesID = &userID
	}
	if cID := c.Query("customer_id"); cID != "" {
		if u, err := uuid.Parse(cID); err == nil {
			filter.CustomerID = &u
		}
	}
	if lID := c.Query("lead_id"); lID != "" {
		if u, err := uuid.Parse(lID); err == nil {
			filter.LeadID = &u
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
	// Support dual photos: selfie and place
	selfieFile, selfieHeader, errSelfie := c.Request.FormFile("selfie")
	placeFile, placeHeader, errPlace := c.Request.FormFile("place")

	var selfiePath, placePath string

	if errSelfie == nil && errPlace == nil {
		defer selfieFile.Close()
		defer placeFile.Close()

		// Save & Compress Selfie
		selfieSavePath := filepath.Join(h.upldir, "visits", uuid.New().String()+".jpg")
		if err := utils.ProcessAndSaveImage(selfieHeader, selfieSavePath, 1080, 1080, 75); err != nil {
			response.Fail(c, http.StatusInternalServerError, "failed processing selfie: "+err.Error())
			return
		}
		selfiePath = "/uploads/visits/" + filepath.Base(selfieSavePath)

		// Save & Compress Place
		placeSavePath := filepath.Join(h.upldir, "visits", uuid.New().String()+".jpg")
		if err := utils.ProcessAndSaveImage(placeHeader, placeSavePath, 1080, 1080, 75); err != nil {
			response.Fail(c, http.StatusInternalServerError, "failed processing place photo: "+err.Error())
			return
		}
		placePath = "/uploads/visits/" + filepath.Base(placeSavePath)
	} else {
		// FALLBACK: Legacy single 'photo'
		file, fileHeader, err := c.Request.FormFile("photo")
		if err != nil {
			response.Fail(c, http.StatusBadRequest, "selfie and place photos (or legacy photo) are required")
			return
		}
		defer file.Close()

		savePath := filepath.Join(h.upldir, "visits", uuid.New().String()+".jpg")
		if err := utils.ProcessAndSaveImage(fileHeader, savePath, 1080, 1080, 75); err != nil {
			response.Fail(c, http.StatusInternalServerError, "failed processing photo: "+err.Error())
			return
		}
		selfiePath = "/uploads/visits/" + filepath.Base(savePath)
		placePath = selfiePath
	}

	lat, _ := strconv.ParseFloat(c.Request.FormValue("latitude"), 64)
	lon, _ := strconv.ParseFloat(c.Request.FormValue("longitude"), 64)
	if lat == 0 || lon == 0 {
		response.Fail(c, http.StatusBadRequest, "valid latitude and longitude coordinates are required")
		return
	}

	salesIDStr := c.GetString("user_id")
	salesID, _ := uuid.Parse(salesIDStr)

	var customerID, leadID *uuid.UUID
	
	if cID := c.Request.FormValue("customer_id"); cID != "" {
		if u, err := uuid.Parse(cID); err == nil {
			customerID = &u
		}
	}
	if lID := c.Request.FormValue("lead_id"); lID != "" {
		if u, err := uuid.Parse(lID); err == nil {
			leadID = &u
		}
	}

	if customerID == nil && leadID == nil {
		// Attempt to resolve from schedule if provided
		if sID := c.Request.FormValue("schedule_id"); sID != "" {
			if suid, err := uuid.Parse(sID); err == nil {
				if sched, err := h.uc.GetSchedule(c.Request.Context(), suid); err == nil {
					customerID = sched.CustomerID
					leadID = sched.LeadID
					// Some schedules might have one or the other as uuid.Nil
					if customerID != nil && *customerID == uuid.Nil { customerID = nil }
					if leadID != nil && *leadID == uuid.Nil { leadID = nil }
				}
			}
		}
	}

	if customerID == nil && leadID == nil {
		// Attempt to resolve from task destination if provided
		if tdID := c.Request.FormValue("task_destination_id"); tdID != "" {
			if tuid, err := uuid.Parse(tdID); err == nil {
				// We need a task repository or a way to get destination directly
				// LogActivity has access to h.uc which usually has what we need
				if t, err := h.uc.GetTaskByDestinationID(c.Request.Context(), tuid); err == nil {
					for _, d := range t.Destinations {
						if d.ID == tuid {
							customerID = d.CustomerID
							leadID = d.LeadID
							if customerID != nil && *customerID == uuid.Nil { customerID = nil }
							if leadID != nil && *leadID == uuid.Nil { leadID = nil }
							break
						}
					}
				}
			}
		}
	}

	if customerID == nil && leadID == nil {
		response.Fail(c, http.StatusBadRequest, "customer_id or lead_id is required")
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
	activity.LeadID = leadID
	activity.Latitude = lat
	activity.Longitude = lon
	activity.SelfiePhotoPath = selfiePath
	activity.PlacePhotoPath = placePath
	activity.PhotoPath = selfiePath // for legacy DB column support if needed

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

	if dID := c.Request.FormValue("deal_id"); dID != "" {
		if u, err := uuid.Parse(dID); err == nil {
			activity.DealID = &u
		}
	}

	// 4. Register logical algorithm mapping
	respAct, err := h.uc.LogActivity(c.Request.Context(), &activity)
	if err != nil {
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

func (h *VisitHandler) ListActivities(c *gin.Context) {
	var filter repository.ActivityFilter
	
	// Role-aware enforcement
	userRole, _ := c.Get("user_role")
	userID, _ := uuid.Parse(c.GetString("user_id"))

	if sID := c.Query("sales_id"); sID != "" {
		if u, err := uuid.Parse(sID); err == nil {
			filter.SalesID = &u
		}
	} else if userRole == models.RoleSales {
		// Default to current user for sales personnel
		filter.SalesID = &userID
	}
	// For other roles, if no sales_id is specified, filter.SalesID remains nil (show all)

	if cID := c.Query("customer_id"); cID != "" {
		if u, err := uuid.Parse(cID); err == nil {
			filter.CustomerID = &u
		}
	}
	if lID := c.Query("lead_id"); lID != "" {
		if u, err := uuid.Parse(lID); err == nil {
			filter.LeadID = &u
		}
	}

	// Optional date range
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

	acts, err := h.uc.ListActivities(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, acts)
}
