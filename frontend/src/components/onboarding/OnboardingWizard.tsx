'use client';

import { useState } from 'react';
import { Globe, MapPin, Zap, Settings, Bell, ChevronRight, ChevronLeft, Check } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import useAppStore from '@/hooks/useAppStore';
import { t, type Locale } from '@/i18n/translations';
import { PROVIDER_META, type ProviderId } from '@/lib/api';

const STEPS = ['language', 'location', 'tariff', 'appliances', 'notifications'] as const;
type Step = typeof STEPS[number];

const STEP_ICONS: Record<Step, React.ElementType> = {
  language: Globe,
  location: MapPin,
  tariff: Zap,
  appliances: Settings,
  notifications: Bell,
};

export default function OnboardingWizard() {
  const {
    locale, setLocale,
    household, setHousehold,
    setOnboardingComplete,
  } = useAppStore();
  const [step, setStep] = useState(0);
  const [postalCode, setPostalCode] = useState(household?.postal_code ?? '6003');
  const [municipality, setMunicipality] = useState(household?.municipality_name ?? 'Luzern');
  const [selectedProvider, setSelectedProvider] = useState<ProviderId>('ckw');
  const [annualKwh, setAnnualKwh] = useState(household?.annual_kwh_estimate ?? 4500);

  const currentStep = STEPS[step];
  const canNext = step < STEPS.length - 1;
  const canBack = step > 0;

  const handleFinish = () => {
    setHousehold({
      id: 'household-1',
      label: 'Mein Zuhause',
      postal_code: postalCode,
      municipality_id: '2196',
      municipality_name: municipality,
      distribution_operator_name: PROVIDER_META[selectedProvider].name,
      provider_id: selectedProvider,
      tariff_product_id: 'dynamic-flex',
      enrollment_status: 'user_claimed',
      annual_kwh_estimate: annualKwh,
    });
    setOnboardingComplete(true);
  };

  const LOCALE_OPTIONS: Array<{ id: Locale; label: string; flag: string; desc: string }> = [
    { id: 'de', label: 'Deutsch', flag: '🇩🇪', desc: 'Standard für die Schweiz' },
    { id: 'en', label: 'English', flag: '🇬🇧', desc: 'Interface in English' },
    { id: 'fr', label: 'Français', flag: '🇫🇷', desc: 'Interface en français' },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-600 to-teal-800 flex items-center justify-center p-4">
      <div className="w-full max-w-lg">
        {/* Progress */}
        <div className="flex items-center justify-center gap-2 mb-8">
          {STEPS.map((s, i) => {
            const Icon = STEP_ICONS[s];
            return (
              <div
                key={s}
                className={`flex items-center gap-1 ${
                  i <= step ? 'text-white' : 'text-teal-300/50'
                }`}
              >
                <div
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm ${
                    i < step
                      ? 'bg-white text-teal-600'
                      : i === step
                        ? 'bg-white/20 text-white border-2 border-white'
                        : 'bg-teal-700/50 text-teal-300/50'
                  }`}
                >
                  {i < step ? <Check className="w-4 h-4" /> : <Icon className="w-4 h-4" />}
                </div>
                {i < STEPS.length - 1 && (
                  <div className={`w-8 h-0.5 ${i < step ? 'bg-white' : 'bg-teal-700/50'}`} />
                )}
              </div>
            );
          })}
        </div>

        <Card className="shadow-2xl">
          <CardContent className="p-8">
            {/* Step 1: Language */}
            {currentStep === 'language' && (
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{t(locale, 'onboarding_welcome')} 👋</h2>
                <p className="text-gray-500 mb-6">{t(locale, 'onboarding_language')}</p>
                <div className="space-y-3">
                  {LOCALE_OPTIONS.map((opt) => (
                    <button
                      key={opt.id}
                      onClick={() => setLocale(opt.id)}
                      className={`w-full flex items-center gap-4 p-4 rounded-xl border-2 transition ${
                        locale === opt.id
                          ? 'border-teal-500 bg-teal-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <span className="text-2xl">{opt.flag}</span>
                      <div className="text-left">
                        <p className="text-sm font-semibold text-gray-900">{opt.label}</p>
                        <p className="text-xs text-gray-500">{opt.desc}</p>
                      </div>
                      {locale === opt.id && <Check className="w-5 h-5 text-teal-600 ml-auto" />}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Step 2: Location */}
            {currentStep === 'location' && (
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{t(locale, 'onboarding_location')}</h2>
                <p className="text-gray-500 mb-6">Dein Standort bestimmt deinen Netzbetreiber und die verfügbaren Tarife.</p>
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-gray-700">PLZ</label>
                    <Input
                      value={postalCode}
                      onChange={(e) => setPostalCode(e.target.value)}
                      placeholder="z.B. 6003"
                      className="mt-1 text-lg"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-700">Gemeinde</label>
                    <Input
                      value={municipality}
                      onChange={(e) => setMunicipality(e.target.value)}
                      placeholder="z.B. Luzern"
                      className="mt-1 text-lg"
                    />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-700">Jahresverbrauch (kWh)</label>
                    <Input
                      type="number"
                      value={annualKwh}
                      onChange={(e) => setAnnualKwh(+e.target.value)}
                      placeholder="4500"
                      className="mt-1 text-lg"
                    />
                    <p className="text-xs text-gray-400 mt-1">Schweizer Durchschnitt: ca. 4&apos;500 kWh/Jahr für einen 4-Personen-Haushalt</p>
                  </div>
                </div>
              </div>
            )}

            {/* Step 3: Tariff */}
            {currentStep === 'tariff' && (
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{t(locale, 'onboarding_tariff')}</h2>
                <p className="text-gray-500 mb-6">Wähle deinen Energieversorger mit dynamischem Tarif.</p>
                <div className="space-y-3">
                  {(Object.keys(PROVIDER_META) as ProviderId[]).map((pid) => (
                    <button
                      key={pid}
                      onClick={() => setSelectedProvider(pid)}
                      className={`w-full flex items-center gap-4 p-4 rounded-xl border-2 transition ${
                        selectedProvider === pid
                          ? 'border-teal-500 bg-teal-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div
                        className="w-10 h-10 rounded-lg flex items-center justify-center text-white font-bold text-sm"
                        style={{ backgroundColor: PROVIDER_META[pid].color }}
                      >
                        {PROVIDER_META[pid].name[0]}
                      </div>
                      <div className="text-left flex-1">
                        <p className="text-sm font-semibold text-gray-900">{PROVIDER_META[pid].name}</p>
                        <p className="text-xs text-gray-500">{PROVIDER_META[pid].territory} · Dynamischer Tarif</p>
                      </div>
                      {selectedProvider === pid && <Check className="w-5 h-5 text-teal-600" />}
                    </button>
                  ))}
                </div>
                <button className="w-full text-center text-sm text-gray-400 mt-4 hover:text-gray-600">
                  {t(locale, 'not_sure')}
                </button>
              </div>
            )}

            {/* Step 4: Appliances */}
            {currentStep === 'appliances' && (
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{t(locale, 'onboarding_appliances')}</h2>
                <p className="text-gray-500 mb-6">Standard-Geräte sind bereits vorkonfiguriert. Du kannst sie später anpassen.</p>
                <div className="space-y-3">
                  {[
                    { name: 'Waschmaschine', detail: '120 Min. · 1.0 kWh', icon: '🧺' },
                    { name: 'Geschirrspüler', detail: '150 Min. · 1.2 kWh', icon: '🍽️' },
                    { name: 'E-Auto', detail: '240 Min. · 11 kWh', icon: '🚗' },
                  ].map((a) => (
                    <div key={a.name} className="flex items-center gap-3 p-3 rounded-xl border border-gray-200 bg-gray-50">
                      <span className="text-2xl">{a.icon}</span>
                      <div className="flex-1">
                        <p className="text-sm font-semibold text-gray-900">{a.name}</p>
                        <p className="text-xs text-gray-500">{a.detail}</p>
                      </div>
                      <Check className="w-5 h-5 text-teal-600" />
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Step 5: Notifications */}
            {currentStep === 'notifications' && (
              <div>
                <h2 className="text-2xl font-bold text-gray-900 mb-2">{t(locale, 'onboarding_notifications')}</h2>
                <p className="text-gray-500 mb-6">Wir erinnern dich an günstige Zeitfenster für deine Geräte.</p>
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                    <div className="flex items-center gap-3">
                      <Bell className="w-5 h-5 text-teal-600" />
                      <div>
                        <p className="text-sm font-medium text-gray-900">Tägliche Zusammenfassung</p>
                        <p className="text-xs text-gray-500">Jeden Abend um 19:00</p>
                      </div>
                    </div>
                    <Switch defaultChecked />
                  </div>
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                    <div className="flex items-center gap-3">
                      <Zap className="w-5 h-5 text-blue-600" />
                      <div>
                        <p className="text-sm font-medium text-gray-900">Erinnerung vor Start</p>
                        <p className="text-xs text-gray-500">15 Minuten vorher</p>
                      </div>
                    </div>
                    <Switch defaultChecked />
                  </div>
                </div>
              </div>
            )}

            {/* Navigation buttons */}
            <div className="flex items-center justify-between mt-8">
              <Button
                variant="ghost"
                onClick={() => setStep((s) => s - 1)}
                disabled={!canBack}
                className={!canBack ? 'invisible' : ''}
              >
                <ChevronLeft className="w-4 h-4 mr-1" />
                {t(locale, 'back')}
              </Button>

              {canNext ? (
                <Button onClick={() => setStep((s) => s + 1)} className="bg-teal-600 hover:bg-teal-700">
                  {t(locale, 'next')}
                  <ChevronRight className="w-4 h-4 ml-1" />
                </Button>
              ) : (
                <Button onClick={handleFinish} className="bg-teal-600 hover:bg-teal-700">
                  {t(locale, 'finish')}
                  <Check className="w-4 h-4 ml-1" />
                </Button>
              )}
            </div>

            {/* Skip */}
            {step < STEPS.length - 1 && (
              <button
                onClick={() => { handleFinish(); }}
                className="w-full text-center text-xs text-gray-400 mt-4 hover:text-gray-600"
              >
                {t(locale, 'skip')} — Dashboard direkt öffnen
              </button>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
