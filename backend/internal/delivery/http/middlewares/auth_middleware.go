package middlewares

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/pkg/jwtutil"
	"crm_wowin_backend/pkg/response"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

// AuthMiddleware injects the JWT validation mechanism
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			response.Fail(c, http.StatusUnauthorized, "authorization header missing")
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			response.Fail(c, http.StatusUnauthorized, "invalid authorization format")
			c.Abort()
			return
		}

		tokenString := parts[1]
		secret := os.Getenv("JWT_SECRET")
		if secret == "" {
			secret = "super_secret_jwt_key_please_change_this_in_production"
		}

		claims, err := jwtutil.ValidateToken(tokenString, secret)
		if err != nil {
			response.Fail(c, http.StatusUnauthorized, err.Error())
			c.Abort()
			return
		}

		// Inject user context payload (id, role, email) natively into Gin Context
		c.Set("user_id", claims.UserID.String())
		c.Set("user_email", claims.Email)
		c.Set("user_role", claims.Role)
		
		c.Next()
	}
}

// RoleMiddleware enforces RBAC restrictions
func RoleMiddleware(allowedRoles ...models.UserRole) gin.HandlerFunc {
	return func(c *gin.Context) {
		roleVal, exists := c.Get("user_role")
		if !exists {
			response.Fail(c, http.StatusUnauthorized, "role context missing")
			c.Abort()
			return
		}

		userRole := roleVal.(models.UserRole)
		hasAccess := false

		// Super admin intrinsically bypasses regular role gates
		if userRole == models.RoleSuperAdmin {
			hasAccess = true
		} else {
			for _, allowed := range allowedRoles {
				if userRole == allowed {
					hasAccess = true
					break
				}
			}
		}

		if !hasAccess {
			response.Fail(c, http.StatusForbidden, "insufficient role permissions")
			c.Abort()
			return
		}

		c.Next()
	}
}
