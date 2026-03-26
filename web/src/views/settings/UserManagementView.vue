<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchAnalytics } from '@/api/reports.api'
import {
  Loader2, RefreshCw, Shield, UserCog, Users, Mail
} from 'lucide-vue-next'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Separator } from '@/components/ui/separator'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'

const loading = ref(false)
const users = ref<any[]>([])

async function loadData() {
  loading.value = true
  try {
    const res = await fetchAnalytics(6)
    users.value = res.data.data.top_performers || []
  } catch (e) {
    console.error('Failed to load user data', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())

const getRoleBadge = (index: number) => {
  if (index === 0) return { label: 'Supervisor', variant: 'default' as const }
  return { label: 'Sales', variant: 'secondary' as const }
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
    <Card class="border-blue-200 dark:border-blue-900/50 bg-blue-50/50 dark:bg-blue-950/20">
      <CardContent class="py-3 flex items-center gap-3">
        <Shield class="w-5 h-5 text-blue-600 dark:text-blue-400 flex-shrink-0" />
        <p class="text-sm text-blue-700 dark:text-blue-300">
          Data pengguna diambil dari laporan analytics. Fitur CRUD pengguna lengkap akan tersedia setelah endpoint admin APIs ditambahkan.
        </p>
      </CardContent>
    </Card>

    <!-- Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Tim Sales</CardTitle>
          <Users class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ users.length }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Kunjungan</CardTitle>
          <Users class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-3xl font-bold">{{ users.reduce((s: number, u: any) => s + (u.total_visits || 0), 0) }}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader class="flex flex-row items-center justify-between pb-2 space-y-0">
          <CardTitle class="text-sm font-medium text-muted-foreground">Total Revenue</CardTitle>
          <Users class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <Loader2 v-if="loading" class="w-6 h-6 animate-spin text-muted-foreground" />
          <div v-else class="text-2xl font-bold truncate">
            {{ new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(users.reduce((s: number, u: any) => s + (u.revenue || 0), 0)) }}
          </div>
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
              <TableHead class="text-center">Kunjungan</TableHead>
              <TableHead class="text-center">Valid</TableHead>
              <TableHead class="text-right">Revenue</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="(user, i) in users" :key="user.sales_id">
              <TableCell class="font-medium text-muted-foreground">{{ i + 1 }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-3">
                  <Avatar class="h-9 w-9">
                    <AvatarFallback class="text-xs bg-primary/10 text-primary font-semibold">
                      {{ user.sales_name.charAt(0) }}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p class="font-medium">{{ user.sales_name }}</p>
                    <p class="text-xs text-muted-foreground font-mono">{{ user.sales_id.slice(0, 8) }}</p>
                  </div>
                </div>
              </TableCell>
              <TableCell>
                <Badge :variant="getRoleBadge(i).variant">
                  {{ getRoleBadge(i).label }}
                </Badge>
              </TableCell>
              <TableCell class="text-center font-mono">{{ user.total_visits }}</TableCell>
              <TableCell class="text-center font-mono">{{ user.valid_checkins }}</TableCell>
              <TableCell class="text-right font-mono text-sm">
                {{ new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(user.revenue) }}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  </div>
</template>
