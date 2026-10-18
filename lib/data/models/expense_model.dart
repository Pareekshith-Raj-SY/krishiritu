class ExpenseModel {
  final String id;
  final String farmId;
  final String userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String? season;
  final String? cropName;

  const ExpenseModel({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.season,
    this.cropName,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      farmId: map['farm_id'] ?? '',
      userId: map['user_id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      season: map['season'],
      cropName: map['crop_name'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'farm_id': farmId, 'user_id': userId, 'category': category,
    'amount': amount, 'description': description,
    'date': date.toIso8601String(), 'season': season, 'crop_name': cropName,
  };

  static const categories = [
    'Seeds', 'Fertilizer', 'Pesticide', 'Labour', 'Irrigation',
    'Equipment', 'Transport', 'Other',
  ];
}

class HarvestRecord {
  final String id;
  final String farmId;
  final String userId;
  final String cropName;
  final double quantityKg;
  final double pricePerKg;
  final DateTime harvestDate;
  final String? season;
  final String? notes;

  const HarvestRecord({
    required this.id,
    required this.farmId,
    required this.userId,
    required this.cropName,
    required this.quantityKg,
    required this.pricePerKg,
    required this.harvestDate,
    this.season,
    this.notes,
  });

  double get totalRevenue => quantityKg * pricePerKg;

  factory HarvestRecord.fromMap(Map<String, dynamic> map) {
    return HarvestRecord(
      id: map['id'] ?? '',
      farmId: map['farm_id'] ?? '',
      userId: map['user_id'] ?? '',
      cropName: map['crop_name'] ?? '',
      quantityKg: (map['quantity_kg'] ?? 0).toDouble(),
      pricePerKg: (map['price_per_kg'] ?? 0).toDouble(),
      harvestDate: DateTime.tryParse(map['harvest_date'] ?? '') ?? DateTime.now(),
      season: map['season'],
      notes: map['notes'],
    );
  }
}
