import client from './client'
import type { ApiResponse } from '@/types/api.types'
import type { LoginResponse } from '@/types/auth.types'

export async function login(email: string, password: string) {
  return client.post<ApiResponse<LoginResponse>>('/auth/login', { email, password })
}

export async function refreshToken(refresh_token: string) {
  return client.post<ApiResponse<{ access_token: string; refresh_token: string }>>('/auth/refresh', { refresh_token })
}

export async function logout() {
  return client.post('/auth/logout')
}
