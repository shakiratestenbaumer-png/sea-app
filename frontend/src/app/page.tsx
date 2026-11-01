'use client';

import { Suspense, useEffect, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import AppHeader from '@/components/layout/AppHeader';
import MobileBottomNav from '@/components/layout/MobileBottomNav';
import DashboardGrid from '@/components/layout/DashboardGrid';
import BestTimeHero from '@/components/overview/BestTimeHero';
import PriceTimelineChart from '@/components/prices/PriceTimelineChart';
import TariffBreakdown from '@/components/prices/TariffBreakdown';
import ProviderComparison from '@/components/comparisons/ProviderComparison';
import OnboardingWizard from '@/components/onboarding/OnboardingWizard';
import SettingsDrawer from '@/components/settings/SettingsDrawer';
import AppStoreBadges from '@/components/shared/AppStoreBadges';
import { Skeleton } from '@/components/ui/skeleton';
import useAppStore from '@/hooks/useAppStore';
import { t } from '@/i18n/translations';

function DashboardContent() {
  const { locale, onboardingComplete, activeSection, setActiveSection } = useAppStore();
  const [mounted, setMounted] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (activeSection === 'settings') {
      setSettingsOpen(true);
      setActiveSection('overview');
    }
  }, [activeSection, setActiveSection]);

  if (!mounted) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-6 space-y-6">
        <Skeleton className="h-24 w-full rounded-xl" />
        <Skeleton className="h-96 w-full rounded-xl" />
        <Skeleton className="h-64 w-full rounded-xl" />
      </div>
    );
  }

  if (!onboardingComplete) {
    return <OnboardingWizard />;
  }

  return (
    <>
      <main className="max-w-7xl mx-auto px-4 py-4 pb-20 md:pb-6">
        <DashboardGrid
          sections={{
            hero: (
              <section id="section-overview">
                <BestTimeHero />
              </section>
            ),
            chart: <PriceTimelineChart />,
            breakdown: <TariffBreakdown />,
            comparison: (
              <section id="section-compare">
                <ProviderComparison />
              </section>
            ),
            download: <AppStoreBadges />,
          }}
        />
      </main>

      <footer className="bg-gray-900 text-gray-400 mt-8">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <div className="flex items-center gap-2 mb-3">
                <Image src="/icons/icon-192x192.png" alt="SEA" width={28} height={28} className="rounded-lg" />
                <span className="text-white font-semibold">Swiss Energy Assistant</span>
              </div>
              <p className="text-xs leading-relaxed">
                Dynamic electricity tariff intelligence for Swiss households. Compare prices from CKW, Groupe E, and
                Primeo in real-time.
              </p>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-3">Links</h4>
              <ul className="space-y-2 text-sm">
                <li>
                  <Link href="/privacy" className="hover:text-teal-400 transition">
                    {t(locale, 'privacy')}
                  </Link>
                </li>
                <li>
                  <Link href="/terms" className="hover:text-teal-400 transition">
                    {t(locale, 'terms')}
                  </Link>
                </li>
                <li>
                  <Link href="/methodology" className="hover:text-teal-400 transition">
                    {t(locale, 'methodology')}
                  </Link>
                </li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-3">Legal</h4>
              <p className="text-sm leading-relaxed">
                {t(locale, 'footer_product_of')} <strong className="text-white">Myrax Core GmbH</strong>
                <br />
                Switzerland
              </p>
              <p className="text-xs mt-3">{t(locale, 'footer_disclaimer')}</p>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-4 pt-3 flex flex-col md:flex-row items-center justify-between gap-2">
            <p className="text-xs">&copy; 2026 Myrax Core GmbH. All rights reserved.</p>
            <p className="text-xs">Live data · 96 &times; 15min intervals · 3 providers</p>
          </div>
        </div>
      </footer>

      <MobileBottomNav />
      <SettingsDrawer open={settingsOpen} onOpenChange={setSettingsOpen} />
    </>
  );
}

export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 via-white to-gray-50">
      <Suspense fallback={<Skeleton className="h-screen w-full" />}>
        <AppHeader />
        <DashboardContent />
      </Suspense>
    </div>
  );
}
