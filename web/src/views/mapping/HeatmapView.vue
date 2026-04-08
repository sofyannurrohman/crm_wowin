<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useCustomerStore } from '@/stores/customers.store'
import { LMap, LTileLayer, LMarker, LPopup, LCircleMarker } from '@vue-leaflet/vue-leaflet'
import { Icon } from 'leaflet'
import { Loader2, Users, MapPin } from 'lucide-vue-next'
import 'leaflet/dist/leaflet.css'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

// @ts-ignore
delete Icon.Default.prototype._getIconUrl
Icon.Default.mergeOptions({
  iconRetinaUrl: '/marker-icon-2x.png',
  iconUrl: '/marker-icon.png',
  shadowUrl: '/marker-shadow.png',
})

const store = useCustomerStore()

const zoom = ref(5)
const center = ref<[number, number]>([-2.5, 118.0])
const mapReady = ref(false)

const customersWithCoords = computed(() =>
  store.customers.filter(c => c.latitude && c.longitude)
)

const stats = computed(() => ({
  total: store.customers.length,
  withCoords: customersWithCoords.value.length,
  active: store.customers.filter(c => c.status === 'active').length,
}))

onMounted(async () => {
  try {
    await store.fetchAll({ limit: 500 })
    mapReady.value = true
    if (customersWithCoords.value.length > 0) {
      const first = customersWithCoords.value[0]
      center.value = [first.latitude!, first.longitude!]
      zoom.value = 10
    }
  } catch (e) {
    console.error('Failed loading customers for heatmap', e)
    mapReady.value = true
  }
})

const getStatusColor = (status: string) => {
  switch (status) {
    case 'active': return '#22c55e'
    case 'inactive': return '#6b7280'
    case 'prospect': return '#3b82f6'
    default: return '#6b7280'
  }
}
</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between flex-shrink-0">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Heatmap</h1>
        <p class="text-muted-foreground mt-1">Distribusi pelanggan berdasarkan lokasi geografi.</p>
      </div>

      <div class="flex items-center gap-3">
        <Card class="border">
          <CardContent class="flex items-center gap-4 py-2 px-4">
            <div class="flex items-center gap-2 text-sm">
              <Users class="w-4 h-4 text-primary" />
              <span class="font-bold">{{ stats.withCoords }}</span>
              <span class="text-muted-foreground">/ {{ stats.total }} di peta</span>
            </div>
            <Separator orientation="vertical" class="h-5" />
            <div class="flex items-center gap-3 text-xs">
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Aktif
              </span>
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded-full bg-blue-500"></span> Prospek
              </span>
              <span class="flex items-center gap-1">
                <span class="w-2 h-2 rounded-full bg-gray-500"></span> Non-Aktif
              </span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>

    <!-- Map -->
    <Card class="flex-1 overflow-hidden relative">
      <div v-if="!mapReady || store.loading"
           class="absolute inset-0 z-[1000] bg-background/80 backdrop-blur-sm flex flex-col items-center justify-center">
        <Loader2 class="w-10 h-10 animate-spin text-primary mb-4" />
        <p class="text-muted-foreground font-medium animate-pulse">Memuat Heatmap...</p>
      </div>

      <LMap
        v-if="mapReady"
        v-model:zoom="zoom"
        v-model:center="center"
        :use-global-leaflet="false"
        class="h-full w-full z-0"
      >
        <LTileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a>"
        />

        <LCircleMarker
          v-for="customer in customersWithCoords"
          :key="customer.id"
          :lat-lng="[customer.latitude!, customer.longitude!]"
          :radius="8"
          :fillColor="getStatusColor(customer.status)"
          :color="getStatusColor(customer.status)"
          :fillOpacity="0.6"
          :weight="2"
        >
          <LPopup :options="{ maxWidth: 250, closeButton: false, className: 'custom-popup' }">
            <div class="p-1 min-w-[180px]">
              <h4 class="font-bold text-sm">{{ customer.name }}</h4>
              <p class="text-xs text-gray-500 mt-1">{{ customer.email }}</p>
              <p class="text-xs text-gray-500">{{ customer.phone }}</p>
              <div class="mt-2 pt-2 border-t flex items-center gap-2">
                <span class="w-2 h-2 rounded-full" :style="{ backgroundColor: getStatusColor(customer.status) }"></span>
                <span class="text-xs capitalize font-medium">{{ customer.status }}</span>
              </div>
              <p v-if="customer.address" class="text-xs text-gray-400 mt-1 flex items-start gap-1">
                <MapPin class="w-3 h-3 mt-0.5 flex-shrink-0" />
                {{ customer.address }}
              </p>
            </div>
          </LPopup>
        </LCircleMarker>
      </LMap>
    </Card>
  </div>
</template>

<style>
.custom-popup .leaflet-popup-content-wrapper {
  border-radius: 0.75rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border: 1px solid hsl(var(--border));
  padding: 0;
}
.custom-popup .leaflet-popup-content { margin: 12px; }
.custom-popup .leaflet-popup-tip {
  background: hsl(var(--background));
  border-left: 1px solid hsl(var(--border));
  border-top: 1px solid hsl(var(--border));
}
.dark .custom-popup .leaflet-popup-content-wrapper { background: hsl(var(--card)); }
.dark .custom-popup .leaflet-popup-tip { background: hsl(var(--card)); }
</style>
