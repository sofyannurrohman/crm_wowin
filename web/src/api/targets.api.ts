import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface Target {
  monthly_revenue: number
  monthly_visits: number
  monthly_new_customers: number
  win_rate: number
  monthly_deals: number
}

export interface SalesTarget extends Target {
  id?: string
  user_id: string
  period_year: number
  period_month: number
}

export async function fetchTargets() {
  return client.get<ApiResponse<Target>>('/settings/targets')
}

export async function updateTargets(data: Target) {
  return client.put<ApiResponse<Target>>('/settings/targets', data)
}

export async function fetchUserTarget(userID: string, month: number, year: number) {
  return client.get<ApiResponse<SalesTarget>>(`/settings/targets/users/${userID}?month=${month}&year=${year}`)
}

export async function updateUserTarget(data: SalesTarget) {
  return client.put<ApiResponse<SalesTarget>>('/settings/targets/users', data)
}
