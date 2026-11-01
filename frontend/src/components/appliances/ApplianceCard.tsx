'use client';

import { Bell, Settings, Droplets, UtensilsCrossed, Car, Flame, HelpCircle, Wind } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import useAppStore from '@/hooks/useAppStore';
import { useProviderData } from '@/hooks/useProviderData';
import { t } from '@/i18n/translations';
import type { Appliance, } from '@/types/energy';
import type { ProviderData } from '@/lib/api';

const APPLIANCE_ICONS: Record<string, React.ElementType> = {
  dishwasher: UtensilsCrossed,
  washing_machine: Droplets,
  tumble_dryer: Wind,
  ev_charger: Car,
  water_heater: Flame,
  other: HelpCircle,
};

function findBestWindow(prov: ProviderData, durationMin: number, energyKwh: number) {
  const slotsNeeded = Math.ceil(durationMin / 15);
  const prices = prov.prices.map((p) => p.integrated);
  const powerKw = energyKwh / (durationMin / 60);
  if (prices.length < slotsNeeded) return null;

  let bestCost = Infinity, bestIdx = 0;
  for (let i = 0; i <= prices.length - slotsNeeded; i++) {
    let cost = 0;
    for (let j = 0; j < slotsNeeded; j++) cost += prices[i + j] * 0.25 * powerKw;
    if (cost < bestCost) { bestCost = cost; bestIdx = i; }
  }

  let worstCost = 0;
  for (let i = 0; i <= prices.length - slotsNeeded; i++) {
    let cost = 0;
    for (let j = 0; j < slotsNeeded; j++) cost += prices[i + j] * 0.25 * powerKw;
    if (cost > worstCost) worstCost = cost;
  }

  const fmt = (ts: string) => new Date(ts).toLocaleTimeString('de-CH', {
    hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'Europe/Zurich',
  });
  const endIdx = Math.min(bestIdx + slotsNeeded, prov.prices.length - 1);

  return {
    startTime: fmt(prov.prices[bestIdx].start),
    endTime: fmt(prov.prices[endIdx].end),
    cost: bestCost.toFixed(2),
    savings: (worstCost - bestCost).toFixed(2),
  };
}

interface Props { appliance: Appliance; }

export default function ApplianceCard({ appliance }: Props) {
  const locale = useAppStore((s) => s.locale);
  const Icon = APPLIANCE_ICONS[appliance.type] ?? HelpCircle;
  const { providers } = useProviderData();
  const ckw = providers.find((p) => p.id === 'ckw' && p.status === 'ok');

  const win = ckw ? findBestWindow(ckw, appliance.duration_minutes, appliance.energy_kwh) : null;
  const savings = parseFloat(win?.savings ?? '0');

  return (
    <Card className="border-gray-200 hover:border-teal-300 transition-colors shadow-sm">
      <CardContent className="p-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-teal-50 flex items-center justify-center">
              <Icon className="w-5 h-5 text-teal-600" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-900 text-sm">{appliance.display_name}</h3>
              <p className="text-xs text-gray-400">{appliance.duration_minutes} Min. · {appliance.energy_kwh} kWh</p>
            </div>
          </div>
          <button className="text-gray-300 hover:text-gray-500 transition-colors p-1">
            <Settings className="w-4 h-4" />
          </button>
        </div>

        <div className="bg-teal-50 rounded-lg p-3 mb-3">
          <p className="text-xs font-bold text-teal-600 tracking-wider mb-0.5">
            {t(locale, 'best_start')} · {t(locale, 'tomorrow_label')}
          </p>
          <p className="text-2xl font-bold text-gray-900">{win?.startTime ?? '—'} <span className="text-sm text-gray-500">Uhr</span></p>
          <p className="text-xs text-gray-500">{t(locale, 'finished_by')} {win?.endTime ?? '—'}</p>
        </div>

        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-gray-400">{t(locale, 'estimated_cost')}</p>
            <p className="text-lg font-bold text-gray-900">CHF {win?.cost ?? '—'}</p>
          </div>
          {savings > 0.005 && (
            <div className="flex items-center gap-1 bg-teal-50 text-teal-700 px-2.5 py-1 rounded-full">
              <span className="text-xs font-semibold">↓ CHF {savings.toFixed(2)} {t(locale, 'less')}</span>
            </div>
          )}
        </div>

        <Button variant="outline" className="w-full mt-3 text-sm" size="sm">
          <Bell className="w-4 h-4 mr-2" />
          {t(locale, 'set_reminder')}
        </Button>
      </CardContent>
    </Card>
  );
}
