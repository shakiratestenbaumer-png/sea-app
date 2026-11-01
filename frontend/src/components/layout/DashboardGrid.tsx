'use client';

import { useState, useCallback, useEffect, type ReactNode } from 'react';
import { Responsive, WidthProvider, type Layout, type Layouts } from 'react-grid-layout';
import { GripVertical } from 'lucide-react';
import 'react-grid-layout/css/styles.css';

const ResponsiveGridLayout = WidthProvider(Responsive);

const STORAGE_KEY = 'sea-dashboard-layouts';

const DEFAULT_LAYOUTS: Layouts = {
  lg: [
    { i: 'hero', x: 0, y: 0, w: 12, h: 4, minW: 6, minH: 3, isResizable: true },
    { i: 'chart', x: 0, y: 4, w: 8, h: 10, minW: 6, minH: 6 },
    { i: 'breakdown', x: 8, y: 4, w: 4, h: 5, minW: 3, minH: 4 },
    { i: 'comparison', x: 8, y: 9, w: 4, h: 5, minW: 3, minH: 4 },
    { i: 'download', x: 0, y: 14, w: 12, h: 4, minW: 6, minH: 3 },
  ],
  md: [
    { i: 'hero', x: 0, y: 0, w: 12, h: 4 },
    { i: 'chart', x: 0, y: 4, w: 12, h: 10 },
    { i: 'breakdown', x: 0, y: 14, w: 6, h: 5 },
    { i: 'comparison', x: 6, y: 14, w: 6, h: 5 },
    { i: 'download', x: 0, y: 19, w: 12, h: 4 },
  ],
  sm: [
    { i: 'hero', x: 0, y: 0, w: 12, h: 5 },
    { i: 'chart', x: 0, y: 5, w: 12, h: 10 },
    { i: 'breakdown', x: 0, y: 15, w: 12, h: 5 },
    { i: 'comparison', x: 0, y: 20, w: 12, h: 5 },
    { i: 'download', x: 0, y: 25, w: 12, h: 4 },
  ],
};

function mergeWithDefaults(saved: Layouts | null): Layouts {
  if (!saved) return DEFAULT_LAYOUTS;
  const breakpoints = ['lg', 'md', 'sm'] as const;
  const merged = { ...DEFAULT_LAYOUTS };
  for (const bp of breakpoints) {
    const defaultItems = DEFAULT_LAYOUTS[bp] ?? [];
    const savedItems = saved[bp];
    if (!savedItems?.length) continue;
    merged[bp] = defaultItems.map((def) => {
      const match = savedItems.find((s) => s.i === def.i);
      return match ? { ...def, ...match } : def;
    });
  }
  return merged;
}

function GridItemShell({ children }: { children: ReactNode }) {
  return (
    <div className="dashboard-grid-item">
      <div
        className="card-drag-handle flex shrink-0 items-center px-2 py-1.5 text-gray-300 hover:text-gray-400"
        aria-label="Drag to rearrange"
      >
        <GripVertical className="h-4 w-4" strokeWidth={2} />
      </div>
      <div className="grid-item-body px-3 pb-3 pt-0">{children}</div>
    </div>
  );
}

export type DashboardGridSections = {
  hero: ReactNode;
  chart: ReactNode;
  breakdown: ReactNode;
  comparison: ReactNode;
  download: ReactNode;
};

export default function DashboardGrid({ sections }: { sections: DashboardGridSections }) {
  const [layouts, setLayouts] = useState<Layouts>(DEFAULT_LAYOUTS);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        setLayouts(mergeWithDefaults(JSON.parse(raw) as Layouts));
      }
    } catch {
      /* ignore corrupt storage */
    }
    setReady(true);
  }, []);

  const onLayoutChange = useCallback((_current: Layout[], allLayouts: Layouts) => {
    setLayouts(allLayouts);
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(allLayouts));
    } catch {
      /* quota exceeded */
    }
  }, []);

  if (!ready) {
    return <div className="min-h-[400px]" aria-hidden />;
  }

  return (
    <ResponsiveGridLayout
      className="layout"
      layouts={layouts}
      breakpoints={{ lg: 1200, md: 996, sm: 768, xs: 480, xxs: 0 }}
      cols={{ lg: 12, md: 12, sm: 12, xs: 12, xxs: 12 }}
      rowHeight={32}
      margin={[12, 12]}
      containerPadding={[0, 0]}
      draggableHandle=".card-drag-handle"
      onLayoutChange={onLayoutChange}
      compactType="vertical"
    >
      <div key="hero">
        <GridItemShell>{sections.hero}</GridItemShell>
      </div>
      <div key="chart">
        <GridItemShell>{sections.chart}</GridItemShell>
      </div>
      <div key="breakdown">
        <GridItemShell>{sections.breakdown}</GridItemShell>
      </div>
      <div key="comparison">
        <GridItemShell>{sections.comparison}</GridItemShell>
      </div>
      <div key="download">
        <GridItemShell>{sections.download}</GridItemShell>
      </div>
    </ResponsiveGridLayout>
  );
}
