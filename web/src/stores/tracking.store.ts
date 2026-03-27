import { defineStore } from 'pinia'
import { ref, onUnmounted } from 'vue'
import { fetchLiveSalesPositions as apiFetchLive } from '@/api/tracking.api'
import type { SalesLivePosition } from '@/types/tracking.types'
import { LIVE_TRACKING_INTERVAL } from '@/constants'

export const useTrackingStore = defineStore('tracking', () => {
  const livePositions = ref<SalesLivePosition[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  let pollingIntervalId: number | null = null

  async function fetchLivePositions() {
    // Only set loading true on the very first fetch to prevent UI blinking
    if (livePositions.value.length === 0) {
       loading.value = true
    }
    
    try {
      const res = await apiFetchLive()
      livePositions.value = res.data.data || []
      error.value = null
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Gagal memuat posisi sales'
    } finally {
      loading.value = false
    }
  }

  function startPolling() {
    if (pollingIntervalId) return // Already polling
    
    // Immediate fetch
    fetchLivePositions()
    
    // Set interval
    pollingIntervalId = window.setInterval(fetchLivePositions, LIVE_TRACKING_INTERVAL)
  }

  function stopPolling() {
    if (pollingIntervalId) {
      window.clearInterval(pollingIntervalId)
      pollingIntervalId = null
    }
  }

  return { 
    livePositions, 
    loading, 
    error, 
    startPolling, 
    stopPolling,
    fetchLivePositions
  }
})
