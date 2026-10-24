import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/localization/app_localizations.dart';
import '../providers/farm_provider.dart';

class FarmProfileScreen extends ConsumerStatefulWidget {
  const FarmProfileScreen({super.key});
  @override
  ConsumerState<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends ConsumerState<FarmProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _village;
  late final TextEditingController _area;
  late final TextEditingController _budget;
  String _district = 'Mysuru';
  String _soil = 'Red Sandy Loam';
  String _irrigation = 'Rainfed';
  String _currentCrop = '';
  String _prevCrop = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final farm = ref.read(farmProvider);
    _name = TextEditingController(text: farm?.name ?? '');
    _village = TextEditingController(text: farm?.village ?? '');
    _area = TextEditingController(text: farm?.landAreaAcres.toString() ?? '2');
    _budget = TextEditingController(text: farm?.budgetPerAcre?.toStringAsFixed(0) ?? '');
    _district = AppLocalizations.canonicalDistrict(farm?.district);
    _soil = AppLocalizations.canonicalSoil(farm?.soilType);
    _irrigation = AppLocalizations.canonicalIrrigation(farm?.irrigationMethod);
    _currentCrop = farm?.currentCrop ?? '';
    _prevCrop = farm?.previousCrop ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          l10n.t('farm_profile'),
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white.withOpacity(0.88),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sec(l10n.t('farm_details')),
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: l10n.t('farm_name'),
                          prefixIcon: const Icon(Icons.agriculture),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _district,
                        decoration: InputDecoration(labelText: l10n.t('district')),
                        items: AppConfig.karnatakaDistricts
                            .map((d) => DropdownMenuItem(value: d, child: Text(l10n.translateDistrict(d))))
                            .toList(),
                        onChanged: (v) => setState(() => _district = v!),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _village,
                        decoration: InputDecoration(labelText: l10n.t('village')),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _area,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.t('land_area_acres')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white.withOpacity(0.88),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sec(l10n.t('soil_irrigation')),
                      DropdownButtonFormField<String>(
                        value: _soil,
                        decoration: InputDecoration(labelText: l10n.t('soil_type')),
                        items: AppConfig.soilTypes
                            .map((s) => DropdownMenuItem(value: s, child: Text(l10n.translateSoil(s))))
                            .toList(),
                        onChanged: (v) => setState(() => _soil = v!),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _irrigation,
                        decoration: InputDecoration(labelText: l10n.t('irrigation_method')),
                        items: AppConfig.irrigationMethods
                            .map((m) => DropdownMenuItem(value: m, child: Text(l10n.translateIrrigation(m))))
                            .toList(),
                        onChanged: (v) => setState(() => _irrigation = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white.withOpacity(0.88),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sec(l10n.t('crops_economics')),
                      TextFormField(
                        initialValue: _currentCrop,
                        onChanged: (v) => _currentCrop = v,
                        decoration: InputDecoration(labelText: l10n.t('current_crop')),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: _prevCrop,
                        onChanged: (v) => _prevCrop = v,
                        decoration: InputDecoration(labelText: l10n.t('previous_crop')),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _budget,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.t('budget_per_acre'),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : () => _save(l10n),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.t('save_profile')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.forestGreen,
      ),
    ),
  );

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => _saving = true);
    await ref.read(farmProvider.notifier).updateFarm(
      name: _name.text,
      district: _district,
      village: _village.text,
      landAreaAcres: double.tryParse(_area.text) ?? 1.0,
      soilType: _soil,
      irrigationMethod: _irrigation,
      currentCrop: _currentCrop.isEmpty ? null : _currentCrop,
      previousCrop: _prevCrop.isEmpty ? null : _prevCrop,
      budgetPerAcre: double.tryParse(_budget.text),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('farm_profile_saved'))),
      );
    }
  }
}
