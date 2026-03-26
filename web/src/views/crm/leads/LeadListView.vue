<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { useLeadStore } from '@/stores/leads.store'
import { useDebounce } from '@vueuse/core'
import type { LeadStatus, LeadSource, Lead } from '@/types/lead.types'
import {
  Plus, Search, Loader2, Eye, Edit, Trash2, ArrowRightLeft,
  UserPlus, ChevronLeft, ChevronRight, MoreHorizontal
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  Dialog, DialogContent, DialogDescription, DialogFooter,
  DialogHeader, DialogTitle
} from '@/components/ui/dialog'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem,
  DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Separator } from '@/components/ui/separator'
import { useToast } from '@/components/ui/toast/use-toast'

const store = useLeadStore()
const { toast } = useToast()

const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedStatus = ref<string>('all')
const selectedSource = ref<string>('all')
const page = ref(1)

// Dialog state
const showDialog = ref(false)
const editingLead = ref<Lead | null>(null)
const saving = ref(false)
const formData = ref({
  title: '',
  name: '',
  company: '',
  email: '',
  phone: '',
  source: 'cold_call' as LeadSource,
  status: 'new' as LeadStatus,
  estimated_value: 0,
  notes: ''
})

// Delete confirmation
const showDeleteDialog = ref(false)
const deletingLead = ref<Lead | null>(null)
const deleting = ref(false)

const isEditing = computed(() => !!editingLead.value)

const loadLeads = () => {
  store.fetchAll({
    search: debouncedSearch.value,
    status: selectedStatus.value === 'all' ? undefined : (selectedStatus.value as LeadStatus),
    source: selectedSource.value === 'all' ? undefined : (selectedSource.value as LeadSource),
    page: page.value,
    limit: 15
  })
}

watch([debouncedSearch, selectedStatus, selectedSource, page], () => {
  loadLeads()
})

onMounted(() => {
  loadLeads()
})

function openCreate() {
  editingLead.value = null
  formData.value = { title: '', name: '', company: '', email: '', phone: '', source: 'cold_call', status: 'new', estimated_value: 0, notes: '' }
  showDialog.value = true
}

function openEdit(lead: Lead) {
  editingLead.value = lead
  formData.value = {
    title: lead.title,
    name: lead.name,
    company: lead.company || '',
    email: lead.email || '',
    phone: lead.phone || '',
    source: lead.source,
    status: lead.status,
    estimated_value: lead.estimated_value || 0,
    notes: lead.notes || ''
  }
  showDialog.value = true
}

