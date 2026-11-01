'use client';

import { Info } from 'lucide-react';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import useAppStore from '@/hooks/useAppStore';
import { useProviderData } from '@/hooks/useProviderData';
import { t } from '@/i18n/translations';

export default function TariffBreakdown() {
  const locale = useAppStore((s) => s.locale);
  const { providers } = useProviderData();
  const ckw = providers.find((p) => p.id === 'ckw' && p.status === 'ok');

  if (!ckw || ckw.prices.length === 0) return null;

  const intPrices = ckw.prices.map((p) => p.integrated * 100);
  const gridPrices = ckw.prices.map((p) => p.grid * 100);
  const elecPrices = ckw.prices.map((p) => p.electricity * 100);
  const avgInt = intPrices.reduce((s, v) => s + v, 0) / intPrices.length;
  const avgGrid = gridPrices.reduce((s, v) => s + v, 0) / gridPrices.length;
  const avgElec = elecPrices.reduce((s, v) => s + v, 0) / elecPrices.length;
  const residual = avgInt - avgGrid - avgElec;

  const components = [
    { label: t(locale, 'energy'), value: avgElec > 0 ? avgElec : avgInt - avgGrid, pct: 0, color: 'bg-teal-500' },
    { label: t(locale, 'network_usage'), value: avgGrid, pct: 0, color: 'bg-blue-400' },
  ];
  if (residual > 0.5) {
    components.push({ label: t(locale, 'levies_taxes'), value: residual, pct: 0, color: 'bg-amber-400' });
  }
  const total = components.reduce((s, c) => s + c.value, 0);
  components.forEach((c) => { c.pct = Math.round((c.value / total) * 100); });

  return (
    <Card className="border-gray-200 shadow-sm">
      <CardHeader className="pb-2 pt-4 px-5">
        <h2 className="text-lg font-bold text-gray-900">{t(locale, 'breakdown_title')}</h2>
        <p className="text-sm text-gray-500 mt-0.5">CKW · Ø {t(locale, 'daily_average')}</p>
      </CardHeader>
      <CardContent className="px-5 pb-4">
        <div className="flex rounded-full overflow-hidden h-4 mb-4">
          {components.map((c) => (
            <div key={c.label} className={`${c.color}`} style={{ width: `${c.pct}%` }} />
          ))}
        </div>
        <div className="space-y-2">
          {components.map((c) => (
            <div key={c.label} className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className={`w-3 h-3 rounded-full ${c.color}`} />
                <span className="text-sm text-gray-700">{c.label}</span>
              </div>
              <span className="text-sm font-semibold text-gray-900">
                {c.value.toFixed(1)} Rp./kWh ({c.pct}%)
              </span>
            </div>
          ))}
          <div className="flex items-center justify-between pt-2 border-t border-gray-100">
            <span className="text-sm font-bold text-gray-900">{t(locale, 'total')}</span>
            <span className="text-sm font-bold text-gray-900">Ø {avgInt.toFixed(1)} Rp./kWh</span>
          </div>
        </div>
        <div className="flex items-center gap-2 bg-gray-50 rounded-lg p-3 mt-4">
          <Info className="w-4 h-4 text-gray-400 flex-shrink-0" />
          <p className="text-xs text-gray-500">
            <span className="font-medium">{t(locale, 'fixed_costs_note')}:</span>{' '}
            CHF 96.00 {t(locale, 'per_year_metering')}
          </p>
        </div>
      </CardContent>
    </Card>
  );
}
