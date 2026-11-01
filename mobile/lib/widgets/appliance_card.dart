import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/optimizer.dart';
import '../core/swiss_format.dart';
import '../l10n/app_localizations.dart';
import '../models/appliance.dart';
import '../models/provider_data.dart';
import '../providers/app_state_providers.dart';

class ApplianceCard extends ConsumerWidget {
  const ApplianceCard({
    super.key,
    required this.appliance,
    required this.provider,
    this.onEdit,
  });

  final Appliance appliance;
  final ProviderData? provider;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = provider != null
        ? ApplianceOptimizer.findBestWindow(provider!, appliance)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon(appliance.type), color: const Color(0xFF0D9488)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliance.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${appliance.durationMinutes} ${l10n.t('min')} · ${appliance.energyKwh} ${l10n.t('kwh')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (window != null) ...[
              Text(
                '${l10n.t('best_start')} · ${l10n.t('today_label')}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${window.startLabel()} – ${window.endLabel()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D9488),
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${l10n.t('estimated_cost')}: ${SwissFormat.formatChf(window.costChf)}'),
                  if (window.savingsChf > 0.01) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${SwissFormat.formatChf(window.savingsChf)} ${l10n.t('less')})',
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ] else
              Text(l10n.t('prices_awaiting')),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.t('set_reminder'), style: const TextStyle(fontSize: 14)),
              value: appliance.reminderEnabled,
              onChanged: (v) {
                ref.read(appliancesProvider.notifier).updateAppliance(
                      appliance.copyWith(reminderEnabled: v),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(ApplianceType type) {
    switch (type) {
      case ApplianceType.dishwasher:
        return Icons.countertops_outlined;
      case ApplianceType.washingMachine:
        return Icons.local_laundry_service_outlined;
      case ApplianceType.tumbleDryer:
        return Icons.dry_cleaning;
      case ApplianceType.evCharger:
        return Icons.electric_car_outlined;
      case ApplianceType.waterHeater:
        return Icons.water_drop_outlined;
      case ApplianceType.other:
        return Icons.help_outline;
    }
  }
}
