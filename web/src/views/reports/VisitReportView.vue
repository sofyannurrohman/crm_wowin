<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { fetchAnalytics } from '@/api/reports.api'
import { Loader2, RefreshCw, MapPin, CheckCircle2, XCircle, Clock } from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'

const loading = ref(false)
const performers = ref<any[]>([])

async function loadData() {
  loading.value = true
  try {
    const res = await fetchAnalytics(6)
    performers.value = res.data.data.top_performers || []
  } catch (e) {
    console.error('Failed to load visit report', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())

const totalVisits = computed(() => performers.value.reduce((sum, p) => sum + (p.total_visits || 0), 0))
const totalValid = computed(() => performers.value.reduce((sum, p) => sum + (p.valid_checkins || 0), 0))
const validRate = computed(() => totalVisits.value > 0 ? ((totalValid.value / totalVisits.value) * 100).toFixed(1) : '0')
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Visit Report</h1>
        <p class="text-muted-foreground mt-1">Analisis kunjungan lapangan dan aktivitas sales.</p>
      </div>
      <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
        <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
        Refresh
      </Button>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Kunjungan</CardTitle>
          <MapPin class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ totalVisits.toLocaleString('id-ID') }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Check-in Valid</CardTitle>
          <CheckCircle2 class="h-4 w-4 text-emerald-500" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ totalValid.toLocaleString('id-ID') }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Tingkat Validitas</CardTitle>
          <CheckCircle2 class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ validRate }}%</div>
        </CardContent>
      </Card>
    </div>

    <!-- Per-Sales Breakdown Table -->
    <Card>
      <CardHeader>
        <CardTitle class="text-base">Breakdown per Sales</CardTitle>
        <CardDescription>Detail kunjungan setiap anggota tim sales</CardDescription>
      </CardHeader>
      <CardContent class="p-0">
        <div v-if="loading" class="flex justify-center py-16">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[50px]">#</TableHead>
              <TableHead>Sales</TableHead>
              <TableHead class="text-center">Total Visit</TableHead>
              <TableHead class="text-center">Valid Check-in</TableHead>
              <TableHead class="text-center">Validitas</TableHead>
              <TableHead class="text-right">Revenue</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="(sales, i) in performers" :key="sales.sales_id">
              <TableCell class="font-medium text-muted-foreground">{{ i + 1 }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-3">
                  <Avatar class="h-8 w-8">
                    <AvatarFallback class="text-xs bg-primary/10 text-primary font-semibold">
                      {{ sales.sales_name.charAt(0) }}
                    </AvatarFallback>
                  </Avatar>
                  <span class="font-medium">{{ sales.sales_name }}</span>
                </div>
              </TableCell>
              <TableCell class="text-center font-mono">{{ sales.total_visits }}</TableCell>
              <TableCell class="text-center font-mono">{{ sales.valid_checkins }}</TableCell>
              <TableCell class="text-center">
                <Badge :variant="(sales.valid_checkins / Math.max(sales.total_visits, 1)) > 0.8 ? 'default' : 'secondary'">
                  {{ ((sales.valid_checkins / Math.max(sales.total_visits, 1)) * 100).toFixed(0) }}%
                </Badge>
              </TableCell>
              <TableCell class="text-right font-mono text-sm">
                {{ new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(sales.revenue) }}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  </div>
</template>
