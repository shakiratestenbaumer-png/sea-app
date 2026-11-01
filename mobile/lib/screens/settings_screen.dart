import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../models/household.dart';
import '../providers/app_state_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final household = ref.watch(householdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.t('language')),
            subtitle: Text(locale.languageCode.toUpperCase()),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
              ],
              onChanged: (code) {
                if (code != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(code));
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.t('household')),
            subtitle: Text(
              '${household.postalCode ?? '—'} · ${household.municipalityName ?? '—'}',
            ),
          ),
          ListTile(
            title: Text(l10n.t('provider')),
            subtitle: Text(household.providerId.toUpperCase()),
            trailing: DropdownButton<String>(
              value: household.providerId,
              items: const [
                DropdownMenuItem(value: 'ckw', child: Text('CKW')),
                DropdownMenuItem(value: 'groupe-e', child: Text('Groupe E')),
                DropdownMenuItem(value: 'primeo', child: Text('Primeo')),
              ],
              onChanged: (id) {
                if (id != null) {
                  ref.read(householdProvider.notifier).update(
                        household.copyWith(providerId: id),
                      );
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.t('postal_code')),
            subtitle: Text(household.postalCode ?? '—'),
            onTap: () => _editHousehold(context, ref, household),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.t('privacy')),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse(ApiConstants.privacyPolicyUrl)),
          ),
          ListTile(
            title: Text(l10n.t('about')),
            subtitle: Text('${l10n.t('version')} 1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _editHousehold(
    BuildContext context,
    WidgetRef ref,
    Household household,
  ) async {
    final l10n = AppLocalizations.of(context);
    final plz = TextEditingController(text: household.postalCode ?? '');
    final muni = TextEditingController(text: household.municipalityName ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('household')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plz,
              decoration: InputDecoration(labelText: l10n.t('postal_code')),
            ),
            TextField(
              controller: muni,
              decoration: InputDecoration(labelText: l10n.t('municipality')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(householdProvider.notifier).update(
                    household.copyWith(
                      postalCode: plz.text.trim(),
                      municipalityName: muni.text.trim(),
                    ),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );

    plz.dispose();
    muni.dispose();
  }
}
