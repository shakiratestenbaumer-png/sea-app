import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.t('nav_overview'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: const Icon(Icons.kitchen),
            label: l10n.t('nav_appliances'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.compare_arrows_outlined),
            selectedIcon: const Icon(Icons.compare_arrows),
            label: l10n.t('nav_compare'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: l10n.t('nav_alerts'),
          ),
        ],
      ),
    );
  }
}
