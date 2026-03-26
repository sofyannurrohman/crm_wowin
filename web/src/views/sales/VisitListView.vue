<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useVisitStore } from '@/stores/visits.store'
import { useRouter } from 'vue-router'
import { useDebounce } from '@vueuse/core'
import {
  Plus, Search, Loader2, Calendar, ChevronLeft, ChevronRight,
  MapPin, Clock, CheckCircle2, XCircle, AlertTriangle, Eye
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'

const store = useVisitStore()
const router = useRouter()

const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedStatus = ref<string>('all')
const page = ref(1)

const loadSchedules = () => {
  store.fetchAll({
    search: debouncedSearch.value,
    status: selectedStatus.value === 'all' ? undefined : selectedStatus.value,
    page: page.value,
    limit: 15
  })
}

watch([debouncedSearch, selectedStatus, page], () => {
  loadSchedules()
})

onMounted(() => {
  loadSchedules()
})

const goDetail = (id: string) => router.push(`/visits/${id}`)

const formatStatus = (status: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' | 'destructive', icon: any }> = {
    scheduled: { label: 'Terjadwal', variant: 'outline', icon: Clock },
    completed: { label: 'Selesai', variant: 'default', icon: CheckCircle2 },
    cancelled: { label: 'Dibatalkan', variant: 'destructive', icon: XCircle },
    missed: { label: 'Terlewat', variant: 'secondary', icon: AlertTriangle },
  }
  return map[status] || { label: status, variant: 'secondary' as const, icon: Clock }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Kunjungan</h1>
        <p class="text-muted-foreground mt-1">Jadwal dan log kunjungan tim sales lapangan.</p>
      </div>
      <Button size="sm">
        <Plus class="w-4 h-4 mr-2" />
        Jadwal Baru
      </Button>
    </div>

    <!-- Filters -->
    <Card>
      <CardContent class="pt-6">
        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div class="relative w-full max-w-sm">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input v-model="searchInput" class="pl-9" placeholder="Cari pelanggan, sales..." />
          </div>
          <Select v-model="selectedStatus">
            <SelectTrigger class="w-[160px]">
              <SelectValue placeholder="Semua Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Status</SelectItem>
              <SelectItem value="scheduled">Terjadwal</SelectItem>
              <SelectItem value="completed">Selesai</SelectItem>
              <SelectItem value="cancelled">Dibatalkan</SelectItem>
              <SelectItem value="missed">Terlewat</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardContent>
    </Card>

    <!-- Table -->
    <Card>
      <CardContent class="p-0">
        <div v-if="store.loading" class="flex justify-center items-center py-24">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>

        <div v-else-if="store.error" class="text-center py-24 px-6">
          <p class="text-destructive">{{ store.error }}</p>
        </div>

        <div v-else-if="store.schedules.length === 0" class="text-center py-24 px-6">
          <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
            <Calendar class="w-6 h-6 text-muted-foreground" />
          </div>
          <h3 class="text-sm font-semibold">Tidak ada jadwal kunjungan</h3>
          <p class="text-sm text-muted-foreground mt-1">Buat jadwal kunjungan baru untuk memulai.</p>
        </div>

        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[250px]">Kunjungan</TableHead>
              <TableHead>Pelanggan</TableHead>
              <TableHead>Sales</TableHead>
              <TableHead>Tanggal</TableHead>
              <TableHead>Status</TableHead>
              <TableHead class="text-right w-[80px]">Aksi</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="schedule in store.schedules" :key="schedule.id" class="cursor-pointer group" @click="goDetail(schedule.id)">
              <TableCell>
                <div>
                  <p class="font-medium">{{ schedule.title }}</p>
                  <p v-if="schedule.objective" class="text-xs text-muted-foreground line-clamp-1">{{ schedule.objective }}</p>
                </div>
              </TableCell>
              <TableCell>
                <div class="flex items-center gap-2">
                  <Avatar class="h-7 w-7">
                    <AvatarFallback class="text-[10px] bg-primary/10 text-primary font-semibold">
                      {{ (schedule.customer_name || 'C').charAt(0) }}
                    </AvatarFallback>
                  </Avatar>
                  <span class="text-sm">{{ schedule.customer_name || schedule.customer_id.slice(0, 8) }}</span>
                </div>
              </TableCell>
              <TableCell>
                <span class="text-sm">{{ schedule.sales_name || schedule.sales_id.slice(0, 8) }}</span>
              </TableCell>
              <TableCell>
                <div class="flex items-center gap-1.5 text-sm text-muted-foreground">
                  <Calendar class="w-3.5 h-3.5" />
                  {{ new Date(schedule.date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' }) }}
                </div>
              </TableCell>
              <TableCell>
                <Badge :variant="formatStatus(schedule.status).variant" class="gap-1">
                  <component :is="formatStatus(schedule.status).icon" class="w-3 h-3" />
                  {{ formatStatus(schedule.status).label }}
                </Badge>
              </TableCell>
              <TableCell class="text-right">
                <Button variant="ghost" size="icon" class="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity" @click.stop="goDetail(schedule.id)">
                  <Eye class="h-4 w-4" />
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>

      <div v-if="store.schedules.length > 0" class="flex items-center justify-between px-6 py-4 border-t">
        <p class="text-sm text-muted-foreground">Halaman {{ page }}</p>
        <div class="flex items-center gap-2">
          <Button variant="outline" size="icon" class="h-8 w-8" :disabled="page <= 1" @click="page--">
            <ChevronLeft class="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon" class="h-8 w-8" @click="page++">
            <ChevronRight class="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  </div>
</template>
