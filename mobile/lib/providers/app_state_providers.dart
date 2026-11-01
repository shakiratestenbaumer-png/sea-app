import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/swiss_format.dart';
import '../l10n/translations.dart';
import '../models/appliance.dart';
import '../models/household.dart';
import '../models/notification_prefs.dart';
import '../models/onboarding_state.dart';
import 'api_providers.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main');
});

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(StorageKeys.locale);
    if (saved != null) return Locale(saved);
    final system = WidgetsBinding.instance.platformDispatcher.locale;
    if (supportedLocales.contains(system.languageCode)) {
      return Locale(system.languageCode);
    }
    return const Locale('de');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.locale,
          locale.languageCode,
        );
  }
}

final onboardingCompleteProvider = StateProvider<bool>((ref) {
  return ref.read(sharedPreferencesProvider).getBool(
            StorageKeys.onboardingComplete,
          ) ??
      false;
});

final onboardingDraftProvider =
    NotifierProvider<OnboardingDraftNotifier, OnboardingState>(
  OnboardingDraftNotifier.new,
);

class OnboardingDraftNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(
          StorageKeys.onboardingDraft,
        );
    if (raw == null) return const OnboardingState();
    try {
      return OnboardingState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const OnboardingState();
    }
  }

  Future<void> update(OnboardingState draft) async {
    state = draft;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.onboardingDraft,
          jsonEncode(draft.toJson()),
        );
  }

  Future<void> complete(OnboardingState finalState) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(StorageKeys.onboardingComplete, true);
    ref.read(onboardingCompleteProvider.notifier).state = true;
    await prefs.setString(StorageKeys.household, jsonEncode(finalState.household.toJson()));
    await prefs.setString(
      StorageKeys.appliances,
      jsonEncode(finalState.appliances.map((a) => a.toJson()).toList()),
    );
    await prefs.setString(
      StorageKeys.notificationPrefs,
      jsonEncode(finalState.notificationPrefs.toJson()),
    );
    await ref.read(localeProvider.notifier).setLocale(Locale(finalState.localeCode));
    await prefs.remove(StorageKeys.onboardingDraft);
    state = finalState;
  }
}

final householdProvider = NotifierProvider<HouseholdNotifier, Household>(
  HouseholdNotifier.new,
);

class HouseholdNotifier extends Notifier<Household> {
  @override
  Household build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(StorageKeys.household);
    if (raw == null) return const Household();
    try {
      return Household.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Household();
    }
  }

  Future<void> update(Household household) async {
    state = household;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.household,
          jsonEncode(household.toJson()),
        );
  }
}

final appliancesProvider =
    NotifierProvider<AppliancesNotifier, List<Appliance>>(
  AppliancesNotifier.new,
);

class AppliancesNotifier extends Notifier<List<Appliance>> {
  @override
  List<Appliance> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(StorageKeys.appliances);
    if (raw == null) {
      return [
        Appliance(
          id: 'default-dishwasher',
          type: ApplianceType.dishwasher,
          displayName: 'Dishwasher',
          durationMinutes: 135,
          energyKwh: 1.2,
        ),
      ];
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Appliance.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Appliance> appliances) async {
    state = appliances;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.appliances,
          jsonEncode(appliances.map((a) => a.toJson()).toList()),
        );
  }

  Future<void> add(Appliance appliance) async {
    await saveAll([...state, appliance]);
  }

  Future<void> updateAppliance(Appliance appliance) async {
    await saveAll([
      for (final a in state)
        if (a.id == appliance.id) appliance else a,
    ]);
  }

  Future<void> remove(String id) async {
    await saveAll(state.where((a) => a.id != id).toList());
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(
          StorageKeys.notificationPrefs,
        );
    if (raw == null) return const NotificationPrefs();
    try {
      return NotificationPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const NotificationPrefs();
    }
  }

  Future<void> update(NotificationPrefs prefs) async {
    state = prefs;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.notificationPrefs,
          jsonEncode(prefs.toJson()),
        );
  }
}

final persistedPriceUnitProvider = NotifierProvider<PriceUnitNotifier, PriceUnit>(
  PriceUnitNotifier.new,
);

class PriceUnitNotifier extends Notifier<PriceUnit> {
  @override
  PriceUnit build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final v = prefs.getString(StorageKeys.priceUnit);
    return v == 'chf' ? PriceUnit.chf : PriceUnit.rp;
  }

  Future<void> setUnit(PriceUnit unit) async {
    state = unit;
    await ref.read(sharedPreferencesProvider).setString(
          StorageKeys.priceUnit,
          unit == PriceUnit.chf ? 'chf' : 'rp',
        );
    ref.read(priceUnitProvider.notifier).state =
        unit == PriceUnit.chf ? PriceUnitPreference.chf : PriceUnitPreference.rp;
  }
}
