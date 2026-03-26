<script setup lang="ts">
import { ref, computed } from 'vue'
import { Save, Target, TrendingUp, MapPin, CircleDollarSign } from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()

const targets = ref({
  monthly_revenue: 500000000,
  monthly_visits: 150,
  monthly_new_customers: 20,
  win_rate: 30,
  monthly_deals: 10,
})

const saved = ref(false)

function handleSave() {
  saved.value = true
  toast({
    title: 'Target disimpan',
    description: 'Target KPI bulanan berhasil diperbarui. (Lokal saja — belum terkoneksi ke backend)'
  })
  setTimeout(() => { saved.value = false }, 2000)
}

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
      <Button size="sm" @click="handleSave">
        <Save class="w-4 h-4 mr-2" />
        Simpan Target
      </Button>
    </div>

    <!-- Info -->
    <Card class="border-amber-200 dark:border-amber-900/50 bg-amber-50/50 dark:bg-amber-950/20">
      <CardContent class="py-3 flex items-center gap-3">
        <Target class="w-5 h-5 text-amber-600 dark:text-amber-400 flex-shrink-0" />
        <p class="text-sm text-amber-700 dark:text-amber-300">
          Target saat ini disimpan secara lokal. Integrasi dengan backend akan tersedia pada versi selanjutnya.
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
