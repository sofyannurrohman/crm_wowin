<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchKpiSummary, fetchAnalytics, type KpiSummary } from '@/api/reports.api'
import {
  Users, Target, CircleDollarSign, Compass, ArrowUpRight,
  Loader2, RefreshCw, TrendingUp, Award
} from 'lucide-vue-next'
import LineChart from '@/components/charts/LineChart.vue'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'

const kpi = ref<KpiSummary | null>(null)
const topPerformers = ref<any[]>([])
const trendData = ref<any[]>([])
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const [kpiRes, analyticsRes] = await Promise.all([
      fetchKpiSummary(),
      fetchAnalytics(6)
    ])
    kpi.value = kpiRes.data.data
    topPerformers.value = analyticsRes.data.data.top_performers || []
    trendData.value = analyticsRes.data.data.revenue_trend || []
  } catch (e) {
    console.error('Failed to fetch KPI data', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())

const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">KPI Report</h1>
        <p class="text-muted-foreground mt-1">Laporan pencapaian indikator kinerja utama tim sales.</p>
      </div>
      <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
        <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
        Refresh
      </Button>
    </div>

    <!-- KPI Summary Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card v-for="(metric, i) in [
        { label: 'Total Pelanggan', value: kpi?.total_customers, icon: Users, color: 'text-blue-600 bg-blue-500/10' },
        { label: 'Pipeline Value', value: kpi?.pipeline_value, icon: CircleDollarSign, color: 'text-emerald-600 bg-emerald-500/10', currency: true },
        { label: 'Win Rate', value: kpi?.win_rate, icon: Target, color: 'text-amber-600 bg-amber-500/10', suffix: '%' },
        { label: 'Kunjungan Hari Ini', value: kpi?.total_visits_today, icon: Compass, color: 'text-violet-600 bg-violet-500/10' },
      ]" :key="i">
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">{{ metric.label }}</CardTitle>
          <div class="h-9 w-9 rounded-lg flex items-center justify-center" :class="metric.color">
            <component :is="metric.icon" class="h-4 w-4" />
          </div>
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-2xl font-bold tracking-tight">
            {{ metric.currency ? formatCurrency(metric.value ?? 0) : (metric.value?.toLocaleString('id-ID') ?? '0') }}{{ metric.suffix || '' }}
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Charts + Table -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Revenue Trend -->
      <Card class="lg:col-span-2">
        <CardHeader>
          <div class="flex items-center gap-2">
            <TrendingUp class="w-4 h-4 text-muted-foreground" />
            <CardTitle class="text-base">Tren Pendapatan</CardTitle>
          </div>
          <CardDescription>Proyeksi revenue per bulan</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="h-[300px] flex items-center justify-center">
            <Loader2 v-if="loading" class="w-8 h-8 animate-spin text-muted-foreground" />
            <LineChart v-else :data="trendData" color="#3B82F6" />
          </div>
        </CardContent>
      </Card>

      <!-- Top Performers -->
      <Card>
        <CardHeader>
          <div class="flex items-center gap-2">
            <Award class="w-4 h-4 text-muted-foreground" />
            <CardTitle class="text-base">Top Performers</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <div class="space-y-3">
            <div v-for="(sales, i) in topPerformers.slice(0, 5)" :key="sales.sales_id"
                 class="flex items-center gap-3">
              <span class="text-xs font-bold text-muted-foreground w-5">{{ i + 1 }}</span>
              <Avatar class="h-8 w-8">
                <AvatarFallback class="text-xs" :class="i === 0 ? 'bg-amber-100 text-amber-700' : 'bg-primary/10 text-primary'">
                  {{ sales.sales_name.charAt(0) }}
                </AvatarFallback>
              </Avatar>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium truncate">{{ sales.sales_name }}</p>
                <p class="text-xs text-muted-foreground">{{ sales.total_visits }} kunjungan</p>
              </div>
              <Badge variant="outline" class="text-[11px] font-mono">
                {{ (sales.revenue / 1000000).toFixed(1) }}Jt
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
