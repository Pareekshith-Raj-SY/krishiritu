import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/farm_model.dart';
import '../models/expense_model.dart';

class FarmRepository {
  static const _farmKey = 'farm_data';
  static const _expensesKey = 'expenses_data';
  static const _harvestKey = 'harvest_data';

  Future<FarmModel?> loadFarm() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_farmKey);
    if (json == null) return null;
    try {
      return FarmModel.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFarm(FarmModel farm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_farmKey, jsonEncode(farm.toMap()));
  }

  Future<void> clearFarm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_farmKey);
  }

  Future<List<ExpenseModel>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_expensesKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => ExpenseModel.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    final expenses = await loadExpenses();
    expenses.add(expense);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expensesKey,
        jsonEncode(expenses.map((e) => e.toMap()).toList()));
  }

  Future<List<HarvestRecord>> loadHarvests() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_harvestKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => HarvestRecord.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
