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

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type BannerHandler struct {
	uc     usecase.BannerUseCase
	upldir string
}

func NewBannerHandler(uc usecase.BannerUseCase, uploadDir string) *BannerHandler {
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		_ = os.MkdirAll(uploadDir, 0755)
	}
	return &BannerHandler{uc: uc, upldir: uploadDir}
}

func (h *BannerHandler) Create(c *gin.Context) {
	// Parse multipart form (max 10MB)
	err := c.Request.ParseMultipartForm(10 << 20)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "failed to parse multipart form")
		return
	}

	salesIDStr := c.GetString("user_id")
	salesID, _ := uuid.Parse(salesIDStr)

	var banner models.Banner
	banner.SalesID = salesID
	banner.ShopName = c.Request.FormValue("shop_name")
	banner.Content = c.Request.FormValue("content")
	banner.Dimensions = c.Request.FormValue("dimensions")
	banner.Address = utils.Ptr(c.Request.FormValue("address"))

	lat, _ := strconv.ParseFloat(c.Request.FormValue("latitude"), 64)
	lon, _ := strconv.ParseFloat(c.Request.FormValue("longitude"), 64)
	banner.Latitude = lat
	banner.Longitude = lon

	if cid := c.Request.FormValue("customer_id"); cid != "" {
		if u, err := uuid.Parse(cid); err == nil {
			banner.CustomerID = &u
		}
	}
	if lid := c.Request.FormValue("lead_id"); lid != "" {
		if u, err := uuid.Parse(lid); err == nil {
			banner.LeadID = &u
		}
	}

	// Handle photo upload
	file, header, err := c.Request.FormFile("photo")
	if err == nil {
		defer file.Close()
		
		saveDir := filepath.Join(h.upldir, "banners")
		filename := uuid.New().String() + ".jpg"
		savePath := filepath.Join(saveDir, filename)
		
		if err := utils.ProcessAndSaveImage(header, savePath, 1080, 1080, 75); err != nil {
			response.Fail(c, http.StatusInternalServerError, "failed to process photo: "+err.Error())
			return
		}
		
		path := "/uploads/banners/" + filename
		banner.PhotoPath = &path
	}

	created, err := h.uc.CreateBanner(c.Request.Context(), &banner)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, created)
}

func (h *BannerHandler) List(c *gin.Context) {
	var filter repository.BannerFilter
	
	userRole, _ := c.Get("user_role")
	userID, _ := uuid.Parse(c.GetString("user_id"))

	if userRole == models.RoleSales {
		filter.SalesID = &userID
	} else if sid := c.Query("sales_id"); sid != "" {
		if u, err := uuid.Parse(sid); err == nil {
			filter.SalesID = &u
		}
	}

	if cid := c.Query("customer_id"); cid != "" {
		if u, err := uuid.Parse(cid); err == nil {
			filter.CustomerID = &u
		}
	}
	if lid := c.Query("lead_id"); lid != "" {
		if u, err := uuid.Parse(lid); err == nil {
			filter.LeadID = &u
		}
	}

	filter.Limit, _ = strconv.Atoi(c.DefaultQuery("limit", "50"))
	filter.Offset, _ = strconv.Atoi(c.DefaultQuery("offset", "0"))

	banners, err := h.uc.ListBanners(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, banners)
}
