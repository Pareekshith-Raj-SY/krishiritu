import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/providers/farm_provider.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Weather & Seasonal Risk'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _apiNotice(),
          const SizedBox(height: 16),
          _seasonalRisk(farm?.district ?? 'Karnataka'),
          const SizedBox(height: 16),
          _riskCalendar(),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _apiNotice() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.skyBlue.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Text('🌤️', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Live Weather', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.skyBlue)),
        Text('Configure OPENWEATHER_API_KEY in your .env file to enable live weather data for your farm location.',
            style: TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4)),
      ])),
    ]),
  );

  Widget _seasonalRisk(String district) {
    final month = DateTime.now().month;
    final risks = _getRisks(month);
    return Card(
      color: Colors.white.withOpacity(0.92),
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📍 Seasonal Risks — $district', style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Based on typical Karnataka conditions for ${_monthName(month)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        const Divider(height: 20),
        ...risks.map((r) => _riskRow(r)),
      ]),
    ));
  }

  List<Map<String, String>> _getRisks(int month) {
    if (month >= 6 && month <= 9) {
      return [
        {'icon': '🌧️', 'risk': 'Heavy Monsoon Rainfall', 'level': 'High', 'action': 'Ensure field drainage; delay sowing if waterlogged'},
        {'icon': '🍄', 'risk': 'Fungal Diseases (Blast, Blight)', 'level': 'High', 'action': 'Monitor crop; apply fungicide preventively'},
        {'icon': '🐛', 'risk': 'Stem Borer Activity', 'level': 'Medium', 'action': 'Deploy pheromone traps; scout weekly'},
      ];
    }
    if (month >= 10 && month <= 11) {
      return [
        {'icon': '🌾', 'risk': 'Kharif Harvest Period', 'level': 'Low', 'action': 'Plan harvest; arrange drying and storage space'},
        {'icon': '💨', 'risk': 'North-East Monsoon', 'level': 'Medium', 'action': 'Watch for unseasonal rains during harvest'},
        {'icon': '🌱', 'risk': 'Rabi Sowing Window', 'level': 'Low', 'action': 'Prepare land; procure Rabi seed varieties'},
      ];
    }
    if (month >= 12 || month <= 2) {
      return [
        {'icon': '❄️', 'risk': 'Cold Nights (< 10°C in north Karnataka)', 'level': 'Medium', 'action': 'Protect nursery beds; delay transplanting during cold spells'},
        {'icon': '💧', 'risk': 'Irrigation Dependency', 'level': 'High', 'action': 'Ensure water availability; use drip for efficiency'},
      ];
    }
    return [
      {'icon': '☀️', 'risk': 'Heat Stress', 'level': 'High', 'action': 'Irrigate in evening; use mulching to retain moisture'},
      {'icon': '💧', 'risk': 'Water Scarcity', 'level': 'High', 'action': 'Only rainfed crops; conserve water strictly'},
    ];
  }

  Widget _riskRow(Map<String, String> r) {
    final levelColor = r['level'] == 'High' ? AppColors.errorRed :
        r['level'] == 'Medium' ? AppColors.warmAmber : AppColors.leafGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r['icon']!, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(r['risk']!, style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(r['level']!, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: levelColor)),
            ),
          ]),
          const SizedBox(height: 3),
          Text(r['action']!, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ])),
      ]),
    );
  }

  Widget _riskCalendar() => Card(
    color: Colors.white.withOpacity(0.92),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📅 Karnataka Crop Risk Calendar', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ..._calendarRows(),
    ]),
  ));

  List<Widget> _calendarRows() {
    final rows = [
      ('June–July', 'Kharif sowing; monsoon onset; flood risk in lowlands'),
      ('August', 'Peak monsoon; disease pressure high; waterlogging in clay soils'),
      ('September', 'Late monsoon; blast risk in ragi/paddy; check drainage'),
      ('October', 'Monsoon withdrawal; kharif harvest begins; rabi preparation'),
      ('November–February', 'Rabi season; fog/cold in north KA; irrigation critical'),
      ('March–May', 'Summer crops only; extreme heat; borewell water stress'),
    ];
    return rows.map((r) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(r.$1, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.leafGreen))),
        Expanded(child: Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.textMedium))),
      ]),
    )).toList();
  }

  String _monthName(int m) => ['', 'January','February','March','April','May','June',
      'July','August','September','October','November','December'][m];
}
