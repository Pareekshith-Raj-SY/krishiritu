import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../models/farm_model.dart';
import '../models/crop_model.dart';

class SupabaseService {
  static String? _cachedUserId;
  static String? _cachedToken;

  static void setCachedUserId(String? id) => _cachedUserId = id;
  static void setCachedToken(String? token) => _cachedToken = token;

  /// Initialize cached credentials from persistent storage
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUserId = prefs.getString('supabase_user_id');
      _cachedToken = prefs.getString('supabase_access_token');
    } catch (_) {}
  }

  static SupabaseClient? get _client {
    if (!AppConfig.hasSupabase) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static String? get userId {
    try {
      final id = _client?.auth.currentUser?.id;
      if (id != null && id.isNotEmpty) return id;
    } catch (_) {}
    return _cachedUserId;
  }

  // Live crop catalog from Supabase
  static Future<List<CropModel>> loadCrops() async {
    if (_client != null) {
      try {
        final data = await _client!.from('crops').select();
        return (data as List).map((c) => CropModel.fromMap(c)).toList();
      } catch (_) {}
    }

    if (AppConfig.hasSupabase) {
      try {
        final res = await http.get(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/crops?select=*'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
          },
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          return list.map((c) => CropModel.fromMap(c as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return [];
  }

  /// Live remote search in Supabase crops table
  static Future<List<CropModel>> searchCrops(String query) async {
    final clean = query.trim().replaceAll('*', '').replaceAll('%', '');
    if (clean.isEmpty) return [];

    if (_client != null) {
      try {
        final data = await _client!
            .from('crops')
            .select()
            .or('name.ilike.%$clean%,name_kn.ilike.%$clean%,id.ilike.%$clean%');
        return (data as List).map((c) => CropModel.fromMap(c)).toList();
      } catch (_) {}
    }

    if (AppConfig.hasSupabase) {
      try {
        final filter = Uri.encodeComponent('(name.ilike.*$clean*,name_kn.ilike.*$clean*,id.ilike.*$clean*)');
        final res = await http.get(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/crops?or=$filter'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
          },
        ).timeout(const Duration(seconds: 6));

        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          return list.map((c) => CropModel.fromMap(c as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return [];
  }

  // Farm operations
  static Future<FarmModel?> loadFarm() async {
    final uid = userId;
    if (uid == null) return null;

    if (_client != null) {
      try {
        final data = await _client!
            .from('farms')
            .select()
            .eq('user_id', uid)
            .order('created_at')
            .limit(1)
            .maybeSingle();
        if (data != null) return FarmModel.fromMap(data);
      } catch (_) {}
    }

    if (AppConfig.hasSupabase) {
      try {
        final token = _cachedToken ?? AppConfig.supabaseAnonKey;
        final res = await http.get(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/farms?user_id=eq.$uid&order=created_at.desc&limit=1'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          if (list.isNotEmpty) {
            return FarmModel.fromMap(list.first as Map<String, dynamic>);
          }
        }
      } catch (_) {}
    }

    return null;
  }

  static Future<bool> saveFarm(FarmModel farm) async {
    final uid = userId;
    if (uid == null) return false;

    final payload = {
      ...farm.toMap(),
      'user_id': uid,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (_client != null) {
      try {
        await _client!.from('farms').upsert(payload);
        return true;
      } catch (_) {}
    }

    if (AppConfig.hasSupabase) {
      try {
        final token = _cachedToken ?? AppConfig.supabaseAnonKey;
        final res = await http.post(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/farms'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Prefer': 'resolution=merge-duplicates',
          },
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200 || res.statusCode == 201) {
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  // Expenses
  static Future<List<Map<String, dynamic>>> loadExpenses(String farmId) async {
    if (_client != null) {
      try {
        return await _client!
            .from('farm_expenses')
            .select()
            .eq('farm_id', farmId)
            .order('expense_date', ascending: false);
      } catch (_) {}
    }

    if (AppConfig.hasSupabase) {
      try {
        final token = _cachedToken ?? AppConfig.supabaseAnonKey;
        final res = await http.get(
          Uri.parse('${AppConfig.supabaseUrl}/rest/v1/farm_expenses?farm_id=eq.$farmId&order=expense_date.desc'),
          headers: {
            'apikey': AppConfig.supabaseAnonKey,
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body);
          return list.cast<Map<String, dynamic>>();
        }
      } catch (_) {}
    }

    return [];
  }
}
