/**
 * Deterministic mock API service for demo/development.
 * All prices are synthetic. DEMO badge must appear on all mock data.
 */

import type {
  Appliance,
  LocalComparisonResult,
  LocationResult,
  NotificationPreferences,
  Provider,
  Recommendation,
  SwissComparisonEntry,
  TariffProduct,
  TariffSchedule,
  TariffSlot,
} from '@/types/energy';

function generateHourlyPrices(dateStr: string): TariffSlot[] {
  const energyMultipliers = [
    0.70, 0.65, 0.60, 0.58, 0.60, 0.65,
    0.80, 0.95, 1.10, 1.20, 1.25, 1.30,
    1.20, 1.00, 0.85, 0.80, 0.90, 1.15,
    1.30, 1.25, 1.15, 1.00, 0.85, 0.75,
  ];
  const baseEnergy = 0.12;
  const baseGrid = 0.091;
  const baseLevies = 0.041;

  const slots: TariffSlot[] = [];

  for (let h = 0; h < 24; h++) {
    const hStr = h.toString().padStart(2, '0');
    const nextH = ((h + 1) % 24).toString().padStart(2, '0');
    const nextDate = h === 23 ? getNextDate(dateStr) : dateStr;
    const start = `${dateStr}T${hStr}:00:00+01:00`;
    const end = `${nextDate}T${nextH}:00:00+01:00`;

    const energyPrice = (baseEnergy * energyMultipliers[h]).toFixed(6);
    const gridPrice = baseGrid.toFixed(6);

    slots.push({
      start,
      end,
      component: 'ENERGY',
      price_chf_per_kwh: energyPrice,
      tax_included: true,
      quality: 'DEMO',
    });

    slots.push({
      start,
      end,
      component: 'GRID_USAGE',
      price_chf_per_kwh: gridPrice,
      tax_included: false,
      quality: 'DEMO',
    });
  }

  return slots;
}

function getNextDate(dateStr: string): string {
  const d = new Date(dateStr);
  d.setDate(d.getDate() + 1);
  return d.toISOString().split('T')[0];
}

function getTomorrowDate(): string {
  const d = new Date();
  d.setDate(d.getDate() + 1);
  return d.toISOString().split('T')[0];
}

function getTodayDate(): string {
  return new Date().toISOString().split('T')[0];
}

export const mockProviders: Provider[] = [
  {
    id: 'demo-provider',
    slug: 'alpenstrom',
    name: 'Alpenstrom Stadtwerk',
    territory: 'Bern',
    active: true,
    license_status: 'approved_public',
    publication_time_local: '12:00',
    native_granularity_minutes: 60,
  },
];

export const mockProducts: TariffProduct[] = [
  {
    id: 'demo-flex',
    provider_id: 'demo-provider',
    name: 'Alpenstrom Flex',
    tariff_type: 'DYNAMIC_ENERGY',
    interval_minutes: 60,
    requires_ems: false,
    requires_smart_meter: true,
    eligibility: 'user_claimed',
    eligibility_text: 'Stündlich variabler Energietarif',
    is_selectable: true,
    scope: 'FULL',
  },
  {
    id: 'demo-klassik',
    provider_id: 'demo-provider',
    name: 'Alpenstrom Klassik',
    tariff_type: 'HT_NT',
    interval_minutes: undefined,
    requires_ems: false,
    requires_smart_meter: false,
    eligibility: 'unknown',
    eligibility_text: 'Einfacher Hoch-/Niedertarif',
    is_selectable: true,
    scope: 'FULL',
  },
];

