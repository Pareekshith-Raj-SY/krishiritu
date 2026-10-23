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

  static String get supabaseUrl => _safeEnv('SUPABASE_URL');
  static String get supabaseAnonKey => _safeEnv('SUPABASE_ANON_KEY');
  static String get openWeatherKey => _safeEnv('OPENWEATHER_API_KEY');
  static String get anthropicKey => _safeEnv('ANTHROPIC_API_KEY');

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

  static bool get hasWeather {
    final key = openWeatherKey.trim().toLowerCase();
    return key.isNotEmpty && !key.contains('your-');
  }

  static bool get hasAI {
    final key = anthropicKey.trim().toLowerCase();
    return key.isNotEmpty && !key.contains('your-');
  }

  static const appVersion = '1.0.10';
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
