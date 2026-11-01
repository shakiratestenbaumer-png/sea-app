'use client';

import Link from 'next/link';
import { Globe, Home, MapPin, Zap, Shield, Trash2, Info } from 'lucide-react';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import useAppStore from '@/hooks/useAppStore';
import { t, type Locale } from '@/i18n/translations';

export default function SettingsDrawer({ open, onOpenChange }: { open: boolean; onOpenChange: (v: boolean) => void }) {
  const { locale, setLocale, household } = useAppStore();

  const LOCALE_OPTIONS: Array<{ id: Locale; label: string; flag: string }> = [
    { id: 'de', label: 'Deutsch', flag: '🇩🇪' },
    { id: 'en', label: 'English', flag: '🇬🇧' },
    { id: 'fr', label: 'Français', flag: '🇫🇷' },
  ];

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-[380px] sm:w-[420px]">
        <SheetHeader>
          <SheetTitle className="text-lg font-bold">{t(locale, 'settings')}</SheetTitle>
        </SheetHeader>

        <div className="mt-6 space-y-6">
          {/* Language */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <Globe className="w-4 h-4 text-teal-600" />
              {t(locale, 'onboarding_language')}
            </h3>
            <div className="flex gap-2">
              {LOCALE_OPTIONS.map((opt) => (
                <button
                  key={opt.id}
                  onClick={() => setLocale(opt.id)}
                  className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg border transition text-sm font-medium ${
                    locale === opt.id
                      ? 'border-teal-300 bg-teal-50 text-teal-700'
                      : 'border-gray-200 hover:border-gray-300 text-gray-600'
                  }`}
                >
                  <span>{opt.flag}</span>
                  <span>{opt.label}</span>
                </button>
              ))}
            </div>
          </div>

          <Separator />

          {/* NullLink ID — coming soon */}
          <div className="rounded-lg border border-dashed border-gray-200 bg-gray-50/80 p-4">
            <div className="flex items-start justify-between gap-2 mb-2">
              <span className="text-sm font-semibold text-gray-800 tracking-tight">{t(locale, 'nlid_brand')}</span>
              <Badge variant="outline" className="text-[10px] uppercase tracking-wide text-gray-500 border-gray-300">
                {t(locale, 'coming_soon')}
              </Badge>
            </div>
            <p className="text-xs text-gray-600 mb-1">{t(locale, 'nlid_tagline')}</p>
            <p className="text-xs text-gray-400">{t(locale, 'nlid_description')}</p>
          </div>

          <Separator />

          {/* Household */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <Home className="w-4 h-4 text-teal-600" />
              Haushalt
            </h3>
            <div className="bg-gray-50 rounded-lg p-4 space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500"><MapPin className="w-3.5 h-3.5 inline mr-1" />Standort</span>
                <span className="font-medium text-gray-900">{household?.municipality_name ?? '—'} · {household?.postal_code ?? '—'}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500"><Zap className="w-3.5 h-3.5 inline mr-1" />Netzbetreiber</span>
                <span className="font-medium text-gray-900">{household?.distribution_operator_name ?? '—'}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Verbrauch</span>
                <span className="font-medium text-gray-900">{household?.annual_kwh_estimate?.toLocaleString() ?? '—'} kWh/Jahr</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Tarif</span>
                <Badge variant="outline" className="text-xs bg-amber-50 text-amber-700 border-amber-200">
                  {t(locale, 'tariff_self_reported')}
                </Badge>
              </div>
            </div>
          </div>

          <Separator />

          {/* About */}
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <Info className="w-4 h-4 text-teal-600" />
              Info
            </h3>
            <div className="space-y-2 text-sm text-gray-500">
              <p>Version 1.0.0 · Swiss Energy Assistant</p>
              <p>Datenquellen: CKW, Groupe E, Primeo (öffentliche APIs)</p>
              <p>Regulierte Tarife: ElCom 2027</p>
            </div>
          </div>

          <Separator />

          {/* Legal */}
          <div className="space-y-2">
            <Button variant="ghost" className="w-full justify-start text-sm text-gray-600" asChild>
              <Link href="/privacy">
                <Shield className="w-4 h-4 mr-2" />
                {t(locale, 'privacy')}
              </Link>
            </Button>
            <Button variant="ghost" className="w-full justify-start text-sm text-gray-600" asChild>
              <Link href="/methodology">
                <Info className="w-4 h-4 mr-2" />
                {t(locale, 'methodology')}
              </Link>
            </Button>
            <Button variant="ghost" className="w-full justify-start text-sm text-red-500 hover:text-red-700">
              <Trash2 className="w-4 h-4 mr-2" />
              Konto löschen
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}
