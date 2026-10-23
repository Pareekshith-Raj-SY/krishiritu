import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../models/crop_model.dart';
import '../repositories/crop_repository.dart';

class GroqCropService {
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _primaryModel = 'openai/gpt-oss-20b';
  static const String _fallbackModel = 'qwen/qwen3.8-27b';

  // In-memory cache for zero-latency retrieval and zero duplicate API calls
  static final Map<String, CropModel> _memoryCache = {};
  static final Map<String, Future<CropModel?>> _pendingRequests = {};
  static DateTime? _lastApiCallTime;
  static const Duration _minCallInterval = Duration(milliseconds: 1500);

  final CropRepository _repo = CropRepository();

  /// Search or generate data for any crop in the world using Groq AI.
  /// Strictly checks cache and respects rate-limits.
  Future<CropModel?> searchWorldCrop(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty || cleanQuery.length < 2) return null;

    final cacheKey = cleanQuery.toLowerCase();

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      _repo.addDynamicCrop(cached);
      return cached;
    }

    // 2. Check persistent SharedPreferences cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('groq_crop_$cacheKey');
      if (savedJson != null && savedJson.isNotEmpty) {
        final map = jsonDecode(savedJson) as Map<String, dynamic>;
        final crop = CropModel.fromMap(map);
        _memoryCache[cacheKey] = crop;
        _repo.addDynamicCrop(crop);
        return crop;
      }
    } catch (_) {}

    // 3. Request Deduplication: If already fetching this query, reuse future
    if (_pendingRequests.containsKey(cacheKey)) {
      return _pendingRequests[cacheKey];
    }

    final future = _executeGroqFetch(cleanQuery, cacheKey);
    _pendingRequests[cacheKey] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  Future<CropModel?> _executeGroqFetch(String cropName, String cacheKey) async {
    // 4. Rate-limit cooldown to avoid bursting Groq limits
    if (_lastApiCallTime != null) {
      final elapsed = DateTime.now().difference(_lastApiCallTime!);
      if (elapsed < _minCallInterval) {
        await Future.delayed(_minCallInterval - elapsed);
      }
    }
    _lastApiCallTime = DateTime.now();

    var apiKey = AppConfig.groqApiKey;
    if (apiKey.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        apiKey = prefs.getString('groq_api_key') ?? '';
      } catch (_) {}
    }
    if (apiKey.isEmpty) return null;

    // Try primary model, with fallback if needed
    CropModel? crop = await _callGroq(apiKey, _primaryModel, cropName);
    crop ??= await _callGroq(apiKey, _fallbackModel, cropName);

    if (crop != null) {
      _memoryCache[cacheKey] = crop;
      _repo.addDynamicCrop(crop);

      // Persist in SharedPreferences so it's never requested from Groq again
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('groq_crop_$cacheKey', jsonEncode(crop.toMap()));
      } catch (_) {}
    }

    return crop;
  }

  Future<CropModel?> _callGroq(String apiKey, String model, String cropName) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'model': model,
          'response_format': {'type': 'json_object'},
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert global agricultural scientist. Return a structured JSON object for the requested crop. '
                  'The JSON must have the following keys:\n'
                  '- id: lowercase alphanumeric slug (e.g. "wheat", "vanilla")\n'
                  '- name: English name with common varieties (e.g. "Wheat (Triticum aestivum)")\n'
                  '- name_kn: Kannada name or transliteration (e.g. "ಗೋಧಿ")\n'
                  '- season: primary agricultural season e.g. "Rabi", "Kharif", "Summer", or "Year-round"\n'
                  '- soil_types: suitable soil types (comma-separated)\n'
                  '- sowing_months: recommended sowing months\n'
                  '- harvest_months: expected harvesting months\n'
                  '- duration_days: total crop cycle in days (integer)\n'
                  '- water_need: "low", "medium", or "high"\n'
                  '- estimated_cost_per_acre: realistic cultivation cost per acre in INR (number)\n'
                  '- estimated_yield_per_acre: expected yield per acre (number)\n'
                  '- unit: yield unit (e.g. "kg", "quintal", "tons")\n'
                  '- irrigation_methods: e.g. "Drip, Borewell, Rainfed"\n'
                  '- description: 2-3 informative sentences covering climate, cultivation, and economic importance\n'
                  '- source_info: authoritative source (e.g. "FAO / ICAR Global Agronomy Guide (Groq AI)")\n'
                  '- suitable_districts: array of 3-6 suitable districts in Karnataka or regions in India/globally\n'
                  'If the input is not a real crop or plant, return {"error": "Not a valid crop"}.',
            },
            {
              'role': 'user',
              'content': 'Crop: $cropName',
            }
          ],
          'max_tokens': 600,
          'temperature': 0.1,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = decoded['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String?;
          if (content != null && content.isNotEmpty) {
            final jsonMap = jsonDecode(content) as Map<String, dynamic>;
            if (jsonMap.containsKey('error') || !jsonMap.containsKey('name')) {
              return null;
            }
            return CropModel.fromMap(jsonMap);
          }
        }
      } else if (response.statusCode == 429) {
        // Rate limited — do not crash, back off gracefully
        return null;
      }
    } catch (_) {}
    return null;
  }
}
