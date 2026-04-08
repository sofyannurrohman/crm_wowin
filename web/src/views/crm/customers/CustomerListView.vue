<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useCustomerStore } from '@/stores/customers.store'
import { useRouter } from 'vue-router'
import { 
  Plus, Search, MapPin, Loader2, Eye, Edit, Users, 
  ChevronLeft, ChevronRight, Building2, UserCircle, Mail, Phone
} from 'lucide-vue-next'
import { useDebounce } from '@vueuse/core'
import type { Customer, CustomerStatus } from '@/types/customer.types'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
import {
  Dialog, DialogContent, DialogDescription, DialogFooter,
  DialogHeader, DialogTitle
} from '@/components/ui/dialog'
import { useToast } from '@/components/ui/toast/use-toast'

const store = useCustomerStore()
const router = useRouter()
const { toast } = useToast()

const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedStatus = ref<string>('all')
const page = ref(1)

// Dialog State
const showDialog = ref(false)
const saving = ref(false)
const formData = ref({
  name: '',
  industry: '',
  email: '',
  phone: '',
  status: 'prospect' as CustomerStatus
})

const businessTypes = [
  'Warung Makan', 
  'Toko Kelontong', 
  'Retail / Minimarket', 
  'Agen / Distributor', 
  'Restoran', 
  'Cafe', 
  'Lainnya'
]

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

function openCreate() {
  formData.value = {
    name: '',
    industry: '',
    email: '',
    phone: '',
    status: 'prospect'
  }
  showDialog.value = true
}

async function handleSave() {
  if (!formData.value.name || !formData.value.industry) {
    toast({ title: 'Input tidak valid', description: 'Nama dan Tipe Bisnis wajib diisi', variant: 'destructive' })
    return
  }

  saving.value = true
  try {
    // Map industry to backend type value
    let typeValue = 'company'
    const ind = formData.value.industry
    if (ind === 'Warung Makan') typeValue = 'warung'
    else if (ind === 'Toko Kelontong') typeValue = 'toko'
    else if (ind === 'Retail / Minimarket') typeValue = 'retail'
    else if (ind === 'Agen / Distributor') typeValue = 'agen'
    else if (ind === 'Restoran') typeValue = 'restoran'
    else if (ind === 'Cafe') typeValue = 'cafe'
    else if (ind === 'Lainnya') typeValue = 'lainnya'

    const payload = {
      ...formData.value,
      type: typeValue as any,
      company_name: formData.value.name
    }

    await store.createCustomer(payload)
    toast({ title: 'Berhasil', description: `Customer "${formData.value.name}" telah dibuat.` })
    showDialog.value = false
  } catch (e: any) {
    toast({ 
      title: 'Gagal membuat customer', 
      description: e.response?.data?.error || 'Terjadi kesalahan pada server', 
      variant: 'destructive' 
    })
  } finally {
    saving.value = false
  }
}

const goDetail = (id: string) => router.push(`/customers/${id}`)

const formatStatus = (status: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' | 'destructive' }> = {
    active: { label: 'Aktif', variant: 'default' },
    inactive: { label: 'Non-Aktif', variant: 'secondary' },
    prospect: { label: 'Prospek / Lead', variant: 'outline' }
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
        <Button size="sm" @click="openCreate">
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
              <SelectItem value="prospect">Lead / Prospek</SelectItem>
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

    <!-- Dialog Add Customer -->
    <Dialog :open="showDialog" @update:open="showDialog = $event">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>Tambah Pelanggan Baru</DialogTitle>
          <DialogDescription>
            Lengkapi data di bawah ini untuk mendaftarkan pelanggan baru ke sistem.
          </DialogDescription>
        </DialogHeader>

        <div class="grid gap-6 py-4">
          <!-- Basic Info Section -->
          <div class="space-y-4">
            <div class="grid gap-2">
              <Label for="name">Nama Bisnis / Toko</Label>
              <div class="relative">
                <Building2 class="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                <Input id="name" v-model="formData.name" placeholder="Contoh: Toko Berkah Jaya" class="pl-10" />
              </div>
            </div>

            <div class="grid gap-2">
              <Label>Tipe Bisnis / Kategori</Label>
              <Select v-model="formData.industry">
                <SelectTrigger>
                  <SelectValue placeholder="Pilih Tipe Bisnis" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="type in businessTypes" :key="type" :value="type">
                    {{ type }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <Separator />

          <!-- Contact Info Section -->
          <div class="space-y-4">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Informasi Kontak</h4>
            
            <div class="grid gap-2">
              <Label for="phone">Nomor Telepon</Label>
              <div class="relative">
                <Phone class="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                <Input id="phone" v-model="formData.phone" placeholder="0812..." class="pl-10" />
              </div>
            </div>

            <div class="grid gap-2">
              <Label for="email">Alamat Email</Label>
              <div class="relative">
                <Mail class="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                <Input id="email" v-model="formData.email" placeholder="email@toko.com" class="pl-10" />
              </div>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="showDialog = false" :disabled="saving">Batal</Button>
          <Button @click="handleSave" :disabled="saving">
            <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
            Simpan Pelanggan
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
