import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface VisitSchedule {
  id: string
  sales_id: string
  sales_name?: string
  customer_id: string
  customer_name?: string
  date: string
  title: string
  objective?: string
  status: 'scheduled' | 'completed' | 'cancelled' | 'missed'
  notes?: string
  created_at: string
  updated_at: string
}

export interface VisitActivity {
  id: string
  schedule_id?: string
  sales_id: string
  customer_id: string
  type: 'check-in' | 'check-out'
  latitude: number
  longitude: number
  photo_path: string
  distance?: number
  is_offline: boolean
  notes?: string
  created_at: string
}

export interface VisitScheduleFilter {
  sales_id?: string
  status?: string
  search?: string
  date_from?: string
  date_to?: string
  page?: number
  limit?: number
}

export async function fetchVisitSchedules(filter?: VisitScheduleFilter) {
  const params = new URLSearchParams()
  if (filter?.sales_id) params.append('sales_id', filter.sales_id)
  if (filter?.status) params.append('status', filter.status)
  if (filter?.search) params.append('search', filter.search)
  if (filter?.date_from) params.append('date_from', filter.date_from)
  if (filter?.date_to) params.append('date_to', filter.date_to)
  if (filter?.page) params.append('page', filter.page.toString())
  if (filter?.limit) params.append('limit', filter.limit.toString())

  return client.get<ApiResponse<VisitSchedule[]>>(`/visits/schedules?${params.toString()}`)
}

export async function createVisitSchedule(data: Partial<VisitSchedule>) {
  return client.post<ApiResponse<VisitSchedule>>('/visits/schedules', data)
}

export async function updateVisitSchedule(id: string, data: Partial<VisitSchedule>) {
  return client.put<ApiResponse<VisitSchedule>>(`/visits/schedules/${id}`, data)
}

export async function fetchVisitActivities(scheduleId: string) {
  return client.get<ApiResponse<VisitActivity[]>>(`/visits/schedules/${scheduleId}/activities`)
}
