export interface PaginationMeta {
  page: number
  limit: number
  total: number
  total_pages: number
}

export interface ApiResponse<T> {
  success: boolean
  data: T
  meta?: PaginationMeta
}

export interface ApiError {
  success: false
  error: {
    code: string
    message: string
  }
}
