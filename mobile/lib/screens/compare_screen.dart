import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../charts/plotly_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/provider_data.dart';
import '../providers/api_providers.dart';
import '../widgets/app_header.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final providersAsync = ref.watch(providersDataProvider);
    const mult = 100.0;
    const unitLabel = 'Rp./kWh';

    return providersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.t('error_loading'))),
      data: (data) {
        final active = data.providers.where((p) => p.isOk).toList()
          ..sort((a, b) {
            final avgA =
                a.prices.map((e) => e.integrated).reduce((x, y) => x + y) /
                    a.prices.length;
            final avgB =
                b.prices.map((e) => e.integrated).reduce((x, y) => x + y) /
                    b.prices.length;
            return avgA.compareTo(avgB);
          });

        final traces = [
          for (final p in active)
            PlotlyConfigBuilder.boxTrace(
              y: p.prices.map((e) => e.integrated * mult).toList(),
              name: p.name,
              color: p.color.startsWith('#') ? p.color : '#0d9488',
            ),
        ];

        final config = PlotlyConfigBuilder.boxChart(
          traces: traces,
          yTitle: unitLabel,
        );

        return ListView(
          children: [
            const AppHeader(),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('comparison_title'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(l10n.t('comparison_subtitle')),
                    const SizedBox(height: 12),
                    if (active.isNotEmpty)
                      PlotlyChart(
                        configJson: config,
                        height: 260,
                        zoomHint: l10n.t('chart_zoom_hint'),
                      )
                    else
                      Text(l10n.t('no_data')),
                  ],
                ),
              ),
            ),
            for (final p in active) _SummaryRow(provider: p, mult: mult),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.t('swiss_disclaimer'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.provider,
    required this.mult,
  });

  final ProviderData provider;
  final double mult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vals = provider.prices.map((e) => e.integrated * mult).toList();
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);
    final avg = vals.reduce((a, b) => a + b) / vals.length;

    String fmt(double v) => '${v.toStringAsFixed(1)} Rp.';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(provider.color.replaceFirst('#', '0xFF')),
          ),
          child: Text(provider.name.characters.first,
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(provider.name),
        subtitle: Text(provider.territory),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${l10n.t('provider_min')}: ${fmt(min)}',
                style: const TextStyle(fontSize: 11)),
            Text('${l10n.t('provider_avg')}: ${fmt(avg)}',
                style: const TextStyle(fontSize: 11)),
            Text('${l10n.t('provider_max')}: ${fmt(max)}',
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
