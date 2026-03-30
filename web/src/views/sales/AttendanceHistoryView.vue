<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { fetchAttendanceHistory, type DailyAttendance } from '@/api/attendance.api'
import {
  Loader2, Calendar as CalendarIcon, Clock, MapPin, Search,
  ChevronLeft, ChevronRight, User as UserIcon, Timer
} from 'lucide-vue-next'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'

const loading = ref(false)
const history = ref<DailyAttendance[]>([])
const date = new Date()
const selectedMonth = ref((date.getMonth() + 1).toString())
const selectedYear = ref(date.getFullYear().toString())

const months = [
  { value: '1', label: 'Januari' }, { value: '2', label: 'Februari' },
  { value: '3', label: 'Maret' }, { value: '4', label: 'April' },
  { value: '5', label: 'Mei' }, { value: '6', label: 'Juni' },
  { value: '7', label: 'Juli' }, { value: '8', label: 'Agustus' },
  { value: '9', label: 'September' }, { value: '10', label: 'Oktober' },
  { value: '11', label: 'November' }, { value: '12', label: 'Desember' }
]

const years = ['2024', '2025', '2026']

async function loadData() {
  loading.value = true
  try {
    const res = await fetchAttendanceHistory(parseInt(selectedMonth.value), parseInt(selectedYear.value))
    history.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load attendance history', e)
  } finally {
    loading.value = false
  }
}

onMounted(loadData)
watch([selectedMonth, selectedYear], loadData)

const formatTime = (dateStr: string | null) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
}

const getStatusColor = (hours: number) => {
  if (hours >= 8) return 'text-emerald-600 bg-emerald-500/10'
  if (hours > 0) return 'text-amber-600 bg-amber-500/10'
  return 'text-red-600 bg-red-500/10'
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Presensi Tim</h1>
        <p class="text-muted-foreground mt-1">Monitoring kehadiran dan jam kerja sales di lapangan.</p>
      </div>
      <div class="flex items-center gap-2">
        <Select v-model="selectedMonth">
          <SelectTrigger class="w-[140px]">
            <SelectValue placeholder="Bulan" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem v-for="m in months" :key="m.value" :value="m.value">{{ m.label }}</SelectItem>
          </SelectContent>
        </Select>
        <Select v-model="selectedYear">
          <SelectTrigger class="w-[100px]">
            <SelectValue placeholder="Tahun" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem v-for="y in years" :key="y" :value="y">{{ y }}</SelectItem>
          </SelectContent>
        </Select>
        <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
          <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
          <CalendarIcon v-else class="w-4 h-4 mr-2" />
          Refresh
        </Button>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <Card>
        <CardHeader class="pb-2">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Hari Kerja</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ history.length }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="pb-2">
          <CardTitle class="text-sm font-medium text-muted-foreground">Rata-rata Jam Kerja</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">
            {{ (history.reduce((sum, h) => sum + h.work_hours, 0) / Math.max(history.length, 1)).toFixed(1) }}j
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="pb-2">
          <CardTitle class="text-sm font-medium text-muted-foreground">Presensi Sempurna</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-emerald-600">{{ history.filter(h => h.work_hours >= 8).length }}</div>
        </CardContent>
      </Card>
    </div>

    <Card>
      <CardHeader>
        <CardTitle class="text-base">Log Kehadiran Bulanan</CardTitle>
        <CardDescription>Detail clock-in dan clock-out harian tim sales.</CardDescription>
      </CardHeader>
      <CardContent class="p-0">
        <div v-if="loading" class="flex justify-center py-16">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <div v-else-if="history.length === 0" class="text-center py-16">
          <Timer class="mx-auto h-12 w-12 text-muted-foreground/50 mb-4" />
          <p class="text-muted-foreground">Belum ada data presensi untuk periode ini.</p>
        </div>
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead>Tanggal</TableHead>
              <TableHead>Sales</TableHead>
              <TableHead class="text-center">Clock In</TableHead>
              <TableHead class="text-center">Clock Out</TableHead>
              <TableHead class="text-center">Total Jam</TableHead>
              <TableHead class="text-right">Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="record in history" :key="record.user_id + record.work_date">
              <TableCell class="font-medium">{{ formatDate(record.work_date) }}</TableCell>
              <TableCell>
                 <div class="flex items-center gap-2">
                  <Avatar class="h-6 w-6">
                    <AvatarFallback class="text-[10px]">{{ record.user_id.slice(0, 2).toUpperCase() }}</AvatarFallback>
                  </Avatar>
                  <span class="text-sm font-medium">User {{ record.user_id.slice(0, 4) }}</span>
                </div>
              </TableCell>
              <TableCell class="text-center font-mono text-sm leading-none">
                <div class="flex flex-col items-center">
                  <span :class="record.clock_in ? 'text-foreground' : 'text-muted-foreground'">{{ formatTime(record.clock_in) }}</span>
                  <span v-if="record.clock_in" class="text-[10px] text-muted-foreground mt-1 flex items-center gap-0.5">
                    <MapPin class="w-2.5 h-2.5" /> GPS Verified
                  </span>
                </div>
              </TableCell>
              <TableCell class="text-center font-mono text-sm leading-none">
                <div class="flex flex-col items-center">
                  <span :class="record.clock_out ? 'text-foreground' : 'text-muted-foreground'">{{ formatTime(record.clock_out) }}</span>
                </div>
              </TableCell>
              <TableCell class="text-center">
                <Badge variant="outline" class="font-mono">{{ record.work_hours.toFixed(1) }}j</Badge>
              </TableCell>
              <TableCell class="text-right">
                <div class="inline-flex items-center px-2 py-1 rounded-md text-[11px] font-bold uppercase tracking-wider"
                     :class="getStatusColor(record.work_hours)">
                  {{ record.work_hours >= 8 ? 'Lengkap' : (record.work_hours > 0 ? 'Setengah Hari' : 'Mangkir') }}
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  </div>
</template>