export const mockAppliances: Appliance[] = [
  {
    id: 'app-1',
    type: 'washing_machine',
    display_name: 'Waschmaschine',
    duration_minutes: 120,
    energy_kwh: 1.0,
    earliest_start_local: '06:00',
    latest_finish_local: '22:00',
    notification_lead_minutes: 15,
    must_be_home: false,
    active: true,
  },
  {
    id: 'app-2',
    type: 'dishwasher',
    display_name: 'Geschirrspüler',
    duration_minutes: 150,
    energy_kwh: 1.2,
    earliest_start_local: '06:00',
    latest_finish_local: '23:00',
    notification_lead_minutes: 15,
    must_be_home: false,
    active: true,
  },
  {
    id: 'app-3',
    type: 'ev_charger',
    display_name: 'E-Auto',
    duration_minutes: 240,
    energy_kwh: 11,
    earliest_start_local: '18:00',
    latest_finish_local: '23:59',
    notification_lead_minutes: 30,
    must_be_home: false,
    active: true,
  },
];

export function getMockTariffSchedule(dateStr: string): TariffSchedule {
  const now = typeof window !== 'undefined' ? new Date().toISOString() : '2027-01-15T12:00:00Z';
  return {
    product_id: 'demo-flex',
    display_name: 'Alpenstrom Flex (Demo)',
    date_local: dateStr,
    timezone: 'Europe/Zurich',
    data_state: 'DEMO',
    published_at: now,
    fetched_at: now,
    resolution_minutes: 60,
    currency: 'CHF',
    scope: 'FULL',
    all_in_price_available: true,
    intervals: generateHourlyPrices(dateStr),
    disclaimer: 'DEMO DATA — these are synthetic prices, not actual provider quotations.',
  };
}

export function computeDemoRecommendation(
  appliance: Appliance,
  dateStr: string
): Recommendation {
  const schedule = getMockTariffSchedule(dateStr);
  const energySlots = schedule.intervals.filter(s => s.component === 'ENERGY');
  const gridSlots = schedule.intervals.filter(s => s.component === 'GRID_USAGE');

  const totalPrices = energySlots.map((es, i) => ({
    start: es.start,
    end: es.end,
    price: parseFloat(es.price_chf_per_kwh) + (gridSlots[i] ? parseFloat(gridSlots[i].price_chf_per_kwh) : 0),
  }));

  const durationHours = appliance.duration_minutes / 60;
  const slotsNeeded = Math.ceil(durationHours);
  const powerKw = appliance.energy_kwh / durationHours;

  let bestCost = Infinity;
  let bestIdx = 0;

  for (let i = 0; i <= totalPrices.length - slotsNeeded; i++) {
    let cost = 0;
    let remaining = appliance.duration_minutes;

    for (let j = 0; j < slotsNeeded && i + j < totalPrices.length; j++) {
      const slotMinutes = Math.min(60, remaining);
      cost += powerKw * (slotMinutes / 60) * totalPrices[i + j].price;
      remaining -= slotMinutes;
    }

    if (cost < bestCost) {
      bestCost = cost;
      bestIdx = i;
    }
  }

  const worstCost = (() => {
    let worst = 0;
    let worstI = 0;
    for (let i = 0; i <= totalPrices.length - slotsNeeded; i++) {
      let cost = 0;
      let remaining = appliance.duration_minutes;
      for (let j = 0; j < slotsNeeded && i + j < totalPrices.length; j++) {
        const slotMinutes = Math.min(60, remaining);
        cost += powerKw * (slotMinutes / 60) * totalPrices[i + j].price;
        remaining -= slotMinutes;
      }
      if (cost > worst) {
        worst = cost;
        worstI = i;
      }
    }
    return worst;
  })();

  const savings = worstCost - bestCost;
  const bestSlot = totalPrices[bestIdx];
  const endIdx = Math.min(bestIdx + slotsNeeded, totalPrices.length - 1);
  const endSlot = totalPrices[endIdx];

  return {
    appliance_id: appliance.id,
    run_date: dateStr,
    best_start: bestSlot.start,
    best_end: endSlot.end,
    modeled_cost_chf: bestCost.toFixed(2),
    baseline_cost_chf: worstCost.toFixed(2),
    potential_savings_chf: savings.toFixed(2),
    confidence: 'modeled',
    priced_components: 'ENERGY+GRID_USAGE',
    alternatives: [],
    caveats: ['DEMO — modeled costs based on synthetic prices and flat consumption profile.'],
  };
}

