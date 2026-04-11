<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchUsers, updateUser } from '@/api/auth.api'
import {
  Loader2, RefreshCw, Shield, UserCog, Users, Mail, TrendingUp, CheckCircle2
} from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()
const loading = ref(false)
const users = ref<any[]>([])

async function loadData() {
  loading.value = true
  try {
    const res = await fetchUsers()
    users.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load user data', e)
  } finally {
    loading.value = false
  }
}

async function handleUpdateSalesType(userId: string, type: string) {
  try {
    await updateUser(userId, { sales_type: type })
    toast({
      title: 'Tipe Sales Diperbarui',
      description: `Berhasil mengubah tipe sales menjadi ${type.replace('_', ' ')}.`
    })
    loadData()
  } catch (e: any) {
    toast({
      title: 'Gagal memperbarui',
      description: e.response?.data?.error?.message || 'Terjadi kesalahan sistem.',
      variant: 'destructive'
    })
  }
}

onMounted(() => loadData())

const getRoleBadge = (role: string) => {
  const map: Record<string, { label: string, variant: 'default' | 'secondary' | 'outline' }> = {
    super_admin: { label: 'Super Admin', variant: 'default' },
    manager: { label: 'Manager', variant: 'default' },
    supervisor: { label: 'Supervisor', variant: 'secondary' },
    sales: { label: 'Sales', variant: 'outline' }
  }
  return map[role] || { label: role, variant: 'outline' as const }
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">User Management</h1>
        <p class="text-muted-foreground mt-1">Kelola pengguna, role, dan hak akses sistem.</p>
      </div>
      <div class="flex items-center gap-2">
        <Button variant="outline" size="sm" @click="loadData" :disabled="loading">
          <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
          Refresh
        </Button>
        <Button size="sm">
          <UserCog class="w-4 h-4 mr-2" />
          Tambah User
        </Button>
      </div>
    </div>

    <!-- Info Banner -->
    <Card class="border-amber-200 dark:border-amber-900/50 bg-amber-50/50 dark:bg-amber-950/20">
      <CardContent class="py-3 flex items-center gap-3">
        <Shield class="w-5 h-5 text-amber-600 dark:text-amber-400 flex-shrink-0" />
        <p class="text-sm text-amber-700 dark:text-amber-300">
          Daftar pengguna ditarik secara real-time dari database. Fitur pembuatan pengguna baru (register/invite) tersedia di tombol aksi.
        </p>
      </CardContent>
    </Card>

    <!-- Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Pengguna</CardTitle>
          <Users class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ users.length }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Tim Sales</CardTitle>
          <Users class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ users.filter(u => u.role === 'sales').length }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Management</CardTitle>
          <Shield class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ users.filter(u => ['super_admin', 'manager', 'supervisor'].includes(u.role)).length }}</div>
        </CardContent>
      </Card>
    </div>

    <!-- Users Table -->
    <Card>
      <CardHeader>
        <CardTitle class="text-base">Daftar Pengguna</CardTitle>
        <CardDescription>Semua anggota tim yang terdaftar dalam sistem</CardDescription>
      </CardHeader>
      <CardContent class="p-0">
        <div v-if="loading" class="flex justify-center py-16">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <div v-else-if="users.length === 0" class="text-center py-16">
          <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
            <Users class="w-6 h-6 text-muted-foreground" />
          </div>
          <p class="text-sm text-muted-foreground">Belum ada data pengguna.</p>
        </div>
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[50px]">#</TableHead>
              <TableHead>Nama</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>Tipe Sales</TableHead>
              <TableHead class="text-center">Email</TableHead>
              <TableHead class="text-center">Status</TableHead>
              <TableHead class="text-right">Last Login</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="(user, i) in users" :key="user.sales_id">
              <TableCell class="font-medium text-muted-foreground">{{ i + 1 }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-3">
                  <Avatar class="h-9 w-9">
                    <AvatarFallback class="text-xs bg-primary/10 text-primary font-semibold">
                      {{ user.name.charAt(0) }}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p class="font-medium">{{ user.name }}</p>
                    <p class="text-xs text-muted-foreground font-mono">{{ user.id.slice(0, 8) }}</p>
                  </div>
                </div>
              </TableCell>
               <TableCell>
                <Badge :variant="getRoleBadge(user.role).variant">
                  {{ getRoleBadge(user.role).label }}
                </Badge>
              </TableCell>
              <TableCell>
                <div v-if="user.role === 'sales'" class="w-[140px]">
                  <Select :modelValue="user.sales_type" @update:modelValue="(val: string) => handleUpdateSalesType(user.id, val)">
                    <SelectTrigger class="h-8 text-xs capitalize">
                      <SelectValue :placeholder="user.sales_type?.replace('_', ' ') || 'Belum diatur'" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="motoris">Motoris</SelectItem>
                      <SelectItem value="task_order">Task Order</SelectItem>
                      <SelectItem value="canvas">Canvas</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <span v-else class="text-xs text-muted-foreground">-</span>
              </TableCell>
              <TableCell class="text-center font-mono text-muted-foreground">
                {{ user.email }}
              </TableCell>
              <TableCell class="text-center font-mono">
                {{ user.status }}
              </TableCell>
              <TableCell class="text-right font-mono text-xs text-muted-foreground">
                {{ user.last_login_at ? new Date(user.last_login_at).toLocaleDateString('id-ID') : 'Never' }}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  </div>
</template>
