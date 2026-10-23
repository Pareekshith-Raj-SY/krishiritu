import '../models/crop_model.dart';

class CropRepository {
  static final List<CropModel> _karnatakaCrops = [
    const CropModel(
      id: 'ragi', name: 'Ragi (Finger Millet)', nameKn: 'ರಾಗಿ',
      season: 'Kharif', soilTypes: 'Red Sandy Loam, Laterite, Red Loam',
      sowingMonths: 'June, July', harvestMonths: 'October, November',
      durationDays: 120, waterNeed: 'low',
      estimatedCostPerAcre: 12000, estimatedYieldPerAcre: 800, unit: 'kg',
      irrigationMethods: 'Rainfed, Borewell',
      description: 'Ragi is a drought-tolerant millet well-suited to red and laterite soils of Karnataka. Staple food crop of Mysuru, Hassan, Tumakuru, and Mandya districts. Requires minimal inputs and is highly nutritious.',
      sourceInfo: 'KSDA Crop Calendar 2023; ICAR-IIMR variety recommendations',
      suitableDistricts: ['Mysuru','Hassan','Tumakuru','Mandya','Chikkamagaluru','Davanagere','Chitradurga','Kolar','Chikballapur','Ramanagara'],
    ),
    const CropModel(
      id: 'paddy', name: 'Paddy (Rice)', nameKn: 'ಭತ್ತ',
      season: 'Kharif', soilTypes: 'Clay, Alluvial, Black Cotton Soil',
      sowingMonths: 'June, July', harvestMonths: 'October, November',
      durationDays: 130, waterNeed: 'high',
      estimatedCostPerAcre: 22000, estimatedYieldPerAcre: 1800, unit: 'kg',
      irrigationMethods: 'Canal, Tank, Borewell',
      description: 'Paddy is a major Kharif crop in Karnataka requiring assured irrigation. Mandya, Mysuru, Hassan, and coastal Karnataka are primary production zones. High water requirement — suitable only where canal or tank irrigation is available.',
      sourceInfo: 'KSDA Crop Calendar 2023; UAS Bengaluru recommendations',
      suitableDistricts: ['Mandya','Mysuru','Hassan','Udupi','Dakshina Kannada','Shivamogga','Uttara Kannada','Raichur','Ballari'],
    ),
    const CropModel(
      id: 'maize', name: 'Maize (Corn)', nameKn: 'ಮೆಕ್ಕೆಜೋಳ',
      season: 'Kharif', soilTypes: 'Red Sandy Loam, Loamy, Alluvial',
      sowingMonths: 'June, July', harvestMonths: 'September, October',
      durationDays: 95, waterNeed: 'medium',
      estimatedCostPerAcre: 18000, estimatedYieldPerAcre: 2200, unit: 'kg',
      irrigationMethods: 'Rainfed, Drip, Borewell',
      description: 'Maize is a fast-growing Kharif crop with good market demand for poultry feed. Haveri, Davanagere, Belagavi, and Dharwad are major production districts. Suitable for medium rainfall zones (600-900 mm).',
      sourceInfo: 'KSDA Crop Calendar 2023; ICAR-IIMR maize variety guide',
      suitableDistricts: ['Haveri','Davanagere','Belagavi','Dharwad','Gadag','Chitradurga','Tumakuru','Ballari','Koppal'],
    ),
    const CropModel(
      id: 'jowar', name: 'Jowar (Sorghum)', nameKn: 'ಜೋಳ',
      season: 'Rabi', soilTypes: 'Black Cotton Soil, Red Loam, Sandy Loam',
      sowingMonths: 'October, November', harvestMonths: 'February, March',
      durationDays: 110, waterNeed: 'low',
      estimatedCostPerAcre: 10000, estimatedYieldPerAcre: 700, unit: 'kg',
      irrigationMethods: 'Rainfed, Borewell',
      description: 'Jowar is the principal Rabi dryland crop in northern Karnataka. Both grain and fodder are valuable. Well-suited to black cotton soil and semi-arid zones of Vijayapura, Kalaburagi, Raichur, and Bidar.',
      sourceInfo: 'KSDA Crop Calendar 2023; UAS Dharwad jowar recommendations',
      suitableDistricts: ['Vijayapura','Kalaburagi','Raichur','Bidar','Yadgir','Koppal','Ballari','Gadag','Dharwad','Haveri'],
    ),
    const CropModel(
      id: 'groundnut', name: 'Groundnut', nameKn: 'ಕಡಲೆ',
      season: 'Kharif', soilTypes: 'Red Sandy Loam, Sandy Loam, Loamy',
      sowingMonths: 'June, July', harvestMonths: 'September, October',
      durationDays: 105, waterNeed: 'medium',
      estimatedCostPerAcre: 16000, estimatedYieldPerAcre: 900, unit: 'kg',
      irrigationMethods: 'Rainfed, Drip, Borewell',
      description: 'Groundnut is a major oilseed crop in Karnataka. Responds well to well-drained red sandy loam soil. Kalaburagi, Ballari, Raichur, and Chitradurga districts are major producers.',
      sourceInfo: 'KSDA Crop Calendar 2023; ICRISAT groundnut guide for Karnataka',
      suitableDistricts: ['Kalaburagi','Ballari','Raichur','Chitradurga','Tumakuru','Chikballapur','Kolar','Yadgir','Koppal','Davanagere'],
    ),
    const CropModel(
      id: 'tur_dal', name: 'Tur Dal (Pigeon Pea)', nameKn: 'ತೊಗರಿ ಬೇಳೆ',
      season: 'Kharif', soilTypes: 'Red Sandy Loam, Black Cotton Soil, Loamy',
      sowingMonths: 'June, July', harvestMonths: 'December, January',
      durationDays: 180, waterNeed: 'low',
      estimatedCostPerAcre: 9000, estimatedYieldPerAcre: 500, unit: 'kg',
      irrigationMethods: 'Rainfed',
      description: 'Tur Dal is a major pulse crop in north Karnataka with assured MSP support. Drought tolerant and nitrogen-fixing. Intercropping with jowar or maize is a traditional practice in Kalaburagi division.',
      sourceInfo: 'KSDA Crop Calendar 2023; ICAR-IIPR pulse recommendations',
      suitableDistricts: ['Kalaburagi','Vijayapura','Bidar','Yadgir','Raichur','Koppal','Ballari','Chitradurga','Dharwad'],
    ),
    const CropModel(
      id: 'cotton', name: 'Cotton (Bt/Hybrid)', nameKn: 'ಹತ್ತಿ',
      season: 'Kharif', soilTypes: 'Black Cotton Soil, Deep Loamy',
      sowingMonths: 'May, June', harvestMonths: 'November, December',
      durationDays: 180, waterNeed: 'medium',
      estimatedCostPerAcre: 28000, estimatedYieldPerAcre: 800, unit: 'kg',
      irrigationMethods: 'Rainfed, Drip, Borewell',
      description: 'Cotton is a high-value Kharif cash crop best suited to deep black cotton soil. Dharwad, Gadag, Haveri, Davanagere, and Ballari are major growing districts. High input cost but profitable in good years.',
      sourceInfo: 'KSDA Crop Calendar 2023; UAS Dharwad Bt Cotton guide',
      suitableDistricts: ['Dharwad','Gadag','Haveri','Davanagere','Ballari','Raichur','Koppal','Chitradurga','Vijayapura','Belagavi'],
    ),
    const CropModel(
      id: 'sugarcane', name: 'Sugarcane', nameKn: 'ಕಬ್ಬು',
      season: 'Kharif, Year-round', soilTypes: 'Alluvial, Black Cotton Soil, Clay Loam, Deep Loamy',
      sowingMonths: 'June, July (Adsali Kharif); October, November, February', harvestMonths: 'October-March (12-14 months after planting)',
      durationDays: 365, waterNeed: 'high',
      estimatedCostPerAcre: 45000, estimatedYieldPerAcre: 35000, unit: 'kg',
      irrigationMethods: 'Canal, Drip, Borewell',
      description: 'Sugarcane is a major commercial cash crop with assured factory purchase agreements in Mandya, Belagavi, Mysuru, and Bagalkot belts. Kharif Adsali planting delivers highest tonnage. Requires assured irrigation; drip irrigation saves 35-40% water.',
      sourceInfo: 'KSDA Crop Calendar 2023; UASR Mandya Sugarcane Guide 2022',
      suitableDistricts: ['Mandya','Mysuru','Belagavi','Vijayapura','Bagalkot','Hassan','Shivamogga','Davanagere','Ballari','Kalaburagi'],
    ),
    const CropModel(
      id: 'sericulture', name: 'Sericulture (Mulberry Silk)', nameKn: 'ರೇಷ್ಮೆ ಕೃಷಿ',
      season: 'Kharif, Year-round', soilTypes: 'Red Sandy Loam, Red Loam, Clay Loam',
      sowingMonths: 'June, July, August (Monsoon mulberry planting; monthly batches)', harvestMonths: 'Year-round (every 25-30 days per batch)',
      durationDays: 365, waterNeed: 'medium',
      estimatedCostPerAcre: 35000, estimatedYieldPerAcre: 600, unit: 'kg cocoons',
      irrigationMethods: 'Borewell, Drip, Well',
      description: 'Sericulture is one of Karnataka\'s most profitable allied agricultural ventures. Ramanagara is Asia\'s largest cocoon market, with extensive farming in Mandya, Kolar, Chikballapur, and Mysuru. Mulberry variety V-1 with Bivoltine hybrid silkworms provides steady monthly cash flow.',
      sourceInfo: 'Central Silk Board Bengaluru; Karnataka Department of Sericulture 2023 Guide',
      suitableDistricts: ['Ramanagara','Mandya','Kolar','Chikballapur','Mysuru','Chamarajanagara','Tumakuru','Hassan','Bengaluru Rural'],
    ),
    const CropModel(
      id: 'marigold', name: 'Marigold (Chendu Hoo)', nameKn: 'ಚೆಂಡು ಹೂ',
      season: 'Kharif, Summer', soilTypes: 'Red Sandy Loam, Loamy, Alluvial',
      sowingMonths: 'June, July, August', harvestMonths: 'September, October, November',
      durationDays: 85, waterNeed: 'medium',
      estimatedCostPerAcre: 22000, estimatedYieldPerAcre: 4000, unit: 'kg',
      irrigationMethods: 'Drip, Borewell, Furrow',
      description: 'Marigold is a leading commercial Kharif flower crop in Karnataka, especially in Gundlupet (Chamarajanagara), Haveri, Davanagere, Kolar, and Mysuru. High demand during Dasara and Deepavali festivals. Fast yielding with first harvest within 50 days of planting.',
      sourceInfo: 'UHS Bagalkot Floriculture Calendar 2023; Karnataka Directorate of Horticulture',
      suitableDistricts: ['Chamarajanagara','Mysuru','Haveri','Davanagere','Kolar','Chikballapur','Chitradurga','Tumakuru','Bengaluru Rural','Ballari'],
    ),
    const CropModel(
      id: 'jasmine', name: 'Jasmine (Mysore Mallige)', nameKn: 'ಮಲ್ಲಿಗೆ',
      season: 'Kharif, Year-round', soilTypes: 'Red Loam, Sandy Loam, Well-drained Clay Loam',
      sowingMonths: 'June, July, August', harvestMonths: 'March to October (Daily morning plucking)',
      durationDays: 300, waterNeed: 'medium',
      estimatedCostPerAcre: 40000, estimatedYieldPerAcre: 2500, unit: 'kg',
      irrigationMethods: 'Drip, Borewell, Well',
      description: 'Jasmine (Mysore Mallige) is a prestigious GI-tagged commercial flower of Karnataka. Cultivated extensively in Mysuru, Mandya, Udupi, and Hassan. A perennial crop with 10-15 years productive lifespan offering daily morning cash revenue.',
      sourceInfo: 'UHS Bagalkot Commercial Flowers Package 2023; Karnataka Horticulture Department',
      suitableDistricts: ['Mysuru','Mandya','Hassan','Udupi','Dakshina Kannada','Shivamogga','Chikkamagaluru','Tumakuru','Bengaluru Rural'],
    ),
    const CropModel(
      id: 'chrysanthemum', name: 'Chrysanthemum (Sevanthige)', nameKn: 'ಶಾವಂತಿಗೆ',
      season: 'Kharif, Rabi', soilTypes: 'Red Sandy Loam, Well-drained Loamy, Alluvial',
      sowingMonths: 'June, July, August', harvestMonths: 'October, November, December',
      durationDays: 120, waterNeed: 'medium',
      estimatedCostPerAcre: 30000, estimatedYieldPerAcre: 3500, unit: 'kg',
      irrigationMethods: 'Drip, Borewell, Sprinkler',
      description: 'Chrysanthemum (Sevanthige) is Karnataka\'s top-selling festival and wedding loose flower. Extensively cultivated in Tumakuru, Kolar, Chikballapur, and Belagavi. Responds exceptionally well to drip fertigation and pinching techniques.',
      sourceInfo: 'IIHR Bengaluru Floriculture Guide; UHS Bagalkot 2023 recommendations',
      suitableDistricts: ['Tumakuru','Kolar','Chikballapur','Belagavi','Haveri','Dharwad','Bengaluru Rural','Chitradurga','Mysuru'],
    ),
    const CropModel(
      id: 'sunflower', name: 'Sunflower', nameKn: 'ಸೂರ್ಯಕಾಂತಿ',
      season: 'Rabi', soilTypes: 'Sandy Loam, Red Sandy Loam, Alluvial',
      sowingMonths: 'October, November', harvestMonths: 'February, March',
      durationDays: 90, waterNeed: 'medium',
      estimatedCostPerAcre: 14000, estimatedYieldPerAcre: 550, unit: 'kg',
      irrigationMethods: 'Drip, Borewell, Rainfed',
      description: 'Sunflower is a profitable short-duration Rabi oilseed crop in Karnataka. Ballari, Raichur, Koppal, and Yadgir are major producers. Short duration suits double-cropping after paddy or cotton.',
      sourceInfo: 'KSDA Crop Calendar 2023; ICAR sunflower production guide',
      suitableDistricts: ['Ballari','Raichur','Koppal','Yadgir','Kalaburagi','Chitradurga','Davanagere','Haveri','Gadag'],
    ),
    const CropModel(
      id: 'bengal_gram', name: 'Bengal Gram (Chickpea)', nameKn: 'ಕಡಲೆ ಬೇಳೆ',
      season: 'Rabi', soilTypes: 'Black Cotton Soil, Sandy Loam, Loamy',
      sowingMonths: 'October, November', harvestMonths: 'February, March',
      durationDays: 100, waterNeed: 'low',
      estimatedCostPerAcre: 11000, estimatedYieldPerAcre: 600, unit: 'kg',
      irrigationMethods: 'Rainfed, Borewell',
      description: 'Bengal Gram is a drought-tolerant Rabi pulse crop with good MSP support. Kalaburagi, Bidar, Vijayapura, and Yadgir districts are the major growing areas. Nitrogen-fixing; improves soil fertility.',
      sourceInfo: 'KSDA Crop Calendar 2023; ICAR-IIPR chickpea production guide',
      suitableDistricts: ['Kalaburagi','Bidar','Vijayapura','Yadgir','Raichur','Koppal','Ballari','Chitradurga','Dharwad'],
    ),
  ];

