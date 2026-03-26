---
name: wowin-crm
description: >
  Skill untuk proyek Wowin CRM — sistem CRM enterprise + Sales Field Automation
  berbasis Golang Gin (backend), PostgreSQL + PostGIS (database), Flutter (mobile),
  dan Vue.js 3 (web dashboard). Gunakan skill ini setiap kali ada permintaan yang
  berkaitan dengan proyek ini: membuat kode backend Go, skema database, endpoint API,
  komponen Flutter, komponen Vue.js, query PostGIS, logika GPS tracking, fitur
  kunjungan sales (check-in/foto), territory mapping, laporan, atau keputusan
  arsitektur apa pun dalam proyek Wowin CRM. Aktifkan skill ini bahkan jika user
  hanya menyebut "CRM kita", "proyek sales", "fitur kunjungan", "tracking GPS",
  atau nama modul apa pun dari sistem ini.
---

# Wowin CRM — Project Skill

Skill ini menyimpan konteks lengkap proyek **Wowin CRM** agar setiap output
konsisten dengan keputusan arsitektur, naming convention, dan stack teknologi
yang sudah ditetapkan.

---

## 1. Identitas Proyek

| Atribut | Nilai |
|---|---|
| Nama Proyek | Wowin CRM |
| Tipe | Enterprise CRM + Sales Force Automation (SFA) |
| Target | Tim sales lapangan + manajemen |
| Bahasa utama | Indonesia (komentar kode boleh English) |

---

## 2. Stack Teknologi (WAJIB dipatuhi)

| Layer | Teknologi | Versi / Catatan |
|---|---|---|
| Backend API | **Golang + Gin** | Go 1.22+, Gin v1 |
| Database | **PostgreSQL + PostGIS** | PG 16+, PostGIS 3+ |
| Cache | **Redis** | Untuk session, JWT blacklist, rate limit |
| Mobile | **Flutter** | Flutter 3.x, Dart 3 |
| Web Dashboard | **Vue.js 3 + Vite** | Composition API, Pinia, Vue Router 4 |
| Auth | **JWT + Refresh Token** | Access token 15 menit, refresh 7 hari |
| Maps | **Google Maps API / Leaflet+OSM** | Leaflet untuk web, google_maps_flutter untuk mobile |
| Push Notif | **Firebase Cloud Messaging** | FCM v1 HTTP API |
| File Storage | **VPS Lokal** | Gin static file server (`router.Static`) |
| Deployment | **Docker + Docker Swarm** | Di VPS, tanpa Kubernetes |
| Reverse Proxy | **Caddy atau Nginx** | HTTPS otomatis |

> ⚠️ **Tidak ada S3, MinIO, atau cloud storage eksternal.** Semua file disimpan
> lokal di VPS dan diakses via Gin static file server.

---

## 3. Struktur Folder Proyek

```
wowin-crm/
├── backend/                   # Golang Gin API
│   ├── cmd/server/main.go
│   ├── internal/
│   │   ├── config/            # Env, database, redis config
│   │   ├── middleware/        # JWT auth, CORS, rate limiter, RLS setter
│   │   ├── handler/           # HTTP handlers (tipis, hanya binding & response)
│   │   │   ├── auth/
│   │   │   ├── crm/           # customers, contacts, leads, deals
│   │   │   ├── sales/         # visits, schedules, photos
│   │   │   ├── tracking/      # GPS, live position
│   │   │   ├── mapping/       # territories, heatmap
│   │   │   └── report/
│   │   ├── service/           # Business logic (semua logika di sini)
│   │   ├── repository/        # Database queries (sqlx atau pgx)
│   │   ├── model/             # Struct domain + request/response DTO
│   │   └── utils/             # Helper: response, pagination, file, geo
│   ├── pkg/
│   │   ├── storage/           # VPS file manager (save, delete, build URL)
│   │   ├── maps/              # Google Maps / geocoding client
│   │   ├── notification/      # FCM client
│   │   └── mailer/            # SMTP email
│   ├── migrations/            # SQL migration files (goose)
│   ├── uploads/               # Root folder file statis (di-serve Gin)
│   │   ├── visits/
│   │   ├── attendance/
│   │   └── avatars/
│   └── docker-compose.yml
│
├── mobile/                    # Flutter App
│   └── lib/
│       ├── core/
│       │   ├── api/           # Dio HTTP client + interceptor
│       │   ├── auth/          # JWT storage + auto-refresh
│       │   └── storage/       # flutter_secure_storage
│       └── features/
│           ├── auth/
│           ├── crm/
│           ├── visits/        # Check-in, foto kamera, check-out
│           ├── tracking/      # Background GPS service
│           ├── map/
│           └── reports/
│
└── web/                       # Vue.js 3 Dashboard
    └── src/
        ├── api/               # Axios instances per modul
        ├── stores/            # Pinia stores
        ├── router/
        └── views/
            ├── crm/
            ├── sales/
            ├── mapping/       # Leaflet map components
            └── reports/
```

---

## 4. Konvensi Kode

### 4.1 Golang Backend

```go
// Naming: snake_case untuk DB, camelCase untuk Go, PascalCase untuk export

// Handler: hanya binding + panggil service + return response
func (h *VisitHandler) CheckIn(c *gin.Context) {
    var req dto.CheckInRequest
    if err := c.ShouldBind(&req); err != nil {
        utils.BadRequest(c, err)
        return
    }
    result, err := h.visitService.CheckIn(c.Request.Context(), req)
    if err != nil {
        utils.HandleServiceError(c, err)
        return
    }
    utils.Created(c, result)
}

// Response envelope standar
// { "success": true, "data": {...}, "meta": {...} }
// { "success": false, "error": { "code": "VALIDATION_ERROR", "message": "..." } }

// Error codes (string constant, bukan angka):
// AUTH_INVALID, AUTH_EXPIRED, FORBIDDEN, NOT_FOUND,
// VALIDATION_ERROR, CHECKIN_OUT_OF_RANGE, GPS_INVALID, DUPLICATE
```

