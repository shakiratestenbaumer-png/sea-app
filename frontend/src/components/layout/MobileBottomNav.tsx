'use client';

import { BarChart3, Bell, GitCompare, LayoutDashboard } from 'lucide-react';
import useAppStore from '@/hooks/useAppStore';
import { t } from '@/i18n/translations';

const NAV_ITEMS = [
  { id: 'overview', icon: LayoutDashboard, labelKey: 'nav_overview' as const },
  { id: 'appliances', icon: BarChart3, labelKey: 'nav_appliances' as const },
  { id: 'compare', icon: GitCompare, labelKey: 'nav_compare' as const },
  { id: 'alerts', icon: Bell, labelKey: 'nav_alerts' as const },
];

export default function MobileBottomNav() {
  const { locale, activeSection, setActiveSection } = useAppStore();

  const scrollTo = (id: string) => {
    setActiveSection(id);
    const el = document.getElementById(`section-${id}`);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 md:hidden shadow-lg">
      <div className="flex justify-around py-2">
        {NAV_ITEMS.map((item) => {
          const Icon = item.icon;
          const isActive = activeSection === item.id;
          return (
            <button
              key={item.id}
              onClick={() => scrollTo(item.id)}
              className={`flex flex-col items-center gap-0.5 px-3 py-1 rounded-lg transition-colors min-w-[64px] ${
                isActive ? 'text-teal-600' : 'text-gray-400'
              }`}
            >
              <Icon className="w-5 h-5" />
              <span className="text-xs font-medium">{t(locale, item.labelKey)}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
