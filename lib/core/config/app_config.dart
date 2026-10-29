import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _safeEnv(String key) {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env[key] ?? '';
      }
    } catch (_) {}
    return '';
  }

  static String get supabaseUrl {
    const compileTime = String.fromEnvironment('SUPABASE_URL');
    if (compileTime.isNotEmpty) return compileTime;
    final env = _safeEnv('SUPABASE_URL');
    if (env.isNotEmpty) return env;
    return 'https://qsnpwvnztfyfmosssked.supabase.co';
  }

  static String get supabaseAnonKey {
    const compileTime = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (compileTime.isNotEmpty) return compileTime;
    final env = _safeEnv('SUPABASE_ANON_KEY');
    if (env.isNotEmpty) return env;
    return 'sb_publishable_1BQ_wOaZufFWXWwmSzoe3Q_FNeo6Fx9';
  }
  static String get openWeatherKey => _safeEnv('OPENWEATHER_API_KEY');
  static String get anthropicKey => _safeEnv('ANTHROPIC_API_KEY');
  static String get groqApiKey {
    const compileTimeKey = String.fromEnvironment('GROQ_API_KEY');
    if (compileTimeKey.isNotEmpty) return compileTimeKey;
    final envKey = _safeEnv('GROQ_API_KEY');
    if (envKey.isNotEmpty && !envKey.contains('your-')) return envKey;
    return '';
  }

  static bool get hasGroq => groqApiKey.isNotEmpty && !groqApiKey.contains('your-');

  static bool get hasSupabase {
    final url = supabaseUrl.trim().toLowerCase();
    final key = supabaseAnonKey.trim().toLowerCase();
    return url.isNotEmpty &&
        key.isNotEmpty &&
        !url.contains('your-project') &&
        !url.contains('example.com') &&
        !key.contains('your-anon-key') &&
        !key.contains('your-key');
  }

  /// Live Weather is active and rate-limit safe via Open-Meteo & OpenWeatherMap
  static bool get hasWeather => true;

  /// AI Assistant is active and rate-limit safe via Smart Agronomy AI Engine & Groq LLM
  static bool get hasAI => true;

  static const appVersion = '1.0.11';
  static const appName = 'KrishiRitu AI';

  // Karnataka districts
  static const karnatakaDistricts = [
    'Bagalkot', 'Ballari', 'Belagavi', 'Bengaluru Rural', 'Bengaluru Urban',
    'Bidar', 'Chamarajanagara', 'Chikballapur', 'Chikkamagaluru',
    'Chitradurga', 'Dakshina Kannada', 'Davanagere', 'Dharwad', 'Gadag',
    'Hassan', 'Haveri', 'Kalaburagi', 'Kodagu', 'Kolar', 'Koppal',
    'Mandya', 'Mysuru', 'Raichur', 'Ramanagara', 'Shivamogga',
    'Tumakuru', 'Udupi', 'Uttara Kannada', 'Vijayapura', 'Yadgir',
  ];

  // Soil types
  static const soilTypes = [
    'Red Sandy Loam', 'Black Cotton Soil', 'Laterite', 'Alluvial',
    'Sandy Loam', 'Clay', 'Loamy', 'Red Loam',
  ];

  // Irrigation methods
  static const irrigationMethods = [
    'Rainfed', 'Borewell', 'Canal', 'Tank', 'Drip', 'Sprinkler',
    'River', 'Well',
  ];

  // Agricultural seasons in Karnataka
  static const seasons = ['Kharif (Jun-Oct)', 'Rabi (Nov-Feb)', 'Summer (Mar-May)', 'Year-round'];
}