### 4.2 Database Conventions

```sql
-- Semua PK: UUID (uuid_generate_v4())
-- Semua tabel punya: created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ
-- Soft delete pakai: deleted_at TIMESTAMPTZ (hanya tabel customers)
-- Timestamp selalu TIMESTAMPTZ (bukan TIMESTAMP)
-- Koordinat: GEOMETRY(POINT, 4326) — WGS84
-- Rute GPS: GEOMETRY(LINESTRING, 4326)
-- Area territory: GEOMETRY(MULTIPOLYGON, 4326)
-- Jarak selalu dalam METER
-- Casting geography untuk perhitungan jarak akurat:
--   ST_Distance(a::GEOGRAPHY, b::GEOGRAPHY)
```

### 4.3 File Storage (VPS Lokal)

```
Path pattern foto kunjungan:
  uploads/visits/{YYYY}/{MM}/{DD}/{visit_id}/{uuid}.jpg

Path pattern foto absensi:
  uploads/attendance/{YYYY}/{MM}/{user_id}_{type}_{timestamp}.jpg

Path avatar:
  uploads/avatars/{user_id}.jpg

URL akses (via Gin static):
  https://domain.com/uploads/visits/2026/03/12/{visit_id}/abc.jpg

// Di database simpan path RELATIF dari folder uploads/
// Contoh: visits/2026/03/12/uuid/abc.jpg
// Jangan simpan full URL (domain bisa berubah)
```

### 4.4 API Versioning

Semua endpoint menggunakan prefix `/api/v1/`. Contoh:
```
POST   /api/v1/auth/login
GET    /api/v1/customers
POST   /api/v1/visits/checkin
POST   /api/v1/tracking/location
GET    /api/v1/map/customers
```

### 4.5 Flutter

```dart
// State management: Riverpod (atau BLoC jika modul kompleks)
// HTTP client: Dio dengan interceptor untuk auto-refresh JWT
// GPS background: geolocator + background_fetch / WorkManager
// Kamera: image_picker dengan source: ImageSource.camera ONLY
//          (tidak boleh dari galeri — integritas bukti kunjungan)
// Maps: google_maps_flutter
// Secure storage: flutter_secure_storage untuk JWT token
```
## Architecture: Feature-First Clean Architecture
Setiap fitur punya struktur:
features/{nama}/
  data/
    datasources/    # API calls (Dio), local storage
    models/         # JSON serializable models (freezed)
    repositories/   # implementasi dari domain/repositories
  domain/
    entities/       # pure Dart class, no framework dependency
    repositories/   # abstract interface
    usecases/       # satu usecase = satu class, satu method call()
  presentation/
    pages/          # full screen widgets
    widgets/        # reusable widgets dalam fitur ini
    providers/      # Riverpod providers

## State Management
- Gunakan RIVERPOD 2.x (riverpod_annotation + code generation)
- AsyncNotifier untuk state yang fetch data dari API
- StateNotifier untuk state lokal yang kompleks
- Provider sederhana untuk dependency injection

## HTTP Client
- Dio dengan BaseOptions (baseUrl dari env)
- Interceptor auth: auto-attach Bearer token
- Interceptor refresh: jika 401, refresh token lalu retry
- Interceptor logging: hanya di debug mode
- Selalu handle: network error, timeout, server error

## Foto & Kamera
- WAJIB gunakan ImageSource.camera — TIDAK BOLEH ImageSource.gallery
- Compress foto sebelum upload: max 1280px, quality 80
- Tampilkan preview sebelum submit
- Package: image_picker, flutter_image_compress

## GPS & Lokasi
- Package: geolocator, permission_handler
- Background tracking: workmanager atau flutter_background_service
- Kirim batch max 10 titik sekaligus
- Interval: 30 detik bergerak, 120 detik diam (speed < 0.5 m/s)
- Hanya aktif 07:00–18:00 waktu lokal
- Simpan titik ke local DB (sqflite) jika offline, sync saat online

## Local Storage
- JWT token: flutter_secure_storage (bukan SharedPreferences)
- Cache data: sqflite untuk offline support
- Settings ringan: shared_preferences

## Navigasi
- GoRouter dengan route names sebagai konstanta
- Redirect otomatis ke login jika token expired

## Error Handling
- Semua usecase return Either<Failure, T> (dartz package)
- Failure types: NetworkFailure, AuthFailure, ServerFailure, ValidationFailure
- Tampilkan snackbar/dialog yang user-friendly, bukan raw error message

## Naming Convention
- File: snake_case (visit_checkin_page.dart)
- Class: PascalCase (VisitCheckinPage)
- Provider: camelCase + suffix (visitCheckinProvider)
- Konstanta route: kRouteVisitCheckin

## UI/UX Rules
- Material 3 design
- Loading state selalu ditampilkan (CircularProgressIndicator atau Shimmer)
- Empty state selalu ditampilkan dengan ilustrasi + pesan
- Semua form punya validasi inline
- Konfirmasi sebelum aksi destruktif

Kita akan membangun Flutter mobile app untuk Wowin CRM.

