/**
 * API client for Swiss Energy Assistant.
 * All data is fetched through our backend proxy — no direct browser-to-provider calls.
 * This avoids CORS issues and rate limiting.
 */

export type ProviderId = 'ckw' | 'groupe-e' | 'primeo';

export interface ProviderPrice {
  start: string;
  end: string;
  integrated: number;
  grid: number;
  electricity: number;
}

export interface ProviderSummary {
  integrated_min: number;
  integrated_max: number;
  integrated_avg: number;
  grid_min: number;
  grid_max: number;
  grid_avg: number;
}

export interface ProviderData {
  id: ProviderId;
  name: string;
  full_name: string;
  territory: string;
  color: string;
  status: string;
  publication: string | null;
  tariff_name?: string;
  interval_count: number;
  summary?: ProviderSummary;
  prices: ProviderPrice[];
}

export interface AllProvidersResponse {
  providers: ProviderData[];
}

export const PROVIDER_META: Record<ProviderId, { name: string; territory: string; color: string }> = {
  'ckw': { name: 'CKW', territory: 'Luzern', color: '#0d9488' },
  'groupe-e': { name: 'Groupe E', territory: 'Fribourg', color: '#2563eb' },
  'primeo': { name: 'Primeo', territory: 'Basel', color: '#7c3aed' },
};

const API_BASE = typeof window !== 'undefined'
  ? `${window.location.origin}/api/v1`
  : '/api/v1';

let _cache: { data: AllProvidersResponse; ts: number } | null = null;
const CACHE_MS = 60_000; // 1 minute client-side cache

export async function fetchAllProviders(): Promise<AllProvidersResponse> {
  const now = Date.now();
  if (_cache && now - _cache.ts < CACHE_MS) {
    return _cache.data;
  }

  try {
    const resp = await fetch(`${API_BASE}/tariffs/providers`, { cache: 'no-store' });
    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    const data: AllProvidersResponse = await resp.json();
    _cache = { data, ts: now };
    return data;
  } catch (e) {
    console.error('Failed to fetch providers:', e);
    if (_cache) return _cache.data;
    return { providers: [] };
  }
}

export function getProvider(providers: ProviderData[], id: ProviderId): ProviderData | undefined {
  return providers.find((p) => p.id === id);
}
