<script setup lang="ts">
import { onMounted, onUnmounted, ref, computed } from 'vue'
import { useTrackingStore } from '@/stores/tracking.store'
import { useTerritoryStore } from '@/stores/territories.store'
import { LMap, LTileLayer, LMarker, LPopup, LPolygon, LControl } from '@vue-leaflet/vue-leaflet'
import { Icon } from 'leaflet'
import { Loader2, Users, Battery, Navigation, Clock, Activity } from 'lucide-vue-next'
import 'leaflet/dist/leaflet.css'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'

const trackingStore = useTrackingStore()
const territoryStore = useTerritoryStore()

const zoom = ref(5)
const center = ref<[number, number]>([-2.5, 118.0])
const mapReady = ref(false)

// @ts-ignore
delete Icon.Default.prototype._getIconUrl
Icon.Default.mergeOptions({
  iconRetinaUrl: '/marker-icon-2x.png',
  iconUrl: '/marker-icon.png',
  shadowUrl: '/marker-shadow.png',
})

const activeSalesCount = computed(() =>
  (trackingStore.livePositions || []).filter(p => p.status === 'active').length
)

onMounted(async () => {
  Promise.all([
    territoryStore.fetchAll(),
    trackingStore.fetchLivePositions()
  ]).then(() => {
    mapReady.value = true
    if (trackingStore.livePositions && trackingStore.livePositions.length > 0) {
      const firstPos = trackingStore.livePositions[0]
      center.value = [firstPos.latitude, firstPos.longitude]
      zoom.value = 13
    }
    trackingStore.startPolling()
  })
})

onUnmounted(() => {
  trackingStore.stopPolling()
})
</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between flex-shrink-0">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Live Tracking</h1>
        <p class="text-muted-foreground mt-1">
          Monitoring pergerakan tim sales lapangan secara real-time.
        </p>
      </div>

      <Card class="border">
        <CardContent class="flex items-center gap-4 py-2 px-4">
          <div class="flex items-center gap-2">
            <div class="relative flex h-2.5 w-2.5">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
            </div>
            <Badge variant="secondary" class="text-[11px]">Live</Badge>
          </div>
          <Separator orientation="vertical" class="h-5" />
          <div class="flex items-center gap-2 text-sm">
            <span class="font-bold">{{ activeSalesCount }}</span>
            <span class="text-muted-foreground">/ {{ (trackingStore.livePositions || []).length || 0 }} Aktif</span>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Map Container -->
    <Card class="flex-1 overflow-hidden relative">
      <!-- Loading Overlay -->
      <div v-if="!mapReady"
           class="absolute inset-0 z-[1000] bg-background/80 backdrop-blur-sm flex flex-col items-center justify-center">
        <Loader2 class="w-10 h-10 animate-spin text-primary mb-4" />
        <p class="text-muted-foreground font-medium animate-pulse">Memuat Peta Geospatial...</p>
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
          attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors"
        />

        <!-- Live Sales Markers -->
        <LMarker
          v-for="pos in trackingStore.livePositions"
          :key="pos.sales_id"
          :lat-lng="[pos.latitude, pos.longitude]"
        >
          <LPopup :options="{ maxWidth: 300, closeButton: false, className: 'custom-popup' }">
            <div class="p-1 min-w-[200px]">
              <div class="flex items-center gap-3 mb-3 border-b pb-3">
                <div class="w-10 h-10 bg-primary/10 text-primary rounded-full flex items-center justify-center font-bold text-lg">
                  {{ pos.sales_name.charAt(0) }}
                </div>
                <div>
                  <h4 class="font-bold leading-tight">{{ pos.sales_name }}</h4>
                  <span class="inline-flex items-center rounded-md px-1.5 py-0.5 text-[10px] font-medium mt-1"
                        :class="pos.status === 'active'
                          ? 'bg-emerald-100 text-emerald-700'
                          : 'bg-muted text-muted-foreground'">
                    {{ pos.status === 'active' ? 'Sedang Bekerja' : 'Istirahat' }}
                  </span>
                </div>
              </div>

              <div class="space-y-2 text-sm">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2 text-muted-foreground"><Navigation class="w-3.5 h-3.5" /> Kecepatan</div>
                  <span class="font-medium font-mono">{{ pos.speed.toFixed(1) }} km/h</span>
                </div>
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2 text-muted-foreground"><Activity class="w-3.5 h-3.5" /> Akurasi GPS</div>
                  <span class="font-medium font-mono">±{{ pos.accuracy.toFixed(0) }}m</span>
                </div>
                <div class="flex items-center justify-between" v-if="pos.battery_level !== undefined">
                  <div class="flex items-center gap-2">
                    <Battery class="w-3.5 h-3.5" :class="pos.battery_level < 20 ? 'text-destructive' : 'text-muted-foreground'" /> Baterai
                  </div>
                  <span class="font-medium font-mono" :class="pos.battery_level < 20 ? 'text-destructive font-bold' : ''">
                    {{ (pos.battery_level * 100).toFixed(0) }}%
                  </span>
                </div>
                <div class="flex items-center justify-between pt-2 border-t mt-2 text-xs">
                  <div class="flex items-center gap-1.5 text-muted-foreground"><Clock class="w-3.5 h-3.5" /> Ping Terakhir</div>
                  <span class="text-muted-foreground">{{ new Date(pos.last_update).toLocaleTimeString('id-ID', { hour: '2-digit', minute:'2-digit', second:'2-digit' }) }}</span>
                </div>
              </div>
            </div>
          </LPopup>
        </LMarker>

        <LControl position="bottomleft" v-if="trackingStore.error">
          <Card class="border-destructive bg-destructive/10 mb-2 ml-2">
            <CardContent class="py-2 px-3 flex items-center gap-2 text-sm text-destructive">
              <Activity class="w-4 h-4 animate-pulse" />
              Koneksi terputus. Menunggu sambungan ulang...
            </CardContent>
          </Card>
        </LControl>
      </LMap>
    </Card>
  </div>
</template>

<style>
.custom-popup .leaflet-popup-content-wrapper {
  border-radius: 0.75rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid hsl(var(--border));
  padding: 0;
}
.custom-popup .leaflet-popup-content {
  margin: 12px;
}
.custom-popup .leaflet-popup-tip {
  background: hsl(var(--background));
  border-left: 1px solid hsl(var(--border));
  border-top: 1px solid hsl(var(--border));
}
.dark .custom-popup .leaflet-popup-content-wrapper {
  background: hsl(var(--card));
}
.dark .custom-popup .leaflet-popup-tip {
  background: hsl(var(--card));
}
</style>
