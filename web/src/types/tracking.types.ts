export interface GpsPoint {
  latitude: number;
  longitude: number;
  speed: number;
  accuracy: number;
  captured_at: string;
}

export interface SalesLivePosition {
  sales_id: string;
  sales_name: string;
  latitude: number;
  longitude: number;
  speed: number;
  accuracy: number;
  battery_level?: number;
  last_update: string;
  status: 'active' | 'inactive';
}

export interface TrackingSession {
  id: string;
  sales_id: string;
  date: string;
  points: GpsPoint[];
}
