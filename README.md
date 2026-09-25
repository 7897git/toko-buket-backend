# Toko Buket Backend

Backend API + Admin Dashboard untuk toko buket, dibangun dengan **Cloudflare Workers + D1 + Midtrans Core API**.

## Fitur

- **Admin Dashboard** (flat design) di `/admin`
  - Login: `admin` / `admin123`
  - Edit detail toko, CRUD produk, config Midtrans, list pesanan
- **Public API**: store, products, checkout (Core API), webhook
- **Database D1** (SQLite di edge)

## Setup

```bash
npm install
npx wrangler login
npm run db:create   # copy database_id ke wrangler.toml
npm run db:migrate  # local
npm run db:migrate:remote
npm run dev
npm run deploy
```

Admin: `http://localhost:8787/admin`

Webhook Midtrans: `https://<worker>.workers.dev/api/midtrans/notification`

## API singkat

- `GET /api/store` | `GET /api/products` | `POST /api/checkout`
- `POST /api/admin/login` lalu Bearer token untuk endpoint admin

Lihat source di `src/` dan `schema.sql` untuk detail.

## Frontend

Set `api_base_url` di Jekyll `_config.yml` ke URL Worker setelah deploy.
