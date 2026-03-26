import { defineStore } from 'pinia'
import { ref } from 'vue'
import * as api from '@/api/notifications.api'
import type { Notification } from '@/api/notifications.api'

export const useNotificationStore = defineStore('notifications', () => {
  const notifications = ref<Notification[]>([])
  const unreadCount = ref(0)
  const loading = ref(false)

  async function fetchAll() {
    loading.value = true
    try {
      const [notifRes, countRes] = await Promise.all([
        api.fetchNotifications(),
        api.getUnreadCount()
      ])
      notifications.value = notifRes.data.data
      unreadCount.value = countRes.data.data.unread_count
    } catch (e) {
      console.error('Failed to fetch notifications', e)
    } finally {
      loading.value = false
    }
  }

  async function markRead(id: string) {
    try {
      await api.markAsRead(id)
      const notif = notifications.value.find(n => n.id === id)
      if (notif && !notif.is_read) {
        notif.is_read = true
        unreadCount.value = Math.max(0, unreadCount.value - 1)
      }
    } catch (e) {
      console.error('Failed to mark notification as read', e)
    }
  }

  async function markAllRead() {
    try {
      await api.markAllAsRead()
      notifications.value.forEach(n => n.is_read = true)
      unreadCount.value = 0
    } catch (e) {
      console.error('Failed to mark all notifications as read', e)
    }
  }

  return {
    notifications,
    unreadCount,
    loading,
    fetchAll,
    markRead,
    markAllRead
  }
})
