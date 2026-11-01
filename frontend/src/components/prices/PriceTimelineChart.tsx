'use client';

import { useMemo, useState } from 'react';
import dynamic from 'next/dynamic';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import useAppStore from '@/hooks/useAppStore';
import { useProviderData } from '@/hooks/useProviderData';
import { t } from '@/i18n/translations';
import type { ProviderId } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';

const Plot = dynamic(() => import('react-plotly.js'), { ssr: false });

type ViewMode = 'single' | 'compare';

export default function PriceTimelineChart() {
  const { locale } = useAppStore();
  const { providers, loading } = useProviderData();
  const [selectedProvider, setSelectedProvider] = useState<ProviderId>('ckw');
  const [viewMode, setViewMode] = useState<ViewMode>('compare');
  const [showGrid, setShowGrid] = useState(false);

  const mult = 100;
  const unitLabel = 'Rp./kWh';

  const activeProviders = providers.filter((p) => p.status === 'ok' && p.prices.length > 0);
  const current = activeProviders.find((p) => p.id === selectedProvider) ?? activeProviders[0];

  const labels = useMemo(() => {
    if (!current) return [];
    return current.prices.map((p) =>
      new Date(p.start).toLocaleTimeString('de-CH', {
        hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'Europe/Zurich',
      })
    );
  }, [current]);

  const stats = useMemo(() => {
    if (!current) return { min: 0, max: 0, avg: 0, minTime: '--:--' };
    const vals = current.prices.map((p) => p.integrated * mult);
    const minVal = Math.min(...vals);
    const idx = vals.indexOf(minVal);
    return {
      min: minVal,
      max: Math.max(...vals),
      avg: vals.reduce((s, v) => s + v, 0) / vals.length,
      minTime: labels[idx] ?? '--:--',
    };
  }, [current, mult, labels]);

  // Build Plotly traces
  const traces: Plotly.Data[] = useMemo(() => {
    if (viewMode === 'compare') {
      return activeProviders.map((prov) => {
        const pLabels = prov.prices.map((p) =>
          new Date(p.start).toLocaleTimeString('de-CH', {
            hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'Europe/Zurich',
          })
        );
        return {
          x: pLabels,
          y: prov.prices.map((p) => p.integrated * mult),
          type: 'scatter' as const,
          mode: 'lines' as const,
          line: { shape: 'spline' as const, smoothing: 0.6, color: prov.color, width: 2 },
          name: prov.name,
          hovertemplate: '%{x}<br><b>%{y:.2f}</b> ' + unitLabel + '<extra>' + prov.name + '</extra>',
        };
      });
    }

    if (!current) return [];
    const tr: Plotly.Data[] = [{
      x: labels,
      y: current.prices.map((p) => p.integrated * mult),
      type: 'scatter' as const,
      mode: 'lines' as const,
      line: { shape: 'spline' as const, smoothing: 0.6, color: current.color, width: 2.5 },
      name: t(locale, 'total'),
      fill: 'tozeroy' as const,
      fillcolor: `${current.color}18`,
      hovertemplate: '%{x}<br><b>%{y:.2f}</b> ' + unitLabel + '<extra>' + t(locale, 'total') + '</extra>',
    }];
    if (showGrid) {
      tr.push({
        x: labels,
        y: current.prices.map((p) => p.grid * mult),
        type: 'scatter' as const,
        mode: 'lines' as const,
        line: { shape: 'spline' as const, smoothing: 0.6, color: '#60a5fa', width: 1.5, dash: 'dot' as const },
        name: t(locale, 'network'),
        hovertemplate: '%{x}<br><b>%{y:.2f}</b> ' + unitLabel + '<extra>' + t(locale, 'network') + '</extra>',
      });
    }
    return tr;
  }, [viewMode, activeProviders, current, labels, mult, unitLabel, showGrid, locale]);

  const layout: Partial<Plotly.Layout> = useMemo(() => ({
    autosize: true,
    height: 320,
    margin: { l: 50, r: 15, t: 40, b: 35 },
    xaxis: {
      showgrid: false,
      tickfont: { size: 11, color: '#6b7280' },
      dtick: 8,
      fixedrange: true,
    },
    yaxis: {
      showgrid: true,
      gridcolor: '#f3f4f6',
      tickfont: { size: 11, color: '#6b7280' },
      fixedrange: true,
      title: { text: unitLabel, font: { size: 11, color: '#9ca3af' }, standoff: 8 },
    },
    showlegend: viewMode === 'compare',
    legend: {
      orientation: 'h' as const,
      x: 0.5,
      xanchor: 'center' as const,
      y: 1.18,
      font: { size: 11 },
    },
    hovermode: 'x unified' as const,
    hoverlabel: { bgcolor: 'white', bordercolor: '#d1d5db', font: { size: 13, family: 'Inter' } },
    paper_bgcolor: 'transparent',
    plot_bgcolor: 'transparent',
  }), [unitLabel, viewMode]);

  const pubDate = current?.publication
    ? new Date(current.publication).toLocaleString('de-CH', { timeZone: 'Europe/Zurich' })
    : '';

  return (
    <Card className="border-gray-200 shadow-sm">
      <CardHeader className="pb-3 pt-4 px-5">
        <div className="flex items-center justify-between flex-wrap gap-2">
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-lg font-bold text-gray-900">{t(locale, 'chart_title')}</h2>
              <Badge variant="outline" className="text-xs h-5 px-2 font-medium text-green-600 border-green-200 bg-green-50">
                LIVE · 15min
              </Badge>
            </div>
            <p className="text-sm text-gray-500 mt-0.5">{t(locale, 'chart_subtitle')}</p>
          </div>
          <div className="flex items-center gap-2">
            <Tabs value={viewMode} onValueChange={(v) => setViewMode(v as ViewMode)}>
              <TabsList className="h-8">
                <TabsTrigger value="single" className="text-xs px-3">{t(locale, 'energy')}</TabsTrigger>
                <TabsTrigger value="compare" className="text-xs px-3">{t(locale, 'comparison_title')}</TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
        </div>

        {viewMode === 'single' && (
          <>
            <div className="flex items-center gap-2 mt-3">
              {activeProviders.map((prov) => (
                <button
                  key={prov.id}
                  onClick={() => setSelectedProvider(prov.id)}
                  className={`px-3 py-1 rounded-lg text-xs font-medium transition-all ${
                    selectedProvider === prov.id ? 'text-white shadow-sm' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                  style={selectedProvider === prov.id ? { backgroundColor: prov.color } : undefined}
                >
                  {prov.name} · {prov.territory}
                </button>
              ))}
              <button
                onClick={() => setShowGrid(!showGrid)}
                className={`px-3 py-1 rounded-lg text-xs font-medium ml-auto transition ${
                  showGrid ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-400'
                }`}
              >
                {t(locale, 'network')}
              </button>
            </div>
            <div className="flex items-center gap-6 mt-3">
              <div>
                <p className="text-xs text-gray-500">{t(locale, 'lowest_price')}</p>
                <p className="text-xl font-bold text-gray-900">
                  {stats.min.toFixed(1)} <span className="text-sm font-normal text-gray-500">{unitLabel}</span>
                </p>
                <p className="text-xs text-gray-400">@ {stats.minTime}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">{t(locale, 'daily_average')}</p>
                <p className="text-xl font-bold text-gray-900">
                  {stats.avg.toFixed(1)} <span className="text-sm font-normal text-gray-500">{unitLabel}</span>
                </p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Maximum</p>
                <p className="text-xl font-bold text-red-600">
                  {stats.max.toFixed(1)} <span className="text-sm font-normal text-gray-500">{unitLabel}</span>
                </p>
              </div>
            </div>
          </>
        )}
      </CardHeader>

      <CardContent className="pt-0 px-3 pb-3">
        {loading ? (
          <div className="h-[320px] bg-gray-50 rounded-lg animate-pulse flex items-center justify-center text-sm text-gray-400">
            {t(locale, 'prices_awaiting')}…
          </div>
        ) : activeProviders.length === 0 ? (
          <div className="h-[320px] bg-red-50 rounded-lg flex items-center justify-center text-sm text-red-500">
            No data available
          </div>
        ) : (
          <div className="w-full" style={{ height: 320 }}>
            <Plot
              data={traces}
              layout={layout}
              config={{ displayModeBar: false, responsive: true }}
              style={{ width: '100%', height: '100%' }}
              useResizeHandler
            />
          </div>
        )}
        <div className="flex items-center justify-between mt-2 text-xs text-gray-400 px-2">
          <span>
            {activeProviders.length} {activeProviders.length === 1 ? 'Anbieter' : 'Anbieter'} · 96 × 15min
          </span>
          <span>{pubDate && `${t(locale, 'last_refresh')} ${pubDate}`}</span>
        </div>
      </CardContent>
    </Card>
  );
}
