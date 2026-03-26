import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { fetchDeals as apiFetchDeals, updateDealStage as apiUpdateStage } from '@/api/deals.api'
import type { Deal, DealStage } from '@/types/deal.types'
import { DEAL_STAGES } from '@/constants'

export const useDealStore = defineStore('deals', () => {
  const deals = ref<Deal[]>([])
  const loading = ref(false)
  const loadingStageUpdate = ref<string | null>(null)
  const error = ref<string | null>(null)

  // Memoized getter for Kanban columns mapping
  const dealsByStage = computed(() => {
    const grouped = {} as Record<string, Deal[]>;
    // Initialize empty arrays
    (DEAL_STAGES || []).forEach(stage => {
      grouped[stage.key] = [];
    });
    
    // Distribute
    const currentDeals = deals.value || [];
    currentDeals.forEach((deal: Deal) => {
      if (deal && grouped[deal.stage]) {
        grouped[deal.stage].push(deal);
      }
    });
    return grouped
  })

  async function fetchAll() {
    loading.value = true
    error.value = null
    try {
      const res = await apiFetchDeals()
      deals.value = res.data.data ?? []
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal mengambil data Deals'
    } finally {
      loading.value = false
    }
  }

  // Optimistic UI Update wrapped around API Call
  async function updateStage(dealId: string, newStage: DealStage) {
    loadingStageUpdate.value = dealId
    
    // 1. Snapshot previous state (optimistic rollback safe)
    const dealIndex = deals.value.findIndex(d => d.id === dealId)
    const oldStage = deals.value[dealIndex]?.stage
    
    // 2. Optimistic UI change instantly
    if (dealIndex > -1) {
       deals.value[dealIndex].stage = newStage
    }

    try {
      // 3. Fire API Call 
      await apiUpdateStage(dealId, newStage)
    } catch (e: any) {
      // 4. Rollback on failure
      if (dealIndex > -1 && oldStage) {
         deals.value[dealIndex].stage = oldStage
      }
      error.value = e.response?.data?.error?.message ?? 'Gagal mengubah stage (Rollback diaktifkan)'
    } finally {
      loadingStageUpdate.value = null
    }
  }

  return { 
    deals, 
    loading, 
    loadingStageUpdate, 
    error, 
    dealsByStage, 
    fetchAll, 
    updateStage 
  }
})
