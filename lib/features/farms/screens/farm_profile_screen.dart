import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
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
    _district = farm?.district ?? 'Mysuru';
    _soil = farm?.soilType ?? 'Red Sandy Loam';
    _irrigation = farm?.irrigationMethod ?? 'Rainfed';
    _currentCrop = farm?.currentCrop ?? '';
    _prevCrop = farm?.previousCrop ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Farm Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        child: Card(
          color: Colors.white.withOpacity(0.92),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sec('Farm Details'),
                  TextFormField(controller: _name,
                      decoration: const InputDecoration(labelText: 'Farm Name',
                          prefixIcon: Icon(Icons.agriculture))),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _district,
                    decoration: const InputDecoration(labelText: 'District'),
                    items: AppConfig.karnatakaDistricts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _district = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(controller: _village,
                      decoration: const InputDecoration(labelText: 'Village')),
                  const SizedBox(height: 14),
                  TextFormField(controller: _area, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Land Area (acres)')),
                  const SizedBox(height: 24),
                  _sec('Soil & Irrigation'),
                  DropdownButtonFormField<String>(
                    value: _soil,
                    decoration: const InputDecoration(labelText: 'Soil Type'),
                    items: AppConfig.soilTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _soil = v!),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _irrigation,
                    decoration: const InputDecoration(labelText: 'Irrigation Method'),
                    items: AppConfig.irrigationMethods
                        .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setState(() => _irrigation = v!),
                  ),
                  const SizedBox(height: 24),
                  _sec('Crops'),
                  TextFormField(
                    initialValue: _currentCrop,
                    onChanged: (v) => _currentCrop = v,
                    decoration: const InputDecoration(labelText: 'Current Crop'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: _prevCrop,
                    onChanged: (v) => _prevCrop = v,
                    decoration: const InputDecoration(labelText: 'Previous Crop'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(controller: _budget, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget per Acre (₹)',
                          prefixIcon: Icon(Icons.currency_rupee))),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(t, style: const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(farmProvider.notifier).updateFarm(
      name: _name.text, district: _district, village: _village.text,
      landAreaAcres: double.tryParse(_area.text) ?? 1.0,
      soilType: _soil, irrigationMethod: _irrigation,
      currentCrop: _currentCrop.isEmpty ? null : _currentCrop,
      previousCrop: _prevCrop.isEmpty ? null : _prevCrop,
      budgetPerAcre: double.tryParse(_budget.text),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm profile saved!')));
    }
  }
}
