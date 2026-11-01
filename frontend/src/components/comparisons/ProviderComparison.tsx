'use client';

import { useMemo } from 'react';
import dynamic from 'next/dynamic';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import useAppStore from '@/hooks/useAppStore';
import { useProviderData } from '@/hooks/useProviderData';
import { t } from '@/i18n/translations';
import type { ProviderData } from '@/lib/api';

const Plot = dynamic(() => import('react-plotly.js'), { ssr: false });

export default function ProviderComparison() {
  const { locale } = useAppStore();
  const { providers, loading } = useProviderData();

  const mult = 100;
  const unitLabel = 'Rp./kWh';

  const activeProviders = providers.filter((p) => p.status === 'ok' && p.prices.length > 0);
  const sorted = useMemo(() => {
    return [...activeProviders].sort((a, b) => {
      const avgA = a.prices.reduce((s, p) => s + p.integrated, 0) / a.prices.length;
      const avgB = b.prices.reduce((s, p) => s + p.integrated, 0) / b.prices.length;
      return avgA - avgB;
    });
  }, [activeProviders]);

  const boxTraces: Plotly.Data[] = useMemo(() => {
    return sorted.map((prov) => ({
      y: prov.prices.map((p) => p.integrated * mult),
      type: 'box' as const,
      name: prov.name,
      marker: { color: prov.color },
      boxmean: 'sd' as const,
      hovertemplate: '<b>' + prov.name + '</b><br>%{y:.1f} ' + unitLabel + '<extra></extra>',
    }));
  }, [sorted, mult, unitLabel]);

  const boxLayout: Partial<Plotly.Layout> = useMemo(() => ({
    autosize: true,
    height: 260,
    margin: { l: 50, r: 15, t: 40, b: 35 },
    yaxis: {
      title: { text: unitLabel, font: { size: 11, color: '#9ca3af' }, standoff: 5 },
      tickfont: { size: 11, color: '#6b7280' },
      gridcolor: '#f3f4f6',
    },
    xaxis: { tickfont: { size: 12, color: '#374151' } },
    showlegend: true,
    legend: {
      orientation: 'h' as const,
      x: 0.5,
      xanchor: 'center' as const,
      y: 1.18,
      font: { size: 11 },
    },
    paper_bgcolor: 'transparent',
    plot_bgcolor: 'transparent',
  }), [unitLabel]);

  if (loading) {
    return (
      <Card className="border-gray-200 shadow-sm">
        <CardContent className="p-6">
          <div className="h-[260px] bg-gray-50 rounded animate-pulse flex items-center justify-center text-sm text-gray-400">
            {t(locale, 'prices_awaiting')}…
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="border-gray-200 shadow-sm">
      <CardHeader className="pb-2 pt-4 px-5">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold text-gray-900">{t(locale, 'comparison_title')}</h2>
            <p className="text-sm text-gray-500">{t(locale, 'comparison_subtitle')}</p>
          </div>
          <Badge variant="outline" className="text-xs h-5 px-2 font-medium text-green-600 border-green-200 bg-green-50">
            LIVE
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="px-3 pb-4">
        {sorted.length > 0 ? (
          <div className="w-full" style={{ height: 260 }}>
            <Plot
              data={boxTraces}
              layout={boxLayout}
              config={{ displayModeBar: false, responsive: true }}
              style={{ width: '100%', height: '100%' }}
              useResizeHandler
            />
          </div>
        ) : (
          <div className="h-[260px] bg-gray-50 rounded flex items-center justify-center text-sm text-gray-400">
            No provider data available
          </div>
        )}

        <div className="mt-3 space-y-2 px-2">
          {sorted.map((s, i) => {
            const avgRp = (s.prices.reduce((sum, p) => sum + p.integrated, 0) / s.prices.length) * mult;
            const minRp = Math.min(...s.prices.map((p) => p.integrated * mult));
            const maxRp = Math.max(...s.prices.map((p) => p.integrated * mult));
            return (
              <div key={s.id} className="flex items-center gap-3">
                <div className="w-3 h-3 rounded-full flex-shrink-0" style={{ backgroundColor: s.color }} />
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-semibold text-gray-900">
                      {s.name} · {s.territory}
                      {i === 0 && <span className="ml-2 text-green-600 text-xs">★</span>}
                    </span>
                    <span className="text-sm font-bold" style={{ color: s.color }}>
                      Ø {avgRp.toFixed(1)} {unitLabel}
                    </span>
                  </div>
                  <div className="text-xs text-gray-400">
                    Min {minRp.toFixed(1)} · Max {maxRp.toFixed(1)} · {s.interval_count} {t(locale, 'intervals')}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        <p className="text-xs text-gray-400 mt-3 px-2">{t(locale, 'swiss_disclaimer')}</p>
      </CardContent>
    </Card>
  );
}
