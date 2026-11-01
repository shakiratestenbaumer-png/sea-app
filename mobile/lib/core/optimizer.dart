import '../models/appliance.dart';
import '../models/provider_data.dart';
import 'swiss_format.dart';

class WindowResult {
  const WindowResult({
    required this.start,
    required this.end,
    required this.costChf,
    required this.baselineCostChf,
    required this.savingsChf,
  });

  final DateTime start;
  final DateTime end;
  final double costChf;
  final double baselineCostChf;
  final double savingsChf;

  String startLabel() => SwissFormat.formatTime24(start.toLocal());
  String endLabel() => SwissFormat.formatTime24(end.toLocal());
}

class ApplianceOptimizer {
  static WindowResult? findBestWindow(
    ProviderData provider,
    Appliance appliance, {
    int slotMinutes = 15,
  }) {
    final prices = provider.prices;
    if (prices.isEmpty) return null;

    final slotsNeeded = (appliance.durationMinutes / slotMinutes).ceil();
    if (prices.length < slotsNeeded) return null;

    final powerKw = appliance.energyKwh / (appliance.durationMinutes / 60);
    final slotEnergyKwh = powerKw * (slotMinutes / 60);

    double bestCost = double.infinity;
    var bestIdx = 0;
    double worstCost = 0;

    for (var i = 0; i <= prices.length - slotsNeeded; i++) {
      var cost = 0.0;
      for (var j = 0; j < slotsNeeded; j++) {
        cost += prices[i + j].integrated * slotEnergyKwh;
      }
      if (cost < bestCost) {
        bestCost = cost;
        bestIdx = i;
      }
      if (cost > worstCost) worstCost = cost;
    }

    final start = DateTime.parse(prices[bestIdx].start);
    final endIdx = (bestIdx + slotsNeeded - 1).clamp(0, prices.length - 1);
    final end = DateTime.parse(prices[endIdx].end);

    return WindowResult(
      start: start,
      end: end,
      costChf: bestCost,
      baselineCostChf: worstCost,
      savingsChf: worstCost - bestCost,
    );
  }
}
