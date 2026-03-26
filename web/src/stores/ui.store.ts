import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUiStore = defineStore('ui', () => {
  const isSidebarOpen = ref(true)
  const isDarkTheme = ref(localStorage.getItem('theme') === 'dark')
  const isGlobalLoading = ref(false)

  function toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value
  }

  function setSidebar(state: boolean) {
    isSidebarOpen.value = state
  }

  function toggleTheme() {
    isDarkTheme.value = !isDarkTheme.value
    localStorage.setItem('theme', isDarkTheme.value ? 'dark' : 'light')
    if (isDarkTheme.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  function setGlobalLoading(state: boolean) {
    isGlobalLoading.value = state
  }

  return {
    isSidebarOpen,
    isDarkTheme,
    isGlobalLoading,
    toggleSidebar,
    setSidebar,
    toggleTheme,
    setGlobalLoading
  }
})
