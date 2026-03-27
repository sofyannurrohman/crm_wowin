import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface Target {
  monthly_revenue: number
  monthly_visits: number
  monthly_new_customers: number
  win_rate: number
  monthly_deals: number
}

export async function fetchTargets() {
  return client.get<ApiResponse<Target>>('/settings/targets')
}

export async function updateTargets(data: Target) {
  return client.put<ApiResponse<Target>>('/settings/targets', data)
}
