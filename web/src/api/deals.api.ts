import client from './client'
import type { ApiResponse } from '@/types/api.types'
import type { Deal, DealStage } from '@/types/deal.types'

export async function fetchDeals() {
  return client.get<ApiResponse<Deal[]>>('/deals')
}

export async function updateDealStage(dealId: string, newStage: DealStage) {
  return client.patch<ApiResponse<Deal>>(`/deals/${dealId}/stage`, { stage: newStage })
}

export async function createDeal(data: Partial<Deal>) {
  return client.post<ApiResponse<Deal>>('/deals', data)
}
