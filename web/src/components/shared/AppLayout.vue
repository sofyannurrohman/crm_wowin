<script setup lang="ts">
import { useUiStore } from '@/stores/ui.store'
import { useAuthStore } from '@/stores/auth.store'
import { useRouter } from 'vue-router'
import { computed, ref, onMounted, onUnmounted } from 'vue'
import {
  PanelLeft, LogOut, LayoutDashboard, Users, UserPlus, FileText,
  Calendar, Map, MapPin, BarChart3, Settings, ChevronDown,
  Sun, Moon, Bell, Search, Target, Flame, Package, ClipboardList, Timer,
  AlertCircle, Clock, Warehouse
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem,
  DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet'
import { Badge } from '@/components/ui/badge'

const ui = useUiStore()
const auth = useAuthStore()
const router = useRouter()
const mobileOpen = ref(false)

const notifications = ref([
  { id: 1, title: 'Follow-up Restock Toko Maju Jaya', type: 'reminder', time: '10 menit yang lalu', isRead: false },
  { id: 2, title: 'Deal "Proyek IT" stagnan lebih dari 14 hari', type: 'alert', time: '1 jam yang lalu', isRead: false },
  { id: 3, title: 'Sales "Budi" tidak aktif sejak 08:00', type: 'warning', time: '3 jam yang lalu', isRead: true },
])

const unreadCount = computed(() => notifications.value.filter(n => !n.isRead).length)

const markAsRead = (id: number) => {
  const notif = notifications.value.find(n => n.id === id)
  if (notif) notif.isRead = true
}

const clearAll = () => {
  notifications.value.forEach(n => n.isRead = true)
}

let ws: WebSocket | null = null

function initWebSocket() {
  if (!auth.user?.id) return
  // Construct WS url based on current host or environment
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  // For local development, assume backend is on :8080 or use matching port
  // Usually this corresponds to VITE_API_URL but replacing protocol
  const host = window.location.hostname === 'localhost' ? 'localhost:8080' : window.location.host
  const wsUrl = `${protocol}//${host}/api/v1/notifications/ws?user_id=${auth.user.id}`
  
  ws = new WebSocket(wsUrl)
  
  ws.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      const payload = data.payload // Maps to the Notification Model of backend
      
      notifications.value.unshift({
        id: payload.id || Date.now(),
        title: payload.title || 'Pemberitahuan Baru',
        type: payload.type || 'alert',
        time: 'Baru saja',
        isRead: false
      })
    } catch (e) {
      console.error('Error parsing WS message', e)
    }
  }
  
  ws.onclose = () => {
    // try to reconnect after 5 seconds if connection drops
    setTimeout(() => initWebSocket(), 5000)
  }
}

onMounted(() => {
  if (auth.isAuthenticated) {
    initWebSocket()
  }
})

onUnmounted(() => {
  if (ws) {
    ws.close()
  }
})

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard, group: 'overview' },
  { name: 'Pelanggan', href: '/customers', icon: Users, group: 'crm' },
  { name: 'Prospek', href: '/leads', icon: UserPlus, group: 'crm' },
  { name: 'Penjualan', href: '/deals', icon: FileText, group: 'crm' },
  { name: 'Produk', href: '/products', icon: Package, group: 'crm' },
  { name: 'Tugas', href: '/tasks', icon: ClipboardList, group: 'crm' },
  { name: 'Kunjungan', href: '/visits', icon: Calendar, group: 'sales' },
  { name: 'Presensi', href: '/attendance', icon: Timer, group: 'sales' },
  { name: 'Pelacakan Langsung', href: '/live-tracking', icon: MapPin, group: 'mapping' },
  { name: 'Wilayah', href: '/territories', icon: Map, group: 'mapping' },
  { name: 'Peta Panas', href: '/heatmap', icon: Flame, group: 'mapping' },
  { name: 'Laporan KPI', href: '/reports/kpi', icon: Target, group: 'reports' },
  { name: 'Laporan Kunjungan', href: '/reports/visits', icon: BarChart3, group: 'reports' },
  { name: 'Laporan Pipeline', href: '/reports/pipeline', icon: BarChart3, group: 'reports' },
  { name: 'Manajemen Pengguna', href: '/settings/users', icon: Settings, group: 'settings' },
  { name: 'Pengaturan Target', href: '/settings/targets', icon: Target, group: 'settings' },
  { name: 'Manajemen Gudang', href: '/settings/warehouses', icon: Warehouse, group: 'settings' },
]

