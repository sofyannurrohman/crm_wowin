/// <reference types="vite/client" />
// Use a relative base URL so all API requests go through the nginx reverse proxy
// on the same origin (port 8081 → proxied to api:8080 internally).
// This eliminates CORS entirely. Override with VITE_API_BASE_URL for bare local dev.
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || ''
export const APP_NAME = import.meta.env.VITE_APP_NAME || 'Wowin CRM'
export const LIVE_TRACKING_INTERVAL = Number(import.meta.env.VITE_LIVE_TRACKING_INTERVAL) || 10000

export const USER_ROLES = {
  SUPER_ADMIN: 'super_admin',
  MANAGER: 'manager',
  SUPERVISOR: 'supervisor',
  SALES: 'sales',
} as const;

export const DEAL_STAGES = [
  { key: 'prospecting', label: 'Prospecting' },
  { key: 'qualification', label: 'Qualification' },
  { key: 'proposal', label: 'Proposal' },
  { key: 'negotiation', label: 'Negotiation' },
  { key: 'closed_won', label: 'Closed Won' },
  { key: 'closed_lost', label: 'Closed Lost' },
] as const;
