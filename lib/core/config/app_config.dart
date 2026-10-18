import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get openWeatherKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  static String get anthropicKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasWeather => openWeatherKey.isNotEmpty;
  static bool get hasAI => anthropicKey.isNotEmpty;

  static const appVersion = '1.0.0';
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
