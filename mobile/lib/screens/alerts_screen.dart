import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/notification_prefs.dart';
import '../providers/app_state_providers.dart';
import '../services/notification_service.dart';
import '../widgets/app_header.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool? _pushGranted;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await ref.read(notificationServiceProvider).initialize();
  }

  Future<void> _requestPush() async {
    final granted =
        await ref.read(notificationServiceProvider).requestPermission();
    setState(() => _pushGranted = granted);
    final prefs = ref.read(notificationPrefsProvider);
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(pushRegistered: granted),
        );
  }

  Future<void> _pickDigestTime(NotificationPrefs prefs) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.dailyDigestHour,
        minute: prefs.dailyDigestMinute,
      ),
    );
    if (time == null) return;
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(
            dailyDigestHour: time.hour,
            dailyDigestMinute: time.minute,
          ),
        );
  }

  Future<void> _pickQuietStart(NotificationPrefs prefs) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.quietHoursStartHour,
        minute: prefs.quietHoursStartMinute,
      ),
    );
    if (time == null) return;
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(
            quietHoursStartHour: time.hour,
            quietHoursStartMinute: time.minute,
          ),
        );
  }

  Future<void> _pickQuietEnd(NotificationPrefs prefs) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.quietHoursEndHour,
        minute: prefs.quietHoursEndMinute,
      ),
    );
    if (time == null) return;
    await ref.read(notificationPrefsProvider.notifier).update(
          prefs.copyWith(
            quietHoursEndHour: time.hour,
            quietHoursEndMinute: time.minute,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(notificationPrefsProvider);
    final pushLabel = _pushGranted ?? prefs.pushRegistered
        ? l10n.t('push_allowed')
        : l10n.t('push_denied');

    return ListView(
      children: [
        const AppHeader(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('alerts_title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(l10n.t('alerts_subtitle')),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.t('request_push')),
                subtitle: Text(pushLabel),
                trailing: FilledButton(
                  onPressed: _requestPush,
                  child: const Icon(Icons.notifications, size: 18),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.t('daily_summary')),
                value: prefs.dailyDigest,
                onChanged: (v) => ref
                    .read(notificationPrefsProvider.notifier)
                    .update(prefs.copyWith(dailyDigest: v)),
              ),
              ListTile(
                title: Text(l10n.t('daily_summary')),
                subtitle: Text(
                  '${prefs.dailyDigestHour.toString().padLeft(2, '0')}:${prefs.dailyDigestMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () => _pickDigestTime(prefs),
              ),
              ListTile(
                title: Text(l10n.t('reminder_before')),
                subtitle: Text('${prefs.reminderLeadMinutes} ${l10n.t('minutes')}'),
                trailing: DropdownButton<int>(
                  value: prefs.reminderLeadMinutes,
                  items: const [15, 30, 45, 60]
                      .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(notificationPrefsProvider.notifier).update(
                          prefs.copyWith(reminderLeadMinutes: v),
                        );
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.t('quiet_hours')),
                subtitle: Text(
                  '${prefs.quietHoursStartHour.toString().padLeft(2, '0')}:${prefs.quietHoursStartMinute.toString().padLeft(2, '0')} – '
                  '${prefs.quietHoursEndHour.toString().padLeft(2, '0')}:${prefs.quietHoursEndMinute.toString().padLeft(2, '0')}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.nightlight_round),
                      onPressed: () => _pickQuietStart(prefs),
                    ),
                    IconButton(
                      icon: const Icon(Icons.wb_sunny_outlined),
                      onPressed: () => _pickQuietEnd(prefs),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