## KONTEKS PROYEK
Backend API sudah tersedia di https://api.wowin.id/api/v1
Auth: JWT Bearer token, refresh endpoint: POST /api/v1/auth/refresh
File statis: https://api.wowin.id/uploads/{path}

## STRUKTUR FOLDER TARGET
mobile/
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   ├── dio_client.dart          # Dio singleton + interceptors
│   │   │   └── api_endpoints.dart       # semua URL sebagai konstanta
│   │   ├── auth/
│   │   │   ├── token_storage.dart       # flutter_secure_storage wrapper
│   │   │   └── auth_interceptor.dart    # auto-refresh interceptor
│   │   ├── error/
│   │   │   ├── failures.dart            # Failure sealed class
│   │   │   └── exceptions.dart          # Exception types
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter config
│   │   └── theme/
│   │       └── app_theme.dart           # Material 3 theme
│   ├── features/
│   │   ├── auth/                        # Login, logout, token management
│   │   ├── customers/                   # List, detail, create pelanggan
│   │   ├── leads/                       # Pipeline leads
│   │   ├── deals/                       # Pipeline deals (kanban)
│   │   ├── visits/                      # Check-in foto, check-out
│   │   ├── tracking/                    # Background GPS service
│   │   ├── map/                         # Peta pelanggan & rute
│   │   └── dashboard/                   # KPI & summary
│   └── main.dart
└── pubspec.yaml

## DEPENDENCIES YANG DIPAKAI
dependencies:
  # State & DI
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # HTTP
  dio: ^5.4.0
  
  # Auth & Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  
  # Database lokal
  sqflite: ^2.3.0
  
  # Kamera & foto
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  
  # GPS & Maps
  geolocator: ^11.0.0
  google_maps_flutter: ^2.6.0
  permission_handler: ^11.3.0
  workmanager: ^0.5.2
  
  # Utils
  dartz: ^0.10.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  intl: ^0.19.0
  
dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.4.0

## TASK — LAKUKAN SECARA BERURUTAN

### STEP 1 — Setup & Core
Buat file-file core berikut (tampilkan full content, bukan snippet):
1. pubspec.yaml (dengan semua dependencies di atas)
2. lib/core/error/failures.dart — sealed class semua Failure types
3. lib/core/api/api_endpoints.dart — semua endpoint sebagai konstanta
4. lib/core/api/dio_client.dart — Dio singleton dengan logging interceptor
5. lib/core/auth/token_storage.dart — wrapper flutter_secure_storage
6. lib/core/auth/auth_interceptor.dart — auto-refresh JWT pada 401
7. lib/core/router/app_router.dart — GoRouter dengan redirect auth guard
8. lib/main.dart — ProviderScope + MaterialApp.router

Setelah selesai Step 1, BERHENTI dan tanya:
"Step 1 selesai. Lanjut ke Step 2 (Feature Auth) atau ada yang perlu direvisi?"

### STEP 2 — Feature Auth
Buat feature auth lengkap:
- domain: UserEntity, AuthRepository (abstract), LoginUseCase
- data: AuthModel (freezed), AuthRemoteDataSource, AuthRepositoryImpl
- presentation: LoginPage dengan form validasi, AuthProvider (AsyncNotifier)

Setelah selesai, BERHENTI dan tanya step selanjutnya.

### STEP 3 — Feature Visits (CHECK-IN DENGAN FOTO)
Ini fitur paling kritis. Buat:
- CheckInPage: ambil foto via kamera (WAJIB ImageSource.camera),
  preview foto, tampilkan jarak ke pelanggan real-time,
  tombol submit aktif hanya jika foto sudah diambil
- CheckOutPage: form hasil kunjungan, next action, next visit date
- VisitRepository + UseCase untuk checkin & checkout
- Kompres foto sebelum upload (max 1280px, quality 80)
- Tampilkan badge "DI LUAR RADIUS" jika jarak > radius pelanggan
  (tapi tetap boleh check-in dengan warning, bukan block)

### STEP 4 — Background GPS Tracking
Buat GPS background service:
- WorkManager task yang jalan setiap 30 detik
- Logic: jika speed < 0.5 m/s → skip (interval jadi 120s)
- Jika jam < 07:00 atau > 18:00 → stop tracking
- Simpan ke sqflite jika offline
- Sync ke backend saat koneksi kembali
- Endpoint: POST /api/v1/tracking/location (batch)


### 4.6 Vue.js 3 Web

```javascript
// Composition API + <script setup> selalu
// State: Pinia (bukan Vuex)
// HTTP: Axios dengan instance per modul + interceptor auth
// Maps: Leaflet.js + vue-leaflet untuk peta & territory
// Charts: Apache ECharts atau Chart.js
// UI: Ant Design Vue atau PrimeVue (konsisten satu pilihan)
// GPS real-time dashboard: polling setiap 10 detik atau WebSocket
```


## 4.6.1. Stack & Dependencies

```
Framework   : Vue.js 3 + Vite 5
Language    : TypeScript (strict mode)
State       : Pinia 2
Router      : Vue Router 4
HTTP        : Axios (instance per modul)
UI          : shadcn-vue (headless, Radix Vue based)
Styling     : Tailwind CSS v3
Maps        : Leaflet.js + @vue-leaflet/vue-leaflet
Charts      : Apache ECharts + vue-echarts
Icons       : Lucide Vue Next
Forms       : VeeValidate + Zod
Drag & Drop : vue-draggable-plus (kanban deals)
Date/Time   : date-fns
```

### package.json dependencies

