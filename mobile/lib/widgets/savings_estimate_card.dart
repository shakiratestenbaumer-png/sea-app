import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/optimizer.dart';
import '../core/swiss_format.dart';
import '../l10n/app_localizations.dart';
import '../models/appliance.dart';
import '../models/provider_data.dart';
import '../providers/app_state_providers.dart';

class SavingsEstimateCard extends ConsumerWidget {
  const SavingsEstimateCard({
    super.key,
    required this.provider,
  });

  final ProviderData? provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appliances = ref.watch(appliancesProvider);

    if (provider == null || appliances.isEmpty) return const SizedBox.shrink();

    double totalBestCost = 0;
    double totalWorstCost = 0;
    final rows = <_ApplianceSaving>[];

    for (final a in appliances) {
      final window = ApplianceOptimizer.findBestWindow(provider!, a);
      if (window != null) {
        totalBestCost += window.costChf;
        totalWorstCost += window.baselineCostChf;
        rows.add(_ApplianceSaving(
          name: a.displayName,
          type: a.type,
          bestCost: window.costChf,
          worstCost: window.baselineCostChf,
          savings: window.savingsChf,
        ));
      }
    }

    final dailySaving = totalWorstCost - totalBestCost;
    final yearlySaving = dailySaving * 365;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.savings_outlined,
                      color: Color(0xFF059669), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('savings_title'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        l10n.t('savings_subtitle'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.t('savings_you_save'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CHF ${yearlySaving.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.t('savings_per_year'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${SwissFormat.formatChf(dailySaving)} ${l10n.t('savings_per_day')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Per-appliance breakdown
            Text(
              l10n.t('savings_all_appliances'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_icon(row.type),
                        size: 18, color: const Color(0xFF0D9488)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          Row(
                            children: [
                              Text(
                                '${l10n.t('savings_best_case')}: ${SwissFormat.formatChf(row.bestCost)}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.t('savings_worst_case')}: ${SwissFormat.formatChf(row.worstCost)}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red.shade300),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${SwissFormat.formatChf(row.savings)}',
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.t('savings_tip'),
                      style: TextStyle(
                          fontSize: 12, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_outlined,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.t('savings_home_automation'),
                      style: TextStyle(
                          fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
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

class _ApplianceSaving {
  const _ApplianceSaving({
    required this.name,
    required this.type,
    required this.bestCost,
    required this.worstCost,
    required this.savings,
  });

  final String name;
  final ApplianceType type;
  final double bestCost;
  final double worstCost;
  final double savings;
}
