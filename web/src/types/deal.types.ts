export type DealStage = 'prospecting' | 'qualification' | 'proposal' | 'negotiation' | 'closed_won' | 'closed_lost';

export interface DealItem {
  id: string;
  deal_id: string;
  product_id: string;
  product_name: string;
  quantity: number;
  price: number;
  subtotal: number;
}

export interface Deal {
  id: string;
  customer_id: string;
  customer_name?: string;
  title: string;
  value: number;
  stage: DealStage;
  expected_close_date: string;
  sales_id: string;
  sales_name?: string;
  items?: DealItem[];
  created_at: string;
  updated_at: string;
}
