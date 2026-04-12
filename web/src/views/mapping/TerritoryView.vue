<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useTerritoryStore } from '@/stores/territories.store'
import { useCustomerStore } from '@/stores/customers.store'
import LeafletMap from '@/components/map/LeafletMap.vue'
import { LGeoJson, LMarker, LTooltip } from '@vue-leaflet/vue-leaflet'
import { Loader2, Plus, Map, Edit2, Trash2, Users, Building2, User } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Separator } from '@/components/ui/separator'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

const store = useTerritoryStore()
const customerStore = useCustomerStore()
const selectedTerritoryId = ref<string | null>(null)
const mapCenter = ref<[number, number]>([-7.5666, 110.8167]) // Default to Surakarta/Solo area
const mapZoom = ref(11)

onMounted(async () => {
  await store.fetchWarehouses()
  // Default to first warehouse if available
  if (store.warehouses.length > 0) {
    store.selectedWarehouseId = store.warehouses[0].id
    handleWarehouseChange(store.selectedWarehouseId)
  } else {
    store.fetchAll()
    customerStore.fetchAll()
  }
})

const handleWarehouseChange = (id: any) => {
  const warehouse = store.warehouses.find(w => w.id === id)
  if (warehouse && warehouse.latitude && warehouse.longitude) {
    mapCenter.value = [warehouse.latitude, warehouse.longitude]
    mapZoom.value = 12
  }
  store.fetchAll(id)
  // For now, load all customers and we can filter them client-side if needed, 
  // or add warehouse_id filter to customer API later.
  customerStore.fetchAll() 
}

// Filter customers by selected territory or just show all in branch
const filteredCustomers = computed(() => {
  if (!selectedTerritoryId.value) return customerStore.customers
  return customerStore.customers.filter(c => c.territory_id === selectedTerritoryId.value)
})

const getTerritoryStyle = (t: any) => ({
  color: t.color,
  weight: selectedTerritoryId.value === t.id ? 3 : 1,
  opacity: selectedTerritoryId.value === t.id ? 1 : 0.5,
  fillOpacity: selectedTerritoryId.value === t.id ? 0.3 : 0.1,
  fillColor: t.color
})
</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 flex-shrink-0">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Manajemen Territory</h1>
        <p class="text-muted-foreground mt-1">
          Atur wilayah operasional sales untuk tiap cabang PT Wowin.
        </p>
      </div>
      <div class="flex items-center gap-3">
        <div class="flex items-center gap-2 bg-background border rounded-lg px-3 py-1 shadow-sm">
          <Building2 class="w-4 h-4 text-muted-foreground" />
          <Select v-model="store.selectedWarehouseId" @update:model-value="handleWarehouseChange">
            <SelectTrigger class="w-[200px] border-none shadow-none focus:ring-0 h-8">
              <SelectValue placeholder="Pilih Cabang" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="w in store.warehouses" :key="w.id" :value="w.id">
                {{ w.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        <Button size="sm">
          <Plus class="w-4 h-4 mr-2" />
          Wilayah Baru
        </Button>
      </div>
    </div>

    <!-- Layout -->
    <div class="flex-1 grid grid-cols-1 lg:grid-cols-3 gap-6 min-h-0">
      <!-- Territory List -->
      <Card class="lg:col-span-1 flex flex-col overflow-hidden">
        <CardHeader class="flex-shrink-0 flex flex-row items-center gap-2 py-4 space-y-0">
          <Map class="w-4 h-4 text-muted-foreground" />
          <CardTitle class="text-sm font-semibold">Wilayah di Cabang Ini</CardTitle>
          <Badge variant="secondary" class="ml-auto text-[11px] font-medium px-2 py-0">
            {{ store.territories.length }}
          </Badge>
        </CardHeader>

        <Separator />

        <ScrollArea class="flex-1">
          <div class="p-2 space-y-1">
            <div v-if="store.loading" class="flex justify-center py-10">
              <Loader2 class="w-6 h-6 animate-spin text-muted-foreground" />
            </div>

            <div v-else-if="store.territories.length === 0" class="text-center py-10 px-4">
              <p class="text-sm text-muted-foreground">Belum ada wilayah untuk cabang ini.</p>
            </div>

            <button
              v-for="t in store.territories"
              :key="t.id"
              @click="selectedTerritoryId = selectedTerritoryId === t.id ? null : t.id"
              class="w-full text-left p-3 rounded-lg transition-all group focus:outline-none hover:bg-accent/50"
              :class="selectedTerritoryId === t.id
                ? 'bg-accent shadow-sm border border-accent-foreground/10'
                : 'border border-transparent'"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                  <div 
                    class="w-4 h-4 rounded-md shadow-sm ring-2 ring-offset-1 ring-background" 
                    :style="{ backgroundColor: t.color, '--tw-ring-color': t.color }"
                  ></div>
                  <span class="font-semibold text-sm">{{ t.name }}</span>
                </div>
                <div class="opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-0.5">
                  <Button variant="ghost" size="icon" class="h-8 w-8 rounded-full">
                    <Edit2 class="w-3.5 h-3.5" />
                  </Button>
                  <Button variant="ghost" size="icon" class="h-8 w-8 rounded-full text-destructive hover:text-destructive hover:bg-destructive/10">
                    <Trash2 class="w-3.5 h-3.5" />
                  </Button>
                </div>
              </div>
              <div class="mt-2 flex items-center gap-4 text-[11px] text-muted-foreground font-medium">
                <span class="flex items-center gap-1"><Users class="w-3.5 h-3.5" /> {{ t.sales_count ?? 0 }} Sales</span>
                <span class="flex items-center gap-1"><User class="w-3.5 h-3.5" /> {{ t.customer_count ?? 0 }} Pelanggan</span>
              </div>
            </button>
          </div>
        </ScrollArea>
      </Card>

      <!-- Map -->
      <Card class="lg:col-span-2 overflow-hidden relative shadow-md ring-1 ring-accent/10">
        <LeafletMap :center="mapCenter" :zoom="mapZoom">
          <!-- Territory Polygons -->
          <template v-for="t in store.territories" :key="'geo-'+t.id">
            <LGeoJson
              :geojson="t.geojson"
              :options-style="() => getTerritoryStyle(t)"
            />
          </template>

          <!-- Customer Markers -->
          <template v-for="c in filteredCustomers" :key="'cust-'+c.id">
            <LMarker v-if="c.latitude && c.longitude" :lat-lng="[c.latitude, c.longitude]">
              <LTooltip>
                <div class="p-1">
                  <p class="font-bold text-sm">{{ c.name }}</p>
                  <p class="text-[10px] text-muted-foreground">{{ c.address }}</p>
                  <Badge variant="outline" class="mt-1 text-[9px] h-4">{{ c.type }}</Badge>
                </div>
              </LTooltip>
            </LMarker>
          </template>
        </LeafletMap>
      </Card>
    </div>
  </div>
</template>
