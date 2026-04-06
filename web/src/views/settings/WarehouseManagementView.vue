<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { warehouseApi, type Warehouse } from '@/api/warehouses.api'
import { Warehouse as WarehouseIcon, Plus, Edit2, Trash2, MapPin } from 'lucide-vue-next'

const warehouses = ref<Warehouse[]>([])
const loading = ref(true)

const showModal = ref(false)
const modalMode = ref<'add' | 'edit'>('add')
const modalData = ref<Partial<Warehouse>>({ name: '', address: '', latitude: 0, longitude: 0 })

const fetchWarehouses = async () => {
  loading.value = true
  try {
    warehouses.value = await warehouseApi.list()
  } catch (error) {
    console.error('Failed to load warehouses', error)
  } finally {
    loading.value = false
  }
}

const openAddModal = () => {
  modalMode.value = 'add'
  modalData.value = { name: '', address: '', latitude: 0, longitude: 0 }
  showModal.value = true
}

const openEditModal = (w: Warehouse) => {
  modalMode.value = 'edit'
  modalData.value = { ...w }
  showModal.value = true
}

const submitForm = async () => {
  try {
    if (modalMode.value === 'add') {
      await warehouseApi.create(modalData.value)
    } else if (modalMode.value === 'edit' && modalData.value.id) {
      await warehouseApi.update(modalData.value.id, modalData.value)
    }
    showModal.value = false
    await fetchWarehouses()
  } catch (error) {
    console.error('Submission failed', error)
  }
}

const deleteWarehouse = async (id: string) => {
  if (!confirm('Hapus lokasi gudang ini?')) return
  try {
    await warehouseApi.delete(id)
    await fetchWarehouses()
  } catch (error) {
    console.error('Delete failed', error)
  }
}

onMounted(fetchWarehouses)
</script>

<template>
  <div class="px-4 sm:px-6 lg:px-8 py-8">
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-bold text-gray-900 flex items-center gap-2">
          <WarehouseIcon class="w-6 h-6 text-blue-600" /> Manajemen Gudang (Pool Area)
        </h1>
        <p class="mt-2 text-sm text-gray-700">Daftar lokasi pusat persediaan yang digunakan sebagai titik awal (start) untuk optimasi rute kunjungan aplikasi Sales.</p>
      </div>
      <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
        <button type="button" @click="openAddModal" class="inline-flex items-center justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700 sm:w-auto">
          <Plus class="w-4 h-4 mr-2" /> Tambah Gudang
        </button>
      </div>
    </div>

    <!-- Data Table -->
    <div class="mt-8 flex flex-col">
      <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">Nama Gudang</th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Alamat Lengkap</th>
                  <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Koordinat GPS</th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6"><span class="sr-only">Aksi</span></th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 bg-white">
                <tr v-if="loading">
                  <td colspan="4" class="py-4 text-center text-sm text-gray-500">Memuat data gudang...</td>
                </tr>
                <tr v-else-if="warehouses.length === 0">
                  <td colspan="4" class="py-4 text-center text-sm text-gray-500">Belum ada lokasi gudang terdaftar.</td>
                </tr>
                <tr v-for="w in warehouses" :key="w.id">
                  <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                    <div class="flex items-center gap-2">
                       <MapPin class="w-4 h-4 text-gray-400" /> {{ w.name }}
                    </div>
                  </td>
                  <td class="px-3 py-4 text-sm text-gray-500">{{ w.address }}</td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">Lat: {{ w.latitude }}<br/>Lng: {{ w.longitude }}</td>
                  <td class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                    <button @click="openEditModal(w)" class="text-blue-600 hover:text-blue-900 mr-4 inline-flex items-center gap-1"><Edit2 class="w-4 h-4"/> Edit</button>
                    <button @click="deleteWarehouse(w.id)" class="text-red-600 hover:text-red-900 inline-flex items-center gap-1"><Trash2 class="w-4 h-4"/> Hapus</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Form -->
    <div v-if="showModal" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex min-h-screen items-center justify-center p-4">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showModal = false"></div>
        <div class="relative w-full max-w-md transform overflow-hidden rounded-xl bg-white p-6 shadow-2xl transition-all">
          <div class="mb-5">
            <h3 class="text-lg font-medium leading-6 text-gray-900">{{ modalMode === 'add' ? 'Tambah Lokasi Gudang' : 'Edit Lokasi Gudang' }}</h3>
          </div>
          
          <form @submit.prevent="submitForm" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Nama Gudang</label>
              <input v-model="modalData.name" type="text" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm p-2 border" placeholder="Contoh: Pool Cikarang" />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Alamat</label>
              <textarea v-model="modalData.address" rows="3" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm p-2 border" placeholder="Jalan industri raya.."></textarea>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Latitude</label>
                <input v-model.number="modalData.latitude" type="number" step="any" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm p-2 border" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Longitude</label>
                <input v-model.number="modalData.longitude" type="number" step="any" required class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm p-2 border" />
              </div>
            </div>

            <div class="mt-6 flex justify-end gap-3">
              <button type="button" @click="showModal = false" class="rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50">Batal</button>
              <button type="submit" class="rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700">{{ modalMode === 'add' ? 'Simpan Data' : 'Update Data' }}</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
