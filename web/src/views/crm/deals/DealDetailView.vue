<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { fetchDeals, updateDealStage } from '@/api/deals.api'
import { fetchDealItems, type DealItem, type Product, fetchProducts } from '@/api/products.api'
import type { Deal, DealStage } from '@/types/deal.types'
import {
  ArrowLeft, Loader2, Calendar, User, Building, CircleDollarSign,
  Package, Trash2, Edit, Plus, Info, Clock, BadgeCheck, XCircle, MoreVertical
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()
const route = useRoute()
const router = useRouter()
const loading = ref(true)
const deal = ref<Deal | null>(null)
const items = ref<DealItem[]>([])
const loadingItems = ref(false)

const dealId = route.params.id as string

async function loadDeal() {
  loading.value = true
  try {
    const res = await fetchDeals()
    // Deal is usually loaded individually in a production app via getDealById, 
    // but here we filter from list to ensure consistency with current deal.api
    deal.value = res.data.data.find(d => d.id === dealId) || null
    if (deal.value) {
      await loadChildren()
    }
  } catch (e) {
    console.error('Failed to load deal', e)
  } finally {
    loading.value = false
  }
}

async function loadChildren() {
  loadingItems.value = true
  try {
    const res = await fetchDealItems(dealId)
    items.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load items', e)
  } finally {
    loadingItems.value = false
  }
}

onMounted(loadDeal)

const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)

const getStageLabel = (stage: DealStage) => {
  const map: Record<string, string> = {
    prospecting: 'Prospecting', qualification: 'Qualification',
    proposal: 'Proposal', negotiation: 'Negotiation',
    closed_won: 'Closed Won', closed_lost: 'Closed Lost'
  }
  return map[stage] || stage
}

