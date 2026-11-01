import { create } from 'zustand';
import type { Locale } from '@/i18n/translations';
import type { Appliance, Household, NotificationPreferences } from '@/types/energy';
import type { ProviderId } from '@/lib/api';

interface AppState {
  locale: Locale;
  setLocale: (locale: Locale) => void;

  selectedDate: 'today' | 'tomorrow';
  setSelectedDate: (d: 'today' | 'tomorrow') => void;

  chartSeries: { total: boolean; energy: boolean; network: boolean };
  toggleSeries: (key: 'total' | 'energy' | 'network') => void;

  selectedProvider: ProviderId;
  setSelectedProvider: (p: ProviderId) => void;

  household: Household | null;
  setHousehold: (h: Household) => void;

  appliances: Appliance[];
  setAppliances: (a: Appliance[]) => void;
  addAppliance: (a: Appliance) => void;
  updateAppliance: (id: string, updates: Partial<Appliance>) => void;
  removeAppliance: (id: string) => void;

  notificationPrefs: NotificationPreferences;
  setNotificationPrefs: (p: Partial<NotificationPreferences>) => void;

  onboardingComplete: boolean;
  setOnboardingComplete: (v: boolean) => void;

  activeSection: string;
  setActiveSection: (s: string) => void;
}

const defaultAppliances: Appliance[] = [
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

const defaultNotificationPrefs: NotificationPreferences = {
  daily_digest: true,
  daily_digest_local_time: '19:00',
  reminder_lead_minutes: 15,
  quiet_hours_start: '22:00',
  quiet_hours_end: '07:00',
  enabled: true,
  push_registered: true,
};

const useAppStore = create<AppState>((set) => ({
  locale: 'de',
  setLocale: (locale) => set({ locale }),

  selectedDate: 'tomorrow',
  setSelectedDate: (selectedDate) => set({ selectedDate }),

  chartSeries: { total: true, energy: true, network: true },
  toggleSeries: (key) =>
    set((state) => ({
      chartSeries: { ...state.chartSeries, [key]: !state.chartSeries[key] },
    })),

  selectedProvider: 'ckw',
  setSelectedProvider: (selectedProvider) => set({ selectedProvider }),

  household: {
    id: 'household-1',
    label: 'Mein Zuhause',
    postal_code: '6003',
    municipality_id: '2196',
    municipality_name: 'Luzern',
    distribution_operator_name: 'CKW',
    provider_id: 'ckw',
    tariff_product_id: 'dynamic-flex',
    enrollment_status: 'user_claimed',
    annual_kwh_estimate: 4500,
  },
  setHousehold: (household) => set({ household }),

  appliances: defaultAppliances,
  setAppliances: (appliances) => set({ appliances }),
  addAppliance: (a) => set((state) => ({ appliances: [...state.appliances, a] })),
  updateAppliance: (id, updates) =>
    set((state) => ({
      appliances: state.appliances.map((a) => (a.id === id ? { ...a, ...updates } : a)),
    })),
  removeAppliance: (id) =>
    set((state) => ({
      appliances: state.appliances.filter((a) => a.id !== id),
    })),

  notificationPrefs: defaultNotificationPrefs,
  setNotificationPrefs: (p) =>
    set((state) => ({ notificationPrefs: { ...state.notificationPrefs, ...p } })),

  onboardingComplete: true,
  setOnboardingComplete: (onboardingComplete) => set({ onboardingComplete }),

  activeSection: 'overview',
  setActiveSection: (activeSection) => set({ activeSection }),
}));

export default useAppStore;
