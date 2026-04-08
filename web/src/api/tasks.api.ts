import client from './client'
import type { ApiResponse } from '@/types/api.types'

export type TaskStatus = 'pending' | 'in_progress' | 'done' | 'cancelled';
export type TaskPriority = 'low' | 'medium' | 'high' | 'urgent';

export interface TaskDestination {
  id: string
  task_id: string
  lead_id?: string
  customer_id?: string
  deal_id?: string
  sequence_order: number
  status: string
  target_name?: string
  target_latitude?: number
  target_longitude?: number
  target_address?: string
}

export interface Task {
  id: string
  title: string
  description: string
  status: TaskStatus
  priority: TaskPriority
  assigned_to: string
  assigned_name?: string
  warehouse_id: string
  warehouse?: any
  customer_id?: string
  customer_name?: string
  destinations?: TaskDestination[]
  due_at: string
  completed_at?: string
  created_at: string
}

export async function fetchTasks(params: Record<string, any> = {}) {
  return client.get<ApiResponse<Task[]>>('/tasks', { params })
}

export async function createTask(data: Partial<Task>) {
  return client.post<ApiResponse<Task>>('/tasks', data)
}

export async function updateTask(id: string, data: Partial<Task>) {
  return client.put<ApiResponse<Task>>(`/tasks/${id}`, data)
}

export async function completeTask(id: string) {
  return client.patch<ApiResponse<Task>>(`/tasks/${id}/complete`)
}

export async function deleteTask(id: string) {
  return client.delete<ApiResponse<any>>(`/tasks/${id}`)
}
