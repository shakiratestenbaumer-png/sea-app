'use client';

import { Bell, Clock, TrendingDown, Zap } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import useAppStore from '@/hooks/useAppStore';
import { useProviderData } from '@/hooks/useProviderData';
import { t } from '@/i18n/translations';
import type { ProviderData } from '@/lib/api';

function findCheapestWindow(prov: ProviderData, durationSlots: number) {
  const prices = prov.prices;
  if (prices.length < durationSlots) return null;

  let bestCost = Infinity, bestIdx = 0;
  for (let i = 0; i <= prices.length - durationSlots; i++) {
    let cost = 0;
    for (let j = 0; j < durationSlots; j++) cost += prices[i + j].integrated;
    if (cost < bestCost) { bestCost = cost; bestIdx = i; }
  }

  let worstCost = 0;
  for (let i = 0; i <= prices.length - durationSlots; i++) {
    let cost = 0;
    for (let j = 0; j < durationSlots; j++) cost += prices[i + j].integrated;
    if (cost > worstCost) worstCost = cost;
  }

  const fmt = (ts: string) => new Date(ts).toLocaleTimeString('de-CH', {
    hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'Europe/Zurich',
  });

  return {
    startTime: fmt(prices[bestIdx].start),
    endTime: fmt(prices[bestIdx + durationSlots - 1].end),
    avgSlotPrice: bestCost / durationSlots,
    savings: worstCost - bestCost,
  };
}

export default function BestTimeHero() {
  const { locale, selectedDate, setSelectedDate, appliances } = useAppStore();
  const { providers } = useProviderData();
  const ckw = providers.find((p) => p.id === 'ckw' && p.status === 'ok');

  const app = appliances[0];
  const slots = Math.ceil((app?.duration_minutes ?? 120) / 15);
  const win = ckw ? findCheapestWindow(ckw, slots) : null;
  const powerKw = (app?.energy_kwh ?? 1) / ((app?.duration_minutes ?? 120) / 60);
  const estCost = win ? (win.avgSlotPrice * slots * 0.25 * powerKw).toFixed(2) : '—';
  const savCHF = win ? (win.savings * 0.25 * powerKw).toFixed(2) : '0.00';

  return (
    <Card className="bg-gradient-to-br from-teal-600 to-teal-700 text-white border-0 shadow-lg">
      <CardContent className="p-5">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <p className="text-teal-200 text-xs font-semibold uppercase tracking-wider">
              {t(locale, 'hero_title')}
            </p>
            <span className="inline-flex items-center gap-1.5 text-xs font-medium text-teal-100 bg-teal-800/40 rounded-full px-2.5 py-0.5">
              <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse shrink-0" />
              {t(locale, 'prices_available')}
            </span>
          </div>
          <div className="flex bg-teal-800/50 rounded-lg p-0.5">
            <button
              onClick={() => setSelectedDate('today')}
              className={`px-3 py-1 text-xs rounded-md transition-colors ${
                selectedDate === 'today' ? 'bg-white text-teal-700 font-semibold' : 'text-teal-200 hover:text-white'
              }`}
            >
              {t(locale, 'hero_today')}
            </button>
            <button
              onClick={() => setSelectedDate('tomorrow')}
              className={`px-3 py-1 text-xs rounded-md transition-colors ${
                selectedDate === 'tomorrow' ? 'bg-white text-teal-700 font-semibold' : 'text-teal-200 hover:text-white'
              }`}
            >
              {t(locale, 'hero_tomorrow')}
            </button>
          </div>
        </div>

        <div className="flex items-end justify-between">
          <div>
            <div className="flex items-baseline gap-2 mb-1">
              <span className="text-4xl font-bold tracking-tight">{win?.startTime ?? '—'}</span>
              <span className="text-base text-teal-200">Uhr</span>
            </div>
            <p className="text-sm text-teal-100">
              <Clock className="w-3.5 h-3.5 inline mr-1" />
              {app?.display_name ?? 'Waschmaschine'} · {t(locale, 'finished_by')} {win?.endTime ?? '—'} · CHF {estCost}
            </p>
            {parseFloat(savCHF) > 0.005 && (
              <p className="text-sm text-green-300 mt-1 flex items-center gap-1">
                <TrendingDown className="w-3.5 h-3.5" />
                CHF {savCHF} {t(locale, 'less')}
              </p>
            )}
          </div>
          <Button variant="secondary" size="sm" className="bg-white/20 text-white hover:bg-white/30 border-0">
            <Bell className="w-4 h-4 mr-1.5" />
            {t(locale, 'remind_me')}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
