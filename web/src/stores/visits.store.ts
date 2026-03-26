import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  fetchVisitSchedules, createVisitSchedule, updateVisitSchedule, fetchVisitActivities,
  type VisitSchedule, type VisitActivity, type VisitScheduleFilter
} from '@/api/visits.api'

export const useVisitStore = defineStore('visits', () => {
  const schedules = ref<VisitSchedule[]>([])
  const activities = ref<VisitActivity[]>([])
  const loading = ref(false)
  const loadingActivities = ref(false)
  const error = ref<string | null>(null)

  async function fetchAll(filter?: VisitScheduleFilter) {
    loading.value = true
    error.value = null
    try {
      const res = await fetchVisitSchedules(filter)
      schedules.value = res.data.data || []
    } catch (e: any) {
      error.value = e.response?.data?.error?.message || 'Gagal memuat jadwal kunjungan'
    } finally {
      loading.value = false
    }
  }

  async function create(data: Partial<VisitSchedule>) {
    const res = await createVisitSchedule(data)
    schedules.value.unshift(res.data.data)
    return res.data.data
  }

  async function update(id: string, data: Partial<VisitSchedule>) {
    const res = await updateVisitSchedule(id, data)
    const idx = schedules.value.findIndex(s => s.id === id)
    if (idx >= 0) schedules.value[idx] = res.data.data
    return res.data.data
  }

  async function loadActivities(scheduleId: string) {
    loadingActivities.value = true
    try {
      const res = await fetchVisitActivities(scheduleId)
      activities.value = res.data.data || []
    } catch (e: any) {
      console.error('Failed to load activities', e)
    } finally {
      loadingActivities.value = false
    }
  }

  return { schedules, activities, loading, loadingActivities, error, fetchAll, create, update, loadActivities }
})
