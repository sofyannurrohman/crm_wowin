import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface AttendanceRecord {
  id: string
  user_id: string
  type: 'clock_in' | 'clock_out'
  latitude: number
  longitude: number
  address: string
  photo_path: string
  timestamp_at: string
  notes: string
}

export interface DailyAttendance {
  user_id: string
  work_date: string
  clock_in: string | null
  clock_out: string | null
  work_hours: number
}

export async function clockIn(formData: FormData) {
  return client.post<ApiResponse<AttendanceRecord>>('/attendance/clock-in', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export async function clockOut(formData: FormData) {
  return client.post<ApiResponse<AttendanceRecord>>('/attendance/clock-out', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export async function fetchAttendanceHistory(month: number, year: number) {
  return client.get<ApiResponse<DailyAttendance[]>>(`/attendance/history?month=${month}&year=${year}`)
}
