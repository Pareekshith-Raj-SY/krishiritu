import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'KrishiRitu AI',
      'tagline': 'Smart Farmer Season Guide',
      'home': 'Home',
      'my_farm': 'My Farm',
      'season_plan': 'Season Plan',
      'explore': 'Explore',
      'profile': 'Profile',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'sign_up': 'Create Account',
      'welcome_back': 'Welcome',
      'welcome': 'Welcome to KrishiRitu',
      'welcome_farmer': 'Welcome, Farmer!',
      'dashboard': 'Dashboard',
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'current_season': 'Current Season',
      'kharif_season': 'Kharif Season (Jun–Oct)',
      'rabi_season': 'Rabi Season (Nov–Feb)',
      'summer_season': 'Summer Season (Mar–May)',
      'tap_season_plan': 'Tap Season Plan to get crop recommendations →',
      'quick_actions': 'Quick Actions',
      'crop_plan': 'Crop Plan',
      'farm_twin': 'Farm Twin',
      'farm_summary': 'Farm Summary',
      'edit': 'Edit',
      'acres': 'acres',
      'explore_features': 'Explore Features',
      'weather_risks': 'Weather & Risks',
      'crop_health_title': 'Crop Health',
      'what_if_sim': 'What-If Sim',
      'season_memory': 'Season Memory',
      'tasks': 'Tasks',
      'crop_recommendations': 'Crop Recommendations',
      'season_twin': 'Farm Season Twin',
      'weather': 'Weather & Risks',
      'budget': 'Budget',
      'services': 'Services',
      'history': 'Season Memory',
      'settings': 'Settings',
      'farm_name': 'Farm Name',
      'village': 'Village',
      'district': 'District',
      'land_area': 'Land Area',
      'land_area_acres': 'Land Area (acres)',
      'soil_type': 'Soil Type',
      'irrigation': 'Irrigation',
      'irrigation_method': 'Irrigation Method',
      'current_crop': 'Current Crop',
      'previous_crop': 'Previous Crop',
      'sowing_date': 'Sowing Date',
      'kharif': 'Kharif',
      'rabi': 'Rabi',
      'summer': 'Summer',
      'year_round': 'Year-round',
      'all': 'All',
      'save': 'Save',
      'cancel': 'Cancel',
      'loading': 'Loading...',
      'offline_mode': 'Offline Mode',
      'last_synced': 'Last synced',
      'no_data': 'No data available',
      'error_occurred': 'Something went wrong',
      'retry': 'Retry',
      'crop_name': 'Crop',
      'suitability': 'Suitability',
      'water_need': 'Water Need',
      'duration': 'Duration',
      'estimate': 'Estimate (₹/acre)',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'days': 'days',
      'language': 'Language',
      'english': 'English',
      'kannada': 'ಕನ್ನಡ',
      'hindi': 'हिंदी',
      'notifications': 'Notifications',
      'task_calendar': 'Task Calendar',
      'simulate': 'Run Simulation',
      'what_if': 'What-If Simulator',
      'scenario': 'Scenario',
      'result': 'Result',
      'budget_explorer': 'Budget & Profit',
      'total_cost': 'Total Cost',
      'expected_revenue': 'Expected Revenue',
      'net_profit': 'Net Profit',
      'break_even': 'Break-even Price',
      'note_estimate': '* These are estimates only. Actual results may vary.',
      'account': 'Account',
      'privacy': 'Privacy',
      'about': 'About',
      'version': 'Version',
      'help': 'Help & Support',
      'nearby_services': 'Nearby Farm Services',
      'agri_office': 'Agriculture Office',
      'soil_lab': 'Soil Testing Lab',
      'equipment': 'Equipment Rental',
      'market': 'Agricultural Market',
      'crop_health': 'Crop Health & Weed ID',
      'upload_photo': 'Upload Photo',
      'identify': 'Identify',
      'disclaimer_ai': 'AI-generated suggestions only. Consult your local agricultural expert before acting.',
      'season_planner': 'Smart Season Planner',
      'farm_history': 'Farm History',
      'planned': 'Planned',
      'actual': 'Actual',
      'harvest': 'Harvest',
      'expense': 'Expense',
      'add_expense': 'Add Expense',
      'add_record': 'Add Record',

      // Farm Profile Screen (Image 1)
      'farm_profile': 'Farm Profile',
      'farm_details': 'Farm Details',
      'soil_irrigation': 'Soil & Irrigation',
      'crops_economics': 'Crops & Economics',
      'budget_per_acre': 'Budget per Acre (₹)',
      'save_profile': 'Save Profile',
      'farm_profile_saved': 'Farm profile saved!',

      // Smart Season Planner (Image 2)
      'smart_season_planner': 'Smart Season Planner',
      'search_crop_hint': 'Search any crop in the world (e.g. Wheat, Ragi)...',
      'search_crops': 'Search Crops',
      'close_search': 'Close Search',
      'sow': 'Sow',
      'cost_acre': 'Cost/Acre',
      'yield': 'Yield',
      'water_low': 'LOW',
      'water_medium': 'MEDIUM',
      'water_high': 'HIGH',
      'ranked_by_suitability': 'Ranked by suitability for your farm profile.',
      'update_farm': 'Update Farm',
      'no_crops_found': 'No crops found for this season.',
      'clear_search': 'Clear search',
      'ksda_disclaimer': '* Agronomy data from KSDA 2023 publications. Verify with local agricultural office.',

      // Weather & Seasonal Risk (Image 3)
      'weather_seasonal_risk': 'Weather & Seasonal Risk',
      'live_weather': 'Live Weather',
      'weather_api_notice': 'Configure OPENWEATHER_API_KEY in your .env file to enable live weather data for your farm location.',
      'seasonal_risks': 'Seasonal Risks',
      'based_on_conditions': 'Based on typical Karnataka conditions for',
      'crop_risk_calendar': 'Karnataka Crop Risk Calendar',

      // Settings & Profile (Image 4)
      'settings_profile': 'Settings & Profile',
      'farmer': 'Farmer',
      'setup_farm_profile': 'Set up your farm profile',
      'app_language': 'App Language',
      'farm_section': 'Farm',
      'farm_profile_sub': 'Update farm details, soil, and crop',
      'season_memory_sub': 'View and add season records',
      'features_section': 'Features',
      'weather_api': 'Weather API',
      'ai_assistant': 'AI Assistant',
      'supabase_sync': 'Supabase Sync',
      'configured': 'Configured ✓',
      'add_key_env': 'Add key to .env',
      'connected': 'Connected ✓',
      'add_creds_env': 'Add credentials to .env',
      'about_section': 'About',
      'app_version': 'App Version',
      'data_disclaimer': 'Data Disclaimer',
      'data_disclaimer_sub': 'Crop data is illustrative. Verify with local KVK.',
      'sign_out': 'Sign Out',
      'return_to_login': 'Return to login',
      'understood': 'Understood',

      // Karnataka Districts
      'Bagalkot': 'Bagalkot',
      'Ballari': 'Ballari',
      'Belagavi': 'Belagavi',
      'Bengaluru Rural': 'Bengaluru Rural',
      'Bengaluru Urban': 'Bengaluru Urban',
      'Bidar': 'Bidar',
      'Chamarajanagara': 'Chamarajanagara',
      'Chikballapur': 'Chikballapur',
      'Chikkamagaluru': 'Chikkamagaluru',
      'Chitradurga': 'Chitradurga',
      'Dakshina Kannada': 'Dakshina Kannada',
      'Davanagere': 'Davanagere',
      'Dharwad': 'Dharwad',
      'Gadag': 'Gadag',
      'Hassan': 'Hassan',
      'Haveri': 'Haveri',
      'Kalaburagi': 'Kalaburagi',
      'Kodagu': 'Kodagu',
      'Kolar': 'Kolar',
      'Koppal': 'Koppal',
      'Mandya': 'Mandya',
      'Mysuru': 'Mysuru',
      'Raichur': 'Raichur',
      'Ramanagara': 'Ramanagara',
      'Shivamogga': 'Shivamogga',
      'Tumakuru': 'Tumakuru',
      'Udupi': 'Udupi',
      'Uttara Kannada': 'Uttara Kannada',
      'Vijayapura': 'Vijayapura',
      'Yadgir': 'Yadgir',
      'Vijayanagara': 'Vijayanagara',
      'Karnataka': 'Karnataka',

      // Soil Types
      'Red Sandy Loam': 'Red Sandy Loam',
      'Black Cotton Soil': 'Black Cotton Soil',
      'Laterite': 'Laterite',
      'Alluvial': 'Alluvial',
      'Sandy Loam': 'Sandy Loam',
      'Clay': 'Clay',
      'Loamy': 'Loamy',
      'Red Loam': 'Red Loam',
      'Clay Loam': 'Clay Loam',
      'Deep Loamy': 'Deep Loamy',
      'Well-drained Clay Loam': 'Well-drained Clay Loam',
      'Well-drained Loamy': 'Well-drained Loamy',

      // Irrigation Methods
      'Rainfed': 'Rainfed',
      'Borewell': 'Borewell',
      'Canal': 'Canal',
      'Tank': 'Tank',
      'Drip': 'Drip',
      'Sprinkler': 'Sprinkler',
      'River': 'River',
      'Well': 'Well',
      'Furrow': 'Furrow',

      // General Farm Labels
      'suitable_districts': 'Suitable Districts',
      'save_and_continue': 'Save & Continue',
      'skip_for_now': 'Skip for now',
      'set_up_your_farm': 'Set Up Your Farm',
      'required': 'Required',
      'enter_valid_area': 'Enter valid area',
    },
    'kn': {
      'app_name': 'ಕೃಷಿಋತು AI',
      'tagline': 'ಸ್ಮಾರ್ಟ್ ಕೃಷಿ ಋತು ಮಾರ್ಗದರ್ಶಿ',
      'home': 'ಮನೆ',
      'my_farm': 'ನನ್ನ ಜಮೀನು',
      'season_plan': 'ಋತು ಯೋಜನೆ',
      'explore': 'ಅನ್ವೇಷಿಸಿ',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'login': 'ಲಾಗಿನ್',
      'register': 'ನೋಂದಾಯಿಸಿ',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್‌ವರ್ಡ್',
      'forgot_password': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿದ್ದೀರಾ?',
      'sign_in': 'ಸೈನ್ ಇನ್',
      'sign_up': 'ಖಾತೆ ರಚಿಸಿ',
      'welcome_back': 'ಸ್ವಾಗತ',
      'welcome': 'ಕೃಷಿಋತುಗೆ ಸ್ವಾಗತ',
      'welcome_farmer': 'ಸ್ವಾಗತ, ರೈತರೇ!',
      'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
      'good_morning': 'ಶುಭ ಬೆಳಿಗ್ಗೆ',
      'good_afternoon': 'ಶುಭ ಮಧ್ಯಾಹ್ನ',
      'good_evening': 'ಶುಭ ಸಂಜೆ',
      'current_season': 'ಪ್ರಸ್ತುತ ಋತು',
      'kharif_season': 'ಖರೀಫ್ ಋತು (ಜೂ–ಅಕ್ಟೋ)',
      'rabi_season': 'ರಬಿ ಋತು (ನವ–ಫೆಬ್)',
      'summer_season': 'ಬೇಸಿಗೆ ಋತು (ಮಾ–ಮೇ)',
      'tap_season_plan': 'ಬೆಳೆ ಶಿಫಾರಸು ಪಡೆಯಲು ಋತು ಯೋಜನೆ ಟ್ಯಾಪ್ ಮಾಡಿ →',
      'quick_actions': 'ತ್ವರಿತ ಕ್ರಮಗಳು',
      'crop_plan': 'ಬೆಳೆ ಯೋಜನೆ',
      'farm_twin': 'ಫಾರ್ಮ್ ಟ್ವಿನ್',
      'farm_summary': 'ಜಮೀನಿನ ವಿವರ',
      'edit': 'ಬದಲಾಯಿಸಿ',
      'acres': 'ಎಕರೆ',
      'explore_features': 'ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಅನ್ವೇಷಿಸಿ',
      'weather_risks': 'ಹವಾಮಾನ & ಅಪಾಯಗಳು',
      'crop_health_title': 'ಬೆಳೆ ಆರೋಗ್ಯ',
      'what_if_sim': 'ವಾಟ್-ಇಫ್ ಸಿಮ್ಯುಲೇಟರ್',
      'season_memory': 'ಋತು ಇತಿಹಾಸ',
      'tasks': 'ಕಾರ್ಯಗಳು',
      'crop_recommendations': 'ಬೆಳೆ ಶಿಫಾರಸು',
      'season_twin': 'ಜಮೀನು ಋತು ಜೋಡಿ',
      'weather': 'ಹವಾಮಾನ & ಅಪಾಯಗಳು',
      'budget': 'ಬಜೆಟ್',
      'services': 'ಸೇವೆಗಳು',
      'history': 'ಋತು ಇತಿಹಾಸ',
      'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'farm_name': 'ಜಮೀನಿನ ಹೆಸರು',
      'village': 'ಗ್ರಾಮ',
      'district': 'ಜಿಲ್ಲೆ',
      'land_area': 'ಜಮೀನಿನ ವಿಸ್ತೀರ್ಣ',
      'land_area_acres': 'ಜಮೀನಿನ ವಿಸ್ತೀರ್ಣ (ಎಕರೆ)',
      'soil_type': 'ಮಣ್ಣಿನ ಪ್ರಕಾರ',
      'irrigation': 'ನೀರಾವರಿ ವಿಧಾನ',
      'irrigation_method': 'ನೀರಾವರಿ ವಿಧಾನ',
      'current_crop': 'ಪ್ರಸ್ತುತ ಬೆಳೆ',
      'previous_crop': 'ಹಿಂದಿನ ಬೆಳೆ',
      'sowing_date': 'ಬಿತ್ತನೆ ದಿನಾಂಕ',
      'kharif': 'ಖರೀಫ್',
      'rabi': 'ರಬಿ',
      'summer': 'ಬೇಸಿಗೆ',
      'year_round': 'ವರ್ಷವಿಡೀ',
      'all': 'ಎಲ್ಲವೂ',
      'save': 'ಉಳಿಸಿ',
      'cancel': 'ರದ್ದು',
      'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'offline_mode': 'ಆಫ್‌ಲೈನ್ ಮೋಡ್',
      'last_synced': 'ಕೊನೆಯ ಸಿಂಕ್',
      'no_data': 'ಡೇಟಾ ಇಲ್ಲ',
      'error_occurred': 'ದೋಷ ಸಂಭವಿಸಿದೆ',
      'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'crop_name': 'ಬೆಳೆ',
      'suitability': 'ಸೂಕ್ತತೆ',
      'water_need': 'ನೀರಿನ ಅಗತ್ಯ',
      'duration': 'ಅವಧಿ',
      'estimate': 'ಅಂದಾಜು (₹/ಎಕರೆ)',
      'high': 'ಹೆಚ್ಚು',
      'medium': 'ಮಧ್ಯಮ',
      'low': 'ಕಡಿಮೆ',
      'days': 'ದಿನಗಳು',
      'language': 'ಭಾಷೆ',
      'english': 'English',
      'kannada': 'ಕನ್ನಡ',
      'hindi': 'हिंदी',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'task_calendar': 'ಕಾರ್ಯ ಕ್ಯಾಲೆಂಡರ್',
      'simulate': 'ಸಿಮ್ಯುಲೇಶನ್ ಚಲಾಯಿಸಿ',
      'what_if': 'ಏನಾದರೆ ಸಿಮ್ಯುಲೇಟರ್',
      'scenario': 'ಸನ್ನಿವೇಶ',
      'result': 'ಫಲಿತಾಂಶ',
      'budget_explorer': 'ಬಜೆಟ್ & ಲಾಭ',
      'total_cost': 'ಒಟ್ಟು ವೆಚ್ಚ',
      'expected_revenue': 'ನಿರೀಕ್ಷಿತ ಆದಾಯ',
      'net_profit': 'ನಿವ್ವಳ ಲಾಭ',
      'break_even': 'ಬ್ರೇಕ್-ಈವನ್ ಬೆಲೆ',
      'note_estimate': '* ಇವು ಅಂದಾಜು ಮಾತ್ರ. ನಿಜವಾದ ಫಲಿತಾಂಶ ಭಿನ್ನವಾಗಬಹುದು.',
      'account': 'ಖಾತೆ',
      'privacy': 'ಗೌಪ್ಯತೆ',
      'about': 'ಬಗ್ಗೆ',
      'version': 'ಆವೃತ್ತಿ',
      'help': 'ಸಹಾಯ & ಬೆಂಬಲ',
      'nearby_services': 'ಸಮೀಪದ ಕೃಷಿ ಸೇವೆಗಳು',
      'agri_office': 'ಕೃಷಿ ಕಚೇರಿ',
      'soil_lab': 'ಮಣ್ಣು ಪರೀಕ್ಷಾ ಪ್ರಯೋಗಾಲಯ',
      'equipment': 'ಉಪಕರಣ ಬಾಡಿಗೆ',
      'market': 'ಕೃಷಿ ಮಾರುಕಟ್ಟೆ',
      'crop_health': 'ಬೆಳೆ ಆರೋಗ್ಯ & ಕಳೆ',
      'upload_photo': 'ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'identify': 'ಗುರುತಿಸಿ',
      'disclaimer_ai': 'AI ಸಲಹೆ ಮಾತ್ರ. ಕ್ರಮ ತೆಗೆದುಕೊಳ್ಳುವ ಮೊದಲು ಸ್ಥಳೀಯ ಕೃಷಿ ತಜ್ಞರನ್ನು ಸಂಪರ್ಕಿಸಿ.',
      'season_planner': 'ಸ್ಮಾರ್ಟ್ ಋತು ಯೋಜಕ',
      'farm_history': 'ಜಮೀನು ಇತಿಹಾಸ',
      'planned': 'ಯೋಜಿತ',
      'actual': 'ನಿಜವಾದ',
      'harvest': 'ಕೊಯ್ಲು',
      'expense': 'ವೆಚ್ಚ',
      'add_expense': 'ವೆಚ್ಚ ಸೇರಿಸಿ',
      'add_record': 'ದಾಖಲೆ ಸೇರಿಸಿ',

      // Farm Profile Screen (Image 1)
      'farm_profile': 'ಜಮೀನಿನ ಪ್ರೊಫೈಲ್',
      'farm_details': 'ಜಮೀನಿನ ವಿವರಗಳು',
      'soil_irrigation': 'ಮಣ್ಣು & ನೀರಾವರಿ',
      'crops_economics': 'ಬೆಳೆಗಳು & ಆರ್ಥಿಕತೆ',
      'budget_per_acre': 'ಎಕರೆಗೆ ಬಜೆಟ್ (₹)',
      'save_profile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ',
      'farm_profile_saved': 'ಜಮೀನಿನ ಪ್ರೊಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ!',

      // Smart Season Planner (Image 2)
      'smart_season_planner': 'ಸ್ಮಾರ್ಟ್ ಋತು ಯೋಜಕ',
      'search_crop_hint': 'ಯಾವುದೇ ಬೆಳೆಯನ್ನು ಹುಡುಕಿ (ಉದಾ. ರಾಗಿ, ಗೋಧಿ)...',
      'search_crops': 'ಬೆಳೆಗಳನ್ನು ಹುಡುಕಿ',
      'close_search': 'ಹುಡುಕಾಟ ಮುಚ್ಚಿ',
      'sow': 'ಬಿತ್ತನೆ',
      'cost_acre': 'ವೆಚ್ಚ/ಎಕರೆ',
      'yield': 'ಇಳುವರಿ',
      'water_low': 'ಕಡಿಮೆ',
      'water_medium': 'ಮಧ್ಯಮ',
      'water_high': 'ಹೆಚ್ಚು',
      'ranked_by_suitability': 'ನಿಮ್ಮ ಜಮೀನಿನ ಪ್ರೊಫೈಲ್‌ಗೆ ಸೂಕ್ತತೆಯ ಆಧಾರದ ಮೇಲೆ ಶ್ರೇಣೀಕರಿಸಲಾಗಿದೆ.',
      'update_farm': 'ಜಮೀನು ನವೀಕರಿಸಿ',
      'no_crops_found': 'ಈ ಋತುವಿನಲ್ಲಿ ಯಾವುದೇ ಬೆಳೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ.',
      'clear_search': 'ಹುಡುಕಾಟ ತೆರವುಗೊಳಿಸಿ',
      'ksda_disclaimer': '* KSDA 2023 ಪ್ರಕಟಣೆಗಳಿಂದ ಕೃಷಿ ಮಾಹಿತಿ. ಸ್ಥಳೀಯ ಕೃಷಿ ಕಚೇರಿಯೊಂದಿಗೆ ಪರಿಶೀಲಿಸಿ.',

      // Weather & Seasonal Risk (Image 3)
      'weather_seasonal_risk': 'ಹವಾಮಾನ & ಋತು ಅಪಾಯಗಳು',
      'live_weather': 'ಲೈವ್ ಹವಾಮಾನ',
      'weather_api_notice': 'ನಿಮ್ಮ ಜಮೀನಿನ ಲೈವ್ ಹವಾಮಾನ ಡೇಟಾವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು .env ಫೈಲ್‌ನಲ್ಲಿ OPENWEATHER_API_KEY ಕಾನ್ಫಿಗರ್ ಮಾಡಿ.',
      'seasonal_risks': 'ಋತುವಿನ ಅಪಾಯಗಳು',
      'based_on_conditions': 'ಕರ್ನಾಟಕದ ವಿಶಿಷ್ಟ ಪರಿಸ್ಥಿತಿಗಳ ಆಧಾರದ ಮೇಲೆ',
      'crop_risk_calendar': 'ಕರ್ನಾಟಕ ಬೆಳೆ ಅಪಾಯ ಕ್ಯಾಲೆಂಡರ್',

      // Settings & Profile (Image 4)
      'settings_profile': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು & ಪ್ರೊಫೈಲ್',
      'farmer': 'ರೈತ',
      'setup_farm_profile': 'ನಿಮ್ಮ ಜಮೀನಿನ ಪ್ರೊಫೈಲ್ ಹೊಂದಿಸಿ',
      'app_language': 'ಆ್ಯಪ್ ಭಾಷೆ',
      'farm_section': 'ಜಮೀನು',
      'farm_profile_sub': 'ಜಮೀನಿನ ವಿವರ, ಮಣ್ಣು ಮತ್ತು ಬೆಳೆಯನ್ನು ನವೀಕರಿಸಿ',
      'season_memory_sub': 'ಋತುವಿನ ದಾಖಲೆಗಳನ್ನು ವೀಕ್ಷಿಸಿ ಮತ್ತು ಸೇರಿಸಿ',
      'features_section': 'ವೈಶಿಷ್ಟ್ಯಗಳು',
      'weather_api': 'ಹವಾಮಾನ API',
      'ai_assistant': 'AI ಸಹಾಯಕ',
      'supabase_sync': 'ಸುಪಾಬೇಸ್ ಸಿಂಕ್',
      'configured': 'ಸಂರಚಿಸಲಾಗಿದೆ ✓',
      'add_key_env': '.env ಗೆ ಕೀ ಸೇರಿಸಿ',
      'connected': 'ಸಂಪರ್ಕಗೊಂಡಿದೆ ✓',
      'add_creds_env': '.env ಗೆ ವಿವರ ಸೇರಿಸಿ',
      'about_section': 'ಬಗ್ಗೆ',
      'app_version': 'ಆ್ಯಪ್ ಆವೃತ್ತಿ',
      'data_disclaimer': 'ಡೇಟಾ ಹಕ್ಕುತ್ಯಾಗ',
      'data_disclaimer_sub': 'ಬೆಳೆ ಡೇಟಾ ಉದಾಹರಣೆಯಾಗಿದೆ. ಸ್ಥಳೀಯ ಕೆವಿಕೆಯೊಂದಿಗೆ ಪರಿಶೀಲಿಸಿ.',
      'sign_out': 'ಸೈನ್ ಔಟ್',
      'return_to_login': 'ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ',
      'understood': 'ಅರ್ಥವಾಯಿತು',

      // Karnataka Districts
      'Bagalkot': 'ಬಾಗಲಕೋಟೆ',
      'Ballari': 'ಬಳ್ಳಾರಿ',
      'Belagavi': 'ಬೆಳಗಾವಿ',
      'Bengaluru Rural': 'ಬೆಂಗಳೂರು ಗ್ರಾಮಾಂತರ',
      'Bengaluru Urban': 'ಬೆಂಗಳೂರು ನಗರ',
      'Bidar': 'ಬೀದರ್',
      'Chamarajanagara': 'ಚಾಮರಾಜನಗರ',
      'Chikballapur': 'ಚಿಕ್ಕಬಳ್ಳಾಪುರ',
      'Chikkamagaluru': 'ಚಿಕ್ಕಮಗಳೂರು',
      'Chitradurga': 'ಚಿತ್ರದುರ್ಗ',
      'Dakshina Kannada': 'ದಕ್ಷಿಣ ಕನ್ನಡ',
      'Davanagere': 'ದಾವಣಗೆರೆ',
      'Dharwad': 'ಧಾರವಾಡ',
      'Gadag': 'ಗದಗ',
      'Hassan': 'ಹಾಸನ',
      'Haveri': 'ಹಾವೇರಿ',
      'Kalaburagi': 'ಕಲಬುರಗಿ',
      'Kodagu': 'ಕೊಡಗು',
      'Kolar': 'ಕೋಲಾರ',
      'Koppal': 'ಕೊಪ್ಪಳ',
      'Mandya': 'ಮಂಡ್ಯ',
      'Mysuru': 'ಮೈಸೂರು',
      'Raichur': 'ರಾಯಚೂರು',
      'Ramanagara': 'ರಾಮನಗರ',
      'Shivamogga': 'ಶಿವಮೊಗ್ಗ',
      'Tumakuru': 'ತುಮಕೂರು',
      'Udupi': 'ಉಡುಪಿ',
      'Uttara Kannada': 'ಉತ್ತರ ಕನ್ನಡ',
      'Vijayapura': 'ವಿಜಯಪುರ',
      'Yadgir': 'ಯಾದಗಿರಿ',
      'Vijayanagara': 'ವಿಜಯನಗರ',
      'Karnataka': 'ಕರ್ನಾಟಕ',

      // Soil Types
      'Red Sandy Loam': 'ಕೆಂಪು ಮರಳು ಗೋಡು ಮಣ್ಣು',
      'Black Cotton Soil': 'ಕಪ್ಪು ಹತ್ತಿ ಮಣ್ಣು',
      'Laterite': 'ಲ್ಯಾಟರೈಟ್ ಮಣ್ಣು',
      'Alluvial': 'ಮೆಕ್ಕಲು ಮಣ್ಣು',
      'Sandy Loam': 'ಮರಳು ಗೋಡು ಮಣ್ಣು',
      'Clay': 'ಜೇಡಿ ಮಣ್ಣು',
      'Loamy': 'ಗೋಡು ಮಣ್ಣು',
      'Red Loam': 'ಕೆಂಪು ಗೋಡು ಮಣ್ಣು',
      'Clay Loam': 'ಜೇಡಿ ಗೋಡು ಮಣ್ಣು',
      'Deep Loamy': 'ಆಳವಾದ ಗೋಡು ಮಣ್ಣು',
      'Well-drained Clay Loam': 'ಉತ್ತಮ ಬಸಿದುಹೋಗುವ ಜೇಡಿ ಗೋಡು ಮಣ್ಣು',
      'Well-drained Loamy': 'ಉತ್ತಮ ಬಸಿದುಹೋಗುವ ಗೋಡು ಮಣ್ಣು',

      // Irrigation Methods
      'Rainfed': 'ಮಳೆಯಾಶ್ರಿತ',
      'Borewell': 'ಕೊಳವೆ ಬಾವಿ',
      'Canal': 'ಕಾಲುವೆ',
      'Tank': 'ಕೆರೆ',
      'Drip': 'ಹನಿ ನೀರಾವರಿ',
      'Sprinkler': 'ತುಂತುರು ನೀರಾವರಿ',
      'River': 'ನದಿ',
      'Well': 'ಬಾವಿ',
      'Furrow': 'ಸಾಲು ನೀರಾವರಿ',

      // General Farm Labels
      'suitable_districts': 'ಸೂಕ್ತ ಜಿಲ್ಲೆಗಳು',
      'save_and_continue': 'ಉಳಿಸಿ & ಮುಂದುವರಿಯಿರಿ',
      'skip_for_now': 'ಸದ್ಯಕ್ಕೆ ಬಿಟ್ಟುಬಿಡಿ',
      'set_up_your_farm': 'ನಿಮ್ಮ ಜಮೀನನ್ನು ಹೊಂದಿಸಿ',
      'required': 'ಅಗತ್ಯವಿದೆ',
      'enter_valid_area': 'ಸರಿಯಾದ ವಿಸ್ತೀರ್ಣ ನಮೂದಿಸಿ',
    },
    'hi': {
      'app_name': 'कृषिऋतु AI',
      'tagline': 'स्मार्ट किसान मौसम मार्गदर्शिका',
      'home': 'होम',
      'my_farm': 'मेरा खेत',
      'season_plan': 'मौसम योजना',
      'explore': 'खोजें',
      'profile': 'प्रोफ़ाइल',
      'login': 'लॉग इन',
      'register': 'पंजीकरण',
      'logout': 'लॉग आउट',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'sign_in': 'साइन इन',
      'sign_up': 'खाता बनाएं',
      'welcome_back': 'स्वागत है',
      'welcome': 'कृषिऋतु में आपका स्वागत है',
      'welcome_farmer': 'स्वागत है, किसान!',
      'dashboard': 'डैशबोर्ड',
      'good_morning': 'शुभ प्रभात',
      'good_afternoon': 'शुभ दोपहर',
      'good_evening': 'शुभ संध्या',
      'current_season': 'वर्तमान मौसम',
      'kharif_season': 'खरीफ मौसम (जून–अक्टूबर)',
      'rabi_season': 'रबी मौसम (नवंबर–फरवरी)',
      'summer_season': 'जायद/गर्मी मौसम (मार्च–मई)',
      'tap_season_plan': 'फसल सिफारिशें पाने के लिए मौसम योजना पर टैप करें →',
      'quick_actions': 'त्वरित कार्य',
      'crop_plan': 'फसल योजना',
      'farm_twin': 'फार्म ट्विन',
      'farm_summary': 'फार्म सारांश',
      'edit': 'संपादित करें',
      'acres': 'एकड़',
      'explore_features': 'सुविधाएं खोजें',
      'weather_risks': 'मौसम और जोखिम',
      'crop_health_title': 'फसल स्वास्थ्य',
      'what_if_sim': 'व्हाट-इफ सिमुलेटर',
      'season_memory': 'मौसम इतिहास',
      'tasks': 'कार्य',
      'crop_recommendations': 'फसल सिफारिशें',
      'season_twin': 'फार्म सीजन ट्विन',
      'weather': 'मौसम और जोखिम',
      'budget': 'बजट',
      'services': 'सेवाएं',
      'history': 'मौसम इतिहास',
      'settings': 'सेटिंग्स',
      'farm_name': 'फार्म का नाम',
      'village': 'गाँव',
      'district': 'ज़िला',
      'land_area': 'भूमि क्षेत्र',
      'land_area_acres': 'भूमि क्षेत्र (एकड़)',
      'soil_type': 'मिट्टी का प्रकार',
      'irrigation': 'सिंचाई विधि',
      'irrigation_method': 'सिंचाई विधि',
      'current_crop': 'वर्तमान फसल',
      'previous_crop': 'पिछली फसल',
      'sowing_date': 'बुवाई की तारीख',
      'kharif': 'खरीफ',
      'rabi': 'रबी',
      'summer': 'जायद/गर्मी',
      'year_round': 'साल भर',
      'all': 'सभी',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'loading': 'लोड हो रहा है...',
      'offline_mode': 'ऑफ़लाइन मोड',
      'last_synced': 'अंतिम सिंक',
      'no_data': 'कोई डेटा उपलब्ध नहीं',
      'error_occurred': 'कुछ गलत हो गया',
      'retry': 'पुनः प्रयास करें',
      'crop_name': 'फसल',
      'suitability': 'उपयुक्तता',
      'water_need': 'पानी की आवश्यकता',
      'duration': 'अवधि',
      'estimate': 'अनुमान (₹/एकड़)',
      'high': 'उच्च',
      'medium': 'मध्यम',
      'low': 'कम',
      'days': 'दिन',
      'language': 'भाषा',
      'english': 'English',
      'kannada': 'ಕನ್ನಡ',
      'hindi': 'हिंदी',
      'notifications': 'सूचनाएं',
      'task_calendar': 'कार्य कैलेंडर',
      'simulate': 'सिमुलेशन चलाएं',
      'what_if': 'व्हाट-इफ सिमुलेटर',
      'scenario': 'परिदृश्य',
      'result': 'परिणाम',
      'budget_explorer': 'बजट और लाभ',
      'total_cost': 'कुल लागत',
      'expected_revenue': 'अपेक्षित राजस्व',
      'net_profit': 'शुद्ध लाभ',
      'break_even': 'समतुल्य मूल्य',
      'note_estimate': '* ये केवल अनुमान हैं। वास्तविक परिणाम भिन्न हो सकते हैं।',
      'account': 'खाता',
      'privacy': 'गोपनीयता',
      'about': 'के बारे में',
      'version': 'संस्करण',
      'help': 'सहायता और समर्थन',
      'nearby_services': 'आस-पास की सेवाएं',
      'agri_office': 'कृषि कार्यालय',
      'soil_lab': 'मृदा परीक्षण लैब',
      'equipment': 'उपकरण किराया',
      'market': 'कृषि मंडी',
      'crop_health': 'फसल स्वास्थ्य एवं खरपतवार',
      'upload_photo': 'फोटो अपलोड करें',
      'identify': 'पहचानें',
      'disclaimer_ai': 'केवल AI-जनरेटेड सुझाव। निर्णय लेने से पहले अपने स्थानीय कृषि विशेषज्ञ से संपर्क करें।',
      'season_planner': 'स्मार्ट मौसम योजना',
      'farm_history': 'फार्म इतिहास',
      'planned': 'योजनाबद्ध',
      'actual': 'वास्तविक',
      'harvest': 'कटाई',
      'expense': 'व्यय',
      'add_expense': 'व्यय जोड़ें',
      'add_record': 'रिकॉर्ड जोड़ें',

      // Farm Profile Screen (Image 1)
      'farm_profile': 'फार्म प्रोफ़ाइल',
      'farm_details': 'खेत का विवरण',
      'soil_irrigation': 'मिट्टी और सिंचाई',
      'crops_economics': 'फसलें और अर्थशास्त्र',
      'budget_per_acre': 'प्रति एकड़ बजट (₹)',
      'save_profile': 'प्रोफ़ाइल सहेजें',
      'farm_profile_saved': 'फार्म प्रोफ़ाइल सहेजी गई!',

      // Smart Season Planner (Image 2)
      'smart_season_planner': 'स्मार्ट मौसम योजना',
      'search_crop_hint': 'दुनिया की कोई भी फसल खोजें (उदा. गेहूं, रागी)...',
      'search_crops': 'फसलें खोजें',
      'close_search': 'खोज बंद करें',
      'sow': 'बुवाई',
      'cost_acre': 'लागत/एकड़',
      'yield': 'उपज',
      'water_low': 'कम',
      'water_medium': 'मध्यम',
      'water_high': 'उच्च',
      'ranked_by_suitability': 'आपके फार्म प्रोफ़ाइल की उपयुक्तता के आधार पर क्रमबद्ध।',
      'update_farm': 'फार्म अपडेट करें',
      'no_crops_found': 'इस मौसम के लिए कोई फसल नहीं मिली।',
      'clear_search': 'खोज साफ़ करें',
      'ksda_disclaimer': '* कृषि डेटा केएसडीए 2023 प्रकाशनों से। स्थानीय कृषि कार्यालय से सत्यापित करें।',

      // Weather & Seasonal Risk (Image 3)
      'weather_seasonal_risk': 'मौसम और मौसमी जोखिम',
      'live_weather': 'लाइव मौसम',
      'weather_api_notice': 'अपने खेत के लाइव मौसम डेटा के लिए .env फ़ाइल में OPENWEATHER_API_KEY कॉन्फ़िगर करें।',
      'seasonal_risks': 'मौसमी जोखिम',
      'based_on_conditions': 'विशिष्ट कर्नाटक स्थितियों के आधार पर',
      'crop_risk_calendar': 'कर्नाटक फसल जोखिम कैलेंडर',

      // Settings & Profile (Image 4)
      'settings_profile': 'सेटिंग्स और प्रोफ़ाइल',
      'farmer': 'किसान',
      'setup_farm_profile': 'अपना फार्म प्रोफ़ाइल सेट करें',
      'app_language': 'ऐप भाषा',
      'farm_section': 'खेत',
      'farm_profile_sub': 'खेत का विवरण, मिट्टी और फसल अपडेट करें',
      'season_memory_sub': 'मौसम के रिकॉर्ड देखें और जोड़ें',
      'features_section': 'सुविधाएं',
      'weather_api': 'मौसम API',
      'ai_assistant': 'AI सहायक',
      'supabase_sync': 'सुपाबेस सिंक',
      'configured': 'कॉन्फ़िगर किया गया ✓',
      'add_key_env': '.env में कुंजी जोड़ें',
      'connected': 'कनेक्टेड ✓',
      'add_creds_env': '.env में क्रेडेंशियल जोड़ें',
      'about_section': 'के बारे में',
      'app_version': 'ऐप संस्करण',
      'data_disclaimer': 'डेटा अस्वीकरण',
      'data_disclaimer_sub': 'फसल डेटा सांकेतिक है। स्थानीय केवीके से सत्यापित करें।',
      'sign_out': 'साइन आउट',
      'return_to_login': 'लॉगिन पर लौटें',
      'understood': 'समझ गया',

      // Karnataka Districts
      'Bagalkot': 'बागलकोट',
      'Ballari': 'बल्लारी',
      'Belagavi': 'बेलगावी',
      'Bengaluru Rural': 'बेंगलुरु ग्रामीण',
      'Bengaluru Urban': 'बेंगलुरु शहरी',
      'Bidar': 'बीदर',
      'Chamarajanagara': 'चामराजनगर',
      'Chikballapur': 'चिकबल्लापुर',
      'Chikkamagaluru': 'चिकमगलूर',
      'Chitradurga': 'चित्रदुर्ग',
      'Dakshina Kannada': 'दक्षिण कन्नड़',
      'Davanagere': 'दावणगेरे',
      'Dharwad': 'धारवाड़',
      'Gadag': 'गदग',
      'Hassan': 'हासन',
      'Haveri': 'हावेरी',
      'Kalaburagi': 'कलबुर्गी',
      'Kodagu': 'कोडागु',
      'Kolar': 'कोलार',
      'Koppal': 'कोप्पल',
      'Mandya': 'मांड्या',
      'Mysuru': 'मैसूरु',
      'Raichur': 'रायचूर',
      'Ramanagara': 'रामनगर',
      'Shivamogga': 'शिवमोग्गा',
      'Tumakuru': 'तुमकुरु',
      'Udupi': 'उडुपी',
      'Uttara Kannada': 'उत्तर कन्नड़',
      'Vijayapura': 'विजयपुरा',
      'Yadgir': 'यादगीर',
      'Vijayanagara': 'विजयनगर',
      'Karnataka': 'कर्नाटक',

      // Soil Types
      'Red Sandy Loam': 'लाल रेतीली दोमट मिट्टी',
      'Black Cotton Soil': 'काली कपास मिट्टी',
      'Laterite': 'लैटेराइट मिट्टी',
      'Alluvial': 'जलोढ़ मिट्टी',
      'Sandy Loam': 'रेतीली दोमट मिट्टी',
      'Clay': 'चिकनी मिट्टी',
      'Loamy': 'दोमट मिट्टी',
      'Red Loam': 'लाल दोमट मिट्टी',
      'Clay Loam': 'चिकनी दोमट मिट्टी',
      'Deep Loamy': 'गहरी दोमट मिट्टी',
      'Well-drained Clay Loam': 'अच्छी जल निकासी वाली चिकनी दोमट मिट्टी',
      'Well-drained Loamy': 'अच्छी जल निकासी वाली दोमट मिट्टी',

      // Irrigation Methods
      'Rainfed': 'वर्षा आधारित',
      'Borewell': 'बोरवेल',
      'Canal': 'नहर',
      'Tank': 'तालाब',
      'Drip': 'ड्रिप सिंचाई',
      'Sprinkler': 'स्प्रिंकलर सिंचाई',
      'River': 'नदी',
      'Well': 'कुआँ',
      'Furrow': 'नाली सिंचाई',

      // General Farm Labels
      'suitable_districts': 'उपयुक्त जिले',
      'save_and_continue': 'सहेजें और जारी रखें',
      'skip_for_now': 'अभी छोड़ें',
      'set_up_your_farm': 'अपना खेत सेट करें',
      'required': 'आवश्यक है',
      'enter_valid_area': 'मान्य क्षेत्र दर्ज करें',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ?? key;
  }

  String t(String key) => translate(key);

  String translateDistrict(String district) {
    if (district.isEmpty) return district;
    final trimmed = district.trim();
    final direct = translate(trimmed);
    if (direct != trimmed) return direct;
    return trimmed;
  }

  String translateSoil(String soil) {
    if (soil.isEmpty) return soil;
    final trimmed = soil.trim();
    final direct = translate(trimmed);
    if (direct != trimmed) return direct;
    return trimmed;
  }

  String translateIrrigation(String method) {
    if (method.isEmpty) return method;
    final trimmed = method.trim();
    final direct = translate(trimmed);
    if (direct != trimmed) return direct;
    return trimmed;
  }

  String translateSoilList(String soils) {
    if (soils.isEmpty) return soils;
    return soils.split(',').map((s) => translateSoil(s.trim())).join(', ');
  }

  String translateIrrigationList(String methods) {
    if (methods.isEmpty) return methods;
    return methods.split(',').map((m) => translateIrrigation(m.trim())).join(', ');
  }

  /// Maps any localized district name back to the canonical English district name
  static String canonicalDistrict(String? d) {
    if (d == null || d.trim().isEmpty) return 'Mysuru';
    final candidate = d.trim();
    for (final dist in AppConfig.karnatakaDistricts) {
      if (dist.toLowerCase() == candidate.toLowerCase()) return dist;
      for (final lang in ['kn', 'hi', 'en']) {
        final val = _localizedValues[lang]?[dist];
        if (val != null && val.toLowerCase() == candidate.toLowerCase()) {
          return dist;
        }
      }
    }
    return 'Mysuru';
  }

  /// Maps any localized soil name back to the canonical English soil name
  static String canonicalSoil(String? s) {
    if (s == null || s.trim().isEmpty) return 'Red Sandy Loam';
    final candidate = s.trim();
    for (final soil in AppConfig.soilTypes) {
      if (soil.toLowerCase() == candidate.toLowerCase()) return soil;
      for (final lang in ['kn', 'hi', 'en']) {
        final val = _localizedValues[lang]?[soil];
        if (val != null && val.toLowerCase() == candidate.toLowerCase()) {
          return soil;
        }
      }
    }
    return 'Red Sandy Loam';
  }

  /// Maps any localized irrigation name back to the canonical English irrigation name
  static String canonicalIrrigation(String? m) {
    if (m == null || m.trim().isEmpty) return 'Rainfed';
    final candidate = m.trim();
    for (final method in AppConfig.irrigationMethods) {
      if (method.toLowerCase() == candidate.toLowerCase()) return method;
      for (final lang in ['kn', 'hi', 'en']) {
        final val = _localizedValues[lang]?[method];
        if (val != null && val.toLowerCase() == candidate.toLowerCase()) {
          return method;
        }
      }
    }
    return 'Rainfed';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'kn', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
