import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  fetchCustomers as apiFetchCustomers, 
  createCustomer as apiCreateCustomer,
  updateCustomer as apiUpdateCustomer,
  deleteCustomer as apiDeleteCustomer
} from '@/api/customers.api'
import type { Customer, CustomerFilter } from '@/types/customer.types'

export const useCustomerStore = defineStore('customers', () => {
  const customers = ref<Customer[]>([])
  const total = ref(0)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const activeCustomers = computed(() =>
    customers.value.filter(c => c.status === 'active')
  )

  async function fetchAll(filter?: CustomerFilter) {
    loading.value = true
    error.value = null
    try {
      const res = await apiFetchCustomers(filter)
      customers.value = res.data.data || []
      total.value = res.data.meta?.total ?? 0
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal mengambil data pelanggan'
    } finally {
      loading.value = false
    }
  }

  async function createCustomer(data: Partial<Customer>) {
    loading.value = true
    error.value = null
    try {
      const res = await apiCreateCustomer(data)
      customers.value.unshift(res.data.data) // Added to top
      total.value++
      return res.data.data
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal membuat pelanggan'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function updateCustomer(id: string, data: Partial<Customer>) {
    loading.value = true
    error.value = null
    try {
      const res = await apiUpdateCustomer(id, data)
      const updated = res.data.data
      const index = customers.value.findIndex(c => c.id === id)
      if (index !== -1) {
        customers.value[index] = updated
      }
      return updated
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal memperbarui pelanggan'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function deleteCustomer(id: string) {
    loading.value = true
    error.value = null
    try {
      await apiDeleteCustomer(id)
      customers.value = customers.value.filter(c => c.id !== id)
      total.value--
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal menghapus pelanggan'
      throw e
    } finally {
      loading.value = false
    }
  }

  return { customers, total, loading, error, activeCustomers, fetchAll, createCustomer, updateCustomer, deleteCustomer }
})