async function handleSave() {
  saving.value = true
  try {
    const payload: any = { ...formData.value }
    if (!payload.company) delete payload.company
    if (!payload.email) delete payload.email
    if (!payload.phone) delete payload.phone
    if (!payload.notes) delete payload.notes
    if (!payload.estimated_value) delete payload.estimated_value

    if (isEditing.value) {
      await store.update(editingLead.value!.id, payload)
      toast({ title: 'Lead diperbarui', description: `Lead "${formData.value.name}" berhasil diperbarui.` })
    } else {
      await store.create(payload)
      toast({ title: 'Lead ditambahkan', description: `Lead "${formData.value.name}" berhasil dibuat.` })
    }
    showDialog.value = false
  } catch (e: any) {
    toast({ title: 'Gagal menyimpan', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    saving.value = false
  }
}

function confirmDelete(lead: Lead) {
  deletingLead.value = lead
  showDeleteDialog.value = true
}

async function handleDelete() {
  if (!deletingLead.value) return
  deleting.value = true
  try {
    await store.remove(deletingLead.value.id)
    toast({ title: 'Lead dihapus', description: `Lead "${deletingLead.value.name}" berhasil dihapus.` })
    showDeleteDialog.value = false
  } catch (e: any) {
    toast({ title: 'Gagal menghapus', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    deleting.value = false
  }
}

async function handleConvert(lead: Lead) {
  try {
    await store.convert(lead.id)
    toast({ title: 'Lead dikonversi', description: `"${lead.name}" telah diubah menjadi pelanggan.` })
  } catch (e: any) {
    toast({ title: 'Gagal konversi', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  }
}

const formatStatus = (status: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' | 'destructive' }> = {
    new: { label: 'Baru', variant: 'default' },
    contacted: { label: 'Dihubungi', variant: 'outline' },
    qualified: { label: 'Qualified', variant: 'default' },
    unqualified: { label: 'Unqualified', variant: 'destructive' },
  }
  return map[status] || { label: status, variant: 'secondary' as const }
}

const formatSource = (source: string) => {
  const map: Record<string, string> = {
    referral: 'Referral', cold_call: 'Cold Call', social_media: 'Social Media',
    website: 'Website', event: 'Event', other: 'Lainnya'
  }
  return map[source] || source
}

const formatCurrency = (val: number) => {
  if (!val) return '-'
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
}
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Leads</h1>
        <p class="text-muted-foreground mt-1">Kelola daftar prospek dan peluang bisnis baru.</p>
      </div>
      <Button size="sm" @click="openCreate">
        <Plus class="w-4 h-4 mr-2" />
        Lead Baru
      </Button>
    </div>

    <!-- Filters -->
    <Card>
      <CardContent class="pt-6">
        <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div class="relative w-full max-w-sm">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input v-model="searchInput" class="pl-9" placeholder="Cari nama, email, perusahaan..." />
          </div>
          <Select v-model="selectedStatus">
            <SelectTrigger class="w-[160px]">
              <SelectValue placeholder="Semua Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Status</SelectItem>
              <SelectItem value="new">Baru</SelectItem>
              <SelectItem value="contacted">Dihubungi</SelectItem>
              <SelectItem value="qualified">Qualified</SelectItem>
              <SelectItem value="unqualified">Unqualified</SelectItem>
            </SelectContent>
          </Select>
          <Select v-model="selectedSource">
            <SelectTrigger class="w-[160px]">
              <SelectValue placeholder="Semua Sumber" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Sumber</SelectItem>
              <SelectItem value="referral">Referral</SelectItem>
              <SelectItem value="cold_call">Cold Call</SelectItem>
              <SelectItem value="social_media">Social Media</SelectItem>
              <SelectItem value="website">Website</SelectItem>
              <SelectItem value="event">Event</SelectItem>
              <SelectItem value="other">Lainnya</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardContent>
    </Card>

    <!-- Data Table -->
    <Card>
      <CardContent class="p-0">
        <div v-if="store.loading" class="flex justify-center items-center py-24">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>

        <div v-else-if="store.error" class="text-center py-24 px-6">
          <p class="text-destructive">{{ store.error }}</p>
        </div>

        <div v-else-if="store.leads.length === 0" class="text-center py-24 px-6">
          <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
            <UserPlus class="w-6 h-6 text-muted-foreground" />
          </div>
          <h3 class="text-sm font-semibold">Tidak ada leads</h3>
          <p class="text-sm text-muted-foreground mt-1">Tambahkan lead baru untuk mulai mengelola prospek Anda.</p>
          <Button size="sm" class="mt-4" @click="openCreate">
            <Plus class="w-4 h-4 mr-2" /> Tambah Lead
          </Button>
        </div>

        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[250px]">Lead</TableHead>
              <TableHead>Kontak</TableHead>
              <TableHead>Sumber</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Est. Value</TableHead>
              <TableHead>Tanggal</TableHead>
              <TableHead class="text-right w-[80px]">Aksi</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="lead in store.leads" :key="lead.id" class="group">
              <TableCell>
                <div>
                  <p class="font-medium">{{ lead.title }}</p>
                  <p class="text-xs text-muted-foreground">{{ lead.name }}<span v-if="lead.company"> · {{ lead.company }}</span></p>
                </div>
              </TableCell>
              <TableCell>
                <p class="text-sm">{{ lead.email || '-' }}</p>
                <p class="text-xs text-muted-foreground">{{ lead.phone || '-' }}</p>
              </TableCell>
              <TableCell>
                <Badge variant="outline" class="text-[11px]">{{ formatSource(lead.source) }}</Badge>
              </TableCell>
              <TableCell>
                <Badge :variant="formatStatus(lead.status).variant">
                  {{ formatStatus(lead.status).label }}
                </Badge>
              </TableCell>
              <TableCell class="font-mono text-sm">
                {{ formatCurrency(lead.estimated_value || 0) }}
              </TableCell>
              <TableCell class="text-muted-foreground text-sm">
                {{ new Date(lead.created_at).toLocaleDateString('id-ID') }}
              </TableCell>
              <TableCell class="text-right">
                <DropdownMenu>
                  <DropdownMenuTrigger as-child>
                    <Button variant="ghost" size="icon" class="h-8 w-8">
                      <MoreHorizontal class="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem @click="openEdit(lead)">
                      <Edit class="w-4 h-4 mr-2" /> Edit
                    </DropdownMenuItem>
                    <DropdownMenuItem v-if="!lead.converted_at" @click="handleConvert(lead)">
                      <ArrowRightLeft class="w-4 h-4 mr-2" /> Konversi ke Pelanggan
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem class="text-destructive focus:text-destructive" @click="confirmDelete(lead)">
                      <Trash2 class="w-4 h-4 mr-2" /> Hapus
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>

      <div v-if="store.leads.length > 0" class="flex items-center justify-between px-6 py-4 border-t">
        <p class="text-sm text-muted-foreground">Halaman {{ page }}</p>
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

    <!-- Create/Edit Dialog -->
    <Dialog v-model:open="showDialog">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{{ isEditing ? 'Edit Lead' : 'Tambah Lead Baru' }}</DialogTitle>
          <DialogDescription>
            {{ isEditing ? 'Perbarui informasi lead yang ada.' : 'Masukkan informasi calon prospek bisnis.' }}
          </DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleSave" class="space-y-4 py-2">
          <div class="grid grid-cols-2 gap-4">
            <div class="col-span-2 space-y-2">
              <Label for="title">Judul Lead</Label>
              <Input id="title" v-model="formData.title" placeholder="Proyek pembangunan gedung A" required />
            </div>
            <div class="space-y-2">
              <Label for="name">Nama Kontak</Label>
              <Input id="name" v-model="formData.name" placeholder="Budi Santoso" required />
            </div>
            <div class="space-y-2">
              <Label for="company">Perusahaan</Label>
              <Input id="company" v-model="formData.company" placeholder="PT ABC" />
            </div>
            <div class="space-y-2">
              <Label for="email">Email</Label>
              <Input id="email" type="email" v-model="formData.email" placeholder="budi@abc.com" />
            </div>
            <div class="space-y-2">
              <Label for="phone">Telepon</Label>
              <Input id="phone" v-model="formData.phone" placeholder="08123456789" />
            </div>
            <div class="space-y-2">
              <Label>Sumber</Label>
              <Select v-model="formData.source">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="referral">Referral</SelectItem>
                  <SelectItem value="cold_call">Cold Call</SelectItem>
                  <SelectItem value="social_media">Social Media</SelectItem>
                  <SelectItem value="website">Website</SelectItem>
                  <SelectItem value="event">Event</SelectItem>
                  <SelectItem value="other">Lainnya</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Status</Label>
              <Select v-model="formData.status">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="new">Baru</SelectItem>
                  <SelectItem value="contacted">Dihubungi</SelectItem>
                  <SelectItem value="qualified">Qualified</SelectItem>
                  <SelectItem value="unqualified">Unqualified</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="col-span-2 space-y-2">
              <Label for="value">Estimasi Nilai (IDR)</Label>
              <Input id="value" type="number" v-model.number="formData.estimated_value" placeholder="0" />
            </div>
          </div>

          <DialogFooter>
            <Button type="button" variant="outline" @click="showDialog = false">Batal</Button>
            <Button type="submit" :disabled="saving">
              <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
              {{ isEditing ? 'Simpan' : 'Tambah' }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation Dialog -->
    <Dialog v-model:open="showDeleteDialog">
      <DialogContent class="sm:max-w-[400px]">
        <DialogHeader>
          <DialogTitle>Hapus Lead</DialogTitle>
          <DialogDescription>
            Apakah Anda yakin ingin menghapus lead "{{ deletingLead?.name }}"? Tindakan ini tidak dapat dibatalkan.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" @click="showDeleteDialog = false">Batal</Button>
          <Button variant="destructive" :disabled="deleting" @click="handleDelete">
            <Loader2 v-if="deleting" class="w-4 h-4 mr-2 animate-spin" />
            Hapus
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
