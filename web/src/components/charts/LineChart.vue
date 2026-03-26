<script setup lang="ts">
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, BarChart, FunnelChart as EFunnelChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  ToolboxComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { ref, computed } from 'vue'

// Provide the specific modules to echarts
use([
  CanvasRenderer,
  LineChart,
  BarChart,
  EFunnelChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  ToolboxComponent
])

const props = defineProps<{
  data: { label: string; value: number }[]
  title?: string
  color?: string
}>()

const option = computed(() => {
  const isDark = document.documentElement.classList.contains('dark')
  const textColor = isDark ? '#d1d5db' : '#374151'
  const gridColor = isDark ? '#374151' : '#f3f4f6'

  return {
    title: {
      text: props.title,
      textStyle: { color: textColor, fontSize: 14, fontWeight: 'normal' },
      left: 'center',
      top: 0
    },
    tooltip: {
      trigger: 'axis',
      backgroundColor: isDark ? '#1f2937' : '#ffffff',
      borderColor: isDark ? '#374151' : '#e5e7eb',
      textStyle: { color: textColor }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: (props.data || []).map(d => d.label),
      axisLabel: { color: textColor },
      axisLine: { lineStyle: { color: gridColor } }
    },
    yAxis: {
      type: 'value',
      axisLabel: { color: textColor },
      splitLine: { lineStyle: { color: gridColor, type: 'dashed' } }
    },
    series: [
      {
        data: (props.data || []).map(d => d.value),
        type: 'line',
        smooth: true,
        lineStyle: {
          width: 3,
          color: props.color || '#3B82F6'
        },
        itemStyle: {
          color: props.color || '#3B82F6'
        },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [{
                offset: 0, color: props.color ? `${props.color}80` : 'rgba(59, 130, 246, 0.5)'
            }, {
                offset: 1, color: props.color ? `${props.color}00` : 'rgba(59, 130, 246, 0)'
            }]
          }
        }
      }
    ]
  }
})
</script>

<template>
  <ClientOnly>
    <v-chart class="w-full h-full min-h-[300px]" :option="option" autoresize />
  </ClientOnly>
</template>
