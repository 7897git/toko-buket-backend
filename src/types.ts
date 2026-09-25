export interface Env {
  DB: D1Database;
  ADMIN_SESSION_TTL_HOURS: string;
}

export interface StoreSettings {
  id: number;
  nama_toko: string;
  deskripsi: string;
  jam_operasional: string;
  alamat: string;
  nomor_telp: string;
  updated_at: string;
}

export interface MidtransConfig {
  id: number;
  server_key: string;
  client_key: string;
  is_production: number;
  updated_at: string;
}

export interface Product {
  id: number;
  slug: string;
  nama: string;
  gambar: string;
  kategori: string;
  harga: number;
  deskripsi: string;
  is_active: number;
  created_at: string;
  updated_at: string;
}

export interface Order {
  id: number;
  order_id: string;
  customer_name: string;
  customer_phone: string;
  customer_email: string;
  customer_address: string;
  notes: string;
  total_amount: number;
  status: string;
  midtrans_transaction_id: string;
  midtrans_payment_type: string;
  midtrans_status: string;
  created_at: string;
  updated_at: string;
}

export interface OrderItem {
  id: number;
  order_id: string;
  product_id: number | null;
  product_name: string;
  product_price: number;
  quantity: number;
}

export interface CheckoutItem {
  product_id: number;
  quantity: number;
}

export interface CheckoutBody {
  customer_name: string;
  customer_phone: string;
  customer_email?: string;
  customer_address?: string;
  notes?: string;
  items: CheckoutItem[];
}
