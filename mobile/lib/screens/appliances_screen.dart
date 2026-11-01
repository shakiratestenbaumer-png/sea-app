import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/api_providers.dart';
import '../providers/app_state_providers.dart';
import '../widgets/add_appliance_dialog.dart';
import '../widgets/appliance_card.dart';
import '../widgets/app_header.dart';
import '../widgets/edit_appliance_sheet.dart';

class AppliancesScreen extends ConsumerWidget {
  const AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appliances = ref.watch(appliancesProvider);
    final providersAsync = ref.watch(providersDataProvider);
    final household = ref.watch(householdProvider);

    final provider = providersAsync.maybeWhen(
      data: (data) => data.providers
          .where((p) => p.id == household.providerId && p.isOk)
          .firstOrNull,
      orElse: () => null,
    );

    return ListView(
      children: [
        const AppHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('appliances_title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                l10n.t('appliances_subtitle'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        for (final a in appliances)
          ApplianceCard(
            appliance: a,
            provider: provider,
            onEdit: () async {
              final updated = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => EditApplianceSheet(appliance: a),
              );
              if (updated != null) {
                await ref
                    .read(appliancesProvider.notifier)
                    .updateAppliance(updated);
              }
            },
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () async {
              final created = await showDialog(
                context: context,
                builder: (_) => const AddApplianceDialog(),
              );
              if (created != null) {
                await ref.read(appliancesProvider.notifier).add(created);
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.t('add_appliance')),
          ),
        ),
      ],
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
