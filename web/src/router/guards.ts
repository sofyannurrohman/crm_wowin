import type { NavigationGuardNext, RouteLocationNormalized } from 'vue-router'

export function authGuard(
  to: RouteLocationNormalized,
  _from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  const token = localStorage.getItem('access_token')
  if (!token && to.meta.requiresAuth) {
    next({ name: 'login', query: { redirect: to.fullPath } })
    return
  }
  
  // Prevent authenticated users from visiting login again
  if (token && to.name === 'login') {
    next({ name: 'dashboard' })
    return  
  }
  
  next()
}

export function roleGuard(allowedRoles: string[]) {
  return (
    to: RouteLocationNormalized,
    _from: RouteLocationNormalized,
    next: NavigationGuardNext
  ) => {
    const role = localStorage.getItem('user_role') ?? ''
    if (!allowedRoles.includes(role)) {
      if (to.name === 'dashboard') {
        // If they can't even access the dashboard, clear invalid session & go login
        localStorage.removeItem('access_token')
        localStorage.removeItem('refresh_token')
        localStorage.removeItem('user_role')
        localStorage.removeItem('user_data')
        next({ name: 'login' })
        return
      }
      next({ name: 'dashboard' }) // Fallback to safe dashboard home
      return
    }
    next()
  }
}
