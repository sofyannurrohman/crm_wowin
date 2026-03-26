<script setup lang="ts">
import { RouterView } from 'vue-router'
import { onMounted } from 'vue'
import { useUiStore } from '@/stores/ui.store'
import { Toaster } from '@/components/ui/toast'

const ui = useUiStore()

onMounted(() => {
  if (ui.isDarkTheme) {
    document.documentElement.classList.add('dark')
  }
})
</script>

<template>
  <RouterView />
  <Toaster />
</template>
