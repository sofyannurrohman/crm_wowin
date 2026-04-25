<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDealStore } from '@/stores/deals.store'
import { VueDraggable } from 'vue-draggable-plus'
import { DEAL_STAGES } from '@/constants'
import { 
  Loader2, DollarSign, Calendar, FileText, Plus, 
  TrendingUp, ArrowRight, User, MoreVertical,
  Target, CheckCircle2, XCircle, BarChart2,
  Search, LayoutGrid, AlertCircle
} from 'lucide-vue-next'
import type { DealStage, Deal } from '@/types/deal.types'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'

const store = useDealStore()
const router = useRouter()

onMounted(() => {
  store.fetchAll()
})

const handleDragEnd = (event: any, newStage: string) => {
  if (event.added) {
    const deal = event.added.element as Deal
    store.updateStage(deal.id, newStage as DealStage)
  }
}

const formatCurrency = (val: number) => {
  if (val >= 1000000000) return (val / 1000000000).toFixed(1) + 'M'
  if (val >= 1000000) return (val / 1000000).toFixed(1) + 'jt'
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}

const getStageTotal = (stageKey: string) => {
  const deals = store.dealsByStage[stageKey] || []
  return deals.reduce((acc, deal) => acc + (deal.value || 0), 0)
}

const getStageIcon = (key: string) => {
  const icons: Record<string, any> = {
    prospecting: Search,
    qualification: Target,
    proposal: FileText,
    negotiation: TrendingUp,
    closed_won: CheckCircle2,
    closed_lost: XCircle,
  }
  return icons[key] || Target
}

