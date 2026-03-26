import { defineStore } from 'pinia'
import { ref } from 'vue'
import { fetchLeads, createLead, updateLead, deleteLead, convertLead } from '@/api/leads.api'
import type { Lead, LeadFilter } from '@/types/lead.types'

export const useLeadStore = defineStore('leads', () => {
  const leads = ref<Lead[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchAll(filter?: LeadFilter) {
    loading.value = true
    error.value = null
    try {
      const res = await fetchLeads(filter)
      leads.value = res.data.data || []
    } catch (e: any) {
      error.value = e.response?.data?.error?.message || 'Gagal memuat data leads'
    } finally {
      loading.value = false
    }
  }

  async function create(data: Partial<Lead>) {
    const res = await createLead(data)
    leads.value.unshift(res.data.data)
    return res.data.data
  }

  async function update(id: string, data: Partial<Lead>) {
    const res = await updateLead(id, data)
    const idx = leads.value.findIndex(l => l.id === id)
    if (idx >= 0) leads.value[idx] = res.data.data
    return res.data.data
  }

  async function remove(id: string) {
    await deleteLead(id)
    leads.value = leads.value.filter(l => l.id !== id)
  }

  async function convert(id: string) {
    const res = await convertLead(id)
    const idx = leads.value.findIndex(l => l.id === id)
    if (idx >= 0) {
      leads.value[idx] = { ...leads.value[idx], status: 'qualified' as const, converted_at: new Date().toISOString(), customer_id: res.data.data?.customer_id }
    }
    return res.data.data
  }

  return { leads, loading, error, fetchAll, create, update, remove, convert }
})
