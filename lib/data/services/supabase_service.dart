import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/farm_model.dart';

class SupabaseService {
  static SupabaseClient? get _client =>
      AppConfig.hasSupabase ? Supabase.instance.client : null;

  static String? get userId => _client?.auth.currentUser?.id;

  // Farm operations
  static Future<FarmModel?> loadFarm() async {
    if (_client == null || userId == null) return null;
    try {
      final data = await _client!
          .from('farms')
          .select()
          .eq('user_id', userId!)
          .order('created_at')
          .limit(1)
          .maybeSingle();
      return data != null ? FarmModel.fromMap(data) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> saveFarm(FarmModel farm) async {
    if (_client == null || userId == null) return false;
    try {
      await _client!.from('farms').upsert({
        ...farm.toMap(),
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // Expenses
  static Future<List<Map<String, dynamic>>> loadExpenses(String farmId) async {
    if (_client == null) return [];
    try {
      return await _client!
          .from('farm_expenses')
          .select()
          .eq('farm_id', farmId)
          .order('expense_date', ascending: false);
    } catch (_) {
      return [];
    }
  }
}