```json
{
  "dependencies": {
    "vue": "^3.4.0",
    "vue-router": "^4.3.0",
    "pinia": "^2.1.0",
    "axios": "^1.6.0",
    "shadcn-vue": "latest",
    "@radix-vue/radix-vue": "^1.7.0",
    "tailwindcss": "^3.4.0",
    "leaflet": "^1.9.0",
    "@vue-leaflet/vue-leaflet": "^0.10.0",
    "echarts": "^5.5.0",
    "vue-echarts": "^6.7.0",
    "lucide-vue-next": "^0.378.0",
    "vee-validate": "^4.12.0",
    "zod": "^3.22.0",
    "@vee-validate/zod": "^4.12.0",
    "vue-draggable-plus": "^0.5.0",
    "date-fns": "^3.6.0",
    "@vueuse/core": "^10.9.0"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "@vitejs/plugin-vue": "^5.0.0",
    "vite": "^5.2.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  }
}
```

---

## 4.6.2. Struktur Folder

```
web/
├── src/
│   ├── api/                        # Axios instances & calls per modul
│   │   ├── client.ts               # Base axios instance + interceptors
│   │   ├── auth.api.ts
│   │   ├── customers.api.ts
│   │   ├── leads.api.ts
│   │   ├── deals.api.ts
│   │   ├── visits.api.ts
│   │   ├── tracking.api.ts
│   │   ├── territories.api.ts
│   │   └── reports.api.ts
│   │
│   ├── stores/                     # Pinia stores
│   │   ├── auth.store.ts
│   │   ├── customers.store.ts
│   │   ├── deals.store.ts
│   │   ├── tracking.store.ts       # Live GPS state
│   │   └── ui.store.ts             # sidebar, theme, loading
│   │
│   ├── router/
│   │   ├── index.ts                # Router instance
│   │   ├── routes.ts               # Route definitions
│   │   └── guards.ts               # Auth guard, role guard
│   │
│   ├── views/                      # Full-page components (route targets)
│   │   ├── auth/
│   │   │   └── LoginView.vue
│   │   ├── dashboard/
│   │   │   └── DashboardView.vue   # KPI ringkasan eksekutif
│   │   ├── crm/
│   │   │   ├── customers/
│   │   │   │   ├── CustomerListView.vue
│   │   │   │   └── CustomerDetailView.vue
│   │   │   ├── leads/
│   │   │   │   └── LeadListView.vue
│   │   │   └── deals/
│   │   │       └── DealKanbanView.vue  # Kanban board
│   │   ├── sales/
│   │   │   ├── VisitListView.vue
│   │   │   └── VisitDetailView.vue
│   │   ├── mapping/
│   │   │   ├── LiveTrackingView.vue    # Real-time peta sales
│   │   │   ├── TerritoryView.vue       # Gambar & manage area
│   │   │   └── HeatmapView.vue
│   │   ├── reports/
│   │   │   ├── KpiReportView.vue
│   │   │   ├── VisitReportView.vue
│   │   │   └── PipelineReportView.vue
│   │   └── settings/
│   │       ├── UserManagementView.vue
│   │       └── TargetSettingView.vue
│   │
│   ├── components/                 # Reusable components
│   │   ├── ui/                     # shadcn-vue generated components
│   │   ├── map/
│   │   │   ├── LeafletMap.vue      # Base map wrapper
│   │   │   ├── CustomerMarkers.vue
│   │   │   ├── SalesTracker.vue    # Live dot per sales
│   │   │   ├── RoutePolyline.vue   # Rute harian
│   │   │   ├── TerritoryPolygon.vue
│   │   │   └── HeatmapLayer.vue
│   │   ├── charts/
│   │   │   ├── KpiCard.vue
│   │   │   ├── FunnelChart.vue     # Pipeline conversion
│   │   │   ├── BarChart.vue        # Kunjungan per hari
│   │   │   └── LineChart.vue       # Revenue trend
│   │   ├── kanban/
│   │   │   ├── KanbanBoard.vue
│   │   │   ├── KanbanColumn.vue
│   │   │   └── KanbanCard.vue
│   │   └── shared/
│   │       ├── AppLayout.vue       # Sidebar + topbar layout
│   │       ├── DataTable.vue       # Reusable table + pagination
│   │       ├── StatusBadge.vue
│   │       ├── EmptyState.vue
│   │       └── ConfirmDialog.vue
│   │
│   ├── composables/                # Reusable composition functions
│   │   ├── useAuth.ts
│   │   ├── usePagination.ts
│   │   ├── useDebounce.ts
│   │   ├── useLiveTracking.ts      # Polling GPS tiap 10 detik
│   │   └── useLeafletMap.ts
│   │
│   ├── types/                      # TypeScript interfaces & types
│   │   ├── api.types.ts            # Response envelope, pagination
│   │   ├── auth.types.ts
│   │   ├── customer.types.ts
│   │   ├── deal.types.ts
│   │   ├── visit.types.ts
│   │   ├── tracking.types.ts
│   │   └── territory.types.ts
│   │
│   ├── utils/
│   │   ├── format.ts               # currency, date, distance formatter
│   │   ├── storage.ts              # localStorage wrapper (token)
│   │   └── geo.ts                  # koordinat helpers
│   │
│   ├── constants/
│   │   └── index.ts                # API base URL, role names, deal stages
│   │
│   ├── App.vue
│   └── main.ts
│
├── public/
├── index.html
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── .env.example
```

## 4.6.3. Konvensi Kode

### 4.6.3.1 Semua komponen wajib `<script setup lang="ts">`