const groups = [
  { key: 'overview', label: 'Ringkasan' },
  { key: 'crm', label: 'CRM' },
  { key: 'sales', label: 'Penjualan' },
  { key: 'mapping', label: 'Pemetaan' },
  { key: 'reports', label: 'Laporan' },
  { key: 'settings', label: 'Pengaturan' },
]

const userInitials = computed(() => {
  if (!auth.user?.name) return 'U'
  return auth.user.name.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase()
})

function handleLogout() {
  auth.logout()
  router.push('/login')
}
</script>

<template>
  <TooltipProvider :delay-duration="0">
    <div class="h-screen w-full flex overflow-hidden bg-background">

      <!-- Desktop Sidebar -->
      <aside
        class="hidden lg:flex flex-col bg-sidebar border-r border-sidebar-border transition-all duration-300 flex-shrink-0"
        :class="ui.isSidebarOpen ? 'w-64' : 'w-[68px]'"
        :style="{ backgroundColor: 'hsl(var(--sidebar-background))' }"
      >
        <!-- Logo -->
        <div class="h-16 flex items-center border-b border-sidebar-border px-4 gap-3 flex-shrink-0"
             :style="{ borderColor: 'hsl(var(--sidebar-border))' }">
          <div class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center shadow-sm flex-shrink-0">
            <span class="text-primary-foreground text-sm font-bold">W</span>
          </div>
          <transition enter-active-class="transition duration-200" enter-from-class="opacity-0" enter-to-class="opacity-100"
                      leave-active-class="transition duration-150" leave-from-class="opacity-100" leave-to-class="opacity-0">
            <div v-show="ui.isSidebarOpen" class="overflow-hidden whitespace-nowrap">
              <h1 class="font-bold text-base tracking-tight" :style="{ color: 'hsl(var(--sidebar-foreground))' }">Wowin CRM</h1>
              <p class="text-[10px] font-medium" :style="{ color: 'hsl(var(--sidebar-foreground) / 0.5)' }">Otomatisasi Penjualan</p>
            </div>
          </transition>
        </div>

        <!-- Navigation -->
        <ScrollArea class="flex-1 py-4">
          <div v-for="group in groups" :key="group.key" class="mb-2">
            <p v-show="ui.isSidebarOpen"
               class="px-4 pb-1 pt-3 text-[11px] font-semibold uppercase tracking-widest"
               :style="{ color: 'hsl(var(--sidebar-foreground) / 0.4)' }">
              {{ group.label }}
            </p>
            <Separator v-show="!ui.isSidebarOpen" class="my-2 mx-3" />

            <nav class="px-2 space-y-0.5">
              <template v-for="item in navigation.filter(n => n.group === group.key)" :key="item.name">
                <Tooltip v-if="!ui.isSidebarOpen">
                  <TooltipTrigger as-child>
                    <router-link
                      :to="item.href"
                      class="flex items-center justify-center w-full h-10 rounded-md transition-colors"
                      :style="{
                        color: 'hsl(var(--sidebar-foreground) / 0.7)',
                      }"
                      active-class="!bg-[hsl(var(--sidebar-accent))] !text-[hsl(var(--sidebar-accent-foreground))] font-semibold"
                    >
                      <component :is="item.icon" class="w-4 h-4 flex-shrink-0" />
                    </router-link>
                  </TooltipTrigger>
                  <TooltipContent side="right">
                    {{ item.name }}
                  </TooltipContent>
                </Tooltip>

                <router-link
                  v-else
                  :to="item.href"
                  class="flex items-center gap-3 px-3 h-9 rounded-md text-[13px] font-medium transition-all duration-150"
                  :style="{
                    color: 'hsl(var(--sidebar-foreground) / 0.7)',
                  }"
                  active-class="!bg-[hsl(var(--sidebar-accent))] !text-[hsl(var(--sidebar-accent-foreground))] font-semibold"
                >
                  <component :is="item.icon" class="w-4 h-4 flex-shrink-0" />
                  <span>{{ item.name }}</span>
                </router-link>
              </template>
            </nav>
          </div>
        </ScrollArea>

        <!-- User section at bottom -->
        <div class="border-t flex-shrink-0 p-3" :style="{ borderColor: 'hsl(var(--sidebar-border))' }">
          <DropdownMenu>
            <DropdownMenuTrigger as-child>
              <button
                class="w-full flex items-center gap-3 rounded-md px-2 py-2 hover:bg-accent/50 transition-colors"
              >
                <Avatar class="h-8 w-8 flex-shrink-0">
                  <AvatarFallback class="bg-primary/10 text-primary text-xs font-semibold">
                    {{ userInitials }}
                  </AvatarFallback>
                </Avatar>
                <div v-show="ui.isSidebarOpen" class="flex-1 text-left overflow-hidden">
                  <p class="text-sm font-medium truncate" :style="{ color: 'hsl(var(--sidebar-foreground))' }">
                    {{ auth.user?.name || 'User' }}
                  </p>
                  <p class="text-[11px] truncate" :style="{ color: 'hsl(var(--sidebar-foreground) / 0.5)' }">
                    {{ auth.user?.role }}
                  </p>
                </div>
                <ChevronDown v-show="ui.isSidebarOpen" class="w-4 h-4 opacity-50 flex-shrink-0" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" :side="ui.isSidebarOpen ? 'top' : 'right'" class="w-56">
              <DropdownMenuLabel>
                <div class="flex flex-col space-y-1">
                  <p class="text-sm font-medium">{{ auth.user?.name }}</p>
                  <p class="text-xs text-muted-foreground">{{ auth.user?.role }}</p>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem @click="handleLogout" class="text-destructive focus:text-destructive">
                <LogOut class="w-4 h-4 mr-2" />
                Keluar
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </aside>

      <!-- Main Content Area -->
      <div class="flex-1 flex flex-col min-w-0 overflow-hidden">

        <!-- Topbar -->
        <header class="h-14 bg-background border-b flex items-center justify-between px-4 lg:px-6 flex-shrink-0">
          <div class="flex items-center gap-2">
            <!-- Desktop toggle -->
            <Button variant="ghost" size="icon" class="hidden lg:inline-flex" @click="ui.toggleSidebar">
              <PanelLeft class="w-4 h-4" />
            </Button>

            <!-- Mobile menu -->
            <Sheet v-model:open="mobileOpen">
              <SheetTrigger as-child>
                <Button variant="ghost" size="icon" class="lg:hidden">
                  <PanelLeft class="w-4 h-4" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" class="w-72 p-0">
                <div class="h-14 flex items-center px-4 gap-3 border-b">
                  <div class="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
                    <span class="text-primary-foreground text-sm font-bold">W</span>
                  </div>
                  <div>
                    <h1 class="font-bold text-base tracking-tight">Wowin CRM</h1>
                    <p class="text-[10px] text-muted-foreground font-medium">Otomatisasi Penjualan</p>
                  </div>
                </div>
                <ScrollArea class="flex-1 py-4 h-[calc(100vh-56px)]">
                  <div v-for="group in groups" :key="group.key" class="mb-2">
                    <p class="px-4 pb-1 pt-3 text-[11px] font-semibold uppercase tracking-widest text-muted-foreground/60">
                      {{ group.label }}
                    </p>
                    <nav class="px-2 space-y-0.5">
                      <router-link
                        v-for="item in navigation.filter(n => n.group === group.key)"
                        :key="item.name"
                        :to="item.href"
                        class="flex items-center gap-3 px-3 h-9 rounded-md text-[13px] font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
                        active-class="!bg-accent !text-accent-foreground font-semibold"
                        @click="mobileOpen = false"
                      >
                        <component :is="item.icon" class="w-4 h-4 flex-shrink-0" />
                        <span>{{ item.name }}</span>
                      </router-link>
                    </nav>
                  </div>
                </ScrollArea>
              </SheetContent>
            </Sheet>
          </div>

          <div class="flex items-center gap-1">
            <!-- Notifications -->
            <DropdownMenu>
              <DropdownMenuTrigger as-child>
                <Button variant="ghost" size="icon" class="relative text-muted-foreground mr-1">
                  <Bell class="w-4 h-4" />
                  <span v-if="unreadCount > 0" class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-destructive border-2 border-background"></span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" class="w-80 p-0 border-muted">
                <div class="flex items-center justify-between px-4 py-3 border-b border-muted">
                  <span class="text-sm font-semibold">Notifikasi</span>
                  <Button v-if="unreadCount > 0" variant="ghost" size="sm" class="h-auto p-0 text-xs text-primary hover:bg-transparent" @click="clearAll">
                    Tandai semua dibaca
                  </Button>
                </div>
                <ScrollArea class="h-[320px]">
                  <div v-if="notifications.length === 0" class="p-8 text-center text-sm text-muted-foreground flex flex-col items-center">
                    <Bell class="w-8 h-8 text-muted/30 mb-2" />
                    Belum ada notifikasi baru
                  </div>
                  <div v-else class="flex flex-col py-1">
                    <DropdownMenuItem 
                      v-for="notif in notifications" 
                      :key="notif.id"
                      class="flex flex-col items-start px-4 py-3 cursor-pointer gap-1 focus:bg-accent rounded-none"
                      :class="{ 'bg-primary/5': !notif.isRead }"
                      @click.prevent="markAsRead(notif.id)"
                    >
                      <div class="flex items-start gap-3 w-full">
                        <div class="mt-0.5 rounded-full p-1.5 flex-shrink-0" :class="{
                          'bg-destructive/10 text-destructive dark:bg-destructive/20': notif.type === 'alert',
                          'bg-amber-100 text-amber-600 dark:bg-amber-900/30': notif.type === 'warning',
                          'bg-primary/10 text-primary dark:bg-primary/20': notif.type === 'reminder'
                        }">
                          <AlertCircle v-if="notif.type === 'alert'" class="w-3.5 h-3.5" />
                          <Clock v-else-if="notif.type === 'reminder'" class="w-3.5 h-3.5" />
                          <Target v-else class="w-3.5 h-3.5" />
                        </div>
                        <div class="flex-1 min-w-0">
                          <p class="text-[13px] font-medium leading-tight mb-1 break-words" :class="{'text-muted-foreground': notif.isRead}">
                            {{ notif.title }}
                          </p>
                          <p class="text-[11px] text-muted-foreground flex items-center gap-1">
                            {{ notif.time }}
                          </p>
                        </div>
                        <div v-if="!notif.isRead" class="w-2 h-2 rounded-full bg-primary flex-shrink-0 mt-1.5"></div>
                      </div>
                    </DropdownMenuItem>
                  </div>
                </ScrollArea>
              </DropdownMenuContent>
            </DropdownMenu>

            <Button variant="ghost" size="icon" @click="ui.toggleTheme" class="text-muted-foreground">
              <Sun v-if="ui.isDarkTheme" class="w-4 h-4" />
              <Moon v-else class="w-4 h-4" />
            </Button>
          </div>
        </header>

        <!-- Page Content -->
        <main class="flex-1 overflow-auto relative">
          <!-- Global Loading -->
          <div v-if="ui.isGlobalLoading"
               class="absolute inset-0 bg-background/50 backdrop-blur-sm flex items-center justify-center z-50">
            <div class="w-8 h-8 rounded-full border-4 border-primary border-t-transparent animate-spin"></div>
          </div>

          <div class="p-4 lg:p-6">
            <router-view v-slot="{ Component }">
              <transition name="fade" mode="out-in">
                <component :is="Component" />
              </transition>
            </router-view>
          </div>
        </main>

      </div>
    </div>
  </TooltipProvider>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
