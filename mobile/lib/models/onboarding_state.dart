import 'appliance.dart';
import 'household.dart';
import 'notification_prefs.dart';

class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.localeCode = 'de',
    this.household = const Household(),
    this.appliances = const [],
    this.notificationPrefs = const NotificationPrefs(),
  });

  final int step;
  final String localeCode;
  final Household household;
  final List<Appliance> appliances;
  final NotificationPrefs notificationPrefs;

  OnboardingState copyWith({
    int? step,
    String? localeCode,
    Household? household,
    List<Appliance>? appliances,
    NotificationPrefs? notificationPrefs,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      localeCode: localeCode ?? this.localeCode,
      household: household ?? this.household,
      appliances: appliances ?? this.appliances,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'locale_code': localeCode,
        'household': household.toJson(),
        'appliances': appliances.map((a) => a.toJson()).toList(),
        'notification_prefs': notificationPrefs.toJson(),
      };

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      step: json['step'] as int? ?? 0,
      localeCode: json['locale_code'] as String? ?? 'de',
      household: Household.fromJson(
        json['household'] as Map<String, dynamic>? ?? {},
      ),
      appliances: (json['appliances'] as List<dynamic>? ?? [])
          .map((e) => Appliance.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationPrefs: NotificationPrefs.fromJson(
        json['notification_prefs'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
