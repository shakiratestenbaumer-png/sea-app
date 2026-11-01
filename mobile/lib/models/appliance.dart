enum ApplianceType {
  dishwasher,
  washingMachine,
  tumbleDryer,
  evCharger,
  waterHeater,
  other,
}

class Appliance {
  const Appliance({
    required this.id,
    required this.type,
    required this.displayName,
    required this.durationMinutes,
    required this.energyKwh,
    this.reminderEnabled = false,
    this.notificationLeadMinutes = 30,
  });

  final String id;
  final ApplianceType type;
  final String displayName;
  final int durationMinutes;
  final double energyKwh;
  final bool reminderEnabled;
  final int notificationLeadMinutes;

  Appliance copyWith({
    String? id,
    ApplianceType? type,
    String? displayName,
    int? durationMinutes,
    double? energyKwh,
    bool? reminderEnabled,
    int? notificationLeadMinutes,
  }) {
    return Appliance(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      energyKwh: energyKwh ?? this.energyKwh,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notificationLeadMinutes:
          notificationLeadMinutes ?? this.notificationLeadMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'display_name': displayName,
        'duration_minutes': durationMinutes,
        'energy_kwh': energyKwh,
        'reminder_enabled': reminderEnabled,
        'notification_lead_minutes': notificationLeadMinutes,
      };

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      id: json['id'] as String,
      type: ApplianceType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ApplianceType.other,
      ),
      displayName: json['display_name'] as String,
      durationMinutes: json['duration_minutes'] as int,
      energyKwh: (json['energy_kwh'] as num).toDouble(),
      reminderEnabled: json['reminder_enabled'] as bool? ?? false,
      notificationLeadMinutes: json['notification_lead_minutes'] as int? ?? 30,
    );
  }

  static Appliance template(ApplianceType type) {
    switch (type) {
      case ApplianceType.dishwasher:
        return Appliance(
          id: '',
          type: type,
          displayName: 'Dishwasher',
          durationMinutes: 135,
          energyKwh: 1.2,
        );
      case ApplianceType.washingMachine:
        return Appliance(
          id: '',
          type: type,
          displayName: 'Washing machine',
          durationMinutes: 120,
          energyKwh: 1.0,
        );
      case ApplianceType.tumbleDryer:
        return Appliance(
          id: '',
          type: type,
          displayName: 'Tumble dryer',
          durationMinutes: 90,
          energyKwh: 2.5,
        );
      case ApplianceType.evCharger:
        return Appliance(
          id: '',
          type: type,
          displayName: 'EV charger',
          durationMinutes: 240,
          energyKwh: 15,
        );
      case ApplianceType.waterHeater:
        return Appliance(
          id: '',
          type: type,
          displayName: 'Water heater',
          durationMinutes: 180,
          energyKwh: 3.0,
        );
      case ApplianceType.other:
        return Appliance(
          id: '',
          type: type,
          displayName: 'Custom appliance',
          durationMinutes: 60,
          energyKwh: 0.5,
        );
    }
  }
}