```vue
<!-- ✅ BENAR -->
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useCustomerStore } from '@/stores/customers.store'

const store = useCustomerStore()
const search = ref('')

const filtered = computed(() =>
  store.customers.filter(c => c.name.includes(search.value))
)

onMounted(() => store.fetchAll())
</script>

<!-- ❌ SALAH — jangan pakai Options API atau <script> tanpa setup -->
```

### 4.6.3.2 Naming Conventions

```
File views      : PascalCase + "View"  → CustomerListView.vue
File components : PascalCase           → DataTable.vue
File composables: camelCase + "use"    → useAuth.ts
File stores     : camelCase + ".store" → auth.store.ts
File api        : camelCase + ".api"   → customers.api.ts
File types      : camelCase + ".types" → customer.types.ts

Props           : camelCase
Emits           : kebab-case           → emit('update:model-value')
CSS classes     : Tailwind utility only, no custom class names
```

### 4.6.3.3 API Response Envelope (sesuai backend)

```typescript
// types/api.types.ts
export interface ApiResponse<T> {
  success: boolean
  data: T
  meta?: {
    page: number
    limit: number
    total: number
    total_pages: number
  }
}

export interface ApiError {
  success: false
  error: {
    code: string       // AUTH_INVALID, NOT_FOUND, VALIDATION_ERROR, dll
    message: string
  }
}
```

### 4.6.3.4 Axios Client Pattern

```typescript
// api/client.ts
import axios from 'axios'
import { useAuthStore } from '@/stores/auth.store'

const client = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL + '/api/v1',
  timeout: 15000,
})

// Request: attach token
client.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// Response: handle 401 → refresh token → retry
client.interceptors.response.use(
  (res) => res,
  async (error) => {
    const original = error.config
    if (error.response?.status === 401 && !original._retry) {
      original._retry = true
      const auth = useAuthStore()
      await auth.refreshToken()
      return client(original)
    }
    return Promise.reject(error)
  }
)

export default client
```

### 4.6.3.5 Pinia Store Pattern

```typescript
// stores/customers.store.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { fetchCustomers, createCustomer } from '@/api/customers.api'
import type { Customer, CustomerFilter } from '@/types/customer.types'

export const useCustomerStore = defineStore('customers', () => {
  // State
  const customers = ref<Customer[]>([])
  const total = ref(0)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const activeCustomers = computed(() =>
    customers.value.filter(c => c.status === 'active')
  )

  // Actions
  async function fetchAll(filter?: CustomerFilter) {
    loading.value = true
    error.value = null
    try {
      const res = await fetchCustomers(filter)
      customers.value = res.data.data
      total.value = res.data.meta?.total ?? 0
    } catch (e: any) {
      error.value = e.response?.data?.error?.message ?? 'Terjadi kesalahan'
    } finally {
      loading.value = false
    }
  }

  return { customers, total, loading, error, activeCustomers, fetchAll }
})
```


## 4.6.4. Auth & Route Guard

```typescript
// router/guards.ts
import type { NavigationGuardNext, RouteLocationNormalized } from 'vue-router'

export function authGuard(
  to: RouteLocationNormalized,
  _from: RouteLocationNormalized,
  next: NavigationGuardNext
) {
  const token = localStorage.getItem('access_token')
  if (!token && to.meta.requiresAuth) {
    next({ name: 'login', query: { redirect: to.fullPath } })
    return
  }
  next()
}

export function roleGuard(allowedRoles: string[]) {
  return (
    to: RouteLocationNormalized,
    _from: RouteLocationNormalized,
    next: NavigationGuardNext
  ) => {
    const role = localStorage.getItem('user_role') ?? ''
    if (!allowedRoles.includes(role)) {
      next({ name: 'dashboard' })
      return
    }
    next()
  }
}

// routes.ts — contoh penggunaan
{
  path: '/territories',
  component: () => import('@/views/mapping/TerritoryView.vue'),
  meta: { requiresAuth: true },
  beforeEnter: roleGuard(['super_admin', 'manager'])
}
```


## 4.6.5. Peta Leaflet — Pola Komponen

### 4.6.5.1 Base Map Wrapper

```vue
<!-- components/map/LeafletMap.vue -->
<script setup lang="ts">
import { LMap, LTileLayer } from '@vue-leaflet/vue-leaflet'
import 'leaflet/dist/leaflet.css'

interface Props {
  center?: [number, number]
  zoom?: number
  height?: string
}

const props = withDefaults(defineProps<Props>(), {
  center: () => [-2.5, 118.0], // center Indonesia
  zoom: 5,
  height: '100%',
})
</script>

<template>
  <LMap
    :center="props.center"
    :zoom="props.zoom"
    :style="{ height: props.height }"
    :use-global-leaflet="false"
  >
    <LTileLayer
      url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      attribution="© OpenStreetMap"
    />
    <slot />
  </LMap>
</template>
```

### 4.6.5.2 Territory Drawing (Polygon)

```vue
<!-- views/mapping/TerritoryView.vue — pola menggambar polygon -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import L from 'leaflet'
import 'leaflet-draw/dist/leaflet.draw.css'
import 'leaflet-draw'

const mapRef = ref<L.Map | null>(null)

function initDrawControl(map: L.Map) {
  const drawnItems = new L.FeatureGroup().addTo(map)

  const drawControl = new (L as any).Control.Draw({
    edit: { featureGroup: drawnItems },
    draw: {
      polygon: true,
      polyline: false,
      rectangle: false,
      circle: false,
      marker: false,
    },
  })
  map.addControl(drawControl)

  map.on((L as any).Draw.Event.CREATED, (e: any) => {
    const layer = e.layer
    drawnItems.addLayer(layer)
    // Ambil GeoJSON untuk dikirim ke backend
    const geojson = layer.toGeoJSON()
    emit('territory-drawn', geojson)
  })
}
</script>
```

