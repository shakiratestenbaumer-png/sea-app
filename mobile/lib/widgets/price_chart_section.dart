import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../charts/plotly_chart.dart';
import '../core/swiss_format.dart';
import '../l10n/app_localizations.dart';
import '../models/provider_data.dart';
import '../providers/api_providers.dart';
import '../utils/price_filters.dart';

class PriceChartSection extends ConsumerWidget {
  const PriceChartSection({super.key, required this.providers});

  final List<ProviderData> providers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final day = ref.watch(priceDayProvider);
    final viewMode = ref.watch(chartViewModeProvider);
    final showGrid = ref.watch(showGridOverlayProvider);
    final selectedId = ref.watch(selectedProviderIdProvider);
    const unit = PriceUnit.rp;

    final targetDay = day == PriceDay.today
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));

    final active = providers
        .where((p) => p.isOk)
        .map((p) => providerForDay(p, targetDay))
        .where((p) => p.prices.isNotEmpty)
        .toList();

    final mult = SwissFormat.toDisplayUnit(1, unit);
    final unitLabel = SwissFormat.unitLabel(unit);

    if (active.isEmpty) {
      return _card(
        context,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(l10n.t('no_data'))),
        ),
      );
    }

    final current = active.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => active.first,
    );

    List<Map<String, dynamic>> traces;
    if (viewMode == ChartViewMode.compare) {
      traces = [
        for (final p in active)
          PlotlyConfigBuilder.splineTrace(
            x: p.prices.map((e) => timeLabel(e.start)).toList(),
            y: p.prices.map((e) => e.integrated * mult).toList(),
            name: '${p.name} (${p.territory})',
            color: p.color.startsWith('#') ? p.color : '#0d9488',
          ),
      ];
    } else {
      traces = [
        PlotlyConfigBuilder.splineTrace(
          x: current.prices.map((e) => timeLabel(e.start)).toList(),
          y: current.prices.map((e) => e.integrated * mult).toList(),
          name: l10n.t('total'),
          color: current.color.startsWith('#') ? current.color : '#0d9488',
          fill: true,
        ),
      ];
      if (showGrid) {
        traces.add(
          PlotlyConfigBuilder.splineTrace(
            x: current.prices.map((e) => timeLabel(e.start)).toList(),
            y: current.prices.map((e) => e.grid * mult).toList(),
            name: l10n.t('network'),
            color: '#60a5fa',
          ),
        );
      }
    }

    final config = PlotlyConfigBuilder.lineChart(
      traces: traces,
      yTitle: unitLabel,
      showLegend: viewMode == ChartViewMode.compare,
    );

    final stats = _stats(current, mult, unitLabel);

    return _card(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('chart_title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    l10n.t('chart_subtitle'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                SegmentedButton<PriceDay>(
                  segments: [
                    ButtonSegment(
                      value: PriceDay.today,
                      label: Text(l10n.t('hero_today')),
                    ),
                    ButtonSegment(
                      value: PriceDay.tomorrow,
                      label: Text(l10n.t('hero_tomorrow')),
                    ),
                  ],
                  selected: {day},
                  onSelectionChanged: (s) =>
                      ref.read(priceDayProvider.notifier).state = s.first,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.t('compare_mode')),
                  selected: viewMode == ChartViewMode.compare,
                  onSelected: (_) => ref
                      .read(chartViewModeProvider.notifier)
                      .state = ChartViewMode.compare,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.t('single_mode')),
                  selected: viewMode == ChartViewMode.single,
                  onSelected: (_) => ref
                      .read(chartViewModeProvider.notifier)
                      .state = ChartViewMode.single,
                ),
                if (viewMode == ChartViewMode.single) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.t('show_grid')),
                    selected: showGrid,
                    onSelected: (v) =>
                        ref.read(showGridOverlayProvider.notifier).state = v,
                  ),
                ],
              ],
            ),
            if (viewMode == ChartViewMode.single)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: current.id,
                  items: [
                    for (final p in active)
                      DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(selectedProviderIdProvider.notifier).state = id;
                    }
                  },
                ),
              ),
            PlotlyChart(
              configJson: config,
              height: 300,
              zoomHint: l10n.t('chart_zoom_hint'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _statChip(context, l10n.t('lowest_price'), stats.min),
                const SizedBox(width: 8),
                _statChip(context, l10n.t('daily_average'), stats.avg),
                const SizedBox(width: 8),
                _statChip(context, l10n.t('max_price'), stats.max),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.grey.shade600)),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  ({String min, String avg, String max}) _stats(
    ProviderData p,
    double mult,
    String unitLabel,
  ) {
    final vals = p.prices.map((e) => e.integrated * mult).toList();
    final min = vals.reduce((a, b) => a < b ? a : b);
    final max = vals.reduce((a, b) => a > b ? a : b);
    final avg = vals.reduce((a, b) => a + b) / vals.length;
    return (
      min: '${min.toStringAsFixed(1)} Rp.',
      avg: '${avg.toStringAsFixed(1)} Rp.',
      max: '${max.toStringAsFixed(1)} Rp.',
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}
