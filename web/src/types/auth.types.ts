export interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  territory_id?: string;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  expires_in?: number;
}

export interface AuthState {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;
}
