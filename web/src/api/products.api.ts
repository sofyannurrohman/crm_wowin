import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface ProductCategory {
  id: string
  name: string
  parent_id?: string
  created_at: string
}

export interface Product {
  id: string
  sku?: string           // backend: sku (maps from 'code' in DB)
  name: string
  category_id?: string
  description?: string
  unit?: string
  price: number          // backend: price (maps from 'base_price' in DB)
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface CreateProductPayload {
  sku?: string
  name: string
  category_id?: string
  description?: string
  unit?: string
  price: number
  is_active: boolean
}

export async function fetchProducts(params: Record<string, any> = {}) {
  return client.get<ApiResponse<Product[]>>('/products', { params })
}

export async function getProductById(id: string) {
  return client.get<ApiResponse<Product>>(`/products/${id}`)
}

export async function createProduct(data: CreateProductPayload) {
  return client.post<ApiResponse<Product>>('/products', data)
}

export async function updateProduct(id: string, data: Partial<CreateProductPayload>) {
  return client.put<ApiResponse<Product>>(`/products/${id}`, data)
}

export async function deleteProduct(id: string) {
  return client.delete<ApiResponse<any>>(`/products/${id}`)
}

// Categories
export async function fetchCategories() {
  return client.get<ApiResponse<ProductCategory[]>>('/categories')
}

export async function createCategory(data: { name: string; parent_id?: string }) {
  return client.post<ApiResponse<ProductCategory>>('/categories', data)
}

export async function updateCategory(id: string, data: { name: string }) {
  return client.put<ApiResponse<ProductCategory>>(`/categories/${id}`, data)
}

// Deal items related to products
export interface DealItem {
  id?: string
  deal_id: string
  product_id: string
  name: string
  quantity: number
  unit: string
  unit_price: number
  discount: number
  subtotal?: number
  notes?: string
}

export async function fetchDealItems(dealId: string) {
  return client.get<ApiResponse<DealItem[]>>(`/deals/${dealId}/items`)
}

export async function addDealItem(data: DealItem) {
  return client.post<ApiResponse<DealItem>>('/deal-items', data)
}

export async function updateDealItem(id: string, data: Partial<DealItem>) {
  return client.put<ApiResponse<DealItem>>(`/deal-items/${id}`, data)
}

export async function removeDealItem(id: string) {
  return client.delete<ApiResponse<any>>(`/deal-items/${id}`)
}
