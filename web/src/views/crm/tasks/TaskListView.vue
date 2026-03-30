<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import {
  fetchTasks, createTask, updateTask, completeTask, deleteTask,
  type Task, type TaskStatus, type TaskPriority
} from '@/api/tasks.api'
import { fetchUsers } from '@/api/auth.api'
import {
  Plus, Search, Loader2, Calendar, ClipboardCheck,
  MoreHorizontal, Edit, Trash2, CheckCircle, AlertTriangle, Clock
} from 'lucide-vue-next'
import { useDebounce } from '@vueuse/core'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import {
  Dialog, DialogContent, DialogDescription, DialogFooter,
  DialogHeader, DialogTitle
} from '@/components/ui/dialog'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()
const tasks = ref<Task[]>([])
const users = ref<any[]>([])
const loading = ref(false)
const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const statusFilter = ref<string>('all')

// Dialog state
const showTaskDialog = ref(false)
const editingTask = ref<Task | null>(null)
const saving = ref(false)
const formData = ref({
  title: '',
  description: '',
  assigned_to: '',
  priority: 'medium' as TaskPriority,
  due_at: ''
})

async function loadTasks() {
  loading.value = true
  try {
    const res = await fetchTasks({
      search: debouncedSearch.value,
      status: statusFilter.value === 'all' ? undefined : statusFilter.value
    })
    tasks.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load tasks', e)
  } finally {
    loading.value = false
  }
}

async function loadUsers() {
  try {
    const res = await fetchUsers()
    users.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load users', e)
  }
}

onMounted(() => {
  loadTasks()
  loadUsers()
})

watch([debouncedSearch, statusFilter], loadTasks)

function openCreate() {
  editingTask.value = null
  formData.value = { title: '', description: '', assigned_to: '', priority: 'medium', due_at: '' }
  showTaskDialog.value = true
}

function openEdit(task: Task) {
  editingTask.value = task
  formData.value = {
    title: task.title,
    description: task.description || '',
    assigned_to: task.assigned_to,
    priority: task.priority,
    due_at: task.due_at ? task.due_at.split('T')[0] : ''
  }
  showTaskDialog.value = true
}

