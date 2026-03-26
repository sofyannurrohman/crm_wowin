export type CustomerStatus = 'active' | 'inactive' | 'lead';

export interface Customer {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  status: CustomerStatus;
  latitude?: number;
  longitude?: number;
  territory_id?: string;
  created_at: string;
  updated_at: string;
}

export interface CustomerFilter {
  status?: CustomerStatus;
  territory_id?: string;
  search?: string;
  page?: number;
  limit?: number;
}
