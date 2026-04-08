<script setup lang="ts">
import { onMounted, onUnmounted, ref, computed, watch } from 'vue'
import { useTrackingStore } from '@/stores/tracking.store'
import { useTerritoryStore } from '@/stores/territories.store'
import { fetchTasks, type Task } from '@/api/tasks.api'
import { LMap, LTileLayer, LMarker, LPopup, LControl, LPolyline, LTooltip } from '@vue-leaflet/vue-leaflet'
import { Icon, LatLng } from 'leaflet'
import { Loader2, Users, Battery, Navigation, Clock, Activity, MapPin, Truck } from 'lucide-vue-next'
import 'leaflet/dist/leaflet.css'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

import { fetchUsers } from '@/api/auth.api'
import { fetchCustomers } from '@/api/customers.api'
import { warehouseApi, type Warehouse } from '@/api/warehouses.api'

const trackingStore = useTrackingStore()
const territoryStore = useTerritoryStore()
const todaysTasks = ref<Task[]>([])

const mapReady = ref(false)
const zoom = ref(5)
const center = ref<[number, number]>([-2.5, 118.0])

// Data stores for the route mapping
const salesmen = ref<any[]>([])
const allWarehouses = ref<Warehouse[]>([])
const allCustomers = ref<any[]>([])

const selectedSalesmanId = ref<string | undefined>(undefined)

const polylinePoints = ref<[number, number][]>([])
const taskMarkers = ref<any[]>([])
const warehousePoint = ref<[number, number] | null>(null)

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

const isFocusMode = computed(() => selectedSalesmanId.value && selectedSalesmanId.value !== 'all')

const selectedSalesmanLivePos = computed(() => {
  if (!isFocusMode.value) return null
  return trackingStore.livePositions?.find(p => p.sales_id === selectedSalesmanId.value)
})

