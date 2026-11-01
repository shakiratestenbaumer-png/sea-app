import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_state_providers.dart';
import '../screens/alerts_screen.dart';
import '../screens/app_shell.dart';
import '../screens/appliances_screen.dart';
import '../screens/compare_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/overview_screen.dart';
import '../screens/settings_screen.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final _routerRefreshProvider = Provider<_RouterRefresh>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(onboardingCompleteProvider, (previous, next) => refresh.ping());
  return refresh;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/',
    redirect: (context, state) {
      final done = ref.read(onboardingCompleteProvider);
      if (!done && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (done && state.matchedLocation == '/onboarding') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appliances',
                builder: (context, state) => const AppliancesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/compare',
                builder: (context, state) => const CompareScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
