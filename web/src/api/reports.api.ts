import client from './client'
import type { ApiResponse } from '@/types/api.types'

export interface KpiSummary {
  total_customers: number
  total_active_deals: number
  pipeline_value: number
  win_rate: number
  total_visits_today: number
  customers_growth?: number
  win_rate_growth?: number
  visits_target?: number
}

// These generic metrics structure allow dynamically populating the Line/Bar charts
export interface ChartSeriesData {
  label: string
  value: number
}

export async function fetchKpiSummary() {
  return client.get<ApiResponse<KpiSummary>>('/reports/kpi-summary')
}

export async function fetchRevenueTrend(months: number = 6) {
  return client.get<ApiResponse<ChartSeriesData[]>>(`/reports/revenue-trend?months=${months}`)
}

export async function fetchPipelineFunnel() {
  return client.get<ApiResponse<ChartSeriesData[]>>('/reports/pipeline-funnel')
}

export async function fetchAnalytics(months: number = 6) {
  return client.get<ApiResponse<any>>(`/reports/analytics?months=${months}`)
}