onMounted(async () => {
  // Fetch initial base data
  try {
    const [usersRes, customersRes, warehouses] = await Promise.all([
      fetchUsers(),
      fetchCustomers({ limit: 10000 }),
      warehouseApi.list()
    ])
    
    // Assuming backend returns an array of users inside data.data or just data
    const usersList = Array.isArray(usersRes.data) ? usersRes.data : (usersRes.data as any).data || []
    salesmen.value = usersList.filter((u: any) => u.role === 'sales')
    
    // Customers
    allCustomers.value = Array.isArray(customersRes.data) 
        ? customersRes.data 
        : (customersRes.data as any).data || []
        
    allWarehouses.value = warehouses

    if (warehouses.length > 0) {
      warehousePoint.value = [warehouses[0].latitude, warehouses[0].longitude]
      center.value = warehousePoint.value
      zoom.value = 12
    }
  } catch (error) {
    console.error("Failed fetching base data for live tracking", error)
  }

  Promise.all([
    territoryStore.fetchAll(),
    trackingStore.fetchLivePositions()
  ]).then(() => {
    mapReady.value = true
    if (!warehousePoint.value && trackingStore.livePositions && trackingStore.livePositions.length > 0) {
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

// Watch for salesman selection to compute route
watch(selectedSalesmanId, async (newVal) => {
  if (!newVal || newVal === 'all') {
    polylinePoints.value = []
    taskMarkers.value = []
    return
  }

  await fetchSalesTasks(newVal)
  computeRoute(true)
})

watch(() => trackingStore.livePositions, async () => {
  if (isFocusMode.value && selectedSalesmanId.value) {
    await fetchSalesTasks(selectedSalesmanId.value)
    computeRoute(false)
  }
}, { deep: true })

const fetchSalesTasks = async (salesId: string) => {
  try {
    const res = await fetchTasks({ sales_id: salesId })
    if (res.data.data) {
      // Filter incomplete tasks
      todaysTasks.value = res.data.data.filter(t => t.status !== 'done' && t.status !== 'cancelled')
    } else {
      todaysTasks.value = []
    }
  } catch(e) {
    console.error("Failed to load tasks", e)
    todaysTasks.value = []
  }
}

const computeRoute = (shouldRecenter: boolean = false) => {
  let unvisitedNodes: any[] = []
  
  todaysTasks.value.forEach(task => {
    if (task.destinations && task.destinations.length > 0) {
      task.destinations.forEach(dest => {
        if (dest.status !== 'done' && dest.status !== 'cancelled') {
           unvisitedNodes.push({
             task,
             dest,
             lat: typeof dest.target_latitude === 'string' ? parseFloat(dest.target_latitude) : dest.target_latitude,
             lng: typeof dest.target_longitude === 'string' ? parseFloat(dest.target_longitude) : dest.target_longitude
           })
        }
      })
    }
  })

  // Safely parse out any misconfigured coordinates
  unvisitedNodes = unvisitedNodes.filter(n => n.lat !== undefined && n.lng !== undefined && n.lat !== null && n.lng !== null && !isNaN(n.lat) && !isNaN(n.lng))

  // Nearest Neighbor Algorithm
  const sortedTasks = []
  
  // Start from chosen salesman's live location if available, otherwise warehouse, else standard center
  let currentPos = new LatLng(center.value[0], center.value[1])
  if (selectedSalesmanLivePos.value) {
    currentPos = new LatLng(selectedSalesmanLivePos.value.latitude, selectedSalesmanLivePos.value.longitude)
  } else if (warehousePoint.value) {
    currentPos = new LatLng(warehousePoint.value[0], warehousePoint.value[1])
  } else if (unvisitedNodes.length > 0) {
    currentPos = new LatLng(unvisitedNodes[0].lat, unvisitedNodes[0].lng)
  }
  
  while (unvisitedNodes.length > 0) {
    let closestIdx = 0
    let minDistance = Infinity
    for (let i = 0; i < unvisitedNodes.length; i++) {
       const node = unvisitedNodes[i]
       const dist = currentPos.distanceTo(new LatLng(node.lat, node.lng))
       if (dist < minDistance) {
         minDistance = dist
         closestIdx = i
       }
    }
    
    const closestNode = unvisitedNodes[closestIdx]
    sortedTasks.push({
       ...closestNode,
       order: sortedTasks.length + 1
    })
    currentPos = new LatLng(closestNode.lat, closestNode.lng)
    
    unvisitedNodes.splice(closestIdx, 1)
  }

  // Generate Polyline structure from starting point to scheduled destinations
  const points: [number, number][] = []
  if (selectedSalesmanLivePos.value) {
    points.push([selectedSalesmanLivePos.value.latitude, selectedSalesmanLivePos.value.longitude])
  } else if (warehousePoint.value) {
    points.push(warehousePoint.value)
  }
  
  for (const t of sortedTasks) {
    points.push([t.lat, t.lng])
  }
  
  polylinePoints.value = points
  taskMarkers.value = sortedTasks

  if (shouldRecenter && points.length > 0) {
     center.value = points[0]
     zoom.value = 13
  }
}

</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between flex-shrink-0">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Live Tracking</h1>
        <p class="text-muted-foreground mt-1">
          Monitoring pergerakan dan rute kunjungan tim sales secara real-time.
        </p>
      </div>

      <div class="flex items-center gap-4">
        <!-- Salesman Filter Dropdown -->
        <Select v-model="selectedSalesmanId">
          <SelectTrigger class="w-[280px]">
            <SelectValue placeholder="Semua Salesman (Overview Mode)" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectItem value="all">
                <span class="font-medium text-foreground">Semua Salesman</span>
              </SelectItem>
              <SelectLabel>Pilih Salesman</SelectLabel>
              <SelectItem v-for="user in salesmen" :key="user.id" :value="user.id">
                <div class="flex items-center gap-2">
                  <div class="w-6 h-6 bg-primary/10 text-primary rounded-full flex items-center justify-center text-[10px] font-bold">
                    {{ user.name.charAt(0) }}
                  </div>
                  {{ user.name }}
                </div>
              </SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>

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

        <!-- Always show Warehouse if fetched -->
        <LMarker v-if="warehousePoint" :lat-lng="warehousePoint">
          <LTooltip direction="top" :permanent="true" class="font-bold custom-tooltip border-primary">
            Gudang Sentral
          </LTooltip>
        </LMarker>

        <!-- Focus Mode: Show specific salesman's daily routing and precise location -->
        <template v-if="isFocusMode">
          <!-- Route Polyline -->
          <LPolyline 
            :lat-lngs="polylinePoints" 
            color="#3b82f6" 
            :weight="4" 
            :opacity="0.8" 
            dashArray="10, 10" 
          />

          <!-- Scheduled Tasks / Destinations -->
          <LMarker
            v-for="task in taskMarkers"
            :key="task.dest.id"
            :lat-lng="[task.lat, task.lng]"
          >
            <LTooltip direction="bottom" :permanent="true" class="font-bold text-lg text-primary custom-tooltip">
              #{{ task.order }}
            </LTooltip>
            <LPopup :options="{ maxWidth: 350, closeButton: false, className: 'custom-popup' }">
               <div class="p-1 min-w-[200px]">
                 <div class="flex items-center gap-3 mb-2 border-b pb-2">
                   <div class="w-10 h-10 bg-blue-100 text-blue-700 rounded-full flex items-center justify-center">
                     <MapPin class="w-5 h-5" />
                   </div>
                   <div>
                     <h4 class="font-bold leading-tight">{{ task.dest.target_name || 'Pelanggan' }}</h4>
                     <p class="text-xs text-muted-foreground mt-0.5 max-w-[200px] truncate">{{ task.dest.target_address || 'Tidak ada alamat' }}</p>
                   </div>
                 </div>
                 <div class="space-y-1">
                   <p class="text-sm font-medium">{{ task.task.title }}</p>
                   <p class="text-xs text-muted-foreground line-clamp-2" v-if="task.task.description">{{ task.task.description }}</p>
                   <div class="pt-2">
                     <Badge :variant="task.dest.status === 'done' ? 'default' : 'secondary'">
                       {{ task.dest.status.toUpperCase() }}
                     </Badge>
                   </div>
                 </div>
               </div>
            </LPopup>
          </LMarker>

          <!-- Focus Salesman Live Location -->
          <LMarker
            v-if="selectedSalesmanLivePos"
            :lat-lng="[selectedSalesmanLivePos.latitude, selectedSalesmanLivePos.longitude]"
          >
            <LTooltip direction="top" :permanent="true" class="bg-emerald-500 text-white font-bold custom-tooltip border-none">
              Posisi Sales Saat Ini
            </LTooltip>
            <LPopup :options="{ maxWidth: 300, closeButton: false, className: 'custom-popup' }">
              <div class="p-1 min-w-[200px]">
                <div class="flex items-center gap-3 mb-3 border-b pb-3">
                  <div class="w-10 h-10 bg-primary/10 text-primary rounded-full flex items-center justify-center font-bold text-lg">
                    {{ selectedSalesmanLivePos.sales_name.charAt(0) }}
                  </div>
                  <div>
                    <h4 class="font-bold leading-tight">{{ selectedSalesmanLivePos.sales_name }}</h4>
                    <span class="inline-flex items-center rounded-md px-1.5 py-0.5 text-[10px] font-medium mt-1"
                          :class="selectedSalesmanLivePos.status === 'active'
                            ? 'bg-emerald-100 text-emerald-700'
                            : 'bg-muted text-muted-foreground'">
                      {{ selectedSalesmanLivePos.status === 'active' ? 'Sedang Bekerja' : 'Istirahat' }}
                    </span>
                  </div>
                </div>

                <div class="space-y-2 text-sm">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2 text-muted-foreground"><Navigation class="w-3.5 h-3.5" /> Kecepatan</div>
                    <span class="font-medium font-mono">{{ selectedSalesmanLivePos.speed.toFixed(1) }} km/h</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <div class="flex items-center gap-2 text-muted-foreground"><Activity class="w-3.5 h-3.5" /> Akurasi GPS</div>
                    <span class="font-medium font-mono">±{{ selectedSalesmanLivePos.accuracy.toFixed(0) }}m</span>
                  </div>
                  <div class="flex items-center justify-between pt-2 border-t mt-2 text-xs">
                    <div class="flex items-center gap-1.5 text-muted-foreground"><Clock class="w-3.5 h-3.5" /> Ping Terakhir</div>
                    <span class="text-muted-foreground">{{ new Date(selectedSalesmanLivePos.last_update).toLocaleTimeString('id-ID', { hour: '2-digit', minute:'2-digit', second:'2-digit' }) }}</span>
                  </div>
                </div>
              </div>
            </LPopup>
          </LMarker>
        </template>

        <!-- General Overview Mode: Show all active salesmen -->
        <template v-else>
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
        </template>

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
.custom-tooltip {
  background: hsl(var(--background));
  color: hsl(var(--foreground));
  border: 1px solid hsl(var(--border));
  border-radius: 0.5rem;
  padding: 0.25rem 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}
.dark .custom-tooltip {
  background: hsl(var(--card));
}
</style>
