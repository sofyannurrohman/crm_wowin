import client from './client'
import type { ApiResponse } from '@/types/api.types'
import type { Customer, CustomerFilter } from '@/types/customer.types'

export async function fetchCustomers(filter?: CustomerFilter) {
  const params = new URLSearchParams()
  if (filter?.status) params.append('status', filter.status)
  if (filter?.search) params.append('search', filter.search)
  if (filter?.page) params.append('page', filter.page.toString())
  if (filter?.limit) params.append('limit', filter.limit.toString())
  
  return client.get<ApiResponse<Customer[]>>(`/customers?${params.toString()}`)
}

export async function createCustomer(data: Partial<Customer>) {
  return client.post<ApiResponse<Customer>>('/customers', data)
}

export async function getCustomerById(id: string) {
  return client.get<ApiResponse<Customer>>(`/customers/${id}`)
}
