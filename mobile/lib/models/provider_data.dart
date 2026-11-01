class ProviderPrice {
  const ProviderPrice({
    required this.start,
    required this.end,
    required this.integrated,
    required this.grid,
    required this.electricity,
  });

  final String start;
  final String end;
  final double integrated;
  final double grid;
  final double electricity;

  factory ProviderPrice.fromJson(Map<String, dynamic> json) {
    return ProviderPrice(
      start: json['start'] as String,
      end: json['end'] as String,
      integrated: (json['integrated'] as num).toDouble(),
      grid: (json['grid'] as num).toDouble(),
      electricity: (json['electricity'] as num).toDouble(),
    );
  }
}

class ProviderSummary {
  const ProviderSummary({
    required this.integratedMin,
    required this.integratedMax,
    required this.integratedAvg,
    required this.gridMin,
    required this.gridMax,
    required this.gridAvg,
  });

  final double integratedMin;
  final double integratedMax;
  final double integratedAvg;
  final double gridMin;
  final double gridMax;
  final double gridAvg;

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      integratedMin: (json['integrated_min'] as num).toDouble(),
      integratedMax: (json['integrated_max'] as num).toDouble(),
      integratedAvg: (json['integrated_avg'] as num).toDouble(),
      gridMin: (json['grid_min'] as num).toDouble(),
      gridMax: (json['grid_max'] as num).toDouble(),
      gridAvg: (json['grid_avg'] as num).toDouble(),
    );
  }
}

class ProviderData {
  const ProviderData({
    required this.id,
    required this.name,
    required this.fullName,
    required this.territory,
    required this.color,
    required this.status,
    required this.publication,
    required this.intervalCount,
    required this.prices,
    this.summary,
    this.tariffName,
  });

  final String id;
  final String name;
  final String fullName;
  final String territory;
  final String color;
  final String status;
  final String? publication;
  final int intervalCount;
  final List<ProviderPrice> prices;
  final ProviderSummary? summary;
  final String? tariffName;

  bool get isOk => status == 'ok' && prices.isNotEmpty;

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      id: json['id'] as String,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      territory: json['territory'] as String,
      color: json['color'] as String? ?? '#0d9488',
      status: json['status'] as String? ?? 'unknown',
      publication: json['publication'] as String?,
      intervalCount: json['interval_count'] as int? ?? 0,
      tariffName: json['tariff_name'] as String?,
      summary: json['summary'] != null
          ? ProviderSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      prices: (json['prices'] as List<dynamic>? ?? [])
          .map((e) => ProviderPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AllProvidersResponse {
  const AllProvidersResponse({required this.providers});

  final List<ProviderData> providers;

  factory AllProvidersResponse.fromJson(Map<String, dynamic> json) {
    return AllProvidersResponse(
      providers: (json['providers'] as List<dynamic>? ?? [])
          .map((e) => ProviderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
