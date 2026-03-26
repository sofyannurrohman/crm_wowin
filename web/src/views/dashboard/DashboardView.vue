<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth.store'
import { fetchKpiSummary, fetchAnalytics, type KpiSummary, type ChartSeriesData } from '@/api/reports.api'
import { Users, Target, CircleDollarSign, Compass, ArrowUpRight, Loader2, RefreshCw, TrendingUp } from 'lucide-vue-next'
import LineChart from '@/components/charts/LineChart.vue'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'

const auth = useAuthStore()

const kpi = ref<KpiSummary | null>(null)
const trendData = ref<ChartSeriesData[]>([])
const topPerformers = ref<any[]>([])
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const [kpiRes, analyticsRes] = await Promise.all([
      fetchKpiSummary(),
      fetchAnalytics(6)
    ])
    kpi.value = kpiRes.data.data
    trendData.value = analyticsRes.data.data.revenue_trend
    topPerformers.value = analyticsRes.data.data.top_performers
  } catch (e) {
    console.error('Failed fetching dashboard data', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})

const formatCurrency = (val: number) => {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}
</script>

<template>
  <div class="space-y-8">
    <!-- Page Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">
          Selamat datang, {{ auth.user?.name || 'User' }}
        </h1>
        <p class="text-muted-foreground mt-1">
          Ringkasan eksekutif Wowin CRM Analytics Anda hari ini.
        </p>
      </div>
      <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
        <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
        Refresh
      </Button>
    </div>

    <!-- KPI Metric Cards -->
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <!-- Total Customers -->
      <Card class="hover:shadow-md transition-shadow group">
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">
            Total Pelanggan Aktif
          </CardTitle>
          <div class="h-9 w-9 rounded-lg bg-blue-500/10 flex items-center justify-center text-blue-600 dark:text-blue-400 group-hover:bg-blue-500/20 transition-colors">
            <Users class="h-4 w-4" />
          </div>
        </CardHeader>
        <CardContent>
          <div class="flex items-baseline gap-2">
            <div class="text-3xl font-bold tracking-tight">
              <Loader2 v-if="loading" class="w-7 h-7 animate-spin text-muted-foreground" />
              <span v-else>{{ kpi?.total_customers.toLocaleString('id-ID') }}</span>
            </div>
            <Badge variant="secondary" class="text-green-700 dark:text-green-400 bg-green-50 dark:bg-green-900/30 border-0 text-[11px]">
              <ArrowUpRight class="w-3 h-3 mr-0.5" /> 12%
            </Badge>
          </div>
        </CardContent>
      </Card>

      <!-- Pipeline Value -->
      <Card class="hover:shadow-md transition-shadow group">
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">
            Total Pipeline (Deals)
          </CardTitle>
          <div class="h-9 w-9 rounded-lg bg-emerald-500/10 flex items-center justify-center text-emerald-600 dark:text-emerald-400 group-hover:bg-emerald-500/20 transition-colors">
            <CircleDollarSign class="h-4 w-4" />
          </div>
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold tracking-tight truncate">
            <Loader2 v-if="loading" class="w-7 h-7 animate-spin text-muted-foreground" />
            <span v-else>{{ formatCurrency(kpi?.pipeline_value ?? 0) }}</span>
          </div>
        </CardContent>
      </Card>

      <!-- Win Rate -->
      <Card class="hover:shadow-md transition-shadow group">
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">
            Win Rate
          </CardTitle>
          <div class="h-9 w-9 rounded-lg bg-amber-500/10 flex items-center justify-center text-amber-600 dark:text-amber-400 group-hover:bg-amber-500/20 transition-colors">
            <Target class="h-4 w-4" />
          </div>
        </CardHeader>
        <CardContent>
          <div class="flex items-baseline gap-2">
            <div class="text-3xl font-bold tracking-tight">
              <Loader2 v-if="loading" class="w-7 h-7 animate-spin text-muted-foreground" />
              <span v-else>{{ kpi?.win_rate }}%</span>
            </div>
            <Badge variant="secondary" class="text-green-700 dark:text-green-400 bg-green-50 dark:bg-green-900/30 border-0 text-[11px]">
              <ArrowUpRight class="w-3 h-3 mr-0.5" /> 2.4%
            </Badge>
          </div>
        </CardContent>
      </Card>

      <!-- Physical Visits Today -->
      <Card class="hover:shadow-md transition-shadow group">
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">
            Kunjungan Fisik Hari Ini
          </CardTitle>
          <div class="h-9 w-9 rounded-lg bg-violet-500/10 flex items-center justify-center text-violet-600 dark:text-violet-400 group-hover:bg-violet-500/20 transition-colors">
            <Compass class="h-4 w-4" />
          </div>
        </CardHeader>
        <CardContent>
          <div class="flex items-baseline gap-2">
            <div class="text-3xl font-bold tracking-tight">
              <Loader2 v-if="loading" class="w-7 h-7 animate-spin text-muted-foreground" />
              <span v-else>{{ kpi?.total_visits_today }}</span>
            </div>
            <span class="text-xs text-muted-foreground">Target: 150</span>
          </div>
          <div class="w-full bg-secondary rounded-full h-1.5 mt-3">
            <div class="bg-violet-600 h-1.5 rounded-full transition-all duration-700"
                 :style="{ width: `${Math.min((kpi?.total_visits_today ?? 0) / 150 * 100, 100)}%` }">
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Charts Area -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Revenue Trend Chart -->
      <Card class="lg:col-span-2">
        <CardHeader>
          <div class="flex items-center gap-2">
            <TrendingUp class="w-4 h-4 text-muted-foreground" />
            <CardTitle class="text-base">Tren Pendapatan (Juta IDR)</CardTitle>
          </div>
          <CardDescription>Proyeksi deal 'Closed Won' per bulan</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="h-[350px] w-full flex items-center justify-center relative">
            <div v-if="loading" class="absolute inset-0 bg-background/50 backdrop-blur-sm z-10 flex items-center justify-center rounded-lg">
              <Loader2 class="w-8 h-8 animate-spin text-primary" />
            </div>
            <LineChart v-else :data="trendData" color="#3B82F6" />
          </div>
        </CardContent>
      </Card>

      <!-- Top Performers -->
      <Card>
        <CardHeader>
          <CardTitle class="text-base">Top Sales Performer</CardTitle>
          <CardDescription>Berdasarkan revenue & kunjungan</CardDescription>
        </CardHeader>
        <CardContent>
          <div class="space-y-4">
            <div v-for="(sales, i) in topPerformers" :key="sales.sales_id"
                 class="flex items-center gap-3 group">
              <Avatar class="h-9 w-9 flex-shrink-0">
                <AvatarFallback class="text-xs font-semibold"
                                :class="i === 0 ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400'
                                       : 'bg-primary/10 text-primary'">
                  {{ sales.sales_name.charAt(0) }}
                </AvatarFallback>
              </Avatar>
              <div class="min-w-0 flex-1">
                <p class="text-sm font-medium truncate">{{ sales.sales_name }}</p>
                <p class="text-xs text-muted-foreground">{{ sales.total_visits }} Kunjungan ({{ sales.valid_checkins }} Valid)</p>
              </div>
              <Badge variant="outline" class="text-[11px] font-mono shrink-0">
                {{ (sales.revenue / 1000000).toFixed(1) }} Jt
              </Badge>
            </div>
          </div>

          <Separator class="my-4" />

          <Button variant="outline" class="w-full" size="sm" @click="$router.push('/reports/kpi')">
            Lihat Laporan Lengkap
          </Button>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
