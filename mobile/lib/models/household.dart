class Household {
  const Household({
    this.postalCode,
    this.municipalityName,
    this.providerId = 'ckw',
    this.tariffProductId,
  });

  final String? postalCode;
  final String? municipalityName;
  final String providerId;
  final String? tariffProductId;

  Map<String, dynamic> toJson() => {
        'postal_code': postalCode,
        'municipality_name': municipalityName,
        'provider_id': providerId,
        'tariff_product_id': tariffProductId,
      };

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      postalCode: json['postal_code'] as String?,
      municipalityName: json['municipality_name'] as String?,
      providerId: json['provider_id'] as String? ?? 'ckw',
      tariffProductId: json['tariff_product_id'] as String?,
    );
  }

  Household copyWith({
    String? postalCode,
    String? municipalityName,
    String? providerId,
    String? tariffProductId,
  }) {
    return Household(
      postalCode: postalCode ?? this.postalCode,
      municipalityName: municipalityName ?? this.municipalityName,
      providerId: providerId ?? this.providerId,
      tariffProductId: tariffProductId ?? this.tariffProductId,
    );
  }
}
