<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import {
  fetchProducts, fetchCategories, createProduct, updateProduct, deleteProduct,
  type Product, type ProductCategory
} from '@/api/products.api'
import {
  Plus, Search, Loader2, Package, Edit, Trash2, Tag,
  LayoutGrid, RefreshCw, BarChart2, MoreHorizontal
} from 'lucide-vue-next'
import { useDebounce } from '@vueuse/core'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  Dialog, DialogContent, DialogDescription, DialogFooter,
  DialogHeader, DialogTitle
} from '@/components/ui/dialog'
import { useToast } from '@/components/ui/toast/use-toast'

const { toast } = useToast()
const products = ref<Product[]>([])
const categories = ref<ProductCategory[]>([])
const loading = ref(false)
const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedCategory = ref<string>('all')

// Dialog State
const showProductDialog = ref(false)
const editingProduct = ref<Product | null>(null)
const saving = ref(false)
const formData = ref({
  code: '',
  name: '',
  category_id: '',
  description: '',
  unit: 'pcs',
  base_price: 0,
  is_active: true
})

async function loadProducts() {
  loading.value = true
  try {
    const res = await fetchProducts({
      search: debouncedSearch.value,
      category_id: selectedCategory.value === 'all' ? undefined : selectedCategory.value
    })
    products.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load products', e)
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  try {
    const res = await fetchCategories()
    categories.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load categories', e)
  }
}

onMounted(() => {
  loadProducts()
  loadCategories()
})

watch([debouncedSearch, selectedCategory], loadProducts)

function openCreate() {
  editingProduct.value = null
  formData.value = { code: '', name: '', category_id: '', description: '', unit: 'pcs', base_price: 0, is_active: true }
  showProductDialog.value = true
}

function openEdit(product: Product) {
  editingProduct.value = product
  formData.value = {
    code: product.code,
    name: product.name,
    category_id: product.category_id || '',
    description: product.description || '',
    unit: product.unit || 'pcs',
    base_price: product.base_price,
    is_active: product.is_active
  }
  showProductDialog.value = true
}

async function handleSave() {
  saving.value = true
  try {
    if (editingProduct.value) {
      await updateProduct(editingProduct.value.id, formData.value)
      toast({ title: 'Produk diperbarui', description: `Produk "${formData.value.name}" berhasil diperbarui.` })
    } else {
      await createProduct(formData.value)
      toast({ title: 'Produk ditambahkan', description: `Produk "${formData.value.name}" berhasil dibuat.` })
    }
    showProductDialog.value = false
    loadProducts()
  } catch (e: any) {
    toast({ title: 'Gagal menyimpan', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    saving.value = false
  }
}

const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Katalog Produk</h1>
        <p class="text-muted-foreground mt-1">Kelola daftar produk, kategori, dan penetapan harga dasar.</p>
      </div>
      <div class="flex items-center gap-2">
        <Button variant="outline" size="sm" @click="loadProducts">
          <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
          Refresh
        </Button>
        <Button size="sm" @click="openCreate">
          <Plus class="w-4 h-4 mr-2" />
          Produk Baru
        </Button>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <Card class="bg-blue-50/50 dark:bg-blue-950/20 border-blue-100 dark:border-blue-900/50">
        <CardContent class="pt-6">
          <div class="flex items-center gap-4">
            <div class="h-10 w-10 rounded-full bg-blue-100 dark:bg-blue-900/50 flex items-center justify-center">
              <Package class="w-5 h-5 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <p class="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Total SKU</p>
              <p class="text-2xl font-bold">{{ products.length }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card class="bg-emerald-50/50 dark:bg-emerald-950/20 border-emerald-100 dark:border-emerald-900/50">
        <CardContent class="pt-6">
          <div class="flex items-center gap-4">
            <div class="h-10 w-10 rounded-full bg-emerald-100 dark:bg-emerald-900/50 flex items-center justify-center">
              <LayoutGrid class="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <p class="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Kategori</p>
              <p class="text-2xl font-bold">{{ categories.length }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <Card>
      <CardHeader class="flex-row items-center justify-between space-y-0">
        <div class="flex flex-col gap-1">
          <CardTitle class="text-base">Daftar Produk</CardTitle>
          <CardDescription>Master data harga dan stock unit.</CardDescription>
        </div>
        <div class="flex items-center gap-2">
          <div class="relative w-64">
             <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
             <Input v-model="searchInput" class="pl-9 h-9" placeholder="Cari nama atau kode..." />
          </div>
          <Select v-model="selectedCategory">
            <SelectTrigger class="w-[180px] h-9">
              <SelectValue placeholder="Kategori" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Semua Kategori</SelectItem>
              <SelectItem v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardHeader>
      <CardContent class="p-0">
        <div v-if="loading" class="flex justify-center py-20">
          <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
        <div v-else-if="products.length === 0" class="text-center py-20">
          <Package class="h-12 w-12 mx-auto text-muted-foreground/30 mb-4" />
          <h3 class="font-semibold text-muted-foreground">Tidak ada produk ditemukan</h3>
          <p class="text-sm text-muted-foreground">Gunakan tombol 'Produk Baru' untuk menambah katalog.</p>
        </div>
        <Table v-else>
          <TableHeader>
            <TableRow>
              <TableHead class="w-[120px]">Kode SKU</TableHead>
              <TableHead>Nama Produk</TableHead>
              <TableHead>Kategori</TableHead>
              <TableHead>Harga Dasar</TableHead>
              <TableHead>Unit</TableHead>
              <TableHead>Status</TableHead>
              <TableHead class="text-right w-[100px]">Aksi</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="product in products" :key="product.id">
              <TableCell class="font-mono text-xs font-bold">{{ product.code }}</TableCell>
              <TableCell class="font-medium">{{ product.name }}</TableCell>
              <TableCell>
                <Badge variant="secondary" class="text-[10px] font-semibold">
                  <Tag class="w-3 h-3 mr-1" />
                  {{ categories.find(c => c.id === product.category_id)?.name || 'N/A' }}
                </Badge>
              </TableCell>
              <TableCell class="font-mono">{{ formatCurrency(product.base_price) }}</TableCell>
              <TableCell class="text-muted-foreground">{{ product.unit }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-1.5">
                  <div class="h-2 w-2 rounded-full" :class="product.is_active ? 'bg-emerald-500' : 'bg-red-500'"></div>
                  <span class="text-xs">{{ product.is_active ? 'Aktif' : 'Non-Aktif' }}</span>
                </div>
              </TableCell>
              <TableCell class="text-right">
                <Button variant="ghost" size="icon" class="h-8 w-8" @click="openEdit(product)">
                  <Edit class="h-4 w-4" />
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>

    <!-- Modal Form -->
    <Dialog v-model:open="showProductDialog">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{{ editingProduct ? 'Edit Produk' : 'Tambah Produk Baru' }}</DialogTitle>
          <DialogDescription>Pengaturan spesifikasi produk dan standardisasi harga katalog.</DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleSave" class="space-y-4 pt-4">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="code">Kode SKU</Label>
              <Input id="code" v-model="formData.code" placeholder="E.g. PRD-001" required />
            </div>
             <div class="space-y-2">
              <Label for="cat">Kategori</Label>
              <Select v-model="formData.category_id">
                <SelectTrigger id="cat">
                  <SelectValue placeholder="Pilih Kategori" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div class="col-span-2 space-y-2">
              <Label for="name">Nama Produk</Label>
              <Input id="name" v-model="formData.name" placeholder="Nama lengkap produk" required />
            </div>
            <div class="space-y-2">
              <Label for="price">Harga Satuan (IDR)</Label>
              <Input id="price" type="number" v-model.number="formData.base_price" required />
            </div>
            <div class="space-y-2">
              <Label for="unit">Unit</Label>
              <Select v-model="formData.unit">
                <SelectTrigger id="unit">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="pcs">Pcs (Pieces)</SelectItem>
                  <SelectItem value="box">Box / Dus</SelectItem>
                  <SelectItem value="kg">Kilogram</SelectItem>
                  <SelectItem value="liter">Liter</SelectItem>
                </SelectContent>
              </Select>
            </div>
             <div class="col-span-2 space-y-2">
              <Label for="desc">Deskripsi</Label>
              <Input id="desc" v-model="formData.description" placeholder="Penjelasan singkat produk..." />
            </div>
          </div>

          <DialogFooter class="pt-4">
            <Button type="button" variant="outline" @click="showProductDialog = false">Batal</Button>
            <Button type="submit" :disabled="saving">
              <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
              Simpan Produk
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  </div>
</template>
