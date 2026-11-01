import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../l10n/app_localizations.dart';

class TrustFooter extends StatelessWidget {
  const TrustFooter({super.key, this.lastRefresh});

  final DateTime? lastRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final refresh = lastRefresh != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(lastRefresh!.toLocal())
        : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('trust_footer'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.t('last_refresh')}: $refresh',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse(ApiConstants.privacyPolicyUrl)),
            child: Text(l10n.t('privacy')),
          ),
        ],
      ),
    );
  }
}
