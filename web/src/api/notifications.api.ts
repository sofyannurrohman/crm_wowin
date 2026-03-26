import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface Notification {
  id: string
  type: string
  title: string
  body: string
  entity_type: string
  entity_id: string
  is_read: boolean
  read_at: string | null
  created_at: string
}

export async function fetchNotifications(limit: number = 20, offset: number = 0) {
  return client.get<ApiResponse<Notification[]>>(`/notifications?limit=${limit}&offset=${offset}`)
}

export async function getUnreadCount() {
  return client.get<ApiResponse<{ unread_count: number }>>('/notifications/unread-count')
}

export async function markAsRead(id: string) {
  return client.patch<ApiResponse<null>>(`/notifications/${id}/read`)
}

export async function markAllAsRead() {
  return client.patch<ApiResponse<null>>('/notifications/read-all')
}