### 4.6.5.3 Live GPS Tracking (Polling)

```typescript
// composables/useLiveTracking.ts
import { ref, onMounted, onUnmounted } from 'vue'
import { getLivePositions } from '@/api/tracking.api'
import type { SalesLivePosition } from '@/types/tracking.types'

export function useLiveTracking(intervalMs = 10000) {
  const positions = ref<SalesLivePosition[]>([])
  let timer: ReturnType<typeof setInterval>

  async function refresh() {
    try {
      const res = await getLivePositions()
      positions.value = res.data.data
    } catch { /* silent fail */ }
  }

  onMounted(() => {
    refresh()
    timer = setInterval(refresh, intervalMs)
  })

  onUnmounted(() => clearInterval(timer))

  return { positions }
}
```

## 4.6.6. Deal Kanban Board

```vue
<!-- components/kanban/KanbanBoard.vue -->
<script setup lang="ts">
import { ref } from 'vue'
import { VueDraggable } from 'vue-draggable-plus'
import KanbanColumn from './KanbanColumn.vue'
import { useDealStore } from '@/stores/deals.store'

const STAGES = [
  { key: 'prospecting',   label: 'Prospecting' },
  { key: 'qualification', label: 'Qualification' },
  { key: 'proposal',      label: 'Proposal' },
  { key: 'negotiation',   label: 'Negotiation' },
  { key: 'closed_won',    label: 'Closed Won' },
  { key: 'closed_lost',   label: 'Closed Lost' },
] as const

const store = useDealStore()

async function onStageDrop(dealId: string, newStage: string) {
  await store.updateStage(dealId, newStage)
}
</script>

<template>
  <div class="flex gap-4 overflow-x-auto h-full pb-4">
    <KanbanColumn
      v-for="stage in STAGES"
      :key="stage.key"
      :title="stage.label"
      :deals="store.byStage(stage.key)"
      @deal-dropped="(dealId) => onStageDrop(dealId, stage.key)"
    />
  </div>
</template>
```

## 4.6.7. Chart ECharts — Pola

```vue
<!-- components/charts/BarChart.vue -->
<script setup lang="ts">
import { computed } from 'vue'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'

use([CanvasRenderer, BarChart, GridComponent, TooltipComponent, LegendComponent])

interface Props {
  labels: string[]
  values: number[]
  title?: string
  color?: string
}

const props = withDefaults(defineProps<Props>(), {
  color: '#3B82F6',
})

const option = computed(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: props.labels },
  yAxis: { type: 'value' },
  series: [{
    type: 'bar',
    data: props.values,
    itemStyle: { color: props.color },
  }],
}))
</script>

<template>
  <VChart :option="option" autoresize style="height: 300px" />
</template>
```

## 4.6.8. Environment Variables

```bash
# .env.example
VITE_API_BASE_URL=https://api.wowin.id
VITE_MAPS_TILE_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
VITE_LIVE_TRACKING_INTERVAL=10000   # milliseconds
VITE_APP_NAME=Wowin CRM
```

## 4.6.9. Aturan Wajib Vue (JANGAN DILANGGAR)

| No | Aturan |
|---|---|
| 1 | Selalu `<script setup lang="ts">` — tidak ada Options API |
| 2 | Selalu Pinia — tidak ada Vuex atau global reactive |
| 3 | Selalu Axios dari `@/api/client.ts` — tidak ada fetch() langsung |
| 4 | Leaflet map hanya via `@vue-leaflet/vue-leaflet` — tidak ada `document.getElementById` |
| 5 | Simpan token di `localStorage` dengan key `access_token` & `refresh_token` |
| 6 | Semua form pakai VeeValidate + Zod schema |
| 7 | Semua tabel pakai komponen `DataTable.vue` yang sudah ada |
| 8 | Loading state wajib ditampilkan — tidak ada blank screen |
| 9 | Konfirmasi dialog sebelum DELETE atau aksi destruktif |
| 10 | `VITE_API_BASE_URL` dari env — tidak hardcode URL |


## 4.6.10. Role & Akses Halaman

| Halaman | super_admin | manager | supervisor | sales |
|---|---|---|---|---|
| Dashboard | ✅ | ✅ | ✅ | ✅ |
| Customers | ✅ | ✅ | ✅ | ✅ (milik sendiri) |
| Leads & Deals | ✅ | ✅ | ✅ | ✅ (milik sendiri) |
| Visit List | ✅ | ✅ | ✅ | ✅ (milik sendiri) |
| Live Tracking | ✅ | ✅ | ✅ | ❌ |
| Territory | ✅ | ✅ | ❌ | ❌ |
| Heatmap | ✅ | ✅ | ✅ | ❌ |
| Reports | ✅ | ✅ | ✅ (tim sendiri) | ✅ (diri sendiri) |
| User Management | ✅ | ✅ | ❌ | ❌ |
| Target Setting | ✅ | ✅ | ❌ | ❌ |

---

## 5. Database Schema Ringkasan

Schema lengkap ada di `schema.sql`. Tabel utama dan relasinya:

