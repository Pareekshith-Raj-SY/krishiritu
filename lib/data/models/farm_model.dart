class FarmModel {
  final String id;
  final String userId;
  final String name;
  final String district;
  final String village;
  final double landAreaAcres;
  final String soilType;
  final String irrigationMethod;
  final String? currentCrop;
  final String? previousCrop;
  final DateTime? sowingDate;
  final double? latitude;
  final double? longitude;
  final double? budgetPerAcre;
  final String? farmingGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.district,
    required this.village,
    required this.landAreaAcres,
    required this.soilType,
    required this.irrigationMethod,
    this.currentCrop,
    this.previousCrop,
    this.sowingDate,
    this.latitude,
    this.longitude,
    this.budgetPerAcre,
    this.farmingGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmModel.fromMap(Map<String, dynamic> map) {
    return FarmModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      district: map['district'] ?? '',
      village: map['village'] ?? '',
      landAreaAcres: (map['land_area_acres'] ?? 0).toDouble(),
      soilType: map['soil_type'] ?? '',
      irrigationMethod: map['irrigation_method'] ?? '',
      currentCrop: map['current_crop'],
      previousCrop: map['previous_crop'],
      sowingDate: map['sowing_date'] != null
          ? DateTime.tryParse(map['sowing_date'])
          : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      budgetPerAcre: map['budget_per_acre']?.toDouble(),
      farmingGoal: map['farming_goal'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'user_id': userId, 'name': name, 'district': district,
    'village': village, 'land_area_acres': landAreaAcres, 'soil_type': soilType,
    'irrigation_method': irrigationMethod, 'current_crop': currentCrop,
    'previous_crop': previousCrop,
    'sowing_date': sowingDate?.toIso8601String(),
    'latitude': latitude, 'longitude': longitude,
    'budget_per_acre': budgetPerAcre, 'farming_goal': farmingGoal,
  };

  FarmModel copyWith({
    String? name, String? district, String? village, double? landAreaAcres,
    String? soilType, String? irrigationMethod, String? currentCrop,
    String? previousCrop, DateTime? sowingDate, double? budgetPerAcre,
    String? farmingGoal,
  }) {
    return FarmModel(
      id: id, userId: userId, name: name ?? this.name,
      district: district ?? this.district, village: village ?? this.village,
      landAreaAcres: landAreaAcres ?? this.landAreaAcres,
      soilType: soilType ?? this.soilType,
      irrigationMethod: irrigationMethod ?? this.irrigationMethod,
      currentCrop: currentCrop ?? this.currentCrop,
      previousCrop: previousCrop ?? this.previousCrop,
      sowingDate: sowingDate ?? this.sowingDate, latitude: latitude,
      longitude: longitude, budgetPerAcre: budgetPerAcre ?? this.budgetPerAcre,
      farmingGoal: farmingGoal ?? this.farmingGoal,
      createdAt: createdAt, updatedAt: DateTime.now(),
    );
  }
}
