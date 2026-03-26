<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useVisitStore } from '@/stores/visits.store'
import type { VisitActivity } from '@/api/visits.api'
import {
  ArrowLeft, Loader2, Calendar, MapPin, Clock, Camera,
  CheckCircle2, XCircle, User, Navigation
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'

const route = useRoute()
const router = useRouter()
const store = useVisitStore()

const loading = ref(true)
const schedule = ref<any>(null)
const error = ref<string | null>(null)

onMounted(async () => {
  const id = route.params.id as string
  // Load schedules to find the one we need
  try {
    await store.fetchAll({ limit: 100 })
    schedule.value = store.schedules.find(s => s.id === id)
    if (schedule.value) {
      await store.loadActivities(id)
    } else {
      error.value = 'Jadwal kunjungan tidak ditemukan'
    }
  } catch (e: any) {
    error.value = 'Gagal memuat detail kunjungan'
  } finally {
    loading.value = false
  }
})

const goBack = () => router.back()

const formatStatus = (status: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' | 'destructive' }> = {
    scheduled: { label: 'Terjadwal', variant: 'outline' },
    completed: { label: 'Selesai', variant: 'default' },
    cancelled: { label: 'Dibatalkan', variant: 'destructive' },
    missed: { label: 'Terlewat', variant: 'secondary' },
  }
  return map[status] || { label: status, variant: 'secondary' as const }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center gap-3">
      <Button variant="ghost" size="icon" @click="goBack" class="h-9 w-9">
        <ArrowLeft class="w-4 h-4" />
      </Button>
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Detail Kunjungan</h1>
        <p class="text-muted-foreground text-sm">Informasi lengkap jadwal dan aktivitas lapangan</p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-24">
      <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <Card v-else-if="error" class="border-destructive bg-destructive/5">
      <CardContent class="py-6 text-center">
        <p class="text-destructive font-medium">{{ error }}</p>
      </CardContent>
    </Card>

    <!-- Content -->
    <div v-else-if="schedule" class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Schedule Info -->
      <Card class="md:col-span-1">
        <CardHeader>
          <div class="flex items-center justify-between">
            <CardTitle class="text-lg">{{ schedule.title }}</CardTitle>
            <Badge :variant="formatStatus(schedule.status).variant">
              {{ formatStatus(schedule.status).label }}
            </Badge>
          </div>
          <CardDescription v-if="schedule.objective">{{ schedule.objective }}</CardDescription>
        </CardHeader>

        <Separator />

        <CardContent class="pt-6 space-y-4">
          <div class="flex items-center gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <Calendar class="w-4 h-4 text-muted-foreground" />
            </div>
            <div>
              <p class="text-muted-foreground text-xs">Tanggal</p>
              <p class="font-medium">{{ new Date(schedule.date).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }) }}</p>
            </div>
          </div>

          <div class="flex items-center gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <User class="w-4 h-4 text-muted-foreground" />
            </div>
            <div>
              <p class="text-muted-foreground text-xs">Sales</p>
              <p class="font-medium">{{ schedule.sales_name || schedule.sales_id.slice(0, 8) }}</p>
            </div>
          </div>

          <div class="flex items-center gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <MapPin class="w-4 h-4 text-muted-foreground" />
            </div>
            <div>
              <p class="text-muted-foreground text-xs">Pelanggan</p>
              <p class="font-medium">{{ schedule.customer_name || schedule.customer_id.slice(0, 8) }}</p>
            </div>
          </div>

          <div v-if="schedule.notes" class="pt-4 border-t">
            <p class="text-xs text-muted-foreground mb-1">Catatan</p>
            <p class="text-sm">{{ schedule.notes }}</p>
          </div>
        </CardContent>
      </Card>

      <!-- Activity Timeline -->
      <Card class="md:col-span-2">
        <CardHeader>
          <CardTitle>Aktivitas Lapangan</CardTitle>
          <CardDescription>Check-in dan check-out yang tercatat</CardDescription>
        </CardHeader>
        <CardContent>
          <div v-if="store.loadingActivities" class="flex justify-center py-12">
            <Loader2 class="w-6 h-6 animate-spin text-muted-foreground" />
          </div>

          <div v-else-if="store.activities.length === 0" class="text-center py-12">
            <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
              <Navigation class="w-6 h-6 text-muted-foreground" />
            </div>
            <p class="text-sm text-muted-foreground">Belum ada aktivitas lapangan untuk kunjungan ini.</p>
          </div>

          <div v-else class="space-y-4">
            <div v-for="activity in store.activities" :key="activity.id"
                 class="flex gap-4 p-4 rounded-lg border hover:bg-accent/50 transition-colors">
              <div class="flex-shrink-0">
                <div class="h-10 w-10 rounded-full flex items-center justify-center"
                     :class="activity.type === 'check-in' ? 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-600' : 'bg-red-100 dark:bg-red-900/30 text-red-600'">
                  <CheckCircle2 v-if="activity.type === 'check-in'" class="w-5 h-5" />
                  <XCircle v-else class="w-5 h-5" />
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 mb-1">
                  <p class="font-medium text-sm">{{ activity.type === 'check-in' ? 'Check In' : 'Check Out' }}</p>
                  <Badge v-if="activity.is_offline" variant="outline" class="text-[10px]">Offline</Badge>
                </div>
                <div class="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-muted-foreground">
                  <span class="flex items-center gap-1">
                    <Clock class="w-3 h-3" />
                    {{ new Date(activity.created_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) }}
                  </span>
                  <span class="flex items-center gap-1">
                    <MapPin class="w-3 h-3" />
                    {{ activity.latitude.toFixed(5) }}, {{ activity.longitude.toFixed(5) }}
                  </span>
                  <span v-if="activity.distance != null" class="flex items-center gap-1">
                    <Navigation class="w-3 h-3" />
                    {{ activity.distance.toFixed(0) }}m dari pelanggan
                  </span>
                </div>
                <p v-if="activity.notes" class="text-sm mt-2 text-muted-foreground">{{ activity.notes }}</p>
                <div v-if="activity.photo_path" class="mt-2 flex items-center gap-1 text-xs text-primary">
                  <Camera class="w-3 h-3" />
                  <span>Foto tersedia</span>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
