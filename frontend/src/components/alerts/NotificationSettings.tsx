'use client';

import { Bell, Check, Clock, Moon } from 'lucide-react';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import useAppStore from '@/hooks/useAppStore';
import { t } from '@/i18n/translations';

export default function NotificationSettings() {
  const { locale, notificationPrefs, setNotificationPrefs } = useAppStore();

  const items = [
    {
      icon: Bell,
      iconBg: 'bg-teal-50',
      iconColor: 'text-teal-600',
      label: t(locale, 'daily_summary'),
      detail: `${notificationPrefs.daily_digest_local_time ?? '19:00'} Uhr`,
      checked: notificationPrefs.daily_digest,
      onChange: (v: boolean) => setNotificationPrefs({ daily_digest: v }),
    },
    {
      icon: Clock,
      iconBg: 'bg-blue-50',
      iconColor: 'text-blue-600',
      label: t(locale, 'reminder_before'),
      detail: `${notificationPrefs.reminder_lead_minutes} ${t(locale, 'minutes')}`,
      checked: notificationPrefs.enabled,
      onChange: (v: boolean) => setNotificationPrefs({ enabled: v }),
    },
    {
      icon: Moon,
      iconBg: 'bg-indigo-50',
      iconColor: 'text-indigo-600',
      label: t(locale, 'quiet_hours'),
      detail: `${notificationPrefs.quiet_hours_start ?? '22:00'} – ${notificationPrefs.quiet_hours_end ?? '07:00'}`,
      checked: true,
      onChange: () => {},
    },
  ];

  return (
    <Card className="border-gray-200 shadow-sm">
      <CardHeader className="pb-2 pt-4 px-5">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-lg font-bold text-gray-900">{t(locale, 'alerts_title')}</h2>
            <p className="text-sm text-gray-500 mt-0.5">{t(locale, 'alerts_subtitle')}</p>
          </div>
          <Badge
            variant="outline"
            className={`text-xs ${
              notificationPrefs.push_registered
                ? 'bg-teal-50 text-teal-700 border-teal-200'
                : 'bg-gray-50 text-gray-500'
            }`}
          >
            {notificationPrefs.push_registered && <Check className="w-3.5 h-3.5 mr-1" />}
            {notificationPrefs.push_registered ? t(locale, 'push_allowed') : t(locale, 'push_denied')}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="px-5 pb-4">
        <div className="space-y-3">
          {items.map((item) => (
            <div key={item.label} className="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
              <div className="flex items-center gap-3">
                <div className={`w-9 h-9 rounded-lg flex items-center justify-center ${item.iconBg}`}>
                  <item.icon className={`w-4 h-4 ${item.iconColor}`} />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">{item.label}</p>
                  <p className="text-xs text-gray-400">{item.detail}</p>
                </div>
              </div>
              <Switch
                checked={item.checked}
                onCheckedChange={item.onChange}
              />
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