```
users ──────────────────────────────────────────────┐
  │                                                  │
  ├──→ territory_users ←── territories (polygon)     │
  │                                                  │
  ├──→ customers ──→ contacts                        │
  │       │                                          │
  │       ├──→ leads                                 │
  │       └──→ deals ──→ deal_items ──→ products     │
  │                                                  │
  ├──→ visit_schedules                               │
  │       └──→ visits ──→ visit_photos               │  (GPS + foto)
  │                                                  │
  ├──→ tracking_sessions ──→ gps_points (partisi)    │  (rute harian)
  ├──→ sales_live_positions                          │  (real-time)
  │                                                  │
  ├──→ attendances                                   │
  ├──→ tasks                                         │
  ├──→ activities                                    │
  ├──→ sales_targets                                 │
  └──→ notifications                                 │
```

**Tabel kritikal untuk fitur lapangan:**

| Tabel | Fungsi | Hal penting |
|---|---|---|
| `visits` | Rekaman kunjungan | `checkin_is_valid` = dalam radius atau tidak |
| `visit_photos` | Foto bukti kunjungan | `mime_type` constraint, `checksum` SHA256 |
| `gps_points` | Titik GPS (partisi/bulan) | Volume tinggi, index GIST |
| `tracking_sessions` | Rute harian (polyline) | `route` = LINESTRING, direbuild via `fn_rebuild_session_route()` |
| `sales_live_positions` | Posisi live satu baris/sales | Di-upsert setiap kirim GPS |
| `territories` | Polygon area kerja | Auto-assign via trigger `trg_customer_auto_territory` |

---

## 6. Alur Bisnis Kritikal

### 6.1 Alur Check-In Kunjungan (WAJIB FOTO)

```
Flutter App:
1. Sales buka halaman kunjungan
2. Ambil foto via KAMERA LANGSUNG (ImageSource.camera)
   → Tidak boleh dari galeri (validasi di Flutter)
3. Kirim POST /api/v1/visits/checkin dengan:
   - photo: file (multipart)
   - customer_id, lat, lng, accuracy
   - taken_at (timestamp device)

Backend (Gin):
4. Validasi JWT + role = sales
5. Hitung jarak ke koordinat pelanggan via ST_Distance (GEOGRAPHY)
6. Set checkin_is_valid = (jarak <= customers.checkin_radius)
7. Simpan file ke: uploads/visits/{YYYY}/{MM}/{DD}/{visit_id}/{uuid}.jpg
8. Hitung SHA256 checksum foto
9. Insert visits + visit_photos
10. Return visit_id + is_valid + distance_meters
```

### 6.2 Alur GPS Tracking

```
Flutter (background):
1. WorkManager / background_fetch jalankan setiap 30 detik
2. Jika tidak bergerak (speed < 0.5 m/s) → interval jadi 120 detik
3. Hanya tracking saat jam kerja (07:00–18:00 WIB)
4. Batch kirim max 10 titik sekaligus ke:
   POST /api/v1/tracking/location
   body: { session_id, points: [{lat, lng, accuracy, speed, heading, battery, recorded_at}] }

Backend:
5. Bulk insert ke gps_points (partisi per bulan)
6. UPSERT ke sales_live_positions (posisi terakhir)
7. Update tracking_sessions.status
8. Setiap malam (cron): fn_rebuild_session_route() → rebuild polyline + hitung total_distance
```

### 6.3 Alur Territory Auto-Assign

```
Saat koordinat pelanggan di-update:
1. Trigger trg_customer_auto_territory otomatis jalan
2. ST_Contains(territory.geom, customer.location)
3. Jika ada territory yang cocok → set customer.territory_id otomatis
4. Sales yang di-assign ke territory itu otomatis jadi PIC pelanggan
```

---

## 7. Endpoint API Lengkap

### Auth
```
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
```

### CRM
```
GET    /api/v1/customers              ?page, limit, status, territory_id, assigned_to
POST   /api/v1/customers
GET    /api/v1/customers/:id
PUT    /api/v1/customers/:id
DELETE /api/v1/customers/:id          (soft delete)
GET    /api/v1/customers/:id/contacts
POST   /api/v1/customers/:id/contacts

GET    /api/v1/leads                  ?status, assigned_to
POST   /api/v1/leads
PUT    /api/v1/leads/:id
POST   /api/v1/leads/:id/convert      (convert lead → customer + deal)

GET    /api/v1/deals                  ?stage, customer_id, assigned_to
POST   /api/v1/deals
PUT    /api/v1/deals/:id
PUT    /api/v1/deals/:id/stage        (update stage → catat history)
GET    /api/v1/deals/:id/items
POST   /api/v1/deals/:id/items
```

### Sales Field
```
GET    /api/v1/visit-schedules        ?date, sales_id
POST   /api/v1/visit-schedules
GET    /api/v1/visit-schedules/:id

POST   /api/v1/visits/checkin         (multipart: photo + metadata)
POST   /api/v1/visits/:id/checkout    (body: result_notes, next_action)
GET    /api/v1/visits                 ?sales_id, customer_id, date_from, date_to
GET    /api/v1/visits/:id
GET    /api/v1/visits/:id/photos
```

### GPS Tracking
```
POST   /api/v1/tracking/location      (batch GPS points)
GET    /api/v1/tracking/live          (semua sales aktif, GeoJSON)
GET    /api/v1/tracking/routes        ?sales_id, date (polyline GeoJSON)
PUT    /api/v1/tracking/status        { status: "on_the_way"|"at_location"|"idle"|"offline" }
```

### Mapping
```
GET    /api/v1/map/customers          GeoJSON FeatureCollection
GET    /api/v1/map/heatmap            ?date_from, date_to
GET    /api/v1/territories
POST   /api/v1/territories            body: { name, geojson_polygon, color }
PUT    /api/v1/territories/:id
DELETE /api/v1/territories/:id
POST   /api/v1/territories/:id/assign body: { user_ids: [...] }
```

