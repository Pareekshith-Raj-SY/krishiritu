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

  List<Map<String, String>> _buildTaskCalendar(String crop, DateTime sow) {
    return [
      {'week': 'Week 1–2', 'task': 'Land preparation and soil testing', 'icon': '🚜'},
      {'week': 'Week 3', 'task': 'Seed treatment and sowing of $crop', 'icon': '🌱'},
      {'week': 'Week 4–6', 'task': 'First irrigation if no rain; weed control', 'icon': '💧'},
      {'week': 'Week 6–8', 'task': 'Apply basal fertilizer; monitor for pests', 'icon': '🌿'},
      {'week': 'Week 8–10', 'task': 'Second irrigation; top-dress nitrogen', 'icon': '💧'},
      {'week': 'Week 10–12', 'task': 'Pest and disease scouting; apply if needed', 'icon': '🔍'},
      {'week': 'Week 14–16', 'task': 'Pre-harvest inspection; arrange market', 'icon': '📊'},
      {'week': 'Week 16+', 'task': 'Harvest, dry, and store $crop', 'icon': '🌾'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Farm Season Twin'), backgroundColor: AppColors.forestGreen),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _profileCard(farm),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🌾 Select Crop for Season Plan', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                hint: const Text('Choose a crop'),
                decoration: const InputDecoration(labelText: 'Crop'),
                items: ['Ragi','Paddy','Maize','Jowar','Groundnut','Tur Dal','Cotton','Sunflower']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
            Card(child: Padding(
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
                color: AppColors.warmAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warmAmber.withOpacity(0.3)),
              ),
              child: const Text(
                '⚠️ This calendar is a general guide based on typical crop duration. '
                'Adjust dates based on local weather conditions and advice from your '
                'nearest Krishi Vigyan Kendra (KVK).',
                style: TextStyle(fontSize: 12, color: AppColors.earthBrown, height: 1.5),
              ),
            ),
          ],
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _profileCard(farm) {
    return Card(
      color: AppColors.forestGreen,
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
