'use client';

import Image from 'next/image';
import { MapPin, Settings } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import useAppStore from '@/hooks/useAppStore';
import { t, type Locale } from '@/i18n/translations';

const LOCALE_LABELS: Record<Locale, string> = { de: 'DE', en: 'EN', fr: 'FR' };

export default function AppHeader() {
  const { locale, setLocale, household, setActiveSection } = useAppStore();

  const cycleLocale = () => {
    const locales: Locale[] = ['de', 'en', 'fr'];
    const idx = locales.indexOf(locale);
    setLocale(locales[(idx + 1) % locales.length]);
  };

  const status = household?.enrollment_status ?? 'unknown';
  const statusKey = status === 'confirmed' ? 'tariff_confirmed' : status === 'user_claimed' ? 'tariff_self_reported' : 'tariff_unknown';

  return (
    <header className="sticky top-0 z-50 bg-white border-b border-gray-200 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 py-2.5 flex items-center justify-between">
        {/* Logo */}
        <div className="flex items-center gap-2">
          <Image src="/icons/icon-192x192.png" alt="SEA" width={36} height={36} className="rounded-lg" />
          <div className="hidden sm:block">
            <div className="text-sm font-bold text-teal-700 leading-tight">Swiss Energy</div>
            <div className="text-xs font-semibold text-teal-500 tracking-widest uppercase leading-tight">
              Assistant
            </div>
          </div>
        </div>

        {/* Location + Provider */}
        <div className="flex items-center gap-3">
          <MapPin className="w-4 h-4 text-teal-600" />
          <div className="text-right">
            <div className="text-sm font-semibold text-gray-900">
              {household?.municipality_name ?? 'Luzern'} · {household?.postal_code ?? '6003'}
            </div>
            <div className="text-xs text-gray-500">
              {household?.distribution_operator_name ?? 'CKW'} · Dynamic Flex
            </div>
          </div>
          <Badge
            variant="outline"
            className="text-xs h-5 px-2 bg-amber-50 text-amber-700 border-amber-200"
          >
            {t(locale, statusKey)}
          </Badge>
        </div>

        {/* Language + Settings */}
        <div className="flex items-center gap-1">
          <Button variant="ghost" size="sm" onClick={cycleLocale} className="text-xs font-medium gap-1">
            <span className="text-teal-600">🌐</span>
            {LOCALE_LABELS[locale]}
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="w-8 h-8"
            onClick={() => setActiveSection('settings')}
          >
            <Settings className="w-4 h-4 text-gray-500" />
          </Button>
        </div>
      </div>
    </header>
  );
}
