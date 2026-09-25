-- Toko Buket Backend Schema (D1 / SQLite)

-- Admin users
CREATE TABLE IF NOT EXISTS admin_users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Sessions (simple token-based)
CREATE TABLE IF NOT EXISTS sessions (
  token TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES admin_users(id) ON DELETE CASCADE
);

-- Store settings (single row, id=1)
CREATE TABLE IF NOT EXISTS store_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  nama_toko TEXT NOT NULL DEFAULT 'Floria Bouquet',
  deskripsi TEXT NOT NULL DEFAULT 'Crafting Your Beautiful Moments',
  jam_operasional TEXT NOT NULL DEFAULT 'Senin - Minggu: 09:00 - 21:00',
  alamat TEXT NOT NULL DEFAULT '',
  nomor_telp TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Midtrans config (stored in DB so admin can edit from dashboard)
CREATE TABLE IF NOT EXISTS midtrans_config (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  server_key TEXT NOT NULL DEFAULT '',
  client_key TEXT NOT NULL DEFAULT '',
  is_production INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Products
CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,
  nama TEXT NOT NULL,
  gambar TEXT NOT NULL DEFAULT '',
  kategori TEXT NOT NULL DEFAULT 'semua',
  harga INTEGER NOT NULL DEFAULT 0,
  deskripsi TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id TEXT NOT NULL UNIQUE,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_email TEXT DEFAULT '',
  customer_address TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  total_amount INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  midtrans_transaction_id TEXT DEFAULT '',
  midtrans_payment_type TEXT DEFAULT '',
  midtrans_status TEXT DEFAULT '',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Order items
CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id TEXT NOT NULL,
  product_id INTEGER,
  product_name TEXT NOT NULL,
  product_price INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_products_kategori ON products(kategori);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);

-- Seed: default admin (username: admin, password: admin123)
-- password_hash = SHA-256 of "admin123" (hex)
INSERT OR IGNORE INTO admin_users (id, username, password_hash)
VALUES (1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9');

-- Seed: store settings
INSERT OR IGNORE INTO store_settings (id, nama_toko, deskripsi, jam_operasional, alamat, nomor_telp)
VALUES (
  1,
  'Floria Bouquet',
  'Crafting Your Beautiful Moments — Buket bunga & gift premium',
  'Senin - Minggu: 09:00 - 21:00',
  'Jakarta, Indonesia',
  '6285156618776'
);

-- Seed: midtrans config (empty — isi dari admin)
INSERT OR IGNORE INTO midtrans_config (id, server_key, client_key, is_production)
VALUES (1, '', '', 0);

-- Seed: sample products (dari data lama)
INSERT OR IGNORE INTO products (id, slug, nama, gambar, kategori, harga, deskripsi) VALUES
(101, 'bunga-buketr-lokal-keren', 'Bucket Bunga Lokal Keren', '/assets/images/buket-black-torquis.jpeg', 'mawar', 299000, 'Bunga buket mawar merah premium yang dirangkai rapi dengan kertas pembungkus beludru hitam beraksen emas. Sangat menonjolkan nuansa mewah dan penuh cinta untuk momen romantis spesial Anda.'),
(102, 'pastel-dream-roses', 'Pastel Dream Bouquet', '/assets/images/buket-pink-butterfly.jpeg', 'mawar', 349000, 'Perpaduan mawar pink pastel, mawar putih, dan baby''s breath segar. Dirangkai dengan kertas wrapping berwarna peach lembut. Sangat cocok sebagai ungkapan ketulusan dan kekaguman.'),
(103, 'graduation-gold-victory', 'Graduation Gold Lily', '/assets/images/buket-torquis-butterfly.jpeg', 'wisuda', 420000, 'Buket wisuda prestisius yang memadukan Bunga Lily Kuning, Aster Putih, serta Boneka Wisuda mini berbulu lembut. Dirangkai elegan dengan pita satin berwarna emas gelap.'),
(104, 'sweet-chocolate-surprise', 'Sweet Chocolate Bouquet', '/assets/images/buket-torquis.jpeg', 'snack', 250000, 'Rangkaian istimewa berisikan 10 batang Ferrero Rocher premium yang ditata menawan di antara dedaunan kering eksotis. Hadiah yang manis dan lezat untuk hari anniversary.'),
(105, 'elegant-blue-hydrangea', 'Elegant Blue Hydrangea', '/assets/images/buket-deepblue.jpeg', 'semua', 385000, 'Bunga Hydrangea biru langit raksasa sebagai titik utama, dikelilingi oleh anyelir putih bersih. Dibungkus rapi dengan kertas beraksen monokrom kontemporer.'),
(106, 'snack-time-joy', 'Crispy Matcha Joy', '/assets/images/buket-bigblue.jpeg', 'snack', 185000, 'Buket snack serba hijau matcha dengan kombinasi Pocky, KitKat, dan wafer renyah pilihan. Dibalut dengan wrapper linen kraft alami bertema ramah lingkungan.');
