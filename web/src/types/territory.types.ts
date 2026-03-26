export interface TerritoryGeoJSON {
  type: "FeatureCollection";
  features: Array<{
    type: "Feature";
    geometry: {
      type: "Polygon" | "MultiPolygon";
      coordinates: any[];
    };
    properties?: any;
  }>;
}

export interface Territory {
  id: string;
  name: string;
  color: string;
  geojson: TerritoryGeoJSON;
  sales_count?: number;
  customer_count?: number;
  created_at: string;
  updated_at: string;
}
