<script setup lang="ts">
import { ref } from 'vue'
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import * as z from 'zod'
import { useAuthStore } from '@/stores/auth.store'
import { useRouter, useRoute } from 'vue-router'
import { Lock, Mail, AlertCircle, Loader2 } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'

const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()

const schema = toTypedSchema(
  z.object({
    email: z.string().min(1, 'Email wajib diisi').email('Format email tidak valid'),
    password: z.string().min(6, 'Password minimal 6 karakter'),
  })
)

const { handleSubmit, errors, defineField, isSubmitting } = useForm({
  validationSchema: schema,
})

const [email, emailAttrs] = defineField('email')
const [password, passwordAttrs] = defineField('password')
const localError = ref('')

const onSubmit = handleSubmit(async (values) => {
  localError.value = ''
  try {
    await authStore.login(values.email, values.password)
    const redirectPath = route.query.redirect as string
    if (redirectPath && redirectPath !== '/login') {
      router.push(redirectPath)
    } else {
      router.push('/dashboard')
    }
  } catch (e: any) {
    if (authStore.error) {
       localError.value = authStore.error
    } else {
       localError.value = e.response?.data?.error?.message || 'Terjadi kesalahan tidak terduga saat login'
    }
  }
})
</script>

<template>
  <div class="min-h-screen flex">
    <!-- Left Panel - Branding -->
    <div class="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-foreground">
      <!-- Gradient overlay -->
      <div class="absolute inset-0 bg-gradient-to-br from-blue-600/90 via-indigo-700/80 to-purple-800/90 z-10"></div>
      <!-- Pattern background -->
      <div class="absolute inset-0 opacity-[0.04] z-20"
           style="background-image: url('data:image/svg+xml,%3Csvg width=&quot;60&quot; height=&quot;60&quot; viewBox=&quot;0 0 60 60&quot; xmlns=&quot;http://www.w3.org/2000/svg&quot;%3E%3Cg fill=&quot;none&quot; fill-rule=&quot;evenodd&quot;%3E%3Cg fill=&quot;%23ffffff&quot; fill-opacity=&quot;1&quot;%3E%3Cpath d=&quot;M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z&quot;/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')">
      </div>
      <!-- Content -->
      <div class="relative z-30 flex flex-col justify-between p-12 text-white">
        <div>
          <div class="w-12 h-12 rounded-xl bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/20">
            <span class="text-white text-2xl font-bold">W</span>
          </div>
        </div>
        <div>
          <h1 class="text-4xl font-bold tracking-tight mb-4 leading-tight">
            Enterprise Sales<br />Force Automation
          </h1>
          <p class="text-white/70 text-lg max-w-md leading-relaxed">
            Kelola pipeline penjualan, monitor tim lapangan secara real-time, dan optimalkan pencapaian target bisnis Anda.
          </p>
          <div class="mt-8 flex items-center gap-6">
            <div class="flex -space-x-2">
              <div v-for="i in 4" :key="i"
                   class="w-8 h-8 rounded-full bg-white/20 border-2 border-white/30 backdrop-blur-sm flex items-center justify-center text-[10px] font-bold">
                {{ ['A','B','C','D'][i-1] }}
              </div>
            </div>
            <span class="text-white/60 text-sm">Dipercaya 200+ tim sales Indonesia</span>
          </div>
        </div>
        <p class="text-white/30 text-xs">&copy; 2024 Wowin CRM. All rights reserved.</p>
      </div>
    </div>

    <!-- Right Panel - Login Form -->
    <div class="flex-1 flex items-center justify-center p-6 bg-background">
      <div class="w-full max-w-[420px]">
        <!-- Mobile Logo -->
        <div class="lg:hidden flex justify-center mb-8">
          <div class="w-12 h-12 rounded-xl bg-primary flex items-center justify-center shadow-lg">
            <span class="text-primary-foreground text-2xl font-bold">W</span>
          </div>
        </div>

        <Card class="border-0 shadow-none lg:border lg:shadow-sm">
          <CardHeader class="space-y-1 pb-6">
            <CardTitle class="text-2xl font-bold tracking-tight">Masuk ke akun Anda</CardTitle>
            <CardDescription>Masukkan email dan password untuk melanjutkan</CardDescription>
          </CardHeader>

          <CardContent>
            <!-- Error Alert -->
            <div v-if="localError"
                 class="mb-6 rounded-lg bg-destructive/10 p-4 border border-destructive/20 flex items-start gap-3">
              <AlertCircle class="h-4 w-4 text-destructive mt-0.5 flex-shrink-0" />
              <p class="text-sm text-destructive font-medium">{{ localError }}</p>
            </div>

            <form @submit="onSubmit" class="space-y-4">
              <div class="space-y-2">
                <Label for="email">Alamat Email</Label>
                <div class="relative">
                  <Mail class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="email"
                    type="email"
                    v-model="email"
                    v-bind="emailAttrs"
                    class="pl-9"
                    :class="errors.email ? 'border-destructive focus-visible:ring-destructive' : ''"
                    placeholder="sales@wowin.id"
                  />
                </div>
                <p v-if="errors.email" class="text-[13px] text-destructive font-medium">{{ errors.email }}</p>
              </div>

              <div class="space-y-2">
                <Label for="password">Password</Label>
                <div class="relative">
                  <Lock class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="password"
                    type="password"
                    v-model="password"
                    v-bind="passwordAttrs"
                    class="pl-9"
                    :class="errors.password ? 'border-destructive focus-visible:ring-destructive' : ''"
                    placeholder="••••••••"
                  />
                </div>
                <p v-if="errors.password" class="text-[13px] text-destructive font-medium">{{ errors.password }}</p>
              </div>

              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <Checkbox id="remember-me" />
                  <Label for="remember-me" class="text-sm font-normal cursor-pointer">Ingat saya</Label>
                </div>
                <a href="#" class="text-sm font-medium text-primary hover:underline" @click.prevent>
                  Lupa password?
                </a>
              </div>

              <Button type="submit" class="w-full" size="lg" :disabled="isSubmitting || authStore.loading">
                <Loader2 v-if="isSubmitting || authStore.loading" class="mr-2 h-4 w-4 animate-spin" />
                {{ isSubmitting || authStore.loading ? 'Memproses...' : 'Masuk' }}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>
