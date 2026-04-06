import client from './client'

export interface Warehouse {
  id: string
  name: string
  address: string
  latitude: number
  longitude: number
  created_at?: string
  updated_at?: string
}

export const warehouseApi = {
  list: async () => {
    const response = await client.get<Warehouse[]>('/warehouses')
    return response.data
  },
  
  create: async (data: Partial<Warehouse>) => {
    const response = await client.post<Warehouse>('/warehouses', data)
    return response.data
  },

  update: async (id: string, data: Partial<Warehouse>) => {
    const response = await client.put<Warehouse>(`/warehouses/${id}`, data)
    return response.data
  },

  delete: async (id: string) => {
    const response = await client.delete(`/warehouses/${id}`)
    return response.data
  }
}