export const mockLocations: LocationResult[] = [
  { id: '351', name: 'Bern', postcode: '3007', canton: 'BE', operator: 'BKW', operator_id: 'bkw' },
  { id: '261', name: 'Zürich', postcode: '8001', canton: 'ZH', operator: 'EKZ', operator_id: 'ekz' },
  { id: '2196', name: 'Luzern', postcode: '6003', canton: 'LU', operator: 'CKW', operator_id: 'ckw' },
  { id: '2311', name: 'Fribourg', postcode: '1700', canton: 'FR', operator: 'Groupe E', operator_id: 'groupe-e' },
  { id: '2762', name: 'Basel', postcode: '4001', canton: 'BS', operator: 'Primeo', operator_id: 'primeo' },
];

export const mockLocalComparison: LocalComparisonResult[] = [
  {
    product_id: 'demo-flex',
    product_name: 'Alpenstrom Flex',
    tariff_type: 'DYNAMIC_ENERGY',
    annual_cost_chf: "1'148",
    is_current: true,
    requires_ems: false,
    requires_smart_meter: true,
    eligibility_text: 'Stündlich variabler Energietarif',
    assumptions: "Annahme: 4'500 kWh/Jahr",
  },
  {
    product_id: 'demo-klassik',
    product_name: 'Alpenstrom Klassik',
    tariff_type: 'HT_NT',
    annual_cost_chf: "1'214",
    is_current: false,
    requires_ems: false,
    requires_smart_meter: false,
    eligibility_text: 'Einfacher Hoch-/Niedertarif',
    assumptions: "Annahme: 4'500 kWh/Jahr",
  },
];

export const mockSwissComparison: SwissComparisonEntry[] = [
  { name: 'Bern', operator: 'BKW', total_rp_kwh: '27.05', energy_rp_kwh: '13.85', grid_rp_kwh: '9.10', levies_rp_kwh: '4.10' },
  { name: 'Zürich', operator: 'EKZ', total_rp_kwh: '29.40', energy_rp_kwh: '15.20', grid_rp_kwh: '10.30', levies_rp_kwh: '3.90' },
  { name: 'Luzern', operator: 'CKW', total_rp_kwh: '25.50', energy_rp_kwh: '12.50', grid_rp_kwh: '8.80', levies_rp_kwh: '4.20' },
  { name: 'Fribourg', operator: 'Groupe E', total_rp_kwh: '25.20', energy_rp_kwh: '11.90', grid_rp_kwh: '9.50', levies_rp_kwh: '3.80' },
  { name: 'Basel', operator: 'Primeo', total_rp_kwh: '27.00', energy_rp_kwh: '14.60', grid_rp_kwh: '7.90', levies_rp_kwh: '4.50' },
  { name: 'St. Gallen', operator: 'SAK', total_rp_kwh: '26.30', energy_rp_kwh: '13.10', grid_rp_kwh: '9.40', levies_rp_kwh: '3.80' },
  { name: 'Winterthur', operator: 'Stadtwerk', total_rp_kwh: '24.80', energy_rp_kwh: '12.00', grid_rp_kwh: '8.70', levies_rp_kwh: '4.10' },
  { name: 'Genève', operator: 'SIG', total_rp_kwh: '28.90', energy_rp_kwh: '14.50', grid_rp_kwh: '10.10', levies_rp_kwh: '4.30' },
];

export const mockNotificationPreferences: NotificationPreferences = {
  daily_digest: true,
  daily_digest_local_time: '19:00',
  reminder_lead_minutes: 15,
  quiet_hours_start: '22:00',
  quiet_hours_end: '07:00',
  enabled: true,
  push_registered: true,
};
