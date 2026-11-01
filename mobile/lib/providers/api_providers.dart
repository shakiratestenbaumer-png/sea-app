import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/provider_data.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final providersDataProvider =
    AsyncNotifierProvider<ProvidersNotifier, AllProvidersResponse>(
  ProvidersNotifier.new,
);

class ProvidersNotifier extends AsyncNotifier<AllProvidersResponse> {
  @override
  Future<AllProvidersResponse> build() async {
    return _fetch();
  }

  Future<void> refresh({bool force = true}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(force: force));
  }

  Future<AllProvidersResponse> _fetch({bool force = false}) async {
    final client = ref.read(apiClientProvider);
    return client.fetchProviders(forceRefresh: force);
  }
}

final selectedProviderIdProvider = StateProvider<String>((ref) => 'ckw');

final priceUnitProvider = StateProvider<PriceUnitPreference>((ref) {
  return PriceUnitPreference.rp;
});

enum PriceUnitPreference { chf, rp }

enum PriceDay { today, tomorrow }

final priceDayProvider = StateProvider<PriceDay>((ref) => PriceDay.today);

final chartViewModeProvider =
    StateProvider<ChartViewMode>((ref) => ChartViewMode.compare);

enum ChartViewMode { compare, single }

final showGridOverlayProvider = StateProvider<bool>((ref) => false);
