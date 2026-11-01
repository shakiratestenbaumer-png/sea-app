import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/translations.dart';
import '../models/appliance.dart';
import '../models/household.dart';
import '../models/notification_prefs.dart';
import '../providers/app_state_providers.dart';
import '../widgets/add_appliance_dialog.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

const _swissPlz = {
  '1000': ('Lausanne', 'VD'), '1003': ('Lausanne', 'VD'),
  '1005': ('Lausanne', 'VD'), '1006': ('Lausanne', 'VD'),
  '1010': ('Lausanne', 'VD'), '1020': ('Renens', 'VD'),
  '1030': ('Bussigny', 'VD'), '1066': ('Epalinges', 'VD'),
  '1100': ('Morges', 'VD'), '1110': ('Morges', 'VD'),
  '1196': ('Gland', 'VD'), '1200': ('Genève', 'GE'),
  '1201': ('Genève', 'GE'), '1202': ('Genève', 'GE'),
  '1203': ('Genève', 'GE'), '1204': ('Genève', 'GE'),
  '1205': ('Genève', 'GE'), '1206': ('Genève', 'GE'),
  '1207': ('Genève', 'GE'), '1208': ('Genève', 'GE'),
  '1209': ('Genève', 'GE'), '1212': ('Grand-Lancy', 'GE'),
  '1227': ('Carouge', 'GE'), '1260': ('Nyon', 'VD'),
  '1400': ('Yverdon-les-Bains', 'VD'), '1700': ('Fribourg', 'FR'),
  '1950': ('Sion', 'VS'),
  '2000': ('Neuchâtel', 'NE'), '2300': ('La Chaux-de-Fonds', 'NE'),
  '2500': ('Biel/Bienne', 'BE'), '2502': ('Biel/Bienne', 'BE'),
  '3000': ('Bern', 'BE'), '3001': ('Bern', 'BE'),
  '3004': ('Bern', 'BE'), '3005': ('Bern', 'BE'),
  '3006': ('Bern', 'BE'), '3007': ('Bern', 'BE'),
  '3008': ('Bern', 'BE'), '3010': ('Bern', 'BE'),
  '3011': ('Bern', 'BE'), '3012': ('Bern', 'BE'),
  '3014': ('Bern', 'BE'), '3018': ('Bern', 'BE'),
  '3027': ('Bern', 'BE'), '3063': ('Ittigen', 'BE'),
  '3073': ('Gümligen', 'BE'), '3098': ('Köniz', 'BE'),
  '3173': ('Oberwangen', 'BE'), '3250': ('Lyss', 'BE'),
  '3400': ('Burgdorf', 'BE'), '3600': ('Thun', 'BE'),
  '3612': ('Steffisburg', 'BE'), '3700': ('Spiez', 'BE'),
  '3800': ('Interlaken', 'BE'), '3900': ('Brig', 'VS'),
  '4000': ('Basel', 'BS'), '4001': ('Basel', 'BS'),
  '4051': ('Basel', 'BS'), '4052': ('Basel', 'BS'),
  '4053': ('Basel', 'BS'), '4054': ('Basel', 'BS'),
  '4055': ('Basel', 'BS'), '4056': ('Basel', 'BS'),
  '4057': ('Basel', 'BS'), '4058': ('Basel', 'BS'),
  '4059': ('Basel', 'BS'), '4102': ('Binningen', 'BL'),
  '4123': ('Allschwil', 'BL'), '4132': ('Muttenz', 'BL'),
  '4410': ('Liestal', 'BL'), '4500': ('Solothurn', 'SO'),
  '4600': ('Olten', 'SO'), '4800': ('Zofingen', 'AG'),
  '5000': ('Aarau', 'AG'), '5001': ('Aarau', 'AG'),
  '5200': ('Brugg', 'AG'), '5400': ('Baden', 'AG'),
  '5430': ('Wettingen', 'AG'), '5600': ('Lenzburg', 'AG'),
  '6000': ('Luzern', 'LU'), '6002': ('Luzern', 'LU'),
  '6003': ('Luzern', 'LU'), '6004': ('Luzern', 'LU'),
  '6005': ('Luzern', 'LU'), '6006': ('Luzern', 'LU'),
  '6010': ('Kriens', 'LU'), '6014': ('Luzern', 'LU'),
  '6020': ('Emmenbrücke', 'LU'), '6030': ('Ebikon', 'LU'),
  '6060': ('Sarnen', 'OW'), '6300': ('Zug', 'ZG'),
  '6340': ('Baar', 'ZG'), '6370': ('Stans', 'NW'),
  '6430': ('Schwyz', 'SZ'), '6440': ('Brunnen', 'SZ'),
  '6460': ('Altdorf', 'UR'), '6500': ('Bellinzona', 'TI'),
  '6600': ('Locarno', 'TI'), '6900': ('Lugano', 'TI'),
  '6901': ('Lugano', 'TI'), '6962': ('Viganello', 'TI'),
  '7000': ('Chur', 'GR'), '7001': ('Chur', 'GR'),
  '7002': ('Chur', 'GR'), '7260': ('Davos', 'GR'),
  '7500': ('St. Moritz', 'GR'), '8000': ('Zürich', 'ZH'),
  '8001': ('Zürich', 'ZH'), '8002': ('Zürich', 'ZH'),
  '8003': ('Zürich', 'ZH'), '8004': ('Zürich', 'ZH'),
  '8005': ('Zürich', 'ZH'), '8006': ('Zürich', 'ZH'),
  '8008': ('Zürich', 'ZH'), '8032': ('Zürich', 'ZH'),
  '8037': ('Zürich', 'ZH'), '8038': ('Zürich', 'ZH'),
  '8041': ('Zürich', 'ZH'), '8044': ('Zürich', 'ZH'),
  '8045': ('Zürich', 'ZH'), '8046': ('Zürich', 'ZH'),
  '8047': ('Zürich', 'ZH'), '8048': ('Zürich', 'ZH'),
  '8049': ('Zürich', 'ZH'), '8050': ('Zürich', 'ZH'),
  '8051': ('Zürich', 'ZH'), '8052': ('Zürich', 'ZH'),
  '8053': ('Zürich', 'ZH'), '8055': ('Zürich', 'ZH'),
  '8057': ('Zürich', 'ZH'), '8063': ('Zürich', 'ZH'),
  '8064': ('Zürich', 'ZH'), '8102': ('Oberengstringen', 'ZH'),
  '8104': ('Weiningen', 'ZH'), '8105': ('Regensdorf', 'ZH'),
  '8118': ('Pfaffhausen', 'ZH'), '8152': ('Glattbrugg', 'ZH'),
  '8153': ('Rümlang', 'ZH'), '8180': ('Bülach', 'ZH'),
  '8200': ('Schaffhausen', 'SH'), '8400': ('Winterthur', 'ZH'),
  '8404': ('Winterthur', 'ZH'), '8472': ('Seuzach', 'ZH'),
  '8500': ('Frauenfeld', 'TG'), '8570': ('Weinfelden', 'TG'),
  '8600': ('Dübendorf', 'ZH'), '8610': ('Uster', 'ZH'),
  '8620': ('Wetzikon', 'ZH'), '8700': ('Küsnacht', 'ZH'),
  '8706': ('Meilen', 'ZH'), '8800': ('Thalwil', 'ZH'),
  '8810': ('Horgen', 'ZH'), '8820': ('Wädenswil', 'ZH'),
  '8840': ('Einsiedeln', 'SZ'), '8903': ('Birmensdorf', 'ZH'),
  '8910': ('Affoltern am Albis', 'ZH'), '8952': ('Schlieren', 'ZH'),
  '8953': ('Dietikon', 'ZH'), '9000': ('St. Gallen', 'SG'),
  '9001': ('St. Gallen', 'SG'), '9008': ('St. Gallen', 'SG'),
  '9014': ('St. Gallen', 'SG'), '9200': ('Gossau', 'SG'),
  '9230': ('Flawil', 'SG'), '9300': ('Wittenbach', 'SG'),
  '9400': ('Rorschach', 'SG'), '9430': ('St. Margrethen', 'SG'),
  '9500': ('Wil', 'SG'), '9620': ('Lichtensteig', 'SG'),
};

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 5;
  late int _step;
  late String _locale;
  final _plz = TextEditingController();
  String? _resolvedMunicipality;
  String? _resolvedCanton;
  bool _plzLookupAttempted = false;
  String _providerId = 'ckw';
  bool _notSure = false;
  final List<Appliance> _appliances = [];
  NotificationPrefs _notif = const NotificationPrefs();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    final hasDraft = ref.read(sharedPreferencesProvider).getString(
          StorageKeys.onboardingDraft,
        ) !=
        null;
    _step = draft.step.clamp(0, _steps - 1);
    if (hasDraft) {
      _locale = draft.localeCode;
    } else {
      final system = WidgetsBinding.instance.platformDispatcher.locale;
      _locale = supportedLocales.contains(system.languageCode)
          ? system.languageCode
          : 'de';
    }
    _plz.text = draft.household.postalCode ?? '';
    _resolvedMunicipality = draft.household.municipalityName;
    _providerId = draft.household.providerId;
    _appliances.addAll(draft.appliances);
    _notif = draft.notificationPrefs;
    if (_plz.text.trim().length == 4) {
      _applyPlzLookup(_plz.text.trim(), suggestProvider: false);
    }
  }

  String _municipalityForSave() =>
      _resolvedMunicipality?.trim() ?? '';

  void _applyPlzLookup(String plz, {bool suggestProvider = true}) {
    final entry = _swissPlz[plz];
    _resolvedMunicipality = entry?.$1;
    _resolvedCanton = entry?.$2;
    _plzLookupAttempted = plz.length == 4;
    if (suggestProvider) {
      final n = int.tryParse(plz);
      if (n != null) {
        if (n >= 6000 && n <= 6099) {
          _providerId = 'ckw';
        } else if (n >= 1700 && n <= 1799) {
          _providerId = 'groupe-e';
        } else if (n >= 4000 && n <= 4199) {
          _providerId = 'primeo';
        }
      }
    }
  }

  void _onPlzChanged(String value) {
    final plz = value.trim();
    if (plz.length == 4) {
      setState(() => _applyPlzLookup(plz));
    } else {
      setState(() {
        _resolvedMunicipality = null;
        _resolvedCanton = null;
        _plzLookupAttempted = false;
      });
    }
  }

  void _applyLocale(String code) {
    setState(() => _locale = code);
    ref.read(localeProvider.notifier).setLocale(Locale(code));
  }

  @override
  void dispose() {
    _plz.dispose();
    super.dispose();
  }

  Future<void> _persistDraft() async {
    await ref.read(onboardingDraftProvider.notifier).update(
          ref.read(onboardingDraftProvider).copyWith(
                step: _step,
                localeCode: _locale,
                household: Household(
                  postalCode: _plz.text.trim(),
                  municipalityName: _municipalityForSave(),
                  providerId: _providerId,
                ),
                appliances: _appliances,
                notificationPrefs: _notif,
              ),
        );
  }

  Future<void> _finish() async {
    final state = ref.read(onboardingDraftProvider).copyWith(
          step: _step,
          localeCode: _locale,
          household: Household(
            postalCode: _plz.text.trim(),
            municipalityName: _municipalityForSave(),
            providerId: _providerId,
          ),
          appliances: _appliances,
          notificationPrefs: _notif,
        );
    await ref.read(onboardingDraftProvider.notifier).complete(state);
    await ref.read(householdProvider.notifier).update(state.household);
    await ref.read(appliancesProvider.notifier).saveAll(state.appliances);
    await ref
        .read(notificationPrefsProvider.notifier)
        .update(state.notificationPrefs);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('app_name')),
        actions: [
          TextButton(
            onPressed: () async {
              await _finish();
            },
            child: Text(l10n.t('skip')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_step + 1) / _steps),
            const SizedBox(height: 16),
            Expanded(child: _buildStep(context, l10n)),
            Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () async {
                      setState(() => _step--);
                      await _persistDraft();
                    },
                    child: Text(l10n.t('back')),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    if (_step >= _steps - 1) {
                      await _finish();
                    } else {
                      setState(() => _step++);
                      await _persistDraft();
                    }
                  },
                  child: Text(_step >= _steps - 1 ? l10n.t('finish') : l10n.t('next')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return _stepCard(
          l10n.t('onboarding_language'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in [
                    ('de', '🇩🇪 Deutsch'),
                    ('en', '🇬🇧 English'),
                    ('fr', '🇫🇷 Français'),
                  ])
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: _locale == entry.$1,
                      onSelected: (_) => _applyLocale(entry.$1),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.t('onboarding_language_hint'),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      case 1:
        return _stepCard(
          l10n.t('onboarding_location'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _plz,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: _onPlzChanged,
                decoration: InputDecoration(labelText: l10n.t('postal_code')),
              ),
              if (_resolvedMunicipality != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_resolvedMunicipality!}${_resolvedCanton != null ? ' (${_resolvedCanton!})' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (_plzLookupAttempted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.t('plz_not_found'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        );
      case 2:
        return _stepCard(
          l10n.t('onboarding_tariff'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in ['ckw', 'groupe-e', 'primeo'])
                    ChoiceChip(
                      label: Text(id.toUpperCase()),
                      selected: _providerId == id && !_notSure,
                      onSelected: (_) => setState(() {
                        _providerId = id;
                        _notSure = false;
                      }),
                    ),
                ],
              ),
              CheckboxListTile(
                title: Text(l10n.t('not_sure')),
                value: _notSure,
                onChanged: (v) => setState(() => _notSure = v ?? false),
              ),
            ],
          ),
        );
      case 3:
        return _stepCard(
          l10n.t('onboarding_appliances'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_appliances.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.t('onboarding_appliances_hint'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
              for (var i = 0; i < _appliances.length; i++)
                Dismissible(
                  key: Key(_appliances[i].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.shade50,
                    child: Icon(Icons.delete, color: Colors.red.shade400),
                  ),
                  onDismissed: (_) => setState(() => _appliances.removeAt(i)),
                  child: ListTile(
                    leading: Icon(_applianceIcon(_appliances[i].type),
                        color: const Color(0xFF0D9488)),
                    title: Text(_appliances[i].displayName),
                    subtitle:
                        Text('${_appliances[i].durationMinutes} min · ${_appliances[i].energyKwh} kWh'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editOnboardingAppliance(i),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addOnboardingAppliance,
                icon: const Icon(Icons.add),
                label: Text(l10n.t('add_appliance')),
              ),
            ],
          ),
        );
      default:
        return _stepCard(
          l10n.t('onboarding_notifications'),
          Column(
            children: [
              SwitchListTile(
                title: Text(l10n.t('daily_summary')),
                value: _notif.dailyDigest,
                onChanged: (v) => setState(
                  () => _notif = _notif.copyWith(dailyDigest: v),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.t('quiet_hours')),
                value: _notif.enabled,
                onChanged: (v) => setState(
                  () => _notif = _notif.copyWith(enabled: v),
                ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> _addOnboardingAppliance() async {
    final result = await showDialog<Appliance>(
      context: context,
      builder: (_) => const AddApplianceDialog(),
    );
    if (result != null) {
      setState(() => _appliances.add(result));
    }
  }

  Future<void> _editOnboardingAppliance(int index) async {
    final a = _appliances[index];
    final nameCtrl = TextEditingController(text: a.displayName);
    final durationCtrl = TextEditingController(text: '${a.durationMinutes}');
    final energyCtrl = TextEditingController(text: '${a.energyKwh}');

    final result = await showDialog<Appliance>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).t('edit_appliance')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(ctx).t('name')),
              ),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppLocalizations.of(ctx).t('duration')),
              ),
              TextField(
                controller: energyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: AppLocalizations.of(ctx).t('energy_label')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              a.copyWith(
                displayName: nameCtrl.text.trim().isEmpty ? a.displayName : nameCtrl.text.trim(),
                durationMinutes: int.tryParse(durationCtrl.text) ?? a.durationMinutes,
                energyKwh: double.tryParse(energyCtrl.text) ?? a.energyKwh,
              ),
            ),
            child: Text(AppLocalizations.of(ctx).t('save')),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    durationCtrl.dispose();
    energyCtrl.dispose();

    if (result != null) {
      setState(() => _appliances[index] = result);
    }
  }

  IconData _applianceIcon(ApplianceType type) {
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
        return Icons.help_outline;
    }
  }

  Widget _stepCard(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
