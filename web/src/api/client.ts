import axios from 'axios'
import { useAuthStore } from '@/stores/auth.store'
import { API_BASE_URL } from '@/constants'

const client = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  timeout: 15000,
})

// Request: attach token
client.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Response: handle 401 → refresh token → retry
client.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true
      const auth = useAuthStore()
      
      try {
        await auth.refreshToken()
        // Retry the original request after successfully refreshing the token
        original.headers.Authorization = `Bearer ${localStorage.getItem('access_token')}`
        return client(original)
      } catch (refreshError) {
        // If refresh fails, log the user out
        auth.logout()
        return Promise.reject(refreshError)
      }
    }
    
    // Provide user-friendly network errors natively
    if (!error.response) {
      error.message = 'Koneksi jaringan terputus. Silakan periksa koneksi internet Anda.'
    }
    
    return Promise.reject(error)
  }
)

export default client
