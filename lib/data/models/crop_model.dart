class CropModel {
  final String id;
  final String name;
  final String nameKn;
  final String season;
  final String soilTypes;
  final String sowingMonths;
  final String harvestMonths;
  final int durationDays;
  final String waterNeed; // low/medium/high
  final double estimatedCostPerAcre;
  final double estimatedYieldPerAcre;
  final String unit;
  final String irrigationMethods;
  final String description;
  final String sourceInfo;
  final List<String> suitableDistricts;
  final double suitabilityScore;
  final String? imageUrl;

  const CropModel({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.season,
    required this.soilTypes,
    required this.sowingMonths,
    required this.harvestMonths,
    required this.durationDays,
    required this.waterNeed,
    required this.estimatedCostPerAcre,
    required this.estimatedYieldPerAcre,
    required this.unit,
    required this.irrigationMethods,
    required this.description,
    required this.sourceInfo,
    required this.suitableDistricts,
    this.suitabilityScore = 0.0,
    this.imageUrl,
  });

  factory CropModel.fromMap(Map<String, dynamic> map) {
    return CropModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameKn: map['name_kn'] ?? '',
      season: map['season'] ?? '',
      soilTypes: map['soil_types'] ?? '',
      sowingMonths: map['sowing_months'] ?? '',
      harvestMonths: map['harvest_months'] ?? '',
      durationDays: map['duration_days'] ?? 0,
      waterNeed: map['water_need'] ?? 'medium',
      estimatedCostPerAcre: (map['estimated_cost_per_acre'] ?? 0).toDouble(),
      estimatedYieldPerAcre: (map['estimated_yield_per_acre'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'kg',
      irrigationMethods: map['irrigation_methods'] ?? '',
      description: map['description'] ?? '',
      sourceInfo: map['source_info'] ?? '',
      suitableDistricts: List<String>.from(map['suitable_districts'] ?? []),
      suitabilityScore: (map['suitability_score'] ?? 0).toDouble(),
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'name_kn': nameKn, 'season': season,
    'soil_types': soilTypes, 'sowing_months': sowingMonths,
    'harvest_months': harvestMonths, 'duration_days': durationDays,
    'water_need': waterNeed, 'estimated_cost_per_acre': estimatedCostPerAcre,
    'estimated_yield_per_acre': estimatedYieldPerAcre, 'unit': unit,
    'irrigation_methods': irrigationMethods, 'description': description,
    'source_info': sourceInfo, 'suitable_districts': suitableDistricts,
  };

  CropModel copyWith({double? suitabilityScore}) => CropModel(
    id: id, name: name, nameKn: nameKn, season: season, soilTypes: soilTypes,
    sowingMonths: sowingMonths, harvestMonths: harvestMonths,
    durationDays: durationDays, waterNeed: waterNeed,
    estimatedCostPerAcre: estimatedCostPerAcre,
    estimatedYieldPerAcre: estimatedYieldPerAcre, unit: unit,
    irrigationMethods: irrigationMethods, description: description,
    sourceInfo: sourceInfo, suitableDistricts: suitableDistricts,
    suitabilityScore: suitabilityScore ?? this.suitabilityScore,
    imageUrl: imageUrl,
  );
}
