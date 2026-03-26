<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useTerritoryStore } from '@/stores/territories.store'
import LeafletMap from '@/components/map/LeafletMap.vue'
import { LGeoJson } from '@vue-leaflet/vue-leaflet'
import { Loader2, Plus, Map, Edit2, Trash2, Users } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Separator } from '@/components/ui/separator'

const store = useTerritoryStore()
const selectedTerritoryId = ref<string | null>(null)

onMounted(() => {
  store.fetchAll()
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
          Atur wilayah operasional sales untuk efisiensi rute dan target pencapaian.
        </p>
      </div>
      <Button size="sm">
        <Plus class="w-4 h-4 mr-2" />
        Gambar Wilayah Baru
      </Button>
    </div>

    <!-- Layout -->
    <div class="flex-1 grid grid-cols-1 lg:grid-cols-3 gap-6 min-h-0">
      <!-- Territory List -->
      <Card class="lg:col-span-1 flex flex-col overflow-hidden">
        <CardHeader class="flex-shrink-0 flex flex-row items-center gap-2 py-4 space-y-0">
          <Map class="w-4 h-4 text-muted-foreground" />
          <CardTitle class="text-sm">Daftar Wilayah</CardTitle>
          <Badge variant="secondary" class="ml-auto text-[11px]">
            {{ store.territories.length }} Total
          </Badge>
        </CardHeader>

        <Separator />

        <ScrollArea class="flex-1">
          <div class="p-2 space-y-1">
            <div v-if="store.loading" class="flex justify-center py-10">
              <Loader2 class="w-6 h-6 animate-spin text-muted-foreground" />
            </div>

            <div v-else-if="store.territories.length === 0" class="text-center py-10 px-4">
              <p class="text-sm text-muted-foreground">Belum ada wilayah yang digambar.</p>
            </div>

            <button
              v-for="t in store.territories"
              :key="t.id"
              @click="selectedTerritoryId = t.id"
              class="w-full text-left p-3 rounded-lg transition-all group focus:outline-none hover:bg-accent"
              :class="selectedTerritoryId === t.id
                ? 'bg-accent shadow-sm'
                : ''"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                  <span class="w-3 h-3 rounded-full shadow-sm ring-2 ring-background" :style="{ backgroundColor: t.color }"></span>
                  <span class="font-medium text-sm">{{ t.name }}</span>
                </div>
                <div class="opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-0.5">
                  <Button variant="ghost" size="icon" class="h-7 w-7">
                    <Edit2 class="w-3.5 h-3.5" />
                  </Button>
                  <Button variant="ghost" size="icon" class="h-7 w-7 text-destructive hover:text-destructive">
                    <Trash2 class="w-3.5 h-3.5" />
                  </Button>
                </div>
              </div>
              <div class="mt-1.5 flex items-center gap-4 text-[11px] text-muted-foreground">
                <span class="flex items-center gap-1"><Users class="w-3 h-3" /> {{ t.sales_count ?? 0 }} Sales</span>
                <span>{{ t.customer_count ?? 0 }} Pelanggan</span>
              </div>
            </button>
          </div>
        </ScrollArea>
      </Card>

      <!-- Map -->
      <Card class="lg:col-span-2 overflow-hidden relative">
        <LeafletMap>
          <template v-for="t in store.territories" :key="'geo-'+t.id">
            <LGeoJson
              :geojson="t.geojson"
              :options-style="() => getTerritoryStyle(t)"
            />
          </template>
        </LeafletMap>
      </Card>
    </div>
  </div>
</template>