### Laporan
```
GET    /api/v1/reports/kpi            ?year, month, user_id
GET    /api/v1/reports/visits         ?sales_id, date_from, date_to
GET    /api/v1/reports/routes         ?sales_id, date
GET    /api/v1/reports/pipeline       ?stage, date_from, date_to
GET    /api/v1/reports/leaderboard    ?year, month
```

### Absensi & User
```
POST   /api/v1/attendance/clock-in    (foto + GPS)
POST   /api/v1/attendance/clock-out
GET    /api/v1/attendance             ?user_id, date_from, date_to

GET    /api/v1/users
POST   /api/v1/users
PUT    /api/v1/users/:id
GET    /api/v1/users/:id/targets
PUT    /api/v1/users/:id/targets
```

---

## 8. Security Rules

| Rule | Detail |
|---|---|
| Auth | Semua endpoint kecuali `/auth/login` wajib JWT Bearer token |
| Role guard | Super admin > Manager > Supervisor > Sales |
| Sales isolation | Sales hanya bisa akses data milik sendiri (RLS + middleware) |
| File upload | Validasi MIME type (jpeg/png/webp only), max 5MB, rename ke UUID |
| Foto kunjungan | Harus dari kamera langsung, bukan galeri (enforced di Flutter) |
| GPS | Tracking hanya aktif jam 07:00–18:00 WIB, transparan ke sales |
| RLS | Set `app.current_user_id` dan `app.current_user_role` tiap query |
| Rate limit | Login: 5x/menit; Upload foto: 20x/menit; GPS: 60x/menit |

---

## 9. PostGIS Query Patterns

```sql
-- Cek apakah sales dalam radius pelanggan (check-in validation)
SELECT * FROM fn_validate_checkin_distance(
    'customer-uuid'::UUID,
    ST_SetSRID(ST_MakePoint(lng, lat), 4326)
);

-- Semua pelanggan dalam radius 5km dari titik tertentu
SELECT id, name, ST_Distance(location::GEOGRAPHY, ref::GEOGRAPHY) AS dist_m
FROM customers
WHERE ST_DWithin(location::GEOGRAPHY, ST_MakePoint(lng,lat)::GEOGRAPHY, 5000)
  AND deleted_at IS NULL
ORDER BY dist_m;

-- Pelanggan dalam territory tertentu
SELECT c.* FROM customers c
JOIN territories t ON ST_Contains(t.geom, c.location)
WHERE t.id = 'territory-uuid';

-- Rute sales hari ini sebagai GeoJSON
SELECT ST_AsGeoJSON(route) FROM tracking_sessions
WHERE sales_id = 'user-uuid' AND session_date = CURRENT_DATE;

-- Heatmap: titik kunjungan 30 hari terakhir
SELECT ST_AsGeoJSON(checkin_location), COUNT(*) as visits
FROM visits
WHERE checkin_at >= NOW() - INTERVAL '30 days'
  AND checkin_location IS NOT NULL
GROUP BY checkin_location;
```

---

## 10. Panduan Output per Task

Saat mengerjakan task dalam proyek ini, ikuti panduan berikut:

### Membuat Endpoint Baru (Go)
1. Buat `model/` struct (domain + request DTO + response DTO)
2. Buat `repository/` method dengan raw SQL (pgx atau sqlx)
3. Buat `service/` business logic
4. Buat `handler/` yang tipis (binding → service → response)
5. Daftarkan route di `cmd/server/main.go` atau router file

### Membuat Fitur Flutter
1. Buat folder `features/{nama}/` dengan subfolder: `data/`, `domain/`, `presentation/`
2. API call via Dio di `core/api/`
3. State via Riverpod Provider
4. Foto: selalu gunakan `ImageSource.camera`
5. GPS: gunakan package `geolocator`

### Membuat Komponen Vue.js
1. Gunakan `<script setup>` + Composition API
2. State via Pinia store
3. API call via Axios instance dari `src/api/`
4. Peta: Leaflet via `vue-leaflet`

### Query Database Baru
1. Selalu gunakan `$1, $2, ...` placeholder (pgx style)
2. Koordinat: selalu cast ke `::GEOGRAPHY` untuk perhitungan jarak
3. Pagination: `LIMIT $n OFFSET $m` + return total count
4. Soft delete: selalu tambah `AND deleted_at IS NULL`

---

## 11. File Referensi Terkait

| File | Isi |
|---|---|
| `schema.sql` | Schema PostgreSQL lengkap (26 tabel + functions + triggers) |
| `project-brief-crm-sales.md` | Project brief lengkap, roadmap, estimasi tim |
| `SKILL.md` | File ini |

---

## 12. Hal yang TIDAK BOLEH dilakukan

- ❌ Jangan gunakan S3, MinIO, atau storage cloud eksternal
- ❌ Jangan simpan full URL di database (simpan path relatif saja)
- ❌ Jangan izinkan upload foto dari galeri untuk kunjungan & absensi
- ❌ Jangan tracking GPS di luar jam kerja (07:00–18:00)
- ❌ Jangan gunakan ORM (gorm dll) — gunakan raw SQL dengan pgx/sqlx
- ❌ Jangan gunakan `TIMESTAMP` tanpa zona — selalu `TIMESTAMPTZ`
- ❌ Jangan hitung jarak tanpa cast `::GEOGRAPHY` (hasilnya derajat, bukan meter)
- ❌ Jangan hardcode domain/URL — ambil dari config/env
- ❌ Jangan bypass RLS — selalu set `app.current_user_id` sebelum query