import 'package:flutter/material.dart';

import '../charts/plotly_chart.dart';
import '../core/swiss_format.dart';
import '../l10n/app_localizations.dart';
import '../models/provider_data.dart';

class TariffBreakdown extends StatelessWidget {
  const TariffBreakdown({super.key, required this.provider});

  final ProviderData provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (provider.prices.isEmpty) return const SizedBox.shrink();

    final sample = provider.prices[provider.prices.length ~/ 2];
    final energy = sample.electricity;
    final grid = sample.grid;
    final levies = (sample.integrated - sample.electricity - sample.grid)
        .clamp(0.0, double.infinity)
        .toDouble();

    final config = PlotlyConfigBuilder.stackedBar(
      labels: [provider.name],
      energy: [energy * 100],
      grid: [grid * 100],
      levies: [levies * 100],
      yTitle: 'Rp./kWh',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('breakdown_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            PlotlyChart(
              configJson: config,
              height: 220,
              zoomHint: l10n.t('chart_zoom_hint'),
            ),
            const SizedBox(height: 8),
            _row(l10n.t('electricity'), SwissFormat.formatPrice(energy, unit: PriceUnit.rp)),
            _row(l10n.t('network_usage'), SwissFormat.formatPrice(grid, unit: PriceUnit.rp)),
            _row(l10n.t('levies_taxes'), SwissFormat.formatPrice(levies, unit: PriceUnit.rp)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
