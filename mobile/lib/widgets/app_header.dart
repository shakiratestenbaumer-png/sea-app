import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_state_providers.dart';
import '../providers/api_providers.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(householdProvider);
    final providersAsync = ref.watch(providersDataProvider);
    final locale = ref.watch(localeProvider);

    final providerName = providersAsync.maybeWhen(
      data: (data) {
        final p = data.providers
            .where((e) => e.id == household.providerId)
            .firstOrNull;
        return p?.name ?? household.providerId.toUpperCase();
      },
      orElse: () => household.providerId.toUpperCase(),
    );

    final locationLabel = household.municipalityName?.isNotEmpty == true
        ? '${household.postalCode ?? ''} ${household.municipalityName}'.trim()
        : l10n.t('location');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/icon.png', width: 36, height: 36),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('app_name'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$locationLabel · $providerName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Text(locale.languageCode.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onSelected: (code) {
              ref.read(localeProvider.notifier).setLocale(Locale(code));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'de', child: Text('Deutsch')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'fr', child: Text('Français')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
