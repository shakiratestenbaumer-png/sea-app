import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/appliance.dart';

class AddApplianceDialog extends StatefulWidget {
  const AddApplianceDialog({super.key});

  @override
  State<AddApplianceDialog> createState() => _AddApplianceDialogState();
}

class _AddApplianceDialogState extends State<AddApplianceDialog> {
  ApplianceType _type = ApplianceType.dishwasher;
  late TextEditingController _name;
  late TextEditingController _duration;
  late TextEditingController _energy;

  @override
  void initState() {
    super.initState();
    final t = Appliance.template(_type);
    _name = TextEditingController(text: t.displayName);
    _duration = TextEditingController(text: '${t.durationMinutes}');
    _energy = TextEditingController(text: '${t.energyKwh}');
  }

  void _applyTemplate(ApplianceType type) {
    final t = Appliance.template(type);
    setState(() {
      _type = type;
      if (type != ApplianceType.other) {
        _name.text = t.displayName;
      } else {
        _name.text = '';
      }
      _duration.text = '${t.durationMinutes}';
      _energy.text = '${t.energyKwh}';
    });
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

    return AlertDialog(
      title: Text(l10n.t('add_appliance')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector as chips
            Text(
              l10n.t('name'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplianceType.values.map((type) {
                final isSelected = _type == type;
                return ChoiceChip(
                  avatar: Icon(
                    _typeIcon(type),
                    size: 18,
                    color: isSelected ? Colors.white : const Color(0xFF0D9488),
                  ),
                  label: Text(_typeLabel(l10n, type)),
                  selected: isSelected,
                  onSelected: (_) => _applyTemplate(type),
                  selectedColor: const Color(0xFF0D9488),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom name field
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.t('custom_name'),
                hintText: l10n.t('custom_name_hint'),
                prefixIcon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            // Duration
            TextField(
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${l10n.t('duration')} (${l10n.t('minutes')})',
                prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                suffixText: l10n.t('min'),
              ),
            ),
            const SizedBox(height: 12),

            // Energy
            TextField(
              controller: _energy,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.t('power_consumption'),
                prefixIcon: const Icon(Icons.bolt_outlined, size: 20),
                suffixText: l10n.t('kwh'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            final appliance = Appliance(
              id: const Uuid().v4(),
              type: _type,
              displayName: name,
              durationMinutes: int.tryParse(_duration.text) ?? 60,
              energyKwh: double.tryParse(_energy.text) ?? 1,
            );
            Navigator.pop(context, appliance);
          },
          child: Text(l10n.t('save')),
        ),
      ],
    );
  }

  String _typeLabel(AppLocalizations l10n, ApplianceType type) {
    switch (type) {
      case ApplianceType.dishwasher:
        return l10n.t('dishwasher');
      case ApplianceType.washingMachine:
        return l10n.t('washing_machine');
      case ApplianceType.tumbleDryer:
        return l10n.t('tumble_dryer');
      case ApplianceType.evCharger:
        return l10n.t('ev_charger');
      case ApplianceType.waterHeater:
        return l10n.t('water_heater');
      case ApplianceType.other:
        return l10n.t('other');
    }
  }

  IconData _typeIcon(ApplianceType type) {
    switch (type) {
      case ApplianceType.dishwasher:
        return Icons.countertops_outlined;
      case ApplianceType.washingMachine:
        return Icons.local_laundry_service_outlined;
      case ApplianceType.tumbleDryer:
        return Icons.dry_cleaning;
      case ApplianceType.evCharger:
        return Icons.electric_car_outlined;
      case ApplianceType.waterHeater:
        return Icons.water_drop_outlined;
      case ApplianceType.other:
        return Icons.devices_other_outlined;
    }
  }
}
