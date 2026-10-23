import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/providers/farm_provider.dart';

class SeasonTwinScreen extends ConsumerStatefulWidget {
  const SeasonTwinScreen({super.key});
  @override
  ConsumerState<SeasonTwinScreen> createState() => _SeasonTwinScreenState();
}

class _SeasonTwinScreenState extends ConsumerState<SeasonTwinScreen> {
  String? _selectedCrop;
  DateTime _sowDate = DateTime.now();

  List<Map<String, String>> _buildTaskCalendar(String crop, DateTime sowDate) {
    if (crop.contains('Sugarcane')) {
      return [
        {'week': 'Month 1', 'task': 'Land preparation, furrow making, sett treatment with fungicide, planting', 'icon': '🚜'},
        {'week': 'Month 2', 'task': 'First weeding, gap filling, first earthing up & shoot borer scouting', 'icon': '🌱'},
        {'week': 'Month 3–4', 'task': 'Top dressing (Urea/Potash), second earthing up, trash mulching', 'icon': '🌿'},
        {'week': 'Month 5–8', 'task': 'Grand growth phase — regular irrigation every 8-10 days, propping & detrashing', 'icon': '🎋'},
        {'week': 'Month 9–11', 'task': 'Sucrose accumulation & ripening — taper down irrigation, stop nitrogen', 'icon': '💧'},
        {'week': 'Month 12–14', 'task': 'Brix refractometer check (18-20%), harvest cane close to ground, mill delivery', 'icon': '🏭'},
      ];
    }
    if (crop.contains('Sericulture')) {
      return [
        {'week': 'Week 1–2', 'task': 'Mulberry garden pruning, FYM application, irrigation, rearing room 2% bleach disinfection', 'icon': '🚜'},
        {'week': 'Week 3–4', 'task': 'Procure disease-free Chawki (2nd instar) silkworm larvae; set up rearing beds', 'icon': '🐛'},
        {'week': 'Week 5–6', 'task': '3rd & 4th instar feeding with fresh mulberry leaves, bed cleaning, Vijetha dusting', 'icon': '🍃'},
        {'week': 'Week 7', 'task': '5th instar voracious feeding stage; ensure good ventilation and Uzi fly netting', 'icon': '🔬'},
        {'week': 'Week 8', 'task': 'Mounting mature worms on Chandrike spinning frames; 3-4 days cocoon spinning', 'icon': '🧵'},
        {'week': 'Week 9+', 'task': 'Harvest cocoons, deflossing, sorting, transport to Govt Cocoon Market (Ramanagara)', 'icon': '💰'},
      ];
    }
    if (crop.contains('Marigold')) {
      return [
        {'week': 'Week 1–2', 'task': 'Raised bed preparation, FYM incorporation, seedling transplanting in evening', 'icon': '🚜'},
        {'week': 'Week 3–4', 'task': 'Gap filling, weeding, terminal shoot pinching (apical bud removal for bushy growth)', 'icon': '✂️'},
        {'week': 'Week 5–6', 'task': 'Drip fertigation / top dressing, bud borer inspection, neem oil 3% spray', 'icon': '💧'},
        {'week': 'Week 7–8', 'task': 'Flower bud swelling stage, micronutrient foliar spray, soil moisture management', 'icon': '🌱'},
        {'week': 'Week 9–12', 'task': 'Peak flower harvest early morning every 3-4 days for festival market (Dasara/Diwali)', 'icon': '🌼'},
        {'week': 'Week 13+', 'task': 'Post-harvest irrigation, second flush harvesting or field clearance', 'icon': '🧺'},
      ];
    }
    if (crop.contains('Jasmine')) {
      return [
        {'week': 'Week 1–2', 'task': 'Annual pruning of previous wood, basal FYM and fertilizer application around basin', 'icon': '✂️'},
        {'week': 'Week 3–4', 'task': 'New vegetative flush initiation; irrigate every 5-7 days; weed basin area', 'icon': '🌱'},
        {'week': 'Week 5–6', 'task': 'Flower bud initiation; prophylactic spray against blossom midge and spider mites', 'icon': '🔬'},
        {'week': 'Week 7+', 'task': 'Daily morning manual plucking of mature unopened white buds for mandi / garlands', 'icon': '🌸'},
      ];
    }
    if (crop.contains('Chrysanthemum')) {
      return [
        {'week': 'Week 1–2', 'task': 'Raised bed preparation, root sucker transplanting, immediate light irrigation', 'icon': '🚜'},
        {'week': 'Week 3–4', 'task': 'First pinching of main terminal shoot to stimulate profuse branch development', 'icon': '✂️'},
        {'week': 'Week 5–7', 'task': 'Second pinching, plant staking, prophylactic spray for aphids and rust', 'icon': '🌿'},
        {'week': 'Week 8–10', 'task': 'Bud emergence stage; balanced fertigation; ensure well-drained bed conditions', 'icon': '💧'},
        {'week': 'Week 11–16', 'task': 'Harvest fully opened flowers with stalks early morning; crate packaging for APMC', 'icon': '🌻'},
      ];
    }
    return [
      {'week': 'Week 1–2', 'task': 'Land preparation, basal fertilizer, sowing of $crop', 'icon': '🚜'},
      {'week': 'Week 3–4', 'task': 'First weeding, gap filling, thinning', 'icon': '🌱'},
      {'week': 'Week 5–6', 'task': 'First top dressing (Urea/Potash), irrigation monitoring', 'icon': '💧'},
      {'week': 'Week 7–8', 'task': 'Pest/disease scouting — look out for shoot fly / stem borer', 'icon': '🔬'},
      {'week': 'Week 9–10', 'task': 'Second top dressing at flowering stage', 'icon': '🌸'},
      {'week': 'Week 11–13', 'task': 'Grain filling / pod formation — critical water stage', 'icon': '🌾'},
      {'week': 'Week 14–15', 'task': 'Pre-harvest inspection, stop irrigation', 'icon': '☀️'},
      {'week': 'Week 16+', 'task': 'Harvest, dry, and store $crop', 'icon': '🌾'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Farm Season Twin'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _profileCard(farm),
          const SizedBox(height: 16),
          Card(
            color: Colors.white.withOpacity(0.92),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🌾 Select Crop for Season Plan', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                hint: const Text('Choose a crop'),
                decoration: const InputDecoration(labelText: 'Crop'),
                items: [
                  'Ragi',
                  'Paddy',
                  'Maize',
                  'Jowar',
                  'Groundnut',
                  'Tur Dal',
                  'Cotton',
                  'Sugarcane',
                  'Sericulture (Mulberry)',
                  'Marigold (Flower)',
                  'Jasmine (Flower)',
                  'Chrysanthemum (Flower)',
                  'Sunflower',
                  'Bengal Gram',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCrop = v),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Planned Sowing Date', style: TextStyle(fontSize: 14)),
                subtitle: Text('${_sowDate.day}/${_sowDate.month}/${_sowDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.leafGreen),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _sowDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (d != null) setState(() => _sowDate = d);
                  },
                ),
              ),
            ]),
          )),
          if (_selectedCrop != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.92),
              child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📅 Task Calendar — $_selectedCrop',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Planned sow: ${_sowDate.day}/${_sowDate.month}/${_sowDate.year}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                const Divider(height: 20),
                ..._buildTaskCalendar(_selectedCrop!, _sowDate).map((t) => _taskRow(t)),
              ]),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warmAmber.withOpacity(0.5)),
              ),
              child: const Text(
                '⚠️ This calendar is a general guide based on typical crop duration. '
                'Adjust dates based on local weather conditions and advice from your '
                'nearest Krishi Vigyan Kendra (KVK).',
                style: TextStyle(fontSize: 12, color: AppColors.earthBrown, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _profileCard(farm) {
    return Card(
      color: AppColors.forestGreen.withOpacity(0.88),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏡 Farm Digital Profile', style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (farm != null) ...[
            _pRow('District', farm.district),
            _pRow('Soil', farm.soilType),
            _pRow('Irrigation', farm.irrigationMethod),
            _pRow('Area', '${farm.landAreaAcres} acres'),
          ] else
            const Text('Set up your farm profile to get personalized recommendations.',
                style: TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }

  Widget _pRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 90, child: Text('$k:', style: const TextStyle(color: Colors.white70, fontSize: 13))),
      Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );

  Widget _taskRow(Map<String, String> t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t['icon']!, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t['week']!, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.leafGreen)),
        Text(t['task']!, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      ])),
    ]),
  );
}
