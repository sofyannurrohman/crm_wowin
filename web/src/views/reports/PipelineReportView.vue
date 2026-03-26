<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useDealStore } from '@/stores/deals.store'
import { DEAL_STAGES } from '@/constants'
import { Loader2, RefreshCw, TrendingUp } from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

const store = useDealStore()
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    await store.fetchAll()
  } catch (e) {
    console.error('Failed to load pipeline data', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())

const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)

const stageStats = computed(() => {
  return DEAL_STAGES.map(stage => {
    const deals = store.dealsByStage[stage.key] || []
    const totalValue = deals.reduce((sum: number, d: any) => sum + (d.value || 0), 0)
    return { ...stage, count: deals.length, totalValue }
  })
})

const totalDeals = computed(() => store.deals.length)
const totalPipelineValue = computed(() => store.deals.reduce((sum, d) => sum + (d.value || 0), 0))
const wonDeals = computed(() => (store.dealsByStage['closed_won'] || []).length)
const lostDeals = computed(() => (store.dealsByStage['closed_lost'] || []).length)
const winRate = computed(() => {
  const closed = wonDeals.value + lostDeals.value
  return closed > 0 ? ((wonDeals.value / closed) * 100).toFixed(1) : '0'
})

const getStageBarColor = (key: string) => {
  const map: Record<string, string> = {
    prospecting: 'bg-gray-400',
    qualification: 'bg-blue-500',
    proposal: 'bg-amber-500',
    negotiation: 'bg-violet-500',
    closed_won: 'bg-emerald-500',
    closed_lost: 'bg-red-500',
  }
  return map[key] || 'bg-gray-400'
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Pipeline Report</h1>
        <p class="text-muted-foreground mt-1">Analisis funnel penjualan dan konversi deal per stage.</p>
      </div>
      <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
        <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
        Refresh
      </Button>
    </div>

    <!-- Summary Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <Card>
        <CardHeader class="pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Deals</CardTitle>
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ totalDeals }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Pipeline Value</CardTitle>
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-2xl font-bold truncate">{{ formatCurrency(totalPipelineValue) }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Win Rate</CardTitle>
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ winRate }}%</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Won / Lost</CardTitle>
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="flex items-baseline gap-2">
            <span class="text-3xl font-bold text-emerald-600">{{ wonDeals }}</span>
            <span class="text-muted-foreground">/</span>
            <span class="text-3xl font-bold text-red-600">{{ lostDeals }}</span>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Funnel Visualization -->
    <Card>
      <CardHeader>
        <div class="flex items-center gap-2">
          <TrendingUp class="w-4 h-4 text-muted-foreground" />
          <CardTitle class="text-base">Pipeline Funnel</CardTitle>
        </div>
        <CardDescription>Distribusi deals per stage pipeline</CardDescription>
      </CardHeader>
      <CardContent>
        <div v-if="loading" class="flex justify-center py-16">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <div v-else class="space-y-4">
          <div v-for="stage in stageStats" :key="stage.key" class="group">
            <div class="flex items-center justify-between mb-1.5">
              <div class="flex items-center gap-2">
                <span class="font-medium text-sm">{{ stage.label }}</span>
                <Badge variant="secondary" class="text-[11px]">{{ stage.count }}</Badge>
              </div>
              <span class="text-sm font-mono text-muted-foreground">{{ formatCurrency(stage.totalValue) }}</span>
            </div>
            <div class="w-full bg-secondary rounded-full h-3 overflow-hidden">
              <div
                class="h-full rounded-full transition-all duration-700"
                :class="getStageBarColor(stage.key)"
                :style="{ width: `${totalDeals > 0 ? (stage.count / totalDeals) * 100 : 0}%`, minWidth: stage.count > 0 ? '8px' : '0' }"
              ></div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
