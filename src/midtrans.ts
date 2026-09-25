import type { Env, MidtransConfig } from './types';

export async function getMidtransConfig(env: Env): Promise<MidtransConfig | null> {
  return env.DB.prepare('SELECT * FROM midtrans_config WHERE id = 1').first<MidtransConfig>();
}

function midtransBaseUrl(isProduction: boolean): string {
  return isProduction
    ? 'https://api.midtrans.com'
    : 'https://api.sandbox.midtrans.com';
}

function authHeader(serverKey: string): string {
  // Midtrans uses Basic auth: server_key as username, empty password
  return 'Basic ' + btoa(serverKey + ':');
}

export interface ChargePayload {
  order_id: string;
  gross_amount: number;
  customer_name: string;
  customer_email?: string;
  customer_phone: string;
  item_details: Array<{
    id: string;
    name: string;
    price: number;
    quantity: number;
  }>;
  payment_type?: string;
}

export async function createCharge(
  config: MidtransConfig,
  payload: ChargePayload & { payment_type?: string; bank?: string }
): Promise<{ ok: boolean; data?: any; error?: string }> {
  if (!config.server_key) {
    return { ok: false, error: 'Midtrans Server Key belum dikonfigurasi di admin.' };
  }

  const paymentType = payload.payment_type || 'bank_transfer';
  const body: Record<string, unknown> = {
    payment_type: paymentType,
    transaction_details: {
      order_id: payload.order_id,
      gross_amount: payload.gross_amount,
    },
    customer_details: {
      first_name: payload.customer_name,
      email: payload.customer_email || `${payload.customer_phone}@customer.local`,
      phone: payload.customer_phone,
    },
    item_details: payload.item_details,
  };

  if (paymentType === 'bank_transfer') {
    body.bank_transfer = { bank: payload.bank || 'bca' };
  } else if (paymentType === 'gopay') {
    body.gopay = { enable_callback: true, callback_url: 'https://example.com/gopay' };
  } else if (paymentType === 'qris') {
    body.qris = { acquirer: 'gopay' };
  }

  const url = `${midtransBaseUrl(!!config.is_production)}/v2/charge`;

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        Authorization: authHeader(config.server_key),
      },
      body: JSON.stringify(body),
    });

    const data = await res.json();
    if (!res.ok || (data.status_code && String(data.status_code).startsWith('4'))) {
      return {
        ok: false,
        error: data.status_message || data.error_messages?.join(', ') || 'Midtrans charge gagal',
        data,
      };
    }
    return { ok: true, data };
  } catch (e: any) {
    return { ok: false, error: e?.message || 'Gagal menghubungi Midtrans' };
  }
}

export async function verifyNotificationSignature(
  serverKey: string,
  orderId: string,
  statusCode: string,
  grossAmount: string,
  signatureKey: string
): Promise<boolean> {
  const raw = orderId + statusCode + grossAmount + serverKey;
  const data = new TextEncoder().encode(raw);
  const hash = await crypto.subtle.digest('SHA-512', data);
  const hex = [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, '0')).join('');
  return hex === signatureKey;
}

export async function getTransactionStatus(
  config: MidtransConfig,
  orderId: string
): Promise<{ ok: boolean; data?: any; error?: string }> {
  if (!config.server_key) {
    return { ok: false, error: 'Server key belum dikonfigurasi' };
  }
  const url = `${midtransBaseUrl(!!config.is_production)}/v2/${encodeURIComponent(orderId)}/status`;
  try {
    const res = await fetch(url, {
      headers: {
        Accept: 'application/json',
        Authorization: authHeader(config.server_key),
      },
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch (e: any) {
    return { ok: false, error: e?.message };
  }
}
