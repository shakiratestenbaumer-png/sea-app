import type { Locale } from '@/i18n/translations';

/** Map browser language to app locale; default German for Swiss users. */
export function detectBrowserLocale(): Locale {
  if (typeof navigator === 'undefined') return 'de';
  const lang = navigator.language.toLowerCase();
  if (lang.startsWith('fr')) return 'fr';
  if (lang.startsWith('en')) return 'en';
  return 'de';
}
