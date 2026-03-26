import { createRouter, createWebHistory } from 'vue-router'
import { routes } from './routes'
import { authGuard, roleGuard } from './guards'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

router.beforeEach(authGuard)

// Global role resolver wrapping explicit Role lists onto meta.roles mapping
router.beforeEach((to, from, next) => {
  if (to.meta.roles && Array.isArray(to.meta.roles)) {
    const shield = roleGuard(to.meta.roles as string[])
    return shield(to, from, next)
  }
  
  next()
})

export default router