async function handleSave() {
  saving.value = true
  try {
    if (editingTask.value) {
      await updateTask(editingTask.value.id, formData.value)
      toast({ title: 'Tugas diperbarui', description: `Tugas "${formData.value.title}" berhasil diubah.` })
    } else {
      await createTask(formData.value)
      toast({ title: 'Tugas ditambahkan', description: `Tugas "${formData.value.title}" berhasil dibuat.` })
    }
    showTaskDialog.value = false
    loadTasks()
  } catch (e: any) {
    toast({ title: 'Gagal menyimpan', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    saving.value = false
  }
}

async function markComplete(id: string) {
  try {
    await completeTask(id)
    toast({ title: 'Selesai', description: 'Tugas berhasil ditandai sebagai selesai.' })
    loadTasks()
  } catch (e: any) {
    toast({ title: 'Gagal', description: e.response?.data?.error?.message || 'Gagal mengubah status', variant: 'destructive' })
  }
}

async function removeTask(id: string) {
  if (!confirm('Hapus tugas ini?')) return
  try {
    await deleteTask(id)
    toast({ title: 'Terhapus', description: 'Tugas berhasil dihapus dari sistem.' })
    loadTasks()
  } catch (e: any) {
    toast({ title: 'Gagal', description: e.response?.data?.error?.message || 'Gagal menghapus tugas', variant: 'destructive' })
  }
}

const getPriorityVariant = (priority: string) => {
  const map: Record<string, 'default' | 'secondary' | 'outline' | 'destructive'> = {
    low: 'outline', medium: 'secondary', high: 'default', urgent: 'destructive'
  }
  return map[priority] || 'secondary'
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'done': return CheckCircle
    case 'in_progress': return Clock
    case 'cancelled': return AlertTriangle
    default: return Clock
  }
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Daftar Tugas</h1>
        <p class="text-muted-foreground mt-1">Delegasi dan monitoring aktivitas tim sales.</p>
      </div>
      <Button size="sm" @click="openCreate">
        <Plus class="w-4 h-4 mr-2" />
        Tugas Baru
      </Button>
    </div>

    <Card>
      <CardHeader class="flex flex-row items-center justify-between py-4">
        <CardTitle class="text-sm font-medium">Monitoring Aktivitas</CardTitle>
        <div class="flex items-center gap-2">
          <div class="relative w-64">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input v-model="searchInput" class="pl-9 h-9" placeholder="Cari judul atau isi..." />
          </div>
          <Select v-model="statusFilter">
            <SelectTrigger class="w-[140px] h-9">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Status</SelectItem>
              <SelectItem value="pending">Pending</SelectItem>
              <SelectItem value="in_progress">Berjalan</SelectItem>
              <SelectItem value="done">Selesai</SelectItem>
              <SelectItem value="cancelled">Dibatalkan</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardHeader>
      <CardContent class="p-0">
        <div v-if="loading" class="flex justify-center py-20">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <div v-else-if="tasks.length === 0" class="text-center py-20">
          <ClipboardCheck class="h-12 w-12 mx-auto text-muted-foreground/30 mb-4" />
          <h3 class="font-semibold text-muted-foreground">Belum ada tugas</h3>
          <p class="text-sm text-muted-foreground">Delegasikan tugas ke tim sales untuk mulai memonitor.</p>
        </div>
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead>Tugas</TableHead>
              <TableHead>Prioritas</TableHead>
              <TableHead>Assigned To</TableHead>
              <TableHead>Deadline</TableHead>
              <TableHead>Status</TableHead>
              <TableHead class="text-right">Aksi</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="task in tasks" :key="task.id" :class="task.status === 'done' ? 'opacity-60 grayscale' : ''">
              <TableCell class="w-[300px]">
                <div>
                  <p class="font-medium text-sm">{{ task.title }}</p>
                  <p v-if="task.description" class="text-xs text-muted-foreground line-clamp-1">{{ task.description }}</p>
                </div>
              </TableCell>
              <TableCell>
                <Badge :variant="getPriorityVariant(task.priority)" class="text-[10px] uppercase font-bold tracking-tight">
                  {{ task.priority }}
                </Badge>
              </TableCell>
              <TableCell>
                <div class="flex items-center gap-2">
                  <Avatar class="h-6 w-6">
                    <AvatarFallback class="text-[10px]">{{ task.assigned_name?.charAt(0) || '?' }}</AvatarFallback>
                  </Avatar>
                  <span class="text-xs">{{ task.assigned_name || 'Unassigned' }}</span>
                </div>
              </TableCell>
              <TableCell class="text-xs text-muted-foreground">
                {{ task.due_at ? new Date(task.due_at).toLocaleDateString('id-ID') : '-' }}
              </TableCell>
              <TableCell>
                <div class="flex items-center gap-1.5 text-xs">
                  <component :is="getStatusIcon(task.status)" class="w-3.5 h-3.5" />
                  <span class="capitalize">{{ task.status.replace('_', ' ') }}</span>
                </div>
              </TableCell>
              <TableCell class="text-right">
                <DropdownMenu>
                  <DropdownMenuTrigger as-child>
                    <Button variant="ghost" size="icon" class="h-8 w-8">
                      <MoreHorizontal class="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem v-if="task.status !== 'done'" @click="markComplete(task.id)">
                      <CheckCircle class="w-4 h-4 mr-2 text-emerald-600" /> Selesai
                    </DropdownMenuItem>
                    <DropdownMenuItem @click="openEdit(task)">
                      <Edit class="w-4 h-4 mr-2" /> Detail / Edit
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem class="text-destructive focus:text-destructive" @click="removeTask(task.id)">
                      <Trash2 class="w-4 h-4 mr-2" /> Hapus
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>

    <!-- Form Dialog -->
    <Dialog v-model:open="showTaskDialog">
       <DialogContent class="sm:max-w-[450px]">
        <DialogHeader>
          <DialogTitle>{{ editingTask ? 'Detail Tugas' : 'Beri Tugas Baru' }}</DialogTitle>
          <DialogDescription>Delegasikan aktivitas lapangan kepada anggota tim.</DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleSave" class="space-y-4 pt-2">
          <div class="space-y-2">
            <Label for="t-title">Judul Tugas</Label>
            <Input id="t-title" v-model="formData.title" placeholder="Follow up penawaran..." required />
          </div>
          <div class="space-y-2">
            <Label for="t-assigned">Assigned To</Label>
            <Select v-model="formData.assigned_to">
              <SelectTrigger id="t-assigned">
                <SelectValue placeholder="Pilih Anggota Tim" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="user in users" :key="user.id" :value="user.id">{{ user.name }}</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label>Prioritas</Label>
              <Select v-model="formData.priority">
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="low">Rendah</SelectItem>
                  <SelectItem value="medium">Menengah</SelectItem>
                  <SelectItem value="high">Tinggi</SelectItem>
                  <SelectItem value="urgent">Gawat / Mendesak</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="space-y-2">
              <Label>Deadline</Label>
              <Input type="date" v-model="formData.due_at" required />
            </div>
          </div>
          <div class="space-y-2">
            <Label>Deskripsi / Instruksi</Label>
            <Input v-model="formData.description" placeholder="Instruksi tambahan..." />
          </div>

          <DialogFooter class="pt-4">
             <Button type="button" variant="outline" @click="showTaskDialog = false">Batal</Button>
             <Button type="submit" :disabled="saving">
              <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
              Simpan Tugas
             </Button>
          </DialogFooter>
        </form>
       </DialogContent>
    </Dialog>
  </div>
</template>
