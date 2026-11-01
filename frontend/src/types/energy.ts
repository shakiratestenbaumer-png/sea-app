export type IsoInstant = string;

export type TariffEligibility = 'confirmed' | 'user_claimed' | 'unknown' | 'ineligible';
export type PublicationStatus = 'available' | 'awaiting_publication' | 'stale' | 'unsupported' | 'partial';
export type ApplianceType = 'dishwasher' | 'washing_machine' | 'tumble_dryer' | 'ev_charger' | 'water_heater' | 'other';
export type PriceComponent = 'energy' | 'network' | 'levies' | 'tax' | 'other';
export type DataQuality = 'ACTUAL' | 'FORECAST' | 'ESTIMATED' | 'STALE' | 'UNAVAILABLE' | 'DEMO';

export interface Provider {
  id: string;
  slug: string;
  name: string;
  territory?: string;
  docs_url?: string;
  license_status: string;
  publication_time_local?: string;
  native_granularity_minutes?: number;
  active: boolean;
}

export interface TariffProduct {
  id: string;
  provider_id: string;
  name: string;
  tariff_type: string;
  interval_minutes?: number;
  requires_ems: boolean;
  requires_smart_meter: boolean;
  eligibility: TariffEligibility;
  eligibility_text?: string;
  official_url?: string;
  is_selectable: boolean;
  scope: string;
}

export interface TariffSlot {
  start: IsoInstant;
  end: IsoInstant;
  component: string;
  price_chf_per_kwh: string;
  tax_included: boolean;
  quality: string;
}

export interface TariffSchedule {
  product_id: string;
  display_name: string;
  date_local: string;
  timezone: string;
  status?: PublicationStatus;
  published_at?: IsoInstant;
  fetched_at?: IsoInstant;
  data_state: string;
  resolution_minutes: number;
  currency: string;
  scope: string;
  all_in_price_available: boolean;
  intervals: TariffSlot[];
  source_url?: string;
  disclaimer?: string;
}

export interface Appliance {
  id: string;
  type: ApplianceType;
  display_name: string;
  duration_minutes: number;
  energy_kwh: number;
  earliest_start_local?: string;
  latest_finish_local?: string;
  preferred_baseline_start?: string;
  notification_lead_minutes: number;
  must_be_home: boolean;
  active: boolean;
}

export interface AlternativeWindow {
  start: IsoInstant;
  end: IsoInstant;
  modeled_cost_chf?: string;
}

export interface Recommendation {
  id?: string;
  appliance_id: string;
  run_date: string;
  best_start: IsoInstant;
  best_end: IsoInstant;
  modeled_cost_chf?: string;
  baseline_cost_chf?: string;
  potential_savings_chf?: string;
  confidence: 'measured' | 'modeled' | 'partial';
  priced_components?: string;
  alternatives: AlternativeWindow[];
  caveats: string[];
}

export interface Household {
  id: string;
  label: string;
  postal_code?: string;
  municipality_id?: string;
  municipality_name?: string;
  distribution_operator_name?: string;
  provider_id?: string;
  tariff_product_id?: string;
  enrollment_status: TariffEligibility;
  annual_kwh_estimate?: number;
}

export interface NotificationPreferences {
  daily_digest: boolean;
  daily_digest_local_time?: string;
  reminder_lead_minutes: number;
  quiet_hours_start?: string;
  quiet_hours_end?: string;
  enabled: boolean;
  push_registered: boolean;
}

export interface LocationResult {
  id: string;
  name: string;
  postcode: string;
  canton: string;
  operator: string;
  operator_id: string;
}

export interface LocalComparisonResult {
  product_id: string;
  product_name: string;
  tariff_type: string;
  annual_cost_chf: string;
  is_current: boolean;
  requires_ems: boolean;
  requires_smart_meter: boolean;
  eligibility_text?: string;
  assumptions: string;
}

export interface SwissComparisonEntry {
  name: string;
  operator: string;
  total_rp_kwh: string;
  energy_rp_kwh: string;
  grid_rp_kwh: string;
  levies_rp_kwh: string;
}