  List<CropModel> getAllCrops() => List.unmodifiable(_karnatakaCrops);

  List<CropModel> getCropsBySeason(String season) {
    if (season.isEmpty || season == 'All') return getAllCrops();
    final s = season.toLowerCase();
    return _karnatakaCrops
        .where((c) => c.season.toLowerCase().contains(s))
        .toList();
  }

  List<CropModel> getRecommendedCrops({
    required String district,
    required String soilType,
    required String irrigationMethod,
    required String season,
    double? budgetPerAcre,
  }) {
    final scored = _karnatakaCrops.map((crop) {
      double score = 0;
      if (crop.suitableDistricts.any((d) => d.toLowerCase() == district.toLowerCase())) {
        score += 40;
      } else {
        score += 10;
      }
      if (crop.season.toLowerCase().contains(season.toLowerCase()) || crop.season.toLowerCase().contains('year-round')) {
        score += 25;
      }
      if (crop.soilTypes.toLowerCase().contains(soilType.toLowerCase())) {
        score += 20;
      } else if (soilType.isNotEmpty) {
        score += 5;
      }
      if (irrigationMethod.toLowerCase() == 'rainfed' && crop.waterNeed == 'low') {
        score += 15;
      } else if (irrigationMethod.toLowerCase() != 'rainfed') {
        score += (crop.waterNeed == 'high' || crop.waterNeed == 'medium') ? 15 : 10;
      } else if (crop.waterNeed == 'medium') {
        score += 10;
      }
      if (budgetPerAcre != null && budgetPerAcre > 0 && crop.estimatedCostPerAcre <= budgetPerAcre) {
        score += 5;
      }
      return crop.copyWith(suitabilityScore: score);
    }).toList();
    scored.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
    return scored;
  }

  CropModel? getCropById(String id) {
    try { return _karnatakaCrops.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }
}
