import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { 
  fetchCustomers as apiFetchCustomers, 
  createCustomer as apiCreateCustomer 
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

  return { customers, total, loading, error, activeCustomers, fetchAll, createCustomer }
})
