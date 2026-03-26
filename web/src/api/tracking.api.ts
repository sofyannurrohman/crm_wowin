import client from './client'
import type { ApiResponse } from '@/types/api.types'
import type { SalesLivePosition, TrackingSession } from '@/types/tracking.types'
import type { Territory } from '@/types/territory.types'

// Tracking API
export async function fetchLiveSalesPositions() {
  return client.get<ApiResponse<SalesLivePosition[]>>('/tracking/live')
}

export async function fetchTrackingSession(salesId: string, date: string) {
  return client.get<ApiResponse<TrackingSession>>(`/tracking/sessions/${salesId}?date=${date}`)
}

// Territory API
export async function fetchTerritories() {
  return client.get<ApiResponse<Territory[]>>('/territories')
}

export async function createTerritory(data: Partial<Territory>) {
  return client.post<ApiResponse<Territory>>('/territories', data)
}

export async function updateTerritory(id: string, data: Partial<Territory>) {
  return client.put<ApiResponse<Territory>>(`/territories/${id}`, data)
}

export async function deleteTerritory(id: string) {
  return client.delete<ApiResponse<null>>(`/territories/${id}`)
}
