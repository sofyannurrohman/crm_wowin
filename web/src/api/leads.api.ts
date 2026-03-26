import client from './client'
import type { ApiResponse } from '@/types/api.types'
import type { Lead, LeadFilter } from '@/types/lead.types'

export async function fetchLeads(filter?: LeadFilter) {
  const params = new URLSearchParams()
  if (filter?.status) params.append('status', filter.status)
  if (filter?.source) params.append('source', filter.source)
  if (filter?.search) params.append('search', filter.search)
  if (filter?.page) params.append('page', filter.page.toString())
  if (filter?.limit) params.append('limit', filter.limit.toString())

  return client.get<ApiResponse<Lead[]>>(`/leads?${params.toString()}`)
}

export async function createLead(data: Partial<Lead>) {
  return client.post<ApiResponse<Lead>>('/leads', data)
}

export async function getLeadById(id: string) {
  return client.get<ApiResponse<Lead>>(`/leads/${id}`)
}

export async function updateLead(id: string, data: Partial<Lead>) {
  return client.put<ApiResponse<Lead>>(`/leads/${id}`, data)
}

export async function deleteLead(id: string) {
  return client.delete<ApiResponse<null>>(`/leads/${id}`)
}

export async function convertLead(id: string) {
  return client.post<ApiResponse<any>>(`/leads/${id}/convert`)
}
