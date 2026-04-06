import type { RouteRecordRaw } from 'vue-router'

export const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/auth/LoginView.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    component: () => import('@/components/shared/AppLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/dashboard'
      },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: () => import('@/views/dashboard/DashboardView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // CRM Customers
      {
        path: 'customers',
        name: 'customers',
        component: () => import('@/views/crm/customers/CustomerListView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      {
        path: 'customers/:id',
        name: 'customer-detail',
        component: () => import('@/views/crm/customers/CustomerDetailView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // CRM Leads
      {
        path: 'leads',
        name: 'leads',
        component: () => import('@/views/crm/leads/LeadListView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // CRM Deals 
      {
        path: 'deals',
        name: 'deals',
        component: () => import('@/views/crm/deals/DealKanbanView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      {
        path: 'deals/:id',
        name: 'deal-detail',
        component: () => import('@/views/crm/deals/DealDetailView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // CRM Products
      {
        path: 'products',
        name: 'products',
        component: () => import('@/views/crm/products/ProductListView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // CRM Tasks
      {
        path: 'tasks',
        name: 'tasks',
        component: () => import('@/views/crm/tasks/TaskListView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // Sales Visits
      {
        path: 'visits',
        name: 'visits',
        component: () => import('@/views/sales/VisitListView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      {
        path: 'visits/:id',
        name: 'visit-detail',
        component: () => import('@/views/sales/VisitDetailView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // Sales Attendance
      {
        path: 'attendance',
        name: 'attendance',
        component: () => import('@/views/sales/AttendanceHistoryView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor'] }
      },
      // Mapping Tools 
      {
        path: 'live-tracking',
        name: 'live-tracking',
        component: () => import('@/views/mapping/LiveTrackingView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor'] } // Sales can't see all other sales
      },
      {
        path: 'territories',
        name: 'territories',
        component: () => import('@/views/mapping/TerritoryView.vue'),
        meta: { roles: ['super_admin', 'manager'] }
      },
      {
        path: 'heatmap',
        name: 'heatmap',
        component: () => import('@/views/mapping/HeatmapView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor'] }
      },
      // Reports
      {
        path: 'reports/kpi',
        name: 'kpi-report',
        component: () => import('@/views/reports/KpiReportView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      {
        path: 'reports/visits',
        name: 'visit-report',
        component: () => import('@/views/reports/VisitReportView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      {
        path: 'reports/pipeline',
        name: 'pipeline-report',
        component: () => import('@/views/reports/PipelineReportView.vue'),
        meta: { roles: ['super_admin', 'manager', 'supervisor', 'sales'] }
      },
      // Settings
      {
        path: 'settings/users',
        name: 'user-management',
        component: () => import('@/views/settings/UserManagementView.vue'),
        meta: { roles: ['super_admin', 'manager'] }
      },
      {
        path: 'settings/targets',
        name: 'target-setting',
        component: () => import('@/views/settings/TargetSettingView.vue'),
        meta: { roles: ['super_admin', 'manager'] }
      },
      {
        path: 'settings/warehouses',
        name: 'warehouse-management',
        component: () => import('@/views/settings/WarehouseManagementView.vue'),
        meta: { roles: ['super_admin', 'manager'] }
      }
    ]
  },
  // Catch all 404
  {
    path: '/:pathMatch(.*)*',
    redirect: '/dashboard'
  }
]
