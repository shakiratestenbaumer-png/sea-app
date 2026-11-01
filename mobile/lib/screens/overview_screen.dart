import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/api_providers.dart';
import '../providers/app_state_providers.dart';
import '../widgets/app_header.dart';
import '../widgets/best_time_hero.dart';
import '../widgets/price_chart_section.dart';
import '../widgets/savings_estimate_card.dart';
import '../widgets/tariff_breakdown.dart';
import '../widgets/trust_footer.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final providersAsync = ref.watch(providersDataProvider);
    final household = ref.watch(householdProvider);

    return providersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        message: l10n.t('error_loading'),
        onRetry: () => ref.read(providersDataProvider.notifier).refresh(),
      ),
      data: (data) {
        final providers = data.providers;
        final userProvider = providers
            .where((p) => p.id == household.providerId)
            .firstOrNull;
        final heroProvider = userProvider?.isOk == true
            ? userProvider
            : providers.where((p) => p.isOk).firstOrNull;

        return RefreshIndicator(
          onRefresh: () => ref.read(providersDataProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const AppHeader(),
              BestTimeHero(provider: heroProvider),
              if (providers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.t('no_data'))),
                )
              else ...[
                PriceChartSection(providers: providers),
                SavingsEstimateCard(provider: heroProvider),
                if (heroProvider != null)
                  TariffBreakdown(provider: heroProvider),
              ],
              TrustFooter(
                lastRefresh: heroProvider?.publication != null
                    ? DateTime.tryParse(heroProvider!.publication!)
                    : DateTime.now(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.t('retry'))),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
