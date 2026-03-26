export type LeadStatus = 'new' | 'contacted' | 'qualified' | 'unqualified'
export type LeadSource = 'referral' | 'cold_call' | 'social_media' | 'website' | 'event' | 'other'

export interface Lead {
  id: string
  title: string
  name: string
  company?: string
  email?: string
  phone?: string
  source: LeadSource
  status: LeadStatus
  assigned_to?: string
  customer_id?: string
  estimated_value?: number
  notes?: string
  converted_at?: string
  created_by?: string
  created_at: string
  updated_at: string
}

export interface LeadFilter {
  status?: LeadStatus
  source?: LeadSource
  search?: string
  page?: number
  limit?: number
}
