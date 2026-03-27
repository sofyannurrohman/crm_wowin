<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { Save, Target, TrendingUp, MapPin, CircleDollarSign, Loader2, RefreshCw, CheckCircle2 } from 'lucide-vue-next'
import { fetchTargets, updateTargets, type Target as TargetModel } from '@/api/targets.api'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()

const targets = ref<TargetModel>({
  monthly_revenue: 0,
  monthly_visits: 0,
  monthly_new_customers: 0,
  win_rate: 0,
  monthly_deals: 0,
})

const loading = ref(false)
const saving = ref(false)

async function loadTargets() {
  loading.value = true
  try {
    const res = await fetchTargets()
    targets.value = res.data.data
  } catch (e: any) {
    toast({
      title: 'Gagal memuat target',
      description: e.response?.data?.error?.message || 'Terjadi kesalahan sistem.',
      variant: 'destructive'
    })
  } finally {
    loading.value = false
  }
}

async function handleSave() {
  saving.value = true
  try {
    await updateTargets(targets.value)
    toast({
      title: 'Target disimpan',
      description: 'Target KPI bulanan berhasil diperbarui dan diterapkan ke seluruh sistem.'
    })
  } catch (e: any) {
    toast({
      title: 'Gagal menyimpan',
      description: e.response?.data?.error?.message || 'Terjadi kesalahan sistem.',
      variant: 'destructive'
    })
  } finally {
    saving.value = false
  }
}

onMounted(loadTargets)

const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)

const metrics = computed(() => [
  {
    key: 'monthly_revenue',
    label: 'Target Revenue Bulanan',
    description: 'Total pendapatan dari deal Closed Won',
    icon: CircleDollarSign,
    color: 'text-emerald-600 bg-emerald-500/10',
    type: 'currency',
    suffix: '',
  },
  {
    key: 'monthly_visits',
    label: 'Target Kunjungan / Bulan',
    description: 'Jumlah minimum kunjungan lapangan per bulan',
    icon: MapPin,
    color: 'text-violet-600 bg-violet-500/10',
    type: 'number',
    suffix: 'kunjungan',
  },
  {
    key: 'monthly_new_customers',
    label: 'Pelanggan Baru / Bulan',
    description: 'Target akuisisi pelanggan baru',
    icon: TrendingUp,
    color: 'text-blue-600 bg-blue-500/10',
    type: 'number',
    suffix: 'pelanggan',
  },
  {
    key: 'win_rate',
    label: 'Win Rate Target',
    description: 'Persentase minimum konversi deal',
    icon: Target,
    color: 'text-amber-600 bg-amber-500/10',
    type: 'percent',
    suffix: '%',
  },
  {
    key: 'monthly_deals',
    label: 'Target Deals / Bulan',
    description: 'Jumlah deal yang harus ditutup per bulan',
    icon: CircleDollarSign,
    color: 'text-rose-600 bg-rose-500/10',
    type: 'number',
    suffix: 'deals',
  },
])
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Target Setting</h1>
        <p class="text-muted-foreground mt-1">Atur target penjualan dan KPI tim sales per bulan.</p>
      </div>
      <div class="flex items-center gap-2">
        <Button variant="outline" size="sm" @click="loadTargets" :disabled="loading">
          <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
          Refresh
        </Button>
        <Button size="sm" @click="handleSave" :disabled="saving || loading">
          <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
          <Save v-else class="w-4 h-4 mr-2" />
          Simpan Target
        </Button>
      </div>
    </div>

    <!-- Info -->
    <Card class="border-emerald-200 dark:border-emerald-900/50 bg-emerald-50/50 dark:bg-emerald-950/20">
      <CardContent class="py-3 flex items-center gap-3">
        <CheckCircle2 class="w-5 h-5 text-emerald-600 dark:text-emerald-400 flex-shrink-0" />
        <p class="text-sm text-emerald-700 dark:text-emerald-300">
          Target saat ini aktif dan terhubung dengan backend Dashboard Analytics.
        </p>
      </CardContent>
    </Card>

    <!-- Target Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <Card v-for="metric in metrics" :key="metric.key" class="hover:shadow-md transition-shadow">
        <CardHeader class="flex flex-row items-start gap-4 space-y-0">
          <div class="h-11 w-11 rounded-lg flex items-center justify-center flex-shrink-0" :class="metric.color">
            <component :is="metric.icon" class="h-5 w-5" />
          </div>
          <div class="flex-1">
            <CardTitle class="text-sm font-semibold">{{ metric.label }}</CardTitle>
            <CardDescription class="text-xs">{{ metric.description }}</CardDescription>
          </div>
        </CardHeader>
        <CardContent>
          <div class="flex items-center gap-3">
            <div class="relative flex-1">
              <Input
                type="number"
                v-model.number="(targets as any)[metric.key]"
                class="text-lg font-bold pr-16"
              />
              <span v-if="metric.suffix" class="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">
                {{ metric.suffix }}
              </span>
            </div>
            <div v-if="metric.type === 'currency'" class="text-xs text-muted-foreground whitespace-nowrap">
              {{ formatCurrency((targets as any)[metric.key]) }}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Summary Preview -->
    <Card>
      <CardHeader>
        <CardTitle class="text-base">Ringkasan Target Aktif</CardTitle>
        <CardDescription>Preview target yang akan diterapkan</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
          <div class="text-center p-3 rounded-lg bg-muted/50">
            <p class="text-2xl font-bold">{{ formatCurrency(targets.monthly_revenue) }}</p>
            <p class="text-xs text-muted-foreground mt-1">Revenue</p>
          </div>
          <div class="text-center p-3 rounded-lg bg-muted/50">
            <p class="text-2xl font-bold">{{ targets.monthly_visits }}</p>
            <p class="text-xs text-muted-foreground mt-1">Kunjungan</p>
          </div>
          <div class="text-center p-3 rounded-lg bg-muted/50">
            <p class="text-2xl font-bold">{{ targets.monthly_new_customers }}</p>
            <p class="text-xs text-muted-foreground mt-1">Pelanggan Baru</p>
          </div>
          <div class="text-center p-3 rounded-lg bg-muted/50">
            <p class="text-2xl font-bold">{{ targets.win_rate }}%</p>
            <p class="text-xs text-muted-foreground mt-1">Win Rate</p>
          </div>
          <div class="text-center p-3 rounded-lg bg-muted/50">
            <p class="text-2xl font-bold">{{ targets.monthly_deals }}</p>
            <p class="text-xs text-muted-foreground mt-1">Deals / Bulan</p>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
