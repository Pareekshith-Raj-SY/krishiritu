import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/crop_repository.dart';
import '../../../shared/localization/app_localizations.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;
  const CropDetailScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crop = CropRepository().getCropById(cropId);
    if (crop == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Crop Detail')),
        body: const Center(child: Text('Crop not found')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.forestGreen.withOpacity(0.85),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forestGreen.withOpacity(0.8),
                      AppColors.leafGreen.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(_getCropEmoji(crop.id), style: const TextStyle(fontSize: 56)),
                      Text(crop.nameKn, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
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
                  _row(l10n.t('soil_type'), l10n.translateSoilList(crop.soilTypes)),
                  _row(l10n.t('water_need'), crop.waterNeed.toUpperCase()),
                  _row(l10n.t('irrigation'), l10n.translateIrrigationList(crop.irrigationMethods)),
                ]),
                const SizedBox(height: 12),
                _infoCard('💰 Economics (Estimates per Acre)', [
                  _row('Input Cost', '₹${crop.estimatedCostPerAcre.toStringAsFixed(0)}'),
                  _row(l10n.t('yield'), '${crop.estimatedYieldPerAcre} ${crop.unit}'),
                  _row(l10n.t('suitable_districts'), crop.suitableDistricts.take(5).map((d) => l10n.translateDistrict(d)).join(', ')),
                ]),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white.withOpacity(0.92),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('ℹ️ About this Crop', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(crop.description, style: const TextStyle(
                          fontSize: 14, color: AppColors.textMedium, height: 1.6)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white.withOpacity(0.92),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.leafGreen.withOpacity(0.3)),
                  ),
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
                const SizedBox(height: 90),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) => Card(
    color: Colors.white.withOpacity(0.92),
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

  static String _getCropEmoji(String id) {
    switch (id) {
      case 'ragi': return '🌾';
      case 'paddy': return '🌾';
      case 'maize': return '🌽';
      case 'jowar': return '🌾';
      case 'groundnut': return '🥜';
      case 'tur_dal': return '🌱';
      case 'cotton': return '☁️';
      case 'sugarcane': return '🎋';
      case 'sericulture': return '🐛';
      case 'marigold': return '🌼';
      case 'jasmine': return '🌸';
      case 'chrysanthemum': return '🌻';
      case 'sunflower': return '🌻';
      case 'bengal_gram': return '🫘';
      default: return '🌱';
    }
  }
}
