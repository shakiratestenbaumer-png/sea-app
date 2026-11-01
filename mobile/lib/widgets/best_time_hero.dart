import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/optimizer.dart';
import '../core/swiss_format.dart';
import '../l10n/app_localizations.dart';
import '../models/appliance.dart';
import '../models/provider_data.dart';
import '../providers/app_state_providers.dart';

class BestTimeHero extends ConsumerWidget {
  const BestTimeHero({
    super.key,
    required this.provider,
  });

  final ProviderData? provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appliances = ref.watch(appliancesProvider);
    final primary = appliances.isNotEmpty ? appliances.first : null;

    WindowResult? window;
    if (provider != null && primary != null) {
      window = ApplianceOptimizer.findBestWindow(provider!, primary);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('hero_title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          if (window != null && primary != null) ...[
            Text(
              '${window.startLabel()} – ${window.endLabel()}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_applianceLabel(l10n, primary)} · ${SwissFormat.formatChf(window.costChf)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
            if (window.savingsChf > 0.01)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${SwissFormat.formatChf(window.savingsChf)} ${l10n.t('less')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ] else
            Text(
              l10n.t('prices_awaiting'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: Text(l10n.t('remind_me')),
          ),
        ],
      ),
    );
  }

  String _applianceLabel(AppLocalizations l10n, Appliance a) {
    switch (a.type) {
      case ApplianceType.dishwasher:
        return l10n.t('dishwasher');
      case ApplianceType.washingMachine:
        return l10n.t('washing_machine');
      case ApplianceType.tumbleDryer:
        return l10n.t('tumble_dryer');
      case ApplianceType.evCharger:
        return l10n.t('ev_charger');
      case ApplianceType.waterHeater:
        return l10n.t('water_heater');
      case ApplianceType.other:
        return a.displayName;
    }
  }
}
