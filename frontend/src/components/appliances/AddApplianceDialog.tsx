'use client';

import { useState } from 'react';
import { Droplets, UtensilsCrossed, Car, Flame, Wind, HelpCircle, Plus } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import useAppStore from '@/hooks/useAppStore';
import { t } from '@/i18n/translations';
import type { ApplianceType } from '@/types/energy';

const TEMPLATES: Array<{
  type: ApplianceType;
  icon: React.ElementType;
  labelKey: string;
  duration: number;
  energy: number;
}> = [
  { type: 'washing_machine', icon: Droplets, labelKey: 'washing_machine', duration: 120, energy: 1.0 },
  { type: 'dishwasher', icon: UtensilsCrossed, labelKey: 'dishwasher', duration: 150, energy: 1.2 },
  { type: 'tumble_dryer', icon: Wind, labelKey: 'tumble_dryer', duration: 90, energy: 2.5 },
  { type: 'ev_charger', icon: Car, labelKey: 'ev_charger', duration: 240, energy: 11 },
  { type: 'water_heater', icon: Flame, labelKey: 'water_heater', duration: 60, energy: 3.0 },
  { type: 'other', icon: HelpCircle, labelKey: 'other', duration: 60, energy: 1.0 },
];

export default function AddApplianceDialog() {
  const { locale, addAppliance } = useAppStore();
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState<'type' | 'details'>('type');
  const [selectedType, setSelectedType] = useState<ApplianceType | null>(null);
  const [name, setName] = useState('');
  const [duration, setDuration] = useState(120);
  const [energy, setEnergy] = useState(1.0);
  const [earliest, setEarliest] = useState('06:00');
  const [latest, setLatest] = useState('22:00');

  const selectTemplate = (tmpl: typeof TEMPLATES[0]) => {
    setSelectedType(tmpl.type);
    setName(t(locale, tmpl.labelKey as any));
    setDuration(tmpl.duration);
    setEnergy(tmpl.energy);
    setStep('details');
  };

  const handleAdd = () => {
    if (!selectedType || !name.trim()) return;
    addAppliance({
      id: `app-${Date.now()}`,
      type: selectedType,
      display_name: name.trim(),
      duration_minutes: duration,
      energy_kwh: energy,
      earliest_start_local: earliest,
      latest_finish_local: latest,
      notification_lead_minutes: 15,
      must_be_home: false,
      active: true,
    });
    setOpen(false);
    setStep('type');
    setSelectedType(null);
  };

  return (
    <>
      <Button variant="outline" size="sm" className="gap-1.5 text-sm" onClick={() => setOpen(true)}>
        <Plus className="w-4 h-4" />
        {t(locale, 'add_appliance')}
      </Button>
      <Dialog open={open} onOpenChange={(v) => { setOpen(v); if (!v) { setStep('type'); setSelectedType(null); } }}>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle className="text-lg">
            {step === 'type' ? t(locale, 'add_appliance') : name}
          </DialogTitle>
        </DialogHeader>

        {step === 'type' ? (
          <div className="grid grid-cols-3 gap-3 mt-2">
            {TEMPLATES.map((tmpl) => {
              const Icon = tmpl.icon;
              return (
                <button
                  key={tmpl.type}
                  onClick={() => selectTemplate(tmpl)}
                  className="flex flex-col items-center gap-2 p-4 rounded-xl border border-gray-200 hover:border-teal-300 hover:bg-teal-50 transition-all"
                >
                  <Icon className="w-7 h-7 text-teal-600" />
                  <span className="text-xs font-medium text-gray-700">{t(locale, tmpl.labelKey as any)}</span>
                </button>
              );
            })}
          </div>
        ) : (
          <div className="space-y-4 mt-2">
            <div>
              <Label className="text-sm font-medium">Name</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} className="mt-1" />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label className="text-sm font-medium">Dauer (Min.)</Label>
                <Input type="number" value={duration} onChange={(e) => setDuration(+e.target.value)} className="mt-1" />
              </div>
              <div>
                <Label className="text-sm font-medium">Verbrauch (kWh)</Label>
                <Input type="number" step="0.1" value={energy} onChange={(e) => setEnergy(+e.target.value)} className="mt-1" />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label className="text-sm font-medium">Frühester Start</Label>
                <Input type="time" value={earliest} onChange={(e) => setEarliest(e.target.value)} className="mt-1" />
              </div>
              <div>
                <Label className="text-sm font-medium">Spätestes Ende</Label>
                <Input type="time" value={latest} onChange={(e) => setLatest(e.target.value)} className="mt-1" />
              </div>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => setStep('type')} className="flex-1">
                {t(locale, 'back')}
              </Button>
              <Button onClick={handleAdd} className="flex-1 bg-teal-600 hover:bg-teal-700">
                {t(locale, 'add_appliance')}
              </Button>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
    </>
  );
}
