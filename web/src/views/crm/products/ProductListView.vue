<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import {
  fetchProducts, fetchCategories, createProduct, updateProduct, deleteProduct,
  createCategory, updateCategory,
  type Product, type ProductCategory, type CreateProductPayload
} from '@/api/products.api'
import {
  Plus, Search, Loader2, Package, Edit, Trash2, Tag,
  LayoutGrid, RefreshCw, FolderPlus,
  ToggleLeft, ToggleRight, AlertTriangle, Check
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
import { Checkbox } from '@/components/ui/checkbox'
import { useToast } from '@/components/ui/toast/use-toast'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

const { toast } = useToast()

// ==================== State ====================
const products = ref<Product[]>([])
const categories = ref<ProductCategory[]>([])
const loading = ref(false)
const searchInput = ref('')
const debouncedSearch = useDebounce(searchInput, 500)
const selectedCategory = ref<string>('all')
const filterStatus = ref<string>('all')
const activeTab = ref('products')

// ==================== Product Dialog ====================
const showProductDialog = ref(false)
const editingProduct = ref<Product | null>(null)
const saving = ref(false)
const formData = ref<CreateProductPayload>({
  sku: '',
  name: '',
  category_id: '',
  description: '',
  unit: 'pcs',
  price: 0,
  is_active: true
})

// ==================== Delete Dialog ====================
const showDeleteDialog = ref(false)
const productToDelete = ref<Product | null>(null)
const deleting = ref(false)

// ==================== Category Dialog ====================
const showCategoryDialog = ref(false)
const editingCategory = ref<ProductCategory | null>(null)
const categoryForm = ref({ name: '' })
const savingCategory = ref(false)

// ==================== Computed ====================
const filteredProducts = computed(() => {
  return products.value.filter(p => {
    if (filterStatus.value === 'active' && !p.is_active) return false
    if (filterStatus.value === 'inactive' && p.is_active) return false
    return true
  })
})

const activeCount = computed(() => products.value.filter(p => p.is_active).length)
const inactiveCount = computed(() => products.value.filter(p => !p.is_active).length)

const getCategoryName = (id?: string) => {
  if (!id) return 'N/A'
  return categories.value.find(c => c.id === id)?.name || 'N/A'
}

// ==================== Loaders ====================
async function loadProducts() {
  loading.value = true
  try {
    const params: Record<string, any> = {}
    if (debouncedSearch.value) params.search = debouncedSearch.value
    if (selectedCategory.value !== 'all') params.category_id = selectedCategory.value
    const res = await fetchProducts(params)
    products.value = res.data.data || []
  } catch (e) {
    console.error('Failed to load products', e)
    toast({ title: 'Gagal memuat produk', variant: 'destructive' })
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

// ==================== Product CRUD ====================
function openCreate() {
  editingProduct.value = null
  formData.value = { sku: '', name: '', category_id: '', description: '', unit: 'pcs', price: 0, is_active: true }
  showProductDialog.value = true
}

function openEdit(product: Product) {
  editingProduct.value = product
  formData.value = {
    sku: product.sku || '',
    name: product.name,
    category_id: product.category_id || '',
    description: product.description || '',
    unit: product.unit || 'pcs',
    price: product.price,
    is_active: product.is_active
  }
  showProductDialog.value = true
}

async function handleSave() {
  saving.value = true
  try {
    const payload: CreateProductPayload = {
      ...formData.value,
      category_id: formData.value.category_id || undefined,
      sku: formData.value.sku || undefined,
      description: formData.value.description || undefined,
    }
    if (editingProduct.value) {
      await updateProduct(editingProduct.value.id, payload)
      toast({ title: 'Produk diperbarui', description: `"${formData.value.name}" berhasil diperbarui.` })
    } else {
      await createProduct(payload)
      toast({ title: 'Produk ditambahkan', description: `"${formData.value.name}" berhasil dibuat.` })
    }
    showProductDialog.value = false
    loadProducts()
  } catch (e: any) {
    toast({ title: 'Gagal menyimpan', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    saving.value = false
  }
}

function confirmDelete(product: Product) {
  productToDelete.value = product
  showDeleteDialog.value = true
}

async function handleDelete() {
  if (!productToDelete.value) return
  deleting.value = true
  try {
    await deleteProduct(productToDelete.value.id)
    toast({ title: 'Produk dihapus', description: `"${productToDelete.value.name}" telah dihapus dari katalog.` })
    showDeleteDialog.value = false
    productToDelete.value = null
    loadProducts()
  } catch (e: any) {
    toast({ title: 'Gagal menghapus', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    deleting.value = false
  }
}

// ==================== Category CRUD ====================
function openCreateCategory() {
  editingCategory.value = null
  categoryForm.value = { name: '' }
  showCategoryDialog.value = true
}

function openEditCategory(cat: ProductCategory) {
  editingCategory.value = cat
  categoryForm.value = { name: cat.name }
  showCategoryDialog.value = true
}

async function handleSaveCategory() {
  savingCategory.value = true
  try {
    if (editingCategory.value) {
      await updateCategory(editingCategory.value.id, { name: categoryForm.value.name })
      toast({ title: 'Kategori diperbarui', description: `Kategori "${categoryForm.value.name}" berhasil diperbarui.` })
    } else {
      await createCategory({ name: categoryForm.value.name })
      toast({ title: 'Kategori ditambahkan', description: `Kategori "${categoryForm.value.name}" berhasil dibuat.` })
    }
    showCategoryDialog.value = false
    await loadCategories()
  } catch (e: any) {
    toast({ title: 'Gagal menyimpan kategori', description: e.response?.data?.error?.message || 'Terjadi kesalahan', variant: 'destructive' })
  } finally {
    savingCategory.value = false
  }
}

// ==================== Helpers ====================
const formatCurrency = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)

const formatDate = (val: string) =>
  val ? new Date(val).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' }) : '-'
</script>

<template>
  <div class="space-y-6">

    <!-- Page Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Katalog Produk</h1>
        <p class="text-muted-foreground mt-1">Kelola daftar produk, kategori, dan harga untuk seluruh tim sales.</p>
      </div>
      <div class="flex items-center gap-2">
        <Button variant="outline" size="sm" @click="() => { loadProducts(); loadCategories() }" :disabled="loading">
          <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
          Refresh
        </Button>
        <Button size="sm" @click="openCreate">
          <Plus class="w-4 h-4 mr-2" />
          Produk Baru
        </Button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
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
              <ToggleRight class="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <p class="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Aktif</p>
              <p class="text-2xl font-bold">{{ activeCount }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card class="bg-red-50/50 dark:bg-red-950/20 border-red-100 dark:border-red-900/50">
        <CardContent class="pt-6">
          <div class="flex items-center gap-4">
            <div class="h-10 w-10 rounded-full bg-red-100 dark:bg-red-900/50 flex items-center justify-center">
              <ToggleLeft class="w-5 h-5 text-red-600 dark:text-red-400" />
            </div>
            <div>
              <p class="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Non-Aktif</p>
              <p class="text-2xl font-bold">{{ inactiveCount }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
      <Card class="bg-violet-50/50 dark:bg-violet-950/20 border-violet-100 dark:border-violet-900/50">
        <CardContent class="pt-6">
          <div class="flex items-center gap-4">
            <div class="h-10 w-10 rounded-full bg-violet-100 dark:bg-violet-900/50 flex items-center justify-center">
              <LayoutGrid class="w-5 h-5 text-violet-600 dark:text-violet-400" />
            </div>
            <div>
              <p class="text-xs text-muted-foreground uppercase tracking-wider font-semibold">Kategori</p>
              <p class="text-2xl font-bold">{{ categories.length }}</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>

    <!-- Tabs: Products | Categories -->
    <Tabs v-model="activeTab">
      <TabsList class="mb-4">
        <TabsTrigger value="products">
          <Package class="w-4 h-4 mr-2" />
          Produk
        </TabsTrigger>
        <TabsTrigger value="categories">
          <Tag class="w-4 h-4 mr-2" />
          Kategori
        </TabsTrigger>
      </TabsList>

      <!-- ==================== PRODUCTS TAB ==================== -->
      <TabsContent value="products">
        <Card>
          <CardHeader class="flex-row items-center justify-between space-y-0 pb-4">
            <div class="flex flex-col gap-1">
              <CardTitle class="text-base">Daftar Produk</CardTitle>
              <CardDescription>Master data harga, SKU, dan status katalog yang tersinkronisasi dengan aplikasi sales.</CardDescription>
            </div>
            <div class="flex items-center gap-2 flex-wrap">
              <div class="relative w-52">
                <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input v-model="searchInput" class="pl-9 h-9" placeholder="Cari nama atau SKU..." />
              </div>
              <Select v-model="selectedCategory">
                <SelectTrigger class="w-[155px] h-9">
                  <SelectValue placeholder="Kategori" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Semua Kategori</SelectItem>
                  <SelectItem v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</SelectItem>
                </SelectContent>
              </Select>
              <Select v-model="filterStatus">
                <SelectTrigger class="w-[130px] h-9">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Semua Status</SelectItem>
                  <SelectItem value="active">Aktif</SelectItem>
                  <SelectItem value="inactive">Non-Aktif</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent class="p-0">
            <div v-if="loading" class="flex justify-center py-20">
              <Loader2 class="w-8 h-8 animate-spin text-muted-foreground" />
            </div>
            <div v-else-if="filteredProducts.length === 0" class="text-center py-20">
              <Package class="h-12 w-12 mx-auto text-muted-foreground/30 mb-4" />
              <h3 class="font-semibold text-muted-foreground">Tidak ada produk ditemukan</h3>
              <p class="text-sm text-muted-foreground mt-1">Gunakan tombol 'Produk Baru' untuk menambah katalog.</p>
              <Button class="mt-4" size="sm" @click="openCreate">
                <Plus class="w-4 h-4 mr-2" />Tambah Produk
              </Button>
            </div>
            <Table v-else>
              <TableHeader>
                <TableRow>
                  <TableHead class="w-[120px]">Kode SKU</TableHead>
                  <TableHead>Nama Produk</TableHead>
                  <TableHead>Kategori</TableHead>
                  <TableHead class="text-right">Harga Satuan</TableHead>
                  <TableHead>Unit</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead class="text-right">Diperbarui</TableHead>
                  <TableHead class="text-right w-[90px]">Aksi</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow
                  v-for="product in filteredProducts"
                  :key="product.id"
                  class="hover:bg-muted/40 transition-colors"
                >
                  <TableCell class="font-mono text-xs font-bold text-muted-foreground">
                    {{ product.sku || '—' }}
                  </TableCell>
                  <TableCell>
                    <div class="flex items-center gap-2">
                      <div class="h-8 w-8 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                        <Package class="w-4 h-4 text-muted-foreground" />
                      </div>
                      <div>
                        <p class="font-medium leading-tight">{{ product.name }}</p>
                        <p v-if="product.description" class="text-xs text-muted-foreground truncate max-w-[200px]">{{ product.description }}</p>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary" class="text-[10px] font-semibold">
                      <Tag class="w-3 h-3 mr-1" />
                      {{ getCategoryName(product.category_id) }}
                    </Badge>
                  </TableCell>
                  <TableCell class="font-mono text-right font-semibold">
                    {{ formatCurrency(product.price) }}
                  </TableCell>
                  <TableCell class="text-muted-foreground uppercase text-xs font-semibold">
                    {{ product.unit || 'pcs' }}
                  </TableCell>
                  <TableCell>
                    <Badge
                      :class="product.is_active
                        ? 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-400 border-emerald-200'
                        : 'bg-red-100 text-red-700 dark:bg-red-950/60 dark:text-red-400 border-red-200'"
                      variant="outline"
                      class="text-[10px] font-semibold gap-1"
                    >
                      <div class="h-1.5 w-1.5 rounded-full" :class="product.is_active ? 'bg-emerald-500' : 'bg-red-500'" />
                      {{ product.is_active ? 'Aktif' : 'Non-Aktif' }}
                    </Badge>
                  </TableCell>
                  <TableCell class="text-right text-xs text-muted-foreground font-mono">
                    {{ formatDate(product.updated_at) }}
                  </TableCell>
                  <TableCell class="text-right">
                    <div class="flex items-center justify-end gap-0.5">
                      <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground" @click="openEdit(product)">
                        <Edit class="h-4 w-4" />
                      </Button>
                      <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmDelete(product)">
                        <Trash2 class="h-4 w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- ==================== CATEGORIES TAB ==================== -->
      <TabsContent value="categories">
        <Card>
          <CardHeader class="flex-row items-center justify-between space-y-0">
            <div class="flex flex-col gap-1">
              <CardTitle class="text-base">Manajemen Kategori</CardTitle>
              <CardDescription>Susun kategori produk untuk memudahkan tim sales dalam memilih produk.</CardDescription>
            </div>
            <Button size="sm" @click="openCreateCategory">
              <FolderPlus class="w-4 h-4 mr-2" />
              Tambah Kategori
            </Button>
          </CardHeader>
          <CardContent class="p-0">
            <div v-if="categories.length === 0" class="text-center py-16">
              <LayoutGrid class="h-10 w-10 mx-auto text-muted-foreground/30 mb-4" />
              <h3 class="font-semibold text-muted-foreground">Belum ada kategori</h3>
              <p class="text-sm text-muted-foreground mt-1">Buat kategori untuk mengorganisir produk Anda.</p>
              <Button class="mt-4" size="sm" @click="openCreateCategory">
                <FolderPlus class="w-4 h-4 mr-2" />Buat Kategori
              </Button>
            </div>
            <Table v-else>
              <TableHeader>
                <TableRow>
                  <TableHead class="w-[50px]">#</TableHead>
                  <TableHead>Nama Kategori</TableHead>
                  <TableHead>Jumlah Produk</TableHead>
                  <TableHead>Dibuat</TableHead>
                  <TableHead class="text-right w-[80px]">Aksi</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-for="(cat, i) in categories" :key="cat.id" class="hover:bg-muted/40 transition-colors">
                  <TableCell class="text-muted-foreground font-medium">{{ i + 1 }}</TableCell>
                  <TableCell>
                    <div class="flex items-center gap-2">
                      <div class="h-7 w-7 rounded-md bg-violet-100 dark:bg-violet-950/60 flex items-center justify-center">
                        <Tag class="w-3.5 h-3.5 text-violet-600 dark:text-violet-400" />
                      </div>
                      <span class="font-medium">{{ cat.name }}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline" class="text-[10px]">
                      {{ products.filter(p => p.category_id === cat.id).length }} produk
                    </Badge>
                  </TableCell>
                  <TableCell class="text-xs text-muted-foreground font-mono">
                    {{ formatDate(cat.created_at) }}
                  </TableCell>
                  <TableCell class="text-right">
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground" @click="openEditCategory(cat)">
                      <Edit class="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>

    <!-- ==================== PRODUCT FORM DIALOG ==================== -->
    <Dialog v-model:open="showProductDialog">
      <DialogContent class="sm:max-w-[560px]">
        <DialogHeader>
          <DialogTitle>{{ editingProduct ? 'Edit Produk' : 'Tambah Produk Baru' }}</DialogTitle>
          <DialogDescription>
            {{ editingProduct
              ? 'Perbarui informasi dan harga produk yang ada di katalog.'
              : 'Isi detail produk baru yang akan ditambahkan ke katalog sales.' }}
          </DialogDescription>
        </DialogHeader>

        <form @submit.prevent="handleSave" class="space-y-4 pt-2">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="sku">Kode SKU</Label>
              <Input id="sku" v-model="formData.sku" placeholder="Cth: PRD-001" />
            </div>
            <div class="space-y-2">
              <Label for="cat">Kategori</Label>
              <Select v-model="formData.category_id">
                <SelectTrigger id="cat">
                  <SelectValue placeholder="Pilih Kategori" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="">— Tanpa Kategori —</SelectItem>
                  <SelectItem v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div class="space-y-2">
            <Label for="name">Nama Produk <span class="text-destructive">*</span></Label>
            <Input id="name" v-model="formData.name" placeholder="Nama lengkap produk" required />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="price">Harga Satuan (IDR) <span class="text-destructive">*</span></Label>
              <Input id="price" type="number" min="0" v-model.number="formData.price" required />
            </div>
            <div class="space-y-2">
              <Label for="unit">Satuan Unit</Label>
              <Select v-model="formData.unit">
                <SelectTrigger id="unit">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="pcs">Pcs (Satuan)</SelectItem>
                  <SelectItem value="box">Box / Dus</SelectItem>
                  <SelectItem value="kg">Kilogram (kg)</SelectItem>
                  <SelectItem value="liter">Liter</SelectItem>
                  <SelectItem value="lusin">Lusin (12 pcs)</SelectItem>
                  <SelectItem value="krat">Krat</SelectItem>
                  <SelectItem value="sak">Sak</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div class="space-y-2">
            <Label for="desc">Deskripsi Produk</Label>
            <Input id="desc" v-model="formData.description" placeholder="Penjelasan singkat produk..." />
          </div>

          <div class="flex items-start gap-3 p-3 rounded-lg bg-muted/50">
            <Checkbox
              id="is-active"
              :checked="formData.is_active"
              @update:checked="(val: boolean | 'indeterminate') => formData.is_active = val === true"
              class="mt-0.5"
            />
            <div>
              <Label for="is-active" class="font-medium cursor-pointer">Produk Aktif</Label>
              <p class="text-xs text-muted-foreground mt-0.5">Produk aktif akan tampil di aplikasi sales dan dapat dipilih dalam transaksi.</p>
            </div>
          </div>

          <DialogFooter class="pt-2">
            <Button type="button" variant="outline" @click="showProductDialog = false">Batal</Button>
            <Button type="submit" :disabled="saving">
              <Loader2 v-if="saving" class="w-4 h-4 mr-2 animate-spin" />
              <Check v-else class="w-4 h-4 mr-2" />
              {{ editingProduct ? 'Simpan Perubahan' : 'Tambah Produk' }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>

    <!-- ==================== DELETE CONFIRM DIALOG ==================== -->
    <Dialog v-model:open="showDeleteDialog">
      <DialogContent class="sm:max-w-[420px]">
        <DialogHeader>
          <DialogTitle class="flex items-center gap-2 text-destructive">
            <AlertTriangle class="w-5 h-5" />
            Hapus Produk?
          </DialogTitle>
          <DialogDescription class="pt-1">
            Anda akan menghapus produk
            <strong class="text-foreground font-semibold">"{{ productToDelete?.name }}"</strong>
            secara permanen. Tindakan ini tidak dapat dibatalkan.
          </DialogDescription>
        </DialogHeader>
        <div class="bg-destructive/10 border border-destructive/20 rounded-lg p-3 text-sm text-destructive dark:text-red-400">
          Menghapus produk dapat mempengaruhi data deal dan transaksi yang menggunakan produk ini.
        </div>
        <DialogFooter class="gap-2">
          <Button variant="outline" @click="showDeleteDialog = false" :disabled="deleting">Batal</Button>
          <Button variant="destructive" @click="handleDelete" :disabled="deleting">
            <Loader2 v-if="deleting" class="w-4 h-4 mr-2 animate-spin" />
            <Trash2 v-else class="w-4 h-4 mr-2" />
            Hapus Produk
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- ==================== CATEGORY FORM DIALOG ==================== -->
    <Dialog v-model:open="showCategoryDialog">
      <DialogContent class="sm:max-w-[400px]">
        <DialogHeader>
          <DialogTitle>{{ editingCategory ? 'Edit Kategori' : 'Tambah Kategori Baru' }}</DialogTitle>
          <DialogDescription>
            Kategori membantu tim sales menemukan produk lebih cepat di aplikasi mobile.
          </DialogDescription>
        </DialogHeader>
        <form @submit.prevent="handleSaveCategory" class="space-y-4 pt-2">
          <div class="space-y-2">
            <Label for="cat-name">Nama Kategori <span class="text-destructive">*</span></Label>
            <Input id="cat-name" v-model="categoryForm.name" placeholder="Cth: Minuman, Makanan Ringan..." required />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" @click="showCategoryDialog = false">Batal</Button>
            <Button type="submit" :disabled="savingCategory">
              <Loader2 v-if="savingCategory" class="w-4 h-4 mr-2 animate-spin" />
              <Check v-else class="w-4 h-4 mr-2" />
              {{ editingCategory ? 'Simpan Perubahan' : 'Buat Kategori' }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>

  </div>
</template>