const getStageVariant = (stage: DealStage) => {
  if (stage === 'closed_won') return 'default'
  if (stage === 'closed_lost') return 'destructive'
  return 'secondary'
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center gap-3">
      <Button variant="ghost" size="icon" @click="router.back()" class="h-9 w-9">
        <ArrowLeft class="w-4 h-4" />
      </Button>
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Detail Peluang</h1>
        <p class="text-muted-foreground text-sm">Informasi lengkap penawaran dan produk terkait.</p>
      </div>
    </div>

    <div v-if="loading" class="flex justify-center py-24">
      <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
    </div>

    <div v-else-if="!deal" class="text-center py-24">
       <Card class="border-destructive bg-destructive/5 mx-auto max-w-md">
        <CardContent class="py-12">
           <XCircle class="mx-auto h-12 w-12 text-destructive/50 mb-4" />
           <p class="text-destructive font-medium">Deal tidak ditemukan di sistem.</p>
        </CardContent>
       </Card>
    </div>

    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Left Column: Deal Overview -->
      <div class="lg:col-span-1 space-y-6">
        <Card>
          <CardHeader class="pb-2">
            <div class="flex items-center justify-between mb-2">
              <Badge :variant="getStageVariant(deal.stage)" class="uppercase text-[10px] font-bold">
                {{ getStageLabel(deal.stage) }}
              </Badge>
              <BadgeCheck v-if="deal.stage === 'closed_won'" class="text-emerald-500 h-5 w-5" />
            </div>
            <CardTitle class="text-xl">{{ deal.title }}</CardTitle>
            <CardDescription class="text-2xl font-bold text-foreground mt-2">
              {{ formatCurrency(deal.value) }}
            </CardDescription>
          </CardHeader>
          <CardContent class="pt-4 space-y-4">
            <Separator />
            <div class="space-y-3">
              <div class="flex items-center gap-3 text-sm">
                <Building class="w-4 h-4 text-muted-foreground" />
                <div>
                  <p class="text-[10px] text-muted-foreground uppercase font-semibold">Pelanggan</p>
                  <p class="font-medium">{{ deal.customer_name || 'Tidak diketahui' }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3 text-sm">
                <User class="w-4 h-4 text-muted-foreground" />
                <div>
                  <p class="text-[10px] text-muted-foreground uppercase font-semibold">Assigned To (Sales)</p>
                  <p class="font-medium text-primary">{{ deal.sales_name || 'Unassigned' }}</p>
                </div>
              </div>
               <div class="flex items-center gap-3 text-sm">
                <Calendar class="w-4 h-4 text-muted-foreground" />
                <div>
                  <p class="text-[10px] text-muted-foreground uppercase font-semibold">Estimasi Closing</p>
                  <p class="font-medium">{{ deal.expected_close_date ? new Date(deal.expected_close_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' }) : '-' }}</p>
                </div>
              </div>
            </div>
             <div class="pt-4 flex gap-2">
              <Button variant="outline" class="flex-1 text-xs h-8">Pindah Tahap</Button>
              <Button variant="outline" class="flex-1 text-xs h-8">Selesaikan</Button>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Right Column: Product Items -->
      <div class="lg:col-span-2 space-y-6">
        <Card>
          <CardHeader class="flex-row items-center justify-between space-y-0">
            <div>
              <CardTitle class="text-lg">Kutipan Produk</CardTitle>
              <CardDescription>Daftar item penawaran di dalam peluang ini.</CardDescription>
            </div>
            <Button size="sm" variant="outline" class="h-8">
              <Plus class="w-4 h-4 mr-2" /> Item
            </Button>
          </CardHeader>
          <CardContent class="p-0">
            <div v-if="loadingItems" class="flex justify-center py-16">
              <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
            </div>
            <div v-else-if="items.length === 0" class="text-center py-16">
               <Package class="mx-auto h-12 w-12 text-muted-foreground/30 mb-4" />
               <p class="text-muted-foreground text-sm font-medium">Belum ada produk yang ditawarkan.</p>
               <Button variant="link" size="sm">Klik 'Tambah Item' untuk mulai</Button>
            </div>
            <Table v-else>
               <TableHeader>
                <TableRow>
                  <TableHead>Produk</TableHead>
                  <TableHead class="text-center">Kuantitas</TableHead>
                  <TableHead>Harga Unit</TableHead>
                  <TableHead>Diskon</TableHead>
                  <TableHead class="text-right">Subtotal</TableHead>
                </TableRow>
               </TableHeader>
               <TableBody>
                <TableRow v-for="item in items" :key="item.id">
                  <TableCell>
                    <div class="font-medium text-sm">{{ item.name }}</div>
                  </TableCell>
                  <TableCell class="text-center font-mono">{{ item.quantity }}</TableCell>
                  <TableCell class="font-mono text-xs">{{ formatCurrency(item.unit_price) }}</TableCell>
                  <TableCell class="text-xs text-muted-foreground">{{ item.discount }}%</TableCell>
                  <TableCell class="text-right font-bold text-sm">
                    {{ formatCurrency(item.subtotal || (item.quantity * item.unit_price * (1 - item.discount/100))) }}
                  </TableCell>
                </TableRow>
               </TableBody>
            </Table>
             <div v-if="items.length > 0" class="p-4 border-t bg-muted/30">
                <div class="flex justify-between items-center px-4">
                  <span class="text-sm font-medium">Total Nilai Penawaran (Estimasi)</span>
                  <span class="text-lg font-bold text-primary">{{ formatCurrency(items.reduce((sum, i) => sum + (i.subtotal || 0), 0)) }}</span>
                </div>
            </div>
          </CardContent>
        </Card>

        <!-- Activities Timeline (Static/Placeholder but formatted) -->
        <Card>
           <CardHeader>
             <CardTitle class="text-lg flex items-center gap-2">
               <Clock class="w-5 h-5 text-muted-foreground" /> Timeline Aktivitas
             </CardTitle>
           </CardHeader>
           <CardContent>
              <div class="space-y-6 relative before:absolute before:inset-0 before:left-[11px] before:w-0.5 before:bg-muted ml-3">
                 <div class="relative pl-8">
                    <div class="absolute left-0 top-1 h-3 w-3 rounded-full bg-primary border-2 border-background ring-4 ring-muted"></div>
                    <div class="text-sm">
                      <p class="font-bold">Deal Dibuat</p>
                      <p class="text-muted-foreground text-xs">{{ new Date(deal.created_at).toLocaleString() }}</p>
                    </div>
                 </div>
                 <div class="relative pl-8">
                    <div class="absolute left-0 top-1 h-3 w-3 rounded-full bg-primary border-2 border-background ring-4 ring-muted"></div>
                    <div class="text-sm">
                      <p class="font-bold">Status Berubah: Prospecting</p>
                      <p class="text-muted-foreground text-xs">{{ new Date(deal.updated_at).toLocaleString() }}</p>
                    </div>
                 </div>
              </div>
           </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>
