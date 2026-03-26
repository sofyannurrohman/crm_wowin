import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { login as apiLogin, logout as apiLogout, refreshToken as apiRefreshToken } from '@/api/auth.api'
import type { User } from '@/types/auth.types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(
    localStorage.getItem('user_data') 
      ? JSON.parse(localStorage.getItem('user_data') as string) 
      : null
  )
  const isAuthenticated = ref<boolean>(!!localStorage.getItem('access_token'))
  const loading = ref(false)
  const error = ref<string | null>(null)
  const router = useRouter()

  async function login(email: string, pass: string) {
    loading.value = true
    error.value = null
    try {
      const { data } = await apiLogin(email, pass)
      
      const { access_token, refresh_token } = data.data
      
      const payloadBase64 = access_token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')
      const decodedPayload = JSON.parse(decodeURIComponent(window.atob(payloadBase64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')))
      
      const userData: User = {
        id: decodedPayload.id || decodedPayload.sub,
        name: decodedPayload.name || decodedPayload.email?.split('@')[0] || 'Unknown',
        email: decodedPayload.email,
        role: decodedPayload.role,
        territory_id: decodedPayload.territory_id
      }
      
      // Persist to storage
      localStorage.setItem('access_token', access_token)
      localStorage.setItem('refresh_token', refresh_token)
      localStorage.setItem('user_role', userData.role)
      localStorage.setItem('user_data', JSON.stringify(userData))
      
      // Update state
      user.value = userData
      isAuthenticated.value = true
      
      router.push({ name: 'dashboard' })
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Login failed. Please check credentials.'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function refreshToken() {
    const token = localStorage.getItem('refresh_token')
    if (!token) throw new Error('No refresh token')
    
    try {
      const { data } = await apiRefreshToken(token)
      const { access_token, refresh_token } = data.data
      
      localStorage.setItem('access_token', access_token)
      localStorage.setItem('refresh_token', refresh_token)
    } catch (e) {
      logout()
      throw e
    }
  }

  function logout() {
    // Attempt backend logout to blacklist the token (fire-and-forget)
    try {
      if (localStorage.getItem('access_token')) {
        apiLogout().catch(() => {})
      }
    } catch (e) {}
    
    // Clear storage
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('user_role')
    localStorage.removeItem('user_data')
    
    // Clear state
    user.value = null
    isAuthenticated.value = false
    
    router.push({ name: 'login' })
  }

  return { 
    user, 
    isAuthenticated, 
    loading, 
    error, 
    login, 
    refreshToken, 
    logout 
  }
})
