import '../models/provider_data.dart';

DateTime _localDate(String iso) {
  return DateTime.parse(iso).toLocal();
}

List<ProviderPrice> filterPricesForDay(
  List<ProviderPrice> prices,
  DateTime dayLocal,
) {
  return prices.where((p) {
    final d = _localDate(p.start);
    return d.year == dayLocal.year &&
        d.month == dayLocal.month &&
        d.day == dayLocal.day;
  }).toList();
}

ProviderData providerForDay(ProviderData provider, DateTime dayLocal) {
  final filtered = filterPricesForDay(provider.prices, dayLocal);
  if (filtered.isEmpty) {
    return ProviderData(
      id: provider.id,
      name: provider.name,
      fullName: provider.fullName,
      territory: provider.territory,
      color: provider.color,
      status: provider.status,
      publication: provider.publication,
      intervalCount: 0,
      prices: const [],
      summary: provider.summary,
      tariffName: provider.tariffName,
    );
  }

  final integrated = filtered.map((p) => p.integrated).toList();
  final grid = filtered.map((p) => p.grid).toList();
  return ProviderData(
    id: provider.id,
    name: provider.name,
    fullName: provider.fullName,
    territory: provider.territory,
    color: provider.color,
    status: provider.status,
    publication: provider.publication,
    intervalCount: filtered.length,
    prices: filtered,
    summary: ProviderSummary(
      integratedMin: integrated.reduce((a, b) => a < b ? a : b),
      integratedMax: integrated.reduce((a, b) => a > b ? a : b),
      integratedAvg: integrated.reduce((a, b) => a + b) / integrated.length,
      gridMin: grid.reduce((a, b) => a < b ? a : b),
      gridMax: grid.reduce((a, b) => a > b ? a : b),
      gridAvg: grid.reduce((a, b) => a + b) / grid.length,
    ),
    tariffName: provider.tariffName,
  );
}

String timeLabel(String iso) {
  final dt = DateTime.parse(iso).toLocal();
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
