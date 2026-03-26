import { defineStore } from 'pinia'
import { ref } from 'vue'
import { fetchTerritories as apiFetch, createTerritory as apiCreate, updateTerritory as apiUpdate, deleteTerritory as apiDelete } from '@/api/tracking.api'
import type { Territory } from '@/types/territory.types'

export const useTerritoryStore = defineStore('territories', () => {
  const territories = ref<Territory[]>([])
  const loading = ref(false)
  const isSubmitting = ref(false)
  const error = ref<string | null>(null)

  async function fetchAll() {
    loading.value = true
    error.value = null
    try {
      const res = await apiFetch()
      territories.value = res.data.data
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal memuat data territory'
    } finally {
      loading.value = false
    }
  }

  async function create(data: Partial<Territory>) {
    isSubmitting.value = true
    error.value = null
    try {
      const res = await apiCreate(data)
      territories.value.push(res.data.data)
      return res.data.data
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal membuat territory'
      throw e
    } finally {
      isSubmitting.value = false
    }
  }

  async function update(id: string, data: Partial<Territory>) {
     isSubmitting.value = true
     try {
       const res = await apiUpdate(id, data)
       const idx = territories.value.findIndex(t => t.id === id)
       if (idx > -1) {
         territories.value[idx] = res.data.data
       }
     } catch (e: any) {
        error.value = e.response?.data?.error?.message ?? 'Gagal menyimpan territory'
        throw e
     } finally {
        isSubmitting.value = false
     }
  }
  
  async function remove(id: string) {
     isSubmitting.value = true
     try {
        await apiDelete(id)
        territories.value = territories.value.filter(t => t.id !== id)
     } catch (e: any) {
        error.value = e.response?.data?.error?.message ?? 'Gagal menghapus territory'
        throw e
     } finally {
        isSubmitting.value = false
     }
  }

  return { territories, loading, isSubmitting, error, fetchAll, create, update, remove }
})
