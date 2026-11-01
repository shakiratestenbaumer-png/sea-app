import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/appliance.dart';

class EditApplianceSheet extends StatefulWidget {
  const EditApplianceSheet({super.key, required this.appliance});

  final Appliance appliance;

  @override
  State<EditApplianceSheet> createState() => _EditApplianceSheetState();
}

class _EditApplianceSheetState extends State<EditApplianceSheet> {
  late TextEditingController _name;
  late TextEditingController _duration;
  late TextEditingController _energy;
  late int _lead;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.appliance.displayName);
    _duration =
        TextEditingController(text: '${widget.appliance.durationMinutes}');
    _energy = TextEditingController(text: '${widget.appliance.energyKwh}');
    _lead = widget.appliance.notificationLeadMinutes;
  }

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _energy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.t('edit_appliance'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.t('name')),
          ),
          TextField(
            controller: _duration,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.t('duration')),
          ),
          TextField(
            controller: _energy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.t('energy_label')),
          ),
          ListTile(
            title: Text(l10n.t('reminder_before')),
            subtitle: Text('$_lead ${l10n.t('minutes')}'),
            trailing: DropdownButton<int>(
              value: _lead,
              items: const [15, 30, 45, 60]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                  .toList(),
              onChanged: (v) => setState(() => _lead = v ?? 30),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                widget.appliance.copyWith(
                  displayName: _name.text.trim(),
                  durationMinutes: int.tryParse(_duration.text) ?? 60,
                  energyKwh: double.tryParse(_energy.text) ?? 1,
                  notificationLeadMinutes: _lead,
                ),
              );
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }
}
