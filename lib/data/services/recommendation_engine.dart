import '../models/crop_model.dart';
import '../models/farm_model.dart';
import '../repositories/crop_repository.dart';

class RecommendationResult {
  final CropModel crop;
  final double score;
  final List<String> reasons;
  final List<String> risks;
  final List<String> missingInfo;

  const RecommendationResult({
    required this.crop,
    required this.score,
    required this.reasons,
    required this.risks,
    required this.missingInfo,
  });
}

class RecommendationEngine {
  final _repo = CropRepository();

  List<RecommendationResult> getRecommendations(FarmModel farm, String season) {
    final crops = _repo.getRecommendedCrops(
      district: farm.district,
      soilType: farm.soilType,
      irrigationMethod: farm.irrigationMethod,
      season: season,
      budgetPerAcre: farm.budgetPerAcre,
    );

    return crops.map((crop) {
      final reasons = <String>[];
      final risks = <String>[];
      final missing = <String>[];

      // Build reasons
      if (crop.suitableDistricts.any(
          (d) => d.toLowerCase() == farm.district.toLowerCase())) {
        reasons.add('${farm.district} is a recognized production district for ${crop.name}');
      }
      if (crop.soilTypes.toLowerCase().contains(farm.soilType.toLowerCase())) {
        reasons.add('${farm.soilType} soil is well-suited for this crop');
      }
      if (farm.irrigationMethod == 'Rainfed' && crop.waterNeed == 'low') {
        reasons.add('Low water need matches your rainfed irrigation');
      } else if (farm.irrigationMethod != 'Rainfed' && crop.waterNeed == 'high') {
        reasons.add('${farm.irrigationMethod} supports this water-intensive crop');
      }
      if (farm.budgetPerAcre != null &&
          crop.estimatedCostPerAcre <= farm.budgetPerAcre!) {
        reasons.add('Estimated cost fits within your ₹${farm.budgetPerAcre!.toStringAsFixed(0)}/acre budget');
      }

      // Build risks
      if (crop.waterNeed == 'high' && farm.irrigationMethod == 'Rainfed') {
        risks.add('High water crop with rainfed irrigation — risky in drought years');
      }
      if (crop.id == 'cotton') {
        risks.add('Bollworm and whitefly management critical — monitor weekly');
        risks.add('High input cost; budget carefully');
      }
      if (crop.id == 'paddy') {
        risks.add('Requires assured water supply throughout season');
        risks.add('Stem borer and blast disease monitoring essential');
      }
      if (crop.id == 'sugarcane') {
        risks.add('High water and fertilizer requirement throughout growth cycle');
        risks.add('Red rot and early shoot borer surveillance recommended');
      }
      if (crop.id == 'sericulture') {
        risks.add('Strict temperature and hygiene control required in rearing house');
        risks.add('Uzi fly netting and grasserie disease prevention essential');
      }
      if (crop.id == 'marigold') {
        risks.add('Market price fluctuations around festive peaks; harvest on schedule');
        risks.add('Monitor bud borer and Alternaria leaf spot during rainy intervals');
      }
      if (crop.id == 'jasmine') {
        risks.add('Requires daily early morning labor for flower plucking');
        risks.add('Watch for blossom midge and red spider mite damage');
      }
      if (crop.id == 'chrysanthemum') {
        risks.add('Vulnerable to collar rot and wilt if drainage is poor');
        risks.add('Regular pinching and aphid control needed for flower density');
      }
      if (crop.durationDays > 150) {
        risks.add('Long-duration crop — plan for late-season water and input needs');
      }

      // Build missing info
      if (farm.budgetPerAcre == null) {
        missing.add('Your budget per acre (add in Farm Profile for better matching)');
      }
      if (farm.currentCrop == null) {
        missing.add('Previous crop information (helps assess soil nitrogen levels)');
      }

      if (reasons.isEmpty) {
        reasons.add('General crop suitable for Karnataka conditions');
      }

      return RecommendationResult(
        crop: crop, score: crop.suitabilityScore,
        reasons: reasons, risks: risks, missingInfo: missing,
      );
    }).toList();
  }
}
