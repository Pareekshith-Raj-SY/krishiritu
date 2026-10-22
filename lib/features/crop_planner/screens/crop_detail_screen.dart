import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/crop_repository.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;
  const CropDetailScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    final crop = CropRepository().getCropById(cropId);
    if (crop == null) {
      return Scaffold(appBar: AppBar(title: const Text('Crop Detail')),
          body: const Center(child: Text('Crop not found')));
    }
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.forestGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.forestGreen, AppColors.leafGreen],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🌾', style: TextStyle(fontSize: 72)),
                  Text(crop.nameKn, style: const TextStyle(
                      color: Colors.white70, fontSize: 18)),
                ])),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _infoCard('🗓️ Seasonal Calendar', [
                  _row('Season', crop.season),
                  _row('Sowing Months', crop.sowingMonths),
                  _row('Harvest Months', crop.harvestMonths),
                  _row('Duration', '${crop.durationDays} days'),
                ]),
                const SizedBox(height: 12),
                _infoCard('🌱 Growing Requirements', [
                  _row('Soil Types', crop.soilTypes),
                  _row('Water Need', crop.waterNeed.toUpperCase()),
                  _row('Irrigation', crop.irrigationMethods),
                ]),
                const SizedBox(height: 12),
                _infoCard('💰 Economics (Estimates per Acre)', [
                  _row('Input Cost', '₹${crop.estimatedCostPerAcre.toStringAsFixed(0)}'),
                  _row('Expected Yield', '${crop.estimatedYieldPerAcre} ${crop.unit}'),
                  _row('Suitable Districts', crop.suitableDistricts.take(5).join(', ')),
                ]),
                const SizedBox(height: 12),
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ℹ️ About this Crop', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(crop.description, style: const TextStyle(
                        fontSize: 14, color: AppColors.textMedium, height: 1.6)),
                  ]),
                )),
                const SizedBox(height: 12),
                Card(
                  color: AppColors.paleGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('📚 Data Source', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
                      const SizedBox(height: 6),
                      Text(crop.sourceInfo, style: const TextStyle(
                          fontSize: 12, color: AppColors.textMedium)),
                      const SizedBox(height: 8),
                      const Text(
                        '⚠️ These are illustrative estimates. Actual results depend on weather, '
                        'market prices, and local conditions. Consult your nearest KVK or agricultural office.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(height: 16),
        ...rows,
      ]),
    ),
  );

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 130, child: Text('$k:', style: const TextStyle(
          color: AppColors.textMedium, fontSize: 13))),
      Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );
}
