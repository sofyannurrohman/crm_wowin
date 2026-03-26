export type VisitStatus = 'scheduled' | 'checked_in' | 'completed' | 'cancelled';

export interface VisitPhoto {
  id: string;
  visit_id: string;
  path: string;
  type: 'check_in' | 'check_out';
  created_at: string;
}

export interface Visit {
  id: string;
  customer_id: string;
  customer_name?: string;
  sales_id: string;
  sales_name?: string;
  status: VisitStatus;
  scheduled_at: string;
  check_in_at?: string;
  check_in_lat?: number;
  check_in_lng?: number;
  check_out_at?: string;
  check_out_lat?: number;
  check_out_lng?: number;
  notes?: string;
  photos?: VisitPhoto[];
}
