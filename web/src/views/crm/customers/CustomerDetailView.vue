<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Phone, Mail, MapPin, Loader2, Calendar, User } from 'lucide-vue-next'
import { getCustomerById } from '@/api/customers.api'
import type { Customer } from '@/types/customer.types'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'

const route = useRoute()
const router = useRouter()
const customer = ref<Customer | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)

onMounted(async () => {
  const id = route.params.id as string
  try {
    const res = await getCustomerById(id)
    customer.value = res.data.data
  } catch (e: any) {
    error.value = 'Gagal memuat detail pelanggan'
  } finally {
    loading.value = false
  }
})

const goBack = () => router.back()
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center gap-3">
      <Button variant="ghost" size="icon" @click="goBack" class="h-9 w-9">
        <ArrowLeft class="w-4 h-4" />
      </Button>
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Profil Pelanggan</h1>
        <p class="text-muted-foreground text-sm">Detail informasi dan aktivitas pelanggan</p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex justify-center py-24">
      <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <Card v-else-if="error" class="border-destructive bg-destructive/5">
      <CardContent class="py-6 text-center">
        <p class="text-destructive font-medium">{{ error }}</p>
      </CardContent>
    </Card>

    <!-- Content -->
    <div v-else-if="customer" class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Identity Card -->
      <Card class="md:col-span-1">
        <CardContent class="pt-8 text-center">
          <Avatar class="h-20 w-20 mx-auto mb-4">
            <AvatarFallback class="bg-primary/10 text-primary text-2xl font-bold">
              {{ customer.name.charAt(0).toUpperCase() }}
            </AvatarFallback>
          </Avatar>
          <h3 class="text-xl font-bold">{{ customer.name }}</h3>
          <Badge class="mt-2 capitalize">{{ customer.status }}</Badge>
        </CardContent>

        <Separator />

        <CardContent class="pt-6 space-y-4">
          <div class="flex items-center gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <Mail class="w-4 h-4 text-muted-foreground" />
            </div>
            <span class="truncate">{{ customer.email }}</span>
          </div>
          <div class="flex items-center gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <Phone class="w-4 h-4 text-muted-foreground" />
            </div>
            <span>{{ customer.phone }}</span>
          </div>
          <div class="flex items-start gap-3 text-sm">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0 mt-0.5">
              <MapPin class="w-4 h-4 text-muted-foreground" />
            </div>
            <span class="leading-relaxed">{{ customer.address }}</span>
          </div>

          <Separator />

          <div class="flex items-center gap-3 text-sm text-muted-foreground">
            <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
              <Calendar class="w-4 h-4 text-muted-foreground" />
            </div>
            <span>Bergabung: {{ new Date(customer.created_at).toLocaleDateString('id-ID') }}</span>
          </div>
        </CardContent>
      </Card>

      <!-- Activity Timeline -->
      <Card class="md:col-span-2">
        <CardHeader>
          <CardTitle>Aktivitas Terakhir</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="border-l-2 border-border ml-4 pl-6 space-y-8">
            <div class="relative">
              <div class="absolute -left-[31px] h-5 w-5 rounded-full bg-primary border-4 border-background"></div>
              <p class="text-xs text-muted-foreground mb-1">Hari ini</p>
              <p class="font-medium text-sm">Pelanggan dibuat</p>
            </div>
          </div>

          <Separator class="my-6" />

          <div class="text-center py-10">
            <div class="mx-auto w-14 h-14 bg-muted rounded-full flex items-center justify-center mb-4">
              <User class="w-6 h-6 text-muted-foreground" />
            </div>
            <p class="text-sm text-muted-foreground italic">
              Riwayat Kunjungan dan Deals CRM akan muncul di sini.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
