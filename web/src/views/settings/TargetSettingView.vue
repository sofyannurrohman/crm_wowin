<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { Save, Target, TrendingUp, MapPin, CircleDollarSign, Loader2, RefreshCw, CheckCircle2, User, Search } from 'lucide-vue-next'
import { fetchTargets, updateTargets, fetchUserTarget, updateUserTarget, type Target as TargetModel, type SalesTarget } from '@/api/targets.api'
import { fetchUsers } from '@/api/auth.api'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { useToast } from '@/components/ui/toast/use-toast'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

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

// Individual Target State
const users = ref<any[]>([])
const selectedUser = ref<string>('')
const selectedMonth = ref(new Date().getMonth() + 1)
const selectedYear = ref(new Date().getFullYear())
const individualTarget = ref<SalesTarget>({
  user_id: '',
  period_month: selectedMonth.value,
  period_year: selectedYear.value,
  monthly_revenue: 0,
  monthly_visits: 0,
  monthly_new_customers: 0,
  win_rate: 0,
  monthly_deals: 0,
})
const loadingIndividual = ref(false)

const months = [
  { value: 1, label: 'Januari' }, { value: 2, label: 'Februari' }, { value: 3, label: 'Maret' },
  { value: 4, label: 'April' }, { value: 5, label: 'Mei' }, { value: 6, label: 'Juni' },
  { value: 7, label: 'Juli' }, { value: 8, label: 'Agustus' }, { value: 9, label: 'September' },
  { value: 10, label: 'Oktober' }, { value: 11, label: 'November' }, { value: 12, label: 'Desember' }
]

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

async function loadUsers() {
  try {
    const res = await fetchUsers()
    users.value = res.data.data.filter((u: any) => u.role === 'sales')
  } catch (e) {
    console.error('Failed to load users', e)
  }
}

async function loadIndividualTarget() {
  if (!selectedUser.value) return
  loadingIndividual.value = true
  try {
    const res = await fetchUserTarget(selectedUser.value, selectedMonth.value, selectedYear.value)
    individualTarget.value = res.data.data
  } catch (e: any) {
    if (e.response?.status === 404) {
      // If not found, reset to current global targets as starting point
      individualTarget.value = {
        user_id: selectedUser.value,
        period_month: selectedMonth.value,
        period_year: selectedYear.value,
        ...targets.value
      }
    }
  } finally {
    loadingIndividual.value = false
  }
}

async function handleSaveGlobal() {
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

async function handleSaveIndividual() {
  if (!selectedUser.value) return
  saving.value = true
  try {
    await updateUserTarget(individualTarget.value)
    toast({
      title: 'Target Individu disimpan',
      description: 'Target KPI individu berhasil diperbarui untuk periode terpilih.'
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

watch([selectedUser, selectedMonth, selectedYear], () => {
  loadIndividualTarget()
})

onMounted(() => {
  loadTargets()
  loadUsers()
})

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
        <p class="text-muted-foreground mt-1">Atur target penjualan dan KPI tim sales.</p>
      </div>
    </div>

    <Tabs defaultValue="global" class="w-full">
      <TabsList class="grid w-full max-w-[400px] grid-cols-2">
        <TabsTrigger value="global">Target Global</TabsTrigger>
        <TabsTrigger value="individual">Target Individu</TabsTrigger>
      </TabsList>

      <TabsContent value="global" class="space-y-6 mt-6">
        <div class="flex items-center justify-between">
           <h2 class="text-lg font-semibold">Pengaturan Target Global (Default)</h2>
           <Button size="sm" @click="handleSaveGlobal" :disabled="saving || loading">
              <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
              <Save v-else class="w-4 h-4 mr-2" />
              Simpan Target Global
            </Button>
        </div>

        <!-- Info -->
        <Card class="border-emerald-200 dark:border-emerald-900/50 bg-emerald-50/50 dark:bg-emerald-950/20">
          <CardContent class="py-3 flex items-center gap-3">
            <CheckCircle2 class="w-5 h-5 text-emerald-600 dark:text-emerald-400 flex-shrink-0" />
            <p class="text-sm text-emerald-700 dark:text-emerald-300">
              Target global akan digunakan sebagai default jika salesperson belum memiliki target khusus.
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
      </TabsContent>

      <TabsContent value="individual" class="space-y-6 mt-6">
        <div class="flex flex-col md:flex-row gap-4 items-end justify-between bg-muted/30 p-4 rounded-xl border">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 flex-1 w-full">
            <div class="space-y-2">
              <Label>Pilih Salesperson</Label>
              <Select v-model="selectedUser">
                <SelectTrigger>
                  <SelectValue placeholder="Pilih Anggota Sales" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="u in users" :key="u.id" :value="u.id">
                    {{ u.name }} ({{ u.sales_type || 'N/A' }})
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Bulan</Label>
              <Select v-model="selectedMonth" :defaultValue="selectedMonth.toString()">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="m in months" :key="m.value" :value="m.value">
                    {{ m.label }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Tahun</Label>
              <Input type="number" v-model.number="selectedYear" />
            </div>
          </div>
          <Button @click="handleSaveIndividual" :disabled="saving || !selectedUser || loadingIndividual">
            <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
            <Save v-else class="w-4 h-4 mr-2" />
            Simpan Target Individu
          </Button>
        </div>

        <div v-if="!selectedUser" class="text-center py-20 border-2 border-dashed rounded-xl">
          <User class="w-12 h-12 mx-auto text-muted-foreground opacity-20 mb-4" />
          <p class="text-muted-foreground">Pilih salesperson untuk mengatur target individu.</p>
        </div>

        <div v-else-if="loadingIndividual" class="flex justify-center py-20">
           <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card v-for="metric in metrics" :key="metric.key" class="hover:shadow-md transition-shadow border-blue-100 dark:border-blue-900/30">
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
                    v-model.number="(individualTarget as any)[metric.key]"
                    class="text-lg font-bold pr-16"
                  />
                  <span v-if="metric.suffix" class="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">
                    {{ metric.suffix }}
                  </span>
                </div>
                <div v-if="metric.type === 'currency'" class="text-xs text-muted-foreground whitespace-nowrap">
                  {{ formatCurrency((individualTarget as any)[metric.key]) }}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </TabsContent>
    </Tabs>
  </div>
</template>