const getStageStyles = (key: string) => {
  const styles: Record<string, { bg: string, border: string, text: string, icon: string }> = {
    prospecting: { bg: 'bg-slate-50/50 dark:bg-slate-900/20', border: 'border-slate-200 dark:border-slate-800', text: 'text-slate-600', icon: 'text-slate-400' },
    qualification: { bg: 'bg-emerald-50/30 dark:bg-emerald-950/10', border: 'border-emerald-100 dark:border-emerald-900/30', text: 'text-emerald-700', icon: 'text-emerald-500' },
    proposal: { bg: 'bg-emerald-50/50 dark:bg-emerald-900/10', border: 'border-emerald-200 dark:border-emerald-800/50', text: 'text-emerald-800', icon: 'text-emerald-600' },
    negotiation: { bg: 'bg-emerald-100/30 dark:bg-emerald-800/20', border: 'border-emerald-300/50 dark:border-emerald-700/50', text: 'text-emerald-900', icon: 'text-emerald-700' },
    closed_won: { bg: 'bg-emerald-200/20 dark:bg-emerald-700/10', border: 'border-emerald-400/50 dark:border-emerald-600/50', text: 'text-emerald-900', icon: 'text-emerald-600' },
    closed_lost: { bg: 'bg-red-50/50 dark:bg-red-950/10', border: 'border-red-100 dark:border-red-900/30', text: 'text-red-700', icon: 'text-red-500' },
  }
  return styles[key] || styles.prospecting
}
</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-6 overflow-hidden">
    <!-- Sophisticated Header -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-6 px-1">
      <div class="space-y-1">
        <h1 class="text-3xl font-extrabold tracking-tight text-foreground flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-emerald-600 flex items-center justify-center shadow-lg shadow-emerald-600/20 text-white">
            <LayoutGrid class="w-6 h-6" />
          </div>
          Pipeline Penjualan
        </h1>
        <p class="text-muted-foreground text-sm flex items-center gap-2">
          <BarChart2 class="w-4 h-4 text-emerald-500" />
          Optimalkan konversi deal dengan manajemen pipeline yang terstruktur.
        </p>
      </div>
      
      <div class="flex items-center gap-3">
        <div class="hidden lg:flex items-center gap-4 px-4 py-2 bg-emerald-50/50 dark:bg-emerald-950/20 border border-emerald-100/50 dark:border-emerald-900/30 rounded-xl">
          <div class="flex flex-col">
            <span class="text-[10px] uppercase tracking-wider font-bold text-emerald-600/70">Total Volume</span>
            <span class="text-lg font-bold text-emerald-950 dark:text-emerald-50">
              Rp {{ formatCurrency(store.deals.reduce((a, b) => a + (b.value || 0), 0)).replace('Rp', '').trim() }}
            </span>
          </div>
          <Separator orientation="vertical" class="h-8 bg-emerald-200/50" />
          <div class="flex flex-col">
            <span class="text-[10px] uppercase tracking-wider font-bold text-emerald-600/70">Total Deals</span>
            <span class="text-lg font-bold text-emerald-950 dark:text-emerald-50">{{ store.deals.length }}</span>
          </div>
        </div>
        
        <Button class="bg-emerald-600 hover:bg-emerald-700 text-white shadow-lg shadow-emerald-600/20 h-11 px-5 rounded-xl font-semibold gap-2 transition-all hover:translate-y-[-1px]">
          <Plus class="w-5 h-5" />
          Deal Baru
        </Button>
      </div>
    </div>

    <!-- Error State -->
    <Card v-if="store.error" class="border-red-200 bg-red-50/50 dark:bg-red-950/10 backdrop-blur-sm">
      <CardContent class="py-4 flex items-center gap-3">
        <AlertCircle class="w-5 h-5 text-red-600" />
        <p class="text-red-700 text-sm font-medium">{{ store.error }}</p>
      </CardContent>
    </Card>

    <!-- Loading State -->
    <div v-if="store.loading && store.deals.length === 0" class="flex-1 flex flex-col justify-center items-center gap-4">
      <div class="relative">
        <div class="w-16 h-16 rounded-full border-4 border-emerald-100 dark:border-emerald-900"></div>
        <div class="absolute inset-0 w-16 h-16 rounded-full border-4 border-emerald-600 border-t-transparent animate-spin"></div>
      </div>
      <p class="text-emerald-600 font-medium animate-pulse">Menyiapkan pipeline anda...</p>
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex-1 overflow-x-auto pb-6 scrollbar-hide">
      <div class="flex gap-5 h-full min-w-max px-1">
        <div
          v-for="stage in DEAL_STAGES"
          :key="stage.key"
          class="flex flex-col w-80 rounded-2xl border transition-all duration-300"
          :class="[getStageStyles(stage.key).bg, getStageStyles(stage.key).border]"
        >
          <!-- Column Header - Premium Design -->
          <div class="p-4 flex flex-col gap-2">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2.5">
                <div class="p-1.5 rounded-lg bg-white/50 dark:bg-black/20" :class="getStageStyles(stage.key).icon">
                  <component :is="getStageIcon(stage.key)" class="w-4 h-4" />
                </div>
                <h3 class="text-[15px] font-bold tracking-tight" :class="getStageStyles(stage.key).text">{{ stage.label }}</h3>
              </div>
              <Badge variant="outline" class="bg-white/80 dark:bg-black/30 border-none shadow-sm rounded-full text-[11px] font-bold h-6 px-2.5">
                {{ store.dealsByStage[stage.key]?.length || 0 }}
              </Badge>
            </div>
            
            <div class="flex items-center justify-between mt-1 px-0.5">
              <span class="text-[11px] font-semibold text-muted-foreground/60 uppercase tracking-widest">Total Value</span>
              <span class="text-xs font-bold" :class="getStageStyles(stage.key).text">
                Rp {{ formatCurrency(getStageTotal(stage.key)).replace('Rp', '').trim() }}
              </span>
            </div>
            
            <div class="w-full h-1 mt-2 bg-emerald-100/30 dark:bg-emerald-900/20 rounded-full overflow-hidden">
               <div class="h-full bg-emerald-500/40" :style="{ width: '100%' }"></div>
            </div>
          </div>

          <!-- Draggable Cards Area -->
          <VueDraggable
            v-model="store.dealsByStage[stage.key]"
            group="deals"
            item-key="id"
            class="flex-1 overflow-y-auto px-3 pb-4 space-y-3 custom-scrollbar min-h-[150px]"
            ghost-class="opacity-0"
            drag-class="rotate-2 scale-105 shadow-2xl z-50 cursor-grabbing"
            @change="handleDragEnd($event, stage.key)"
          >
            <template #item="{ element }">
                <Card
                  class="cursor-pointer border-transparent shadow-sm hover:shadow-xl hover:border-emerald-200/50 dark:hover:border-emerald-800/50 transition-all duration-300 group ring-offset-background focus-visible:ring-2 focus-visible:ring-emerald-500 overflow-hidden"
                  :class="{ 'opacity-50 pointer-events-none scale-95': store.loadingStageUpdate === element.id }"
                  @click="router.push(`/deals/${element.id}`)"
                >
                  <div v-if="store.loadingStageUpdate === element.id"
                       class="absolute inset-0 bg-white/60 dark:bg-black/60 backdrop-blur-[2px] flex items-center justify-center rounded-lg z-20">
                    <Loader2 class="w-6 h-6 animate-spin text-emerald-600" />
                  </div>
                  
                  <CardContent class="p-4 relative overflow-hidden bg-white dark:bg-slate-950">
                    <!-- Progress underline -->
                    <div class="absolute bottom-0 left-0 h-0.5 bg-emerald-500 transition-all duration-500 group-hover:w-full w-0"></div>
                    
                    <div class="flex items-start justify-between gap-2 mb-3">
                      <h4 class="font-bold text-[14px] leading-snug line-clamp-2 group-hover:text-emerald-700 dark:group-hover:text-emerald-400 transition-colors">
                        {{ element.title }}
                      </h4>
                      <Button variant="ghost" size="icon" class="h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity">
                        <MoreVertical class="w-3.5 h-3.5" />
                      </Button>
                    </div>

                    <div class="flex flex-col gap-2.5">
                      <div class="flex items-center text-xs text-muted-foreground gap-2 bg-slate-50 dark:bg-slate-900/50 p-2 rounded-lg">
                        <div class="w-6 h-6 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center text-emerald-700 dark:text-emerald-400 text-[10px] uppercase font-black">
                          {{ element.customer_name ? element.customer_name[0] : 'C' }}
                        </div>
                        <span class="truncate font-medium flex-1">{{ element.customer_name }}</span>
                      </div>
                      
                      <div class="flex items-center justify-between items-end mt-1">
                        <div class="flex flex-col">
                          <span class="text-[9px] uppercase tracking-tighter font-bold text-muted-foreground/50">Deal Value</span>
                          <span class="text-[15px] font-black tracking-tight text-emerald-600 dark:text-emerald-400">
                            Rp {{ formatCurrency(element.value).replace('Rp', '').trim() }}
                          </span>
                        </div>
                        
                        <TooltipProvider>
                          <Tooltip>
                            <TooltipTrigger as-child>
                              <div class="flex items-center gap-1.5 px-2 py-1 bg-slate-50 dark:bg-slate-900 rounded-md border border-slate-100 dark:border-slate-800">
                                <Calendar class="w-3 h-3 text-muted-foreground" />
                                <span class="text-[10px] font-bold text-muted-foreground">{{ new Date(element.expected_close_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' }) }}</span>
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>Target Tutup</TooltipContent>
                          </Tooltip>
                        </TooltipProvider>
                      </div>
                    </div>
                  </CardContent>
                </Card>
            </template>
          </VueDraggable>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(16, 185, 129, 0.1);
  border-radius: 20px;
}
.custom-scrollbar:hover::-webkit-scrollbar-thumb {
  background: rgba(16, 185, 129, 0.3);
}

.fade-move,
.fade-enter-active,
.fade-leave-active {
  transition: all 0.5s cubic-bezier(0.55, 0, 0.1, 1);
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scaleY(0.01) translate(30px, 0);
}

.fade-leave-active {
  position: absolute;
}
</style>
