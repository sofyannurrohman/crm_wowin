<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useDealStore } from '@/stores/deals.store'
import { VueDraggable } from 'vue-draggable-plus'
import { DEAL_STAGES } from '@/constants'
import { Loader2, DollarSign, Calendar, FileText, Plus } from 'lucide-vue-next'
import type { DealStage, Deal } from '@/types/deal.types'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { ScrollArea, ScrollBar } from '@/components/ui/scroll-area'

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
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}

const getStageColor = (key: string) => {
  const map: Record<string, { bg: string, badge: 'default' | 'secondary' | 'outline' | 'destructive' }> = {
    prospecting: { bg: 'bg-muted/50', badge: 'secondary' },
    qualification: { bg: 'bg-blue-50 dark:bg-blue-950/20', badge: 'default' },
    proposal: { bg: 'bg-amber-50 dark:bg-amber-950/20', badge: 'outline' },
    negotiation: { bg: 'bg-violet-50 dark:bg-violet-950/20', badge: 'outline' },
    closed_won: { bg: 'bg-emerald-50 dark:bg-emerald-950/20', badge: 'default' },
    closed_lost: { bg: 'bg-red-50 dark:bg-red-950/20', badge: 'destructive' },
  }
  return map[key] || { bg: 'bg-muted/50', badge: 'secondary' as const }
}
</script>

<template>
  <div class="h-[calc(100vh-8rem)] flex flex-col space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 flex-shrink-0">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Sales Pipeline</h1>
        <p class="text-muted-foreground mt-1">
          Geser kartu (drag & drop) untuk mengubah status penawaran.
        </p>
      </div>
      <Button size="sm">
        <Plus class="w-4 h-4 mr-2" />
        Penawaran Baru
      </Button>
    </div>

    <!-- Error -->
    <Card v-if="store.error" class="border-destructive bg-destructive/5 flex-shrink-0">
      <CardContent class="py-4">
        <p class="text-destructive text-sm">{{ store.error }}</p>
      </CardContent>
    </Card>

    <!-- Loading -->
    <div v-if="store.loading && store.deals.length === 0" class="flex-1 flex justify-center items-center">
      <Loader2 class="w-10 h-10 animate-spin text-muted-foreground" />
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex-1 overflow-x-auto pb-4 custom-scrollbar">
      <div class="flex gap-4 h-full min-w-max px-1">

        <div
          v-for="stage in DEAL_STAGES"
          :key="stage.key"
          class="flex flex-col w-80 rounded-xl border p-3 transition-colors"
          :class="getStageColor(stage.key).bg"
        >
          <!-- Column Header -->
          <div class="flex items-center justify-between mb-3 px-1">
            <h3 class="text-sm font-semibold">{{ stage.label }}</h3>
            <Badge variant="secondary" class="text-[11px] px-2 py-0.5 rounded-full">
              {{ store.dealsByStage[stage.key]?.length || 0 }}
            </Badge>
          </div>

          <!-- Draggable Cards -->
          <VueDraggable
            v-model="store.dealsByStage[stage.key]"
            group="deals"
            item-key="id"
            class="flex-1 overflow-y-auto space-y-2 custom-scrollbar pr-1 min-h-[150px]"
            ghost-class="opacity-50"
            @change="handleDragEnd($event, stage.key)"
          >
            <template #item="{ element }">
                <Card
                  class="cursor-pointer hover:shadow-md transition-all relative group"
                  :class="{ 'opacity-50 pointer-events-none': store.loadingStageUpdate === element.id }"
                  @click="router.push(`/deals/${element.id}`)"
                >
                  <div v-if="store.loadingStageUpdate === element.id"
                       class="absolute inset-0 bg-background/50 backdrop-blur-sm flex items-center justify-center rounded-lg z-10">
                    <Loader2 class="w-5 h-5 animate-spin text-primary" />
                  </div>
                  <CardContent class="p-4">
                    <h4 class="font-medium text-sm leading-tight line-clamp-2">{{ element.title }}</h4>

                    <div class="flex items-center mt-2.5 text-xs text-muted-foreground gap-1.5">
                      <FileText class="w-3.5 h-3.5 flex-shrink-0" />
                      <span class="truncate">{{ element.customer_name }}</span>
                    </div>

                  <div class="mt-3 flex items-center justify-between pt-3 border-t">
                    <span class="text-sm font-semibold flex items-center gap-1">
                      <DollarSign class="w-3.5 h-3.5 text-emerald-500" />
                      {{ formatCurrency(element.value).replace('Rp', '').trim() }}
                    </span>
                    <span class="text-[11px] text-muted-foreground flex items-center gap-1">
                      <Calendar class="w-3 h-3" />
                      {{ new Date(element.expected_close_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' }) }}
                    </span>
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
