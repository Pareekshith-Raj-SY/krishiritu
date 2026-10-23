import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_background.dart';
import '../providers/farm_provider.dart';

class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});
  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'My Farm');
  final _villageCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  String _district = 'Mysuru';
  String _soil = 'Red Sandy Loam';
  String _irrigation = 'Rainfed';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    if (userName != null && userName.isNotEmpty && mounted) {
      setState(() {
        _nameCtrl.text = '$userName\'s Farm';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _villageCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Set Up Your Farm'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.forestGreen,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white.withOpacity(0.92),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Farm Details'),
                    TextFormField(controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Farm Name', prefixIcon: Icon(Icons.agriculture)),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _district,
                      decoration: const InputDecoration(labelText: 'District', prefixIcon: Icon(Icons.location_city)),
                      items: AppConfig.karnatakaDistricts
                          .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _district = v!),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(controller: _villageCtrl,
                        decoration: const InputDecoration(labelText: 'Village / Hobli', prefixIcon: Icon(Icons.home_outlined))),
                    const SizedBox(height: 14),
                    TextFormField(controller: _areaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Land Area (acres)', prefixIcon: Icon(Icons.crop_square)),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          return n != null && n > 0 ? null : 'Enter valid area';
                        }),
                    const SizedBox(height: 24),
                    _sectionHeader('Soil & Irrigation'),
                    DropdownButtonFormField<String>(
                      value: _soil,
                      decoration: const InputDecoration(labelText: 'Soil Type', prefixIcon: Icon(Icons.grass)),
                      items: AppConfig.soilTypes
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _soil = v!),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _irrigation,
                      decoration: const InputDecoration(labelText: 'Irrigation Method', prefixIcon: Icon(Icons.water_drop_outlined)),
                      items: AppConfig.irrigationMethods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _irrigation = v!),
                    ),
                    const SizedBox(height: 36),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save & Continue'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_authenticated', true);
                        if (context.mounted) context.go('/home');
                      },
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
    ref.read(farmProvider.notifier).updateFarm(
      name: _nameCtrl.text, district: _district, village: _villageCtrl.text,
      landAreaAcres: double.parse(_areaCtrl.text), soilType: _soil, irrigationMethod: _irrigation,
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) context.go('/home');
  }
}
