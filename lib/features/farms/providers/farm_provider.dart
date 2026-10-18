import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/models/farm_model.dart';

class FarmNotifier extends StateNotifier<FarmModel?> {
  FarmNotifier() : super(null) { _load(); }

  static const _key = 'farm_data';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      state = FarmModel.fromMap(jsonDecode(json));
    }
  }

  Future<void> updateFarm({
    String? name, String? district, String? village,
    double? landAreaAcres, String? soilType, String? irrigationMethod,
    String? currentCrop, String? previousCrop, DateTime? sowingDate,
    double? budgetPerAcre, String? farmingGoal,
  }) async {
    final current = state ?? FarmModel(
      id: 'local', userId: 'local', name: name ?? 'My Farm',
      district: district ?? '', village: village ?? '',
      landAreaAcres: landAreaAcres ?? 1.0, soilType: soilType ?? '',
      irrigationMethod: irrigationMethod ?? '', createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    state = current.copyWith(
      name: name, district: district, village: village,
      landAreaAcres: landAreaAcres, soilType: soilType,
      irrigationMethod: irrigationMethod, currentCrop: currentCrop,
      previousCrop: previousCrop, sowingDate: sowingDate,
      budgetPerAcre: budgetPerAcre, farmingGoal: farmingGoal,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state!.toMap()));
  }

  void clearFarm() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final farmProvider = StateNotifierProvider<FarmNotifier, FarmModel?>((ref) => FarmNotifier());
