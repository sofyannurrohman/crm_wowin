<script setup lang="ts">
import { LMap, LTileLayer } from '@vue-leaflet/vue-leaflet'
import 'leaflet/dist/leaflet.css'

interface Props {
  center?: [number, number]
  zoom?: number
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  center: () => [-2.5, 118.0], // Default center to Indonesia
  zoom: 5,
  height: '100%',
})

</script>

<template>
  <LMap
    :center="props.center"
    :zoom="props.zoom"
    :style="{ height: props.height }"
    :use-global-leaflet="false"
  >
    <LTileLayer
      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors"
    />
    <slot />
  </LMap>
</template>

<style>
/* Fix Leaflet Map Z-Index context within Tailwind dialog/tooltips */
.leaflet-container {
  z-index: 10;
}
</style>
