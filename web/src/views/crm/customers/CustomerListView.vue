<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useCustomerStore } from '@/stores/customers.store'
import { useRouter } from 'vue-router'
import { Plus, Search, MapPin, Loader2, Eye, Edit, Users, ChevronLeft, ChevronRight } from 'lucide-vue-next'
import { useDebounce } from '@vueuse/core'
import type { Customer, CustomerStatus } from '@/types/customer.types'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'

const store = useCustomerStore()
const router = useRouter()

const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedStatus = ref<string>('all')
const page = ref(1)

const loadCustomers = () => {
  store.fetchAll({
    search: debouncedSearch.value,
    status: selectedStatus.value === 'all' ? undefined : (selectedStatus.value as CustomerStatus),
    page: page.value,
    limit: 15
  })
}

watch([debouncedSearch, selectedStatus, page], () => {
  loadCustomers()
})

onMounted(() => {
  loadCustomers()
})

const goDetail = (id: string) => router.push(`/customers/${id}`)

const formatStatus = (status: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' | 'destructive' }> = {
    active: { label: 'Aktif', variant: 'default' },
    inactive: { label: 'Non-Aktif', variant: 'secondary' },
    lead: { label: 'Lead', variant: 'outline' }
  }
  return map[status] || { label: status, variant: 'secondary' }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Page Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Pelanggan</h1>
        <p class="text-muted-foreground mt-1">Kelola direktori kontak dan informasi prospek.</p>
      </div>
      <div class="flex items-center gap-2">
        <Button variant="outline" size="sm">
          <MapPin class="w-4 h-4 mr-2" />
          Lihat Peta
        </Button>
        <Button size="sm">
          <Plus class="w-4 h-4 mr-2" />
          Pelanggan Baru
        </Button>
      </div>
    </div>

    <!-- Filters -->
    <Card>
      <CardContent class="pt-6">
        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div class="relative w-full max-w-sm">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              v-model="searchInput"
              class="pl-9"
              placeholder="Cari nama, email, hp..."
            />
          </div>
          <Select v-model="selectedStatus">
            <SelectTrigger class="w-[180px]">
              <SelectValue placeholder="Semua Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Status</SelectItem>
              <SelectItem value="active">Aktif</SelectItem>
              <SelectItem value="inactive">Non-Aktif</SelectItem>
              <SelectItem value="lead">Lead</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardContent>
    </Card>

    <!-- Data Table -->
    <Card>
      <CardContent class="p-0">
        <!-- Loading -->
        <div v-if="store.loading" class="flex justify-center items-center py-24">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>

        <!-- Error -->
        <div v-else-if="store.error" class="text-center py-24 px-6">
          <p class="text-destructive">{{ store.error }}</p>
        </div>

        <!-- Empty -->
        <div v-else-if="store.customers.length === 0" class="text-center py-24 px-6">
          <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
            <Users class="w-6 h-6 text-muted-foreground" />
          </div>
          <h3 class="text-sm font-semibold">Tidak ada pelanggan</h3>
          <p class="text-sm text-muted-foreground mt-1">Sesuaikan filter pencarian atau tambahkan pelanggan baru.</p>
        </div>

        <!-- Table -->
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[300px]">Nama</TableHead>
              <TableHead>Kontak</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Didaftarkan</TableHead>
              <TableHead class="text-right">Aksi</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="customer in store.customers" :key="customer.id"
                       class="cursor-pointer group" @click="goDetail(customer.id)">
              <TableCell>
                <div class="flex items-center gap-3">
                  <Avatar class="h-9 w-9 flex-shrink-0">
                    <AvatarFallback class="bg-primary/10 text-primary text-xs font-semibold">
                      {{ customer.name.charAt(0).toUpperCase() }}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p class="font-medium">{{ customer.name }}</p>
                    <p class="text-xs text-muted-foreground font-mono">{{ customer.id.slice(0, 8) }}</p>
                  </div>
                </div>
              </TableCell>
              <TableCell>
                <p class="text-sm">{{ customer.email }}</p>
                <p class="text-xs text-muted-foreground">{{ customer.phone }}</p>
              </TableCell>
              <TableCell>
                <Badge :variant="formatStatus(customer.status).variant">
                  {{ formatStatus(customer.status).label }}
                </Badge>
              </TableCell>
              <TableCell class="text-muted-foreground">
                {{ new Date(customer.created_at).toLocaleDateString('id-ID') }}
              </TableCell>
              <TableCell class="text-right">
                <TooltipProvider>
                  <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Tooltip>
                      <TooltipTrigger as-child>
                        <Button variant="ghost" size="icon" class="h-8 w-8" @click.stop="goDetail(customer.id)">
                          <Eye class="h-4 w-4" />
                        </Button>
                      </TooltipTrigger>
                      <TooltipContent>Detail</TooltipContent>
                    </Tooltip>
                    <Tooltip>
                      <TooltipTrigger as-child>
                        <Button variant="ghost" size="icon" class="h-8 w-8" @click.stop>
                          <Edit class="h-4 w-4" />
                        </Button>
                      </TooltipTrigger>
                      <TooltipContent>Edit</TooltipContent>
                    </Tooltip>
                  </div>
                </TooltipProvider>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>

      <!-- Pagination -->
      <div v-if="store.customers.length > 0"
           class="flex items-center justify-between px-6 py-4 border-t">
        <p class="text-sm text-muted-foreground">
          Halaman {{ page }}
        </p>
        <div class="flex items-center gap-2">
          <Button variant="outline" size="icon" class="h-8 w-8" :disabled="page <= 1" @click="page--">
            <ChevronLeft class="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon" class="h-8 w-8" @click="page++">
            <ChevronRight class="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  </div>
</template>
