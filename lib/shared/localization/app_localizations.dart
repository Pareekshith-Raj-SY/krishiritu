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
      'what_if_simulator': 'What-If Simulator',
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

      // Scenario Simulator
      'scenario_parameters': '📊 Scenario Parameters',
      'what_if_adjustments': '⚡ What-If Adjustments',
      'monsoon_delay': 'Monsoon Delay',
      'monsoon_delay_hint': 'Reduces yield if sowing is delayed',
      'input_cost_increase': 'Input Cost Increase',
      'input_cost_hint': 'Seeds, fertilizer, labour prices rise',
      'yield_reduction': 'Yield Reduction',
      'yield_reduction_hint': 'Pest, disease, or water shortage impact',
      'market_price_kg': 'Market Price (₹/kg)',
      'market_price_hint': 'Adjust expected selling price',
      'simulation_results': 'Simulation Results',
      'total_input_cost': 'Total Input Cost',
      'net_profit_loss': 'Net Profit / Loss',
      'simulator_disclaimer': '* These are estimates only. Market prices, weather, and yields are variable. Do not use as financial advice.',

      // Nearby Farm Services
      'nearby_services_notice': 'Sample data for Mysuru. Configure location permissions for live results.',
      'kvk': 'KVK',
      'bank': 'Bank',
      'input_shop': 'Input Shop',
      'no_services_found': 'No services found',
      'away': 'away',
      'contact_agri_office': 'Contact AgriOffice',
      'contact_state_dept': 'Contact State Dept',

      // Tasks & Notifications
      'tasks_and_notifications': 'Tasks & Notifications',
      'notifications_notice': 'Notifications are based on typical Karnataka crop calendars. Set up your farm profile for personalized reminders.',
      'this_week': 'This week',
      'week_4': 'Week 4',
      'month_2': 'Month 2',
      'upcoming': 'Upcoming',
      'info': 'Info',

      // Budget Screen
      'input_costs_per_acre': '📋 Input Costs (per acre, ₹)',
      'seeds_seedlings': 'Seeds/Seedlings',
      'fertilizers': 'Fertilizers',
      'pesticides': 'Pesticides',
      'labour': 'Labour',
      'irrigation_cost': 'Irrigation',
      'other_cost': 'Other',
      'revenue_assumptions': '💰 Revenue Assumptions',
      'expected_yield_kg': 'Expected Yield (kg/acre)',
      'calculate': 'Calculate',
      'results': 'Results',
      'estimated_profit': 'Estimated Profit',
      'estimated_loss': 'Estimated Loss',
      'budget_disclaimer': '* Estimates only. Actual results depend on weather, market prices, and farming conditions. Not financial advice.',

      // Crop Health
      'upload_photo_prompt': 'Upload a crop or weed photo',
      'upload_photo_sub': 'Get a possible identification and care guidance.',
      'take_photo': 'Take Photo',
      'upload_gallery': 'Upload from Gallery',
      'common_problems': 'Common Crop Problems in Karnataka',
      'affects': 'Affects',
      'symptoms': 'Symptoms:',
      'suggested_action': 'Suggested Action:',
      'important_disclaimer': 'Important Disclaimer',
      'crop_health_disclaimer': 'Photo-based identification is not a confirmed diagnosis. Always confirm with your local agricultural extension officer or KVK before applying any treatment. Do not apply pesticides without verified, crop-specific guidance.',
      'feature_coming_soon': 'Feature Coming Soon',
      'feature_coming_soon_desc': 'Photo-based crop identification requires an AI image analysis service to be configured. This feature will be available once the service is set up in your .env file.',
      'ok': 'OK',

      // Season Twin
      'farm_digital_profile': '🏡 Farm Digital Profile',
      'setup_farm_profile_hint': 'Set up your farm profile to get personalized recommendations.',
      'select_crop_season_plan': '🌾 Select Crop for Season Plan',
      'choose_crop': 'Choose a crop',
      'planned_sowing_date': 'Planned Sowing Date',
      'task_calendar_crop': '📅 Task Calendar',
      'planned_sow': 'Planned sow:',
      'season_twin_disclaimer': '⚠️ This calendar is a general guide based on typical crop duration. Adjust dates based on local weather conditions and advice from your nearest Krishi Vigyan Kendra (KVK).',

      // Season Memory
      'expenses': 'Expenses',
      'harvests': 'Harvests',
      'no_expenses_logged': 'No expenses logged yet',
      'tap_add_record_expense': 'Tap + Add Record to start tracking',
      'total_expenses': 'Total Expenses',
      'total_revenue': 'Total Revenue',
      'no_harvests_logged': 'No harvest records yet',
      'tap_add_record_harvest': 'Tap + Add Record to log your harvest',
      'category': 'Category',
      'description': 'Description',
      'amount_rs': 'Amount (₹)',
      'quantity_kg': 'Quantity (kg)',
      'price_rs_kg': 'Price (₹/kg)',
      'save_record': 'Save Record',

      // Crop Detail
      'seasonal_calendar': '🗓️ Seasonal Calendar',
      'sowing_months': 'Sowing Months',
      'harvest_months': 'Harvest Months',
      'growing_requirements': '🌱 Growing Requirements',
      'economics_estimates': '💰 Economics (Estimates per Acre)',
      'input_cost': 'Input Cost',
      'about_crop': 'ℹ️ About this Crop',
      'data_source': '📚 Data Source',
      'crop_detail_disclaimer': '⚠️ These are illustrative estimates. Actual results depend on weather, market prices, and local conditions. Consult your nearest KVK or agricultural office.',
      'kg': 'kg',
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
      'what_if': 'ವಾಟ್-ಇಫ್ ಸಿಮ್ಯುಲೇಟರ್',
      'what_if_simulator': 'ವಾಟ್-ಇಫ್ ಸಿಮ್ಯುಲೇಟರ್',
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
      'nearby_services': 'ಹತ್ತಿರದ ಕೃಷಿ ಸೇವೆಗಳು',
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

      // Scenario Simulator
      'scenario_parameters': '📊 ಸನ್ನಿವೇಶ ನಿಯತಾಂಕಗಳು',
      'what_if_adjustments': '⚡ ವಾಟ್-ಇಫ್ ಹೊಂದಾಣಿಕೆಗಳು',
      'monsoon_delay': 'ಮುಂಗಾರು ವಿಳಂಬ',
      'monsoon_delay_hint': 'ಬಿತ್ತನೆ ವಿಳಂಬವಾದರೆ ಇಳುವರಿ ಕಡಿಮೆಯಾಗುತ್ತದೆ',
      'input_cost_increase': 'ಹೂಡಿಕೆ ವೆಚ್ಚ ಹೆಚ್ಚಳ',
      'input_cost_hint': 'ಬೀಜ, ಗೊಬ್ಬರ, ಕೂಲಿ ವೆಚ್ಚ ಹೆಚ್ಚಳ',
      'yield_reduction': 'ಇಳುವರಿ ಇಳಿಕೆ',
      'yield_reduction_hint': 'ಕೀಟ, ರೋಗ ಅಥವಾ ನೀರಿನ ಕೊರತೆಯ ಪರಿಣಾಮ',
      'market_price_kg': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆ (₹/ಕೆಜಿ)',
      'market_price_hint': 'ನಿರೀಕ್ಷಿತ ಮಾರಾಟ ಬೆಲೆಯನ್ನು ಹೊಂದಿಸಿ',
      'simulation_results': 'ಸಿಮ್ಯುಲೇಶನ್ ಫಲಿತಾಂಶಗಳು',
      'total_input_cost': 'ಒಟ್ಟು ಹೂಡಿಕೆ ವೆಚ್ಚ',
      'net_profit_loss': 'ನಿವ್ವಳ ಲಾಭ / ನಷ್ಟ',
      'simulator_disclaimer': '* ಇವು ಅಂದಾಜುಗಳು ಮಾತ್ರ. ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು, ಹವಾಮಾನ ಮತ್ತು ಇಳುವರಿ ಬದಲಾಗಬಹುದು. ಹಣಕಾಸಿನ ಸಲಹೆಯಾಗಿ ಬಳಸಬೇಡಿ.',

      // Nearby Farm Services
      'nearby_services_notice': 'ಮೈಸೂರಿನ ಮಾದರಿ ಮಾಹಿತಿ. ಲೈವ್ ಫಲಿತಾಂಶಗಳಿಗಾಗಿ ಸ್ಥಳ ಅನುಮತಿಯನ್ನು ನೀಡಿ.',
      'kvk': 'ಕೆವಿಕೆ (KVK)',
      'bank': 'ಬ್ಯಾಂಕ್',
      'input_shop': 'ಕೃಷಿ ಪರಿಕರಗಳ ಮಳಿಗೆ',
      'no_services_found': 'ಯಾವುದೇ ಸೇವೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
      'away': 'ದೂರದಲ್ಲಿದೆ',
      'contact_agri_office': 'ಕೃಷಿ ಕಚೇರಿ ಸಂಪರ್ಕಿಸಿ',
      'contact_state_dept': 'ರಾಜ್ಯ ಇಲಾಖೆ ಸಂಪರ್ಕಿಸಿ',

      // Tasks & Notifications
      'tasks_and_notifications': 'ಕಾರ್ಯಗಳು ಮತ್ತು ಅಧಿಸೂಚನೆಗಳು',
      'notifications_notice': 'ಅಧಿಸೂಚನೆಗಳು ಕರ್ನಾಟಕದ ವಿಶಿಷ್ಟ ಬೆಳೆ ಕ್ಯಾಲೆಂಡರ್‌ಗಳನ್ನು ಆಧರಿಸಿವೆ. ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಜ್ಞಾಪನೆಗಳಿಗಾಗಿ ನಿಮ್ಮ ಜಮೀನಿನ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಹೊಂದಿಸಿ.',
      'this_week': 'ಈ ವಾರ',
      'week_4': 'ವಾರ 4',
      'month_2': 'ತಿಂಗಳು 2',
      'upcoming': 'ಮುಂಬರುವ',
      'info': 'ಮಾಹಿತಿ',

      // Budget Screen
      'input_costs_per_acre': '📋 ಕೃಷಿ ಹೂಡಿಕೆ ವೆಚ್ಚಗಳು (ಎಕರೆಗೆ, ₹)',
      'seeds_seedlings': 'ಬೀಜಗಳು / ಸಸಿಗಳು',
      'fertilizers': 'ರಸಗೊಬ್ಬರಗಳು',
      'pesticides': 'ಕೀಟನಾಶಕಗಳು',
      'labour': 'ಕೂಲಿ ವೆಚ್ಚ',
      'irrigation_cost': 'ನೀರಾವರಿ ವೆಚ್ಚ',
      'other_cost': 'ಇತರೆ ವೆಚ್ಚ',
      'revenue_assumptions': '💰 ನಿರೀಕ್ಷಿತ ಆದಾಯದ ಊಹೆಗಳು',
      'expected_yield_kg': 'ನಿರೀಕ್ಷಿತ ಇಳುವರಿ (ಕೆಜಿ/ಎಕರೆ)',
      'calculate': 'ಲೆಕ್ಕಾಚಾರ ಮಾಡಿ',
      'results': 'ಫಲಿತಾಂಶಗಳು',
      'estimated_profit': 'ಅಂದಾಜು ಲಾಭ',
      'estimated_loss': 'ಅಂದಾಜು ನಷ್ಟ',
      'budget_disclaimer': '* ಇವು ಅಂದಾಜುಗಳು ಮಾತ್ರ. ನಿಜವಾದ ಫಲಿತಾಂಶಗಳು ಹವಾಮಾನ, ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು ಮತ್ತು ಕೃಷಿ ಪರಿಸ್ಥಿತಿಗಳನ್ನು ಅವಲಂಬಿಸಿವೆ. ಹಣಕಾಸಿನ ಸಲಹೆಯಲ್ಲ.',

      // Crop Health
      'upload_photo_prompt': 'ಬೆಳೆ ಅಥವಾ ಕಳೆಯ ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'upload_photo_sub': 'ಸಂಭಾವ್ಯ ಕೀಟ/ರೋಗ ಗುರುತಿಸುವಿಕೆ ಮತ್ತು ಆರೈಕೆ ಮಾರ್ಗದರ್ಶನ ಪಡೆಯಿರಿ.',
      'take_photo': 'ಫೋಟೋ ತೆಗೆಯಿರಿ',
      'upload_gallery': 'ಗ್ಯಾಲರಿಯಿಂದ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'common_problems': 'ಕರ್ನಾಟಕದ ಸಾಮಾನ್ಯ ಬೆಳೆ ಸಮಸ್ಯೆಗಳು',
      'affects': 'ಬಾಧಿತ ಬೆಳೆ',
      'symptoms': 'ರೋಗಲಕ್ಷಣಗಳು:',
      'suggested_action': 'ಶಿಫಾರಸು ಮಾಡಿದ ಕ್ರಮ:',
      'important_disclaimer': 'ಪ್ರಮುಖ ಹಕ್ಕುತ್ಯಾಗ',
      'crop_health_disclaimer': 'ಫೋಟೋ ಆಧಾರಿತ ಗುರುತಿಸುವಿಕೆಯು ಅಂತಿಮ ರೋಗನಿರ್ಣಯವಲ್ಲ. ಯಾವುದೇ ಚಿಕಿತ್ಸೆ ನೀಡುವ ಮೊದಲು ನಿಮ್ಮ ಸ್ಥಳೀಯ ಕೃಷಿ ವಿಸ್ತರಣಾಧಿಕಾರಿ ಅಥವಾ ಕೆವಿಕೆಯೊಂದಿಗೆ ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ. ಪರಿಶೀಲಿಸದೆ ಕೀಟನಾಶಕಗಳನ್ನು ಬಳಸಬೇಡಿ.',
      'feature_coming_soon': 'ವೈಶಿಷ್ಟ್ಯ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ',
      'feature_coming_soon_desc': 'ಫೋಟೋ ಆಧಾರಿತ ಬೆಳೆ ಗುರುತಿಸುವಿಕೆಗೆ AI ಇಮೇಜ್ ವಿಶ್ಲೇಷಣೆ ಸೇವೆಯ ಅಗತ್ಯವಿದೆ. ನಿಮ್ಮ .env ಫೈಲ್‌ನಲ್ಲಿ ಸೇವೆಯನ್ನು ಹೊಂದಿಸಿದ ನಂತರ ಈ ವೈಶಿಷ್ಟ್ಯವು ಲಭ್ಯವಿರುತ್ತದೆ.',
      'ok': 'ಸರಿ',

      // Season Twin
      'farm_digital_profile': '🏡 ಜಮೀನಿನ ಡಿಜಿಟಲ್ ಪ್ರೊಫೈಲ್',
      'setup_farm_profile_hint': 'ವೈಯಕ್ತಿಕ ಶಿಫಾರಸುಗಳನ್ನು ಪಡೆಯಲು ನಿಮ್ಮ ಜಮೀನಿನ ಪ್ರೊಫೈಲ್ ಹೊಂದಿಸಿ.',
      'select_crop_season_plan': '🌾 ಋತು ಯೋಜನೆಗಾಗಿ ಬೆಳೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'choose_crop': 'ಬೆಳೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'planned_sowing_date': 'ಯೋಜಿತ ಬಿತ್ತನೆ ದಿನಾಂಕ',
      'task_calendar_crop': '📅 ಕಾರ್ಯ ಕ್ಯಾಲೆಂಡರ್',
      'planned_sow': 'ಯೋಜಿತ ಬಿತ್ತನೆ:',
      'season_twin_disclaimer': '⚠️ ಈ ಕ್ಯಾಲೆಂಡರ್ ಸಾಮಾನ್ಯ ಬೆಳೆ ಅವಧಿಯನ್ನು ಆಧರಿಸಿದ ಮಾರ್ಗದರ್ಶಿಯಾಗಿದೆ. ಸ್ಥಳೀಯ ಹವಾಮಾನ ಪರಿಸ್ಥಿತಿಗಳು ಮತ್ತು ಸಮೀಪದ ಕೃಷಿ ವಿಜ್ಞಾನ ಕೇಂದ್ರದ (KVK) ಸಲಹೆಯ ಆಧಾರದ ಮೇಲೆ ದಿನಾಂಕಗಳನ್ನು ಹೊಂದಿಸಿ.',

      // Season Memory
      'expenses': 'ವೆಚ್ಚಗಳು',
      'harvests': 'ಕೊಯ್ಲುಗಳು',
      'no_expenses_logged': 'ಇನ್ನೂ ಯಾವುದೇ ವೆಚ್ಚಗಳು ದಾಖಲಾಗಿಲ್ಲ',
      'tap_add_record_expense': 'ಟ್ರ್ಯಾಕ್ ಮಾಡಲು + ದಾಖಲೆ ಸೇರಿಸಿ ಟ್ಯಾಪ್ ಮಾಡಿ',
      'total_expenses': 'ಒಟ್ಟು ವೆಚ್ಚಗಳು',
      'total_revenue': 'ಒಟ್ಟು ಆದಾಯ',
      'no_harvests_logged': 'ಇನ್ನೂ ಯಾವುದೇ ಕೊಯ್ಲು ದಾಖಲಾಗಿಲ್ಲ',
      'tap_add_record_harvest': 'ನಿಮ್ಮ ಕೊಯ್ಲು ದಾಖಲಿಸಲು + ದಾಖಲೆ ಸೇರಿಸಿ ಟ್ಯಾಪ್ ಮಾಡಿ',
      'category': 'ವರ್ಗ',
      'description': 'ವಿವರಣೆ',
      'amount_rs': 'ಮೊತ್ತ (₹)',
      'quantity_kg': 'ಪ್ರಮಾಣ (ಕೆಜಿ)',
      'price_rs_kg': 'ಬೆಲೆ (₹/ಕೆಜಿ)',
      'save_record': 'ದಾಖಲೆ ಉಳಿಸಿ',

      // Crop Detail
      'seasonal_calendar': '🗓️ ಋತು ಕ್ಯಾಲೆಂಡರ್',
      'sowing_months': 'ಬಿತ್ತನೆ ತಿಂಗಳುಗಳು',
      'harvest_months': 'ಕೊಯ್ಲು ತಿಂಗಳುಗಳು',
      'growing_requirements': '🌱 ಬೆಳವಣಿಗೆಯ ಅಗತ್ಯತೆಗಳು',
      'economics_estimates': '💰 ಆರ್ಥಿಕತೆ (ಎಕರೆಗೆ ಅಂದಾಜುಗಳು)',
      'input_cost': 'ಹೂಡಿಕೆ ವೆಚ್ಚ',
      'about_crop': 'ℹ️ ಈ ಬೆಳೆಯ ಬಗ್ಗೆ',
      'data_source': '📚 ಡೇಟಾ ಮೂಲ',
      'crop_detail_disclaimer': '⚠️ ಇವು ವಿವರಣಾತ್ಮಕ ಅಂದಾಜುಗಳಾಗಿವೆ. ನಿಜವಾದ ಫಲಿತಾಂಶಗಳು ಹವಾಮಾನ, ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು ಮತ್ತು ಸ್ಥಳೀಯ ಪರಿಸ್ಥಿತಿಗಳನ್ನು ಅವಲಂಬಿಸಿವೆ. ನಿಮ್ಮ ಸಮೀಪದ ಕೆವಿಕೆ ಅಥವಾ ಕೃಷಿ ಕಚೇರಿಯನ್ನು ಸಂಪರ್ಕಿಸಿ.',
      'kg': 'ಕೆಜಿ',
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
      'what_if': 'व्हाट्स-इफ सिम्युलेटर',
      'what_if_simulator': 'व्हाट्स-इफ सिम्युलेटर',
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
      'nearby_services': 'आस-पास की कृषि सेवाएं',
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

      // Scenario Simulator
      'scenario_parameters': '📊 परिदृश्य पैरामीटर',
      'what_if_adjustments': '⚡ व्हाट-इफ समायोजन',
      'monsoon_delay': 'मानसून में देरी',
      'monsoon_delay_hint': 'बुवाई में देरी होने पर उपज कम हो जाती है',
      'input_cost_increase': 'लागत में वृद्धि',
      'input_cost_hint': 'बीज, खाद, मजदूरी के दाम बढ़ना',
      'yield_reduction': 'उपज में कमी',
      'yield_reduction_hint': 'कीट, रोग या पानी की कमी का प्रभाव',
      'market_price_kg': 'बाजार मूल्य (₹/किग्रा)',
      'market_price_hint': 'अपेक्षित बिक्री मूल्य समायोजित करें',
      'simulation_results': 'सिमुलेशन परिणाम',
      'total_input_cost': 'कुल इनपुट लागत',
      'net_profit_loss': 'शुद्ध लाभ / हानि',
      'simulator_disclaimer': '* ये केवल अनुमान हैं। बाजार मूल्य, मौसम और उपज परिवर्तनशील हैं। वित्तीय सलाह के रूप में उपयोग न करें।',

      // Nearby Farm Services
      'nearby_services_notice': 'मैसूरु के लिए नमूना डेटा। लाइव परिणामों के लिए स्थान अनुमति कॉन्फ़िगर करें।',
      'kvk': 'केवीके (KVK)',
      'bank': 'बैंक',
      'input_shop': 'कृषि इनपुट दुकान',
      'no_services_found': 'कोई सेवा नहीं मिली',
      'away': 'दूरी पर',
      'contact_agri_office': 'कृषि कार्यालय से संपर्क करें',
      'contact_state_dept': 'राज्य विभाग से संपर्क करें',

      // Tasks & Notifications
      'tasks_and_notifications': 'कार्य और सूचनाएं',
      'notifications_notice': 'सूचनाएं विशिष्ट कर्नाटक फसल कैलेंडर पर आधारित हैं। व्यक्तिगत अनुस्मारक के लिए अपना फार्म प्रोफ़ाइल सेट करें।',
      'this_week': 'इस सप्ताह',
      'week_4': 'सप्ताह 4',
      'month_2': 'माह 2',
      'upcoming': 'आगामी',
      'info': 'जानकारी',

      // Budget Screen
      'input_costs_per_acre': '📋 इनपुट लागत (प्रति एकड़, ₹)',
      'seeds_seedlings': 'बीज / पौधे',
      'fertilizers': 'उर्वरक',
      'pesticides': 'कीटनाशक',
      'labour': 'मजदूरी',
      'irrigation_cost': 'सिंचाई',
      'other_cost': 'अन्य',
      'revenue_assumptions': '💰 राजस्व अनुमान',
      'expected_yield_kg': 'अपेक्षित उपज (किग्रा/एकड़)',
      'calculate': 'गणना करें',
      'results': 'परिणाम',
      'estimated_profit': 'अनुमानित लाभ',
      'estimated_loss': 'अनुमानित हानि',
      'budget_disclaimer': '* केवल अनुमान। वास्तविक परिणाम मौसम, बाजार भाव और कृषि स्थितियों पर निर्भर करते हैं। वित्तीय सलाह नहीं।',

      // Crop Health
      'upload_photo_prompt': 'फसल या खरपतवार की फोटो अपलोड करें',
      'upload_photo_sub': 'संभावित पहचान और देखभाल मार्गदर्शन प्राप्त करें।',
      'take_photo': 'फोटो खींचें',
      'upload_gallery': 'गैलरी से अपलोड करें',
      'common_problems': 'कर्नाटक में सामान्य फसल समस्याएं',
      'affects': 'प्रभावित फसल',
      'symptoms': 'लक्षण:',
      'suggested_action': 'सुझाया गया उपाय:',
      'important_disclaimer': 'महत्वपूर्ण अस्वीकरण',
      'crop_health_disclaimer': 'फोटो-आधारित पहचान अंतिम निदान नहीं है। कोई भी उपचार करने से पहले हमेशा अपने स्थानीय कृषि विस्तार अधिकारी या केवीके से पुष्टि करें।',
      'feature_coming_soon': 'सुविधा जल्द आ रही है',
      'feature_coming_soon_desc': 'फोटो-आधारित फसल पहचान के लिए AI छवि विश्लेषण सेवा की आवश्यकता होती है। यह सुविधा आपके .env फ़ाइल में सेट होने के बाद उपलब्ध होगी।',
      'ok': 'ठीक है',

      // Season Twin
      'farm_digital_profile': '🏡 खेत का डिजिटल प्रोफ़ाइल',
      'setup_farm_profile_hint': 'व्यक्तिगत सिफारिशें पाने के लिए अपना फार्म प्रोफ़ाइल सेट करें।',
      'select_crop_season_plan': '🌾 मौसम योजना के लिए फसल चुनें',
      'choose_crop': 'एक फसल चुनें',
      'planned_sowing_date': 'नियोजित बुवाई की तारीख',
      'task_calendar_crop': '📅 कार्य कैलेंडर',
      'planned_sow': 'नियोजित बुवाई:',
      'season_twin_disclaimer': '⚠️ यह कैलेंडर विशिष्ट फसल अवधि पर आधारित एक सामान्य मार्गदर्शिका है। स्थानीय मौसम स्थितियों और निकटतम कृषि विज्ञान केंद्र (KVK) की सलाह के आधार पर तारीखें समायोजित करें।',

      // Season Memory
      'expenses': 'खर्च',
      'harvests': 'कटाई',
      'no_expenses_logged': 'अभी तक कोई खर्च दर्ज नहीं हुआ है',
      'tap_add_record_expense': 'ट्रैक करने के लिए + रिकॉर्ड जोड़ें पर टैप करें',
      'total_expenses': 'कुल खर्च',
      'total_revenue': 'कुल आय',
      'no_harvests_logged': 'अभी तक कोई कटाई रिकॉर्ड नहीं है',
      'tap_add_record_harvest': 'अपनी कटाई दर्ज करने के लिए + रिकॉर्ड जोड़ें पर टैप करें',
      'category': 'श्रेणी',
      'description': 'विवरण',
      'amount_rs': 'राशि (₹)',
      'quantity_kg': 'मात्रा (किग्रा)',
      'price_rs_kg': 'मूल्य (₹/किग्रा)',
      'save_record': 'रिकॉर्ड सहेजें',

      // Crop Detail
      'seasonal_calendar': '🗓️ मौसमी कैलेंडर',
      'sowing_months': 'बुवाई के महीने',
      'harvest_months': 'कटाई के महीने',
      'growing_requirements': '🌱 विकास आवश्यकताएं',
      'economics_estimates': '💰 अर्थशास्त्र (प्रति एकड़ अनुमान)',
      'input_cost': 'लागत',
      'about_crop': 'ℹ️ इस फसल के बारे में',
      'data_source': '📚 डेटा स्रोत',
      'crop_detail_disclaimer': '⚠️ ये सांकेतिक अनुमान हैं। वास्तविक परिणाम मौसम, बाजार भाव और स्थानीय स्थितियों पर निर्भर करते हैं। अपने निकटतम केवीके या कृषि कार्यालय से संपर्क करें।',
      'kg': 'किग्रा',
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

  String translateCrop(String crop) {
    if (crop.isEmpty) return crop;
    const cropKn = {
      'Ragi': 'ರಾಗಿ',
      'Paddy': 'ಭತ್ತ',
      'Maize': 'ಮೆಕ್ಕೆಜೋಳ',
      'Tur Dal': 'ತೊಗರಿ ಬೇಳೆ',
      'Groundnut': 'ಕಡಲೆಕಾಯಿ',
      'Cotton': 'ಹತ್ತಿ',
      'Sugarcane': 'ಕಬ್ಬು',
      'Sericulture': 'ರೇಷ್ಮೆ ಕೃಷಿ',
      'Sericulture (Silk)': 'ರೇಷ್ಮೆ ಕೃಷಿ (Silk)',
      'Sericulture (Mulberry)': 'ರೇಷ್ಮೆ ಕೃಷಿ (ಹಿಪ್ಪುನೇರಳೆ)',
      'Marigold': 'ಚೆಂಡು ಹೂ',
      'Marigold (Flower)': 'ಚೆಂಡು ಹೂ (Flower)',
      'Jasmine': 'ಮಲ್ಲಿಗೆ ಹೂ',
      'Jasmine (Flower)': 'ಮಲ್ಲಿಗೆ ಹೂ (Flower)',
      'Chrysanthemum': 'ಶೇವಂತಿ ಹೂ',
      'Chrysanthemum (Flower)': 'ಶೇವಂತಿ ಹೂ (Flower)',
      'Jowar': 'ಜೋಳ',
      'Sunflower': 'ಸೂರ್ಯಕಾಂತಿ',
      'Bengal Gram': 'ಕಡಲೆ',
      'Wheat': 'ಗೋಧಿ',
      'All crops': 'ಎಲ್ಲಾ ಬೆಳೆಗಳು',
    };
    const cropHi = {
      'Ragi': 'रागी',
      'Paddy': 'धान',
      'Maize': 'मक्का',
      'Tur Dal': 'अरहर दाल',
      'Groundnut': 'मूंगफली',
      'Cotton': 'कपास',
      'Sugarcane': 'गन्ना',
      'Sericulture': 'रेशम कीट पालन',
      'Sericulture (Silk)': 'रेशम कीट पालन (Silk)',
      'Sericulture (Mulberry)': 'रेशम कीट पालन (शहतूत)',
      'Marigold': 'गेंदा फूल',
      'Marigold (Flower)': 'गेंदा फूल (Flower)',
      'Jasmine': 'चमेली',
      'Jasmine (Flower)': 'चमेली (Flower)',
      'Chrysanthemum': 'गुलदाउदी',
      'Chrysanthemum (Flower)': 'गुलदाउदी (Flower)',
      'Jowar': 'ज्वार',
      'Sunflower': 'सूरजमुखी',
      'Bengal Gram': 'चना',
      'Wheat': 'गेहूं',
      'All crops': 'सभी फसलें',
    };
    if (locale.languageCode == 'kn') {
      return cropKn[crop] ?? translate(crop);
    } else if (locale.languageCode == 'hi') {
      return cropHi[crop] ?? translate(crop);
    }
    return crop;
  }

  String translateServiceType(String type) {
    switch (type) {
      case 'Agriculture Office':
        return t('agri_office');
      case 'KVK':
        return t('kvk');
      case 'Soil Testing Lab':
        return t('soil_lab');
      case 'Agriculture Market':
        return t('market');
      case 'Bank':
        return t('bank');
      case 'Input Shop':
        return t('input_shop');
      case 'All':
        return t('all');
      default:
        return translate(type);
    }
  }

  String translateServiceName(String name) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Assistant Director of Agriculture, Mysuru': 'ಸಹಾಯಕ ಕೃಷಿ ನಿರ್ದೇಶಕರ ಕಚೇರಿ, ಮೈಸೂರು',
        'Krishi Vigyan Kendra, Mysuru': 'ಕೃಷಿ ವಿಜ್ಞಾನ ಕೇಂದ್ರ, ಮೈಸೂರು',
        'District Soil Testing Lab, Mysuru': 'ಜಿಲ್ಲಾ ಮಣ್ಣು ಪರೀಕ್ಷಾ ಪ್ರಯೋಗಾಲಯ, ಮೈಸೂರು',
        'APMC Yard, Mysuru': 'ಎಪಿಎಂಸಿ ಯಾರ್ಡ್, ಮೈಸೂರು',
        'Karnataka Grameena Bank': 'ಕರ್ನಾಟಕ ಗ್ರಾಮೀಣ ಬ್ಯಾಂಕ್',
        'KSSF Fertilizer Depot': 'ಕೆಎಸ್‌ಎಸ್‌ಎಫ್ ರಸಗೊಬ್ಬರ ಡಿಪೋ',
      };
      return map[name] ?? name;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Assistant Director of Agriculture, Mysuru': 'सहायक कृषि निदेशक कार्यालय, मैसूरु',
        'Krishi Vigyan Kendra, Mysuru': 'कृषि विज्ञान केंद्र, मैसूरु',
        'District Soil Testing Lab, Mysuru': 'जिला मृदा परीक्षण प्रयोगशाला, मैसूरु',
        'APMC Yard, Mysuru': 'एपीएमसी यार्ड, मैसूरु',
        'Karnataka Grameena Bank': 'कर्नाटक ग्रामीण बैंक',
        'KSSF Fertilizer Depot': 'केएसएसएफ उर्वरक डिपो',
      };
      return map[name] ?? name;
    }
    return name;
  }

  String translateServiceAddress(String addr) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Krishidevaraya Road, Mysuru – 570001': 'ಕೃಷ್ಣದೇವರಾಯ ರಸ್ತೆ, ಮೈಸೂರು – 570001',
        'V.C. Farm, Mandya Road, Mysuru': 'ವಿ.ಸಿ. ಫಾರ್ಮ್, ಮಂಡ್ಯ ರಸ್ತೆ, ಮೈಸೂರು',
        'Office of the Deputy Director of Agriculture': 'ಉಪ ಕೃಷಿ ನಿರ್ದೇಶಕರ ಕಚೇರಿ ಆವರಣ',
        'Bannimantap, Mysuru – 570015': 'ಬನ್ನಿಮಂಟಪ, ಮೈಸೂರು – 570015',
        'Multiple branches across Mysuru district': 'ಮೈಸೂರು ಜಿಲ್ಲೆಯಾದ್ಯಂತ ಶಾಖೆಗಳು',
        'Check nearest cooperative society': 'ಹತ್ತಿರದ ಪ್ರಾಥಮಿಕ ಕೃಷಿ ಪತ್ತಿನ ಸಹಕಾರ ಸಂಘ',
        'Contact AgriOffice': 'ಕೃಷಿ ಕಚೇರಿ ಸಂಪರ್ಕಿಸಿ',
        'Contact State Dept': 'ರಾಜ್ಯ ಕೃಷಿ ಇಲಾಖೆ ಸಂಪರ್ಕಿಸಿ',
      };
      return map[addr] ?? addr;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Krishidevaraya Road, Mysuru – 570001': 'कृष्णदेवराय रोड, मैसूरु – 570001',
        'V.C. Farm, Mandya Road, Mysuru': 'वी.सी. फार्म, मांड्या रोड, मैसूरु',
        'Office of the Deputy Director of Agriculture': 'उप कृषि निदेशक का कार्यालय',
        'Bannimantap, Mysuru – 570015': 'बन्निमंटप, मैसूरु – 570015',
        'Multiple branches across Mysuru district': 'मैसूरु जिले में कई शाखाएं',
        'Check nearest cooperative society': 'निकटतम सहकारी समिति से संपर्क करें',
        'Contact AgriOffice': 'कृषि कार्यालय से संपर्क करें',
        'Contact State Dept': 'राज्य विभाग से संपर्क करें',
      };
      return map[addr] ?? addr;
    }
    return addr;
  }

  String translateTaskTitle(String title) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Kharif Sowing Window Open': 'ಖರೀಫ್ ಬಿತ್ತನೆ ಸಮಯ ಆರಂಭವಾಗಿದೆ',
        'Sericulture Batch Prep': 'ರೇಷ್ಮೆ ಬೆಳೆ ಬ್ಯಾಚ್ ಸಿದ್ಧತೆ',
        'Marigold & Flower Pinching': 'ಚೆಂಡು ಹೂ ಕುಡಿ ಕತ್ತರಿಸುವಿಕೆ (ಪಿಂಚಿಂಗ್)',
        'Sugarcane Earthing Up Alert': 'ಕಬ್ಬಿನ ಬುಡಕ್ಕೆ ಮಣ್ಣು ಏರಿಸುವ ಎಚ್ಚರಿಕೆ',
        'First Irrigation Due': 'ಮೊದಲ ನೀರಾವರಿ ಸಮಯ',
        'Pest Scouting Reminder': 'ಕೀಟ ಬಾಧೆ ಪರಿಶೀಲನಾ ಜ್ಞಾಪನೆ',
        'Rabi Season Preparation': 'ರಬಿ ಋತುವಿನ ಪೂರ್ವಸಿದ್ಧತೆ',
        'Harvest Approaching': 'ಕೊಯ್ಲು ಸಮೀಪಿಸುತ್ತಿದೆ',
        'MSP & Market Rate Alert': 'ಬೆಂಬಲ ಬೆಲೆ (MSP) & ಮಾರುಕಟ್ಟೆ ದರ ಎಚ್ಚರಿಕೆ',
      };
      return map[title] ?? title;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Kharif Sowing Window Open': 'खरीफ बुवाई का समय खुला है',
        'Sericulture Batch Prep': 'रेशम कीट बैच तैयारी',
        'Marigold & Flower Pinching': 'गेंदा फूल की टहनियां तोड़ना (पिंचिंग)',
        'Sugarcane Earthing Up Alert': 'गन्ने की जड़ों में मिट्टी चढ़ाने का अलर्ट',
        'First Irrigation Due': 'पहली सिंचाई का समय',
        'Pest Scouting Reminder': 'कीट निरीक्षण अनुस्मारक',
        'Rabi Season Preparation': 'रबी मौसम की तैयारी',
        'Harvest Approaching': 'कटाई का समय निकट है',
        'MSP & Market Rate Alert': 'एमएसपी (MSP) और बाजार भाव अलर्ट',
      };
      return map[title] ?? title;
    }
    return title;
  }

  String translateTaskDesc(String desc) {
    if (locale.languageCode == 'kn') {
      const map = {
        'June–July is ideal for Ragi, Paddy, Maize, Groundnut, Sugarcane, Sericulture, and Flower crops.':
            'ಜೂನ್-ಜುಲೈ ತಿಂಗಳು ರಾಗಿ, ಭತ್ತ, ಮೆಕ್ಕೆಜೋಳ, ಕಡಲೆಕಾಯಿ, ಕಬ್ಬು, ರೇಷ್ಮೆ ಮತ್ತು ಹೂವಿನ ಬೆಳೆಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.',
        'Complete rearing house disinfection with 2% bleach solution and check Uzi fly nets.':
            '2% ಬ್ಲೀಚಿಂಗ್ ದ್ರಾವಣದಿಂದ ಹುಳು ಸಾಕಣೆ ಮನೆಯನ್ನು ಸೋಂಕುರಹಿತಗೊಳಿಸಿ ಮತ್ತು ಉಜಿ ನೊಣದ ಜಾಲರಿಯನ್ನು ಪರೀಕ್ಷಿಸಿ.',
        'Pinch terminal shoots 25-30 days after transplanting to stimulate branching for Dasara/Diwali harvest.':
            'ದಸರಾ/ದೀಪಾವಳಿ ಕೊಯ್ಲಿಗೆ ಹೆಚ್ಚು ಕವಲುಗಳು ಬರಲು ನಾಟಿ ಮಾಡಿದ 25-30 ದಿನಗಳ ನಂತರ ತುದಿಯನ್ನು ಚಿವುಟಿ.',
        'Perform first earthing up and detrash lower dried leaves to conserve soil moisture.':
            'ಮಣ್ಣಿನ ತೇವಾಂಶ ಉಳಿಸಲು ಮೊದಲ ಬಾರಿ ಬುಡಕ್ಕೆ ಮಣ್ಣು ಏರಿಸಿ ಮತ್ತು ಕೆಳಗಿನ ಒಣಗಿದ ಎಲೆಗಳನ್ನು ತೆಗೆಯಿರಿ.',
        'If no significant rainfall in the past 10 days, irrigate your crop.':
            'ಕಳೆದ 10 ದಿನಗಳಲ್ಲಿ ಉತ್ತಮ ಮಳೆಯಾಗದಿದ್ದರೆ, ನಿಮ್ಮ ಬೆಳೆಗೆ ನೀರು ಹಾಯಿಸಿ.',
        'Week 6–8 is critical for stem borer in Paddy/Maize and bud borer in Flowers.':
            '6-8ನೇ ವಾರವು ಭತ್ತ/ಮೆಕ್ಕೆಜೋಳದಲ್ಲಿ ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಹೂವುಗಳಲ್ಲಿ ಮೊಗ್ಗು ಕೊರೆಯುವ ಕೀಟಕ್ಕೆ ಸೂಕ್ಷ್ಮ ಸಮಯ.',
        'Start planning Rabi crops (Jowar, Bengal Gram, Chrysanthemum) for October–November sowing.':
            'ಅಕ್ಟೋಬರ್-ನವೆಂಬರ್ ಬಿತ್ತನೆಗಾಗಿ ರಬಿ ಬೆಳೆಗಳನ್ನು (ಜೋಳ, ಕಡಲೆ, ಶೇವಂತಿ) ಯೋಜಿಸಲು ಪ್ರಾರಂಭಿಸಿ.',
        'Based on your sowing date, harvest window may begin soon. Arrange drying and market crates.':
            'ನಿಮ್ಮ ಬಿತ್ತನೆ ದಿನಾಂಕದ ಆಧಾರದ ಮೇಲೆ, ಕೊಯ್ಲು ಶೀಘ್ರದಲ್ಲೇ ಪ್ರಾರಂಭವಾಗಬಹುದು. ಒಣಗಿಸಲು ಮತ್ತು ಕ್ರೇಟ್‌ಗಳನ್ನು ವ್ಯವಸ್ಥೆ ಮಾಡಿ.',
        'Government MSP for Ragi is ₹3,846/quintal. Check live cocoon prices at Ramanagara APMC.':
            'ರಾಗಿಗೆ ಸರ್ಕಾರದ ಎಂಎಸ್‌ಪಿ ₹3,846/ಕ್ವಿಂಟಾಲ್ ಆಗಿದೆ. ರಾಮನಗರ ಎಪಿಎಂಸಿಯಲ್ಲಿ ಲೈವ್ ರೇಷ್ಮೆ ಗೂಡಿನ ದರ ಪರಿಶೀಲಿಸಿ.',
      };
      return map[desc] ?? desc;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'June–July is ideal for Ragi, Paddy, Maize, Groundnut, Sugarcane, Sericulture, and Flower crops.':
            'जून-जुलाई रागी, धान, मक्का, मूंगफली, गन्ना, रेशम और फूलों की फसलों के लिए आदर्श है।',
        'Complete rearing house disinfection with 2% bleach solution and check Uzi fly nets.':
            '2% ब्लीच घोल से पालन गृह को कीटाणुरहित करें और उजी मक्खी की जाली की जांच करें।',
        'Pinch terminal shoots 25-30 days after transplanting to stimulate branching for Dasara/Diwali harvest.':
            'दशहरा/दिवाली की फसल में अधिक शाखाएं लाने के लिए रोपाई के 25-30 दिन बाद मुख्य शाखा की नोक तोड़ें।',
        'Perform first earthing up and detrash lower dried leaves to conserve soil moisture.':
            'नमी बनाए रखने के लिए पहली बार मिट्टी चढ़ाएं और नीचे की सूखी पत्तियों को हटाएं।',
        'If no significant rainfall in the past 10 days, irrigate your crop.':
            'यदि पिछले 10 दिनों में पर्याप्त वर्षा नहीं हुई है, तो फसल की सिंचाई करें।',
        'Week 6–8 is critical for stem borer in Paddy/Maize and bud borer in Flowers.':
            'सप्ताह 6-8 धान/मक्का में तना छेदक और फूलों में कली छेदक कीट के लिए महत्वपूर्ण है।',
        'Start planning Rabi crops (Jowar, Bengal Gram, Chrysanthemum) for October–November sowing.':
            'अक्टूबर-नवंबर की बुवाई के लिए रबी फसलों (ज्वार, चना, गुलदाउदी) की योजना बनाना शुरू करें।',
        'Based on your sowing date, harvest window may begin soon. Arrange drying and market crates.':
            'बुवाई की तारीख के अनुसार कटाई जल्द शुरू हो सकती है। सुखाने और मंडी क्रेट्स की व्यवस्था करें।',
        'Government MSP for Ragi is ₹3,846/quintal. Check live cocoon prices at Ramanagara APMC.':
            'रागी का सरकारी एमएसपी ₹3,846/क्विंटल है। रामनगर एपीएमसी में रेशम कोकून के लाइव भाव देखें।',
      };
      return map[desc] ?? desc;
    }
    return desc;
  }

  String translateTaskDate(String date) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Jun 2025': 'ಜೂನ್ 2025',
        'This week': 'ಈ ವಾರ',
        'Week 4': 'ವಾರ 4',
        'Month 2': 'ತಿಂಗಳು 2',
        'Oct 2025': 'ಅಕ್ಟೋ 2025',
        'Upcoming': 'ಮುಂಬರುವ',
        'Info': 'ಮಾಹಿತಿ',
      };
      return map[date] ?? date;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Jun 2025': 'जून 2025',
        'This week': 'इस सप्ताह',
        'Week 4': 'सप्ताह 4',
        'Month 2': 'माह 2',
        'Oct 2025': 'अक्टूबर 2025',
        'Upcoming': 'आगामी',
        'Info': 'जानकारी',
      };
      return map[date] ?? date;
    }
    return date;
  }

  String translateExpenseCategory(String category) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Seeds': 'ಬೀಜಗಳು',
        'Fertilizer': 'ರಸಗೊಬ್ಬರ',
        'Pesticide': 'ಕೀಟನಾಶಕ',
        'Labour': 'ಕೂಲಿ ವೆಚ್ಚ',
        'Irrigation': 'ನೀರಾವರಿ',
        'Equipment': 'ಉಪಕರಣ ಬಾಡಿಗೆ',
        'Transport': 'ಸಾರಿಗೆ',
        'Other': 'ಇತರ ವೆಚ್ಚ',
      };
      return map[category] ?? translate(category);
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Seeds': 'बीज',
        'Fertilizer': 'उर्वरक',
        'Pesticide': 'कीटनाशक',
        'Labour': 'मजदूरी',
        'Irrigation': 'सिंचाई',
        'Equipment': 'उपकरण',
        'Transport': 'परिवहन',
        'Other': 'अन्य',
      };
      return map[category] ?? translate(category);
    }
    return category;
  }

  String translateCropHealthTitle(String title) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Ragi Blast (Neck Blast)': 'ರಾಗಿ ಬೆಂಕಿ ರೋಗ (ಕುತ್ತಿಗೆ ಬೆಂಕಿ)',
        'Paddy Stem Borer': 'ಭತ್ತದ ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು',
        'Cotton Bollworm': 'ಹತ್ತಿ ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು',
        'Sugarcane Red Rot & Early Shoot Borer': 'ಕಬ್ಬಿನ ಕೆಂಪು ಕೊಳೆ ರೋಗ & ಸುಳಿ ಕೊರೆಯುವ ಹುಳು',
        'Silkworm Grasserie & Uzi Fly': 'ರೇಷ್ಮೆ ಹುಳು ಗ್ರಾಸ್ಸರಿ & ಉಜಿ ನೊಣ',
        'Marigold Bud Borer & Leaf Spot': 'ಚೆಂಡು ಹೂ ಮೊಗ್ಗು ಕೊರೆಯುವ ಹುಳು & ಎಲೆ ಚುಕ್ಕೆ ರೋಗ',
        'Jasmine Blossom Midge & Spider Mites': 'ಮಲ್ಲಿಗೆ ಮೊಗ್ಗು ನೊಣ & ಕೆಂಪು ಜೇಡ ನುಸಿ',
        'Chrysanthemum Foliar Rust & Aphids': 'ಶೇವಂತಿ ಎಲೆ ತುಕ್ಕು ರೋಗ & ಹೇನುಗಳು',
        'Parthenium Weed': 'ಕಾಂಗ್ರೆಸ್ ಗಿಡ (ಪಾರ್ಥೇನಿಯಂ ಕಳೆ)',
      };
      return map[title] ?? title;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Ragi Blast (Neck Blast)': 'रागी ब्लास्ट (गर्दन ब्लास्ट)',
        'Paddy Stem Borer': 'धान का तना छेदक कीट',
        'Cotton Bollworm': 'कपास का बोलवर्म (सुंडी)',
        'Sugarcane Red Rot & Early Shoot Borer': 'गन्ना लाल सड़न एवं प्ररोह छेदक',
        'Silkworm Grasserie & Uzi Fly': 'रेशम कीट ग्रैसरी एवं उजी मक्खी',
        'Marigold Bud Borer & Leaf Spot': 'गेंदा कली छेदक एवं पत्ती धब्बा रोग',
        'Jasmine Blossom Midge & Spider Mites': 'चमेली कली मिज एवं मकड़ी माइट्स',
        'Chrysanthemum Foliar Rust & Aphids': 'गुलदाउदी पत्ती रतुआ एवं एफिड्स (माहू)',
        'Parthenium Weed': 'गाजर घास (पार्थेनियम खरपतवार)',
      };
      return map[title] ?? title;
    }
    return title;
  }

  String translateCropHealthSymptoms(String s) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Diamond-shaped lesions on leaves; neck rotting; empty grains.':
            'ಎಲೆಗಳ ಮೇಲೆ ವಜ್ರಾಕಾರದ ಚುಕ್ಕೆಗಳು; ಕುತ್ತಿಗೆ ಕೊಳೆಯುವಿಕೆ; ಜಳ್ಳು ಕಾಳುಗಳು.',
        'Dead heart in vegetative stage; white ear at panicle stage.':
            'ಬೆಳವಣಿಗೆ ಹಂತದಲ್ಲಿ ಒಣಗಿದ ಸುಳಿ; ತೆನೆ ಹಂತದಲ್ಲಿ ಬಿಳಿ ತೆನೆ.',
        'Damaged bolls; frass visible; early boll drop.':
            'ಹಾಳಾದ ಹತ್ತಿ ಕಾಯಿಗಳು; ಕಾಯಿ ಉದುರುವುದು.',
        'Crown leaves wither and turn red-brown; internal stalk pith reddens with white cross bands; dead hearts in young tillers.':
            'ತುದಿಯ ಎಲೆಗಳು ಒಣಗಿ ಕೆಂಪು-ಕಂದು ಬಣ್ಣಕ್ಕೆ ತಿರುಗುತ್ತವೆ; ಕಬ್ಬಿನ ಒಳಭಾಗ ಕೆಂಪಾಗಿ ಬಿಳಿ ಪಟ್ಟಿಗಳು ಕಾಣುತ್ತವೆ; ಒಣಗಿದ ಸುಳಿ.',
        'Larval segments swell, oily appearance, skin easily ruptures leaking infectious milky hemolymph; black egg scars on worm body.':
            'ಹುಳುಗಳ ಖಂಡಗಳು ಉಬ್ಬುತ್ತವೆ, ಎಣ್ಣೆಯುಕ್ತ ನೋಟ, ಚರ್ಮ ಸುಲಭವಾಗಿ ಒಡೆದು ಬಿಳಿ ದ್ರವ ಹೊರಬರುತ್ತದೆ; ಹುಳುವಿನ ಮೈಮೇಲೆ ಕಪ್ಪು ಮೊಟ್ಟೆಯ ಕಲೆಗಳು.',
        'Bored cavities in developing flower buds; concentric brown necrotic lesions on leaves leading to premature drying.':
            'ಮೊಗ್ಗುಗಳಲ್ಲಿ ರಂಧ್ರಗಳು; ಎಲೆಗಳ ಮೇಲೆ ಏಕಕೇಂದ್ರಿತ ಕಂದು ಕಲೆಗಳು ಮತ್ತು ಅಕಾಲಿಕ ಒಣಗುವಿಕೆ.',
        'Buds become swollen and turn pinkish without opening; yellow specks and delicate webbing under foliage.':
            'ಮೊಗ್ಗುಗಳು ಅರಳದೆ ಊದಿಕೊಂಡು ಗುಲಾಬಿ ಬಣ್ಣಕ್ಕೆ ತಿರುಗುತ್ತವೆ; ಎಲೆಗಳ ಕೆಳಗೆ ಹಳದಿ ಚುಕ್ಕೆಗಳು ಮತ್ತು ಸೂಕ್ಷ್ಮ ಜಾಲರಿ.',
        'Clusters of black/brown aphids distorting tips and flower buds; brown powdery rust pustules on leaf undersides.':
            'ಕುಡಿ ಮತ್ತು ಮೊಗ್ಗುಗಳಲ್ಲಿ ಕಪ್ಪು/ಕಂದು ಹೇನುಗಳ ಗುಂಪು; ಎಲೆಗಳ ಕೆಳಗೆ ಕಂದು ಪುಡಿಯಂತಹ ತುಕ್ಕು ಕಲೆಗಳು.',
        'White flower weed spreading rapidly in fields and borders.':
            'ಜಮೀನು ಮತ್ತು ಬದುಗಳಲ್ಲಿ ವೇಗವಾಗಿ ಹರಡುವ ಬಿಳಿ ಹೂವಿನ ಕಳೆ.',
      };
      return map[s] ?? s;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Diamond-shaped lesions on leaves; neck rotting; empty grains.':
            'पत्तियों पर हीरे के आकार के धब्बे; गर्दन का सड़ना; खाली दाने।',
        'Dead heart in vegetative stage; white ear at panicle stage.':
            'वानस्पतिक अवस्था में डेड हार्ट; बाली अवस्था में सफेद बाली।',
        'Damaged bolls; frass visible; early boll drop.':
            'क्षतिग्रस्त गूलर; कीड़े का मल दिखना; समय से पहले गूलर गिरना।',
        'Crown leaves wither and turn red-brown; internal stalk pith reddens with white cross bands; dead hearts in young tillers.':
            'शीर्ष पत्तियां मुरझाकर लाल-भूरी हो जाती हैं; तने का भीतरी भाग लाल हो जाता है; युवा कल्लियों में डेड हार्ट।',
        'Larval segments swell, oily appearance, skin easily ruptures leaking infectious milky hemolymph; black egg scars on worm body.':
            'लार्वा के खंड सूज जाते हैं, तैलीय बनावट, त्वचा आसानी से फटकर दूधिया तरल निकलता है; शरीर पर काले अंडे के निशान।',
        'Bored cavities in developing flower buds; concentric brown necrotic lesions on leaves leading to premature drying.':
            'विकसित होती कलियों में छेद; पत्तियों पर गोल भूरे धब्बे जिससे पत्तियां समय से पहले सूखती हैं।',
        'Buds become swollen and turn pinkish without opening; yellow specks and delicate webbing under foliage.':
            'कलियां फूलकर बिना खिले गुलाबी हो जाती हैं; पत्तियों के नीचे पीले धब्बे और बारीक जाला।',
        'Clusters of black/brown aphids distorting tips and flower buds; brown powdery rust pustules on leaf undersides.':
            'काले/भूरे माहू का प्रकोप; पत्तियों की निचली सतह पर भूरे चूर्ण जैसे रतुआ के फफोले।',
        'White flower weed spreading rapidly in fields and borders.':
            'खेतों और मेड़ों पर तेजी से फैलने वाला सफेद फूल वाला खरपतवार।',
      };
      return map[s] ?? s;
    }
    return s;
  }

  String translateCropHealthAction(String a) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Use resistant varieties (MR6, GPU-28). Spray Tricyclazole 75WP. Consult KVK for timing.':
            'ರೋಗ ನಿರೋಧಕ ತಳಿಗಳನ್ನು ಬಳಸಿ (MR-6, GPU-28). ಟ್ರೈಸೈಕ್ಲಾಜೋಲ್ 75WP ಸಿಂಪಡಿಸಿ. ಸಮಯಕ್ಕಾಗಿ ಕೆವಿಕೆ ಸಂಪರ್ಕಿಸಿ.',
        'Apply Chlorpyriphos granules at transplanting. Use light traps. Avoid excess nitrogen.':
            'ನಾಟಿ ಸಮಯದಲ್ಲಿ ಕ್ಲೋರ್‌ಪೈರಿಫಾಸ್ ಹರಳುಗಳನ್ನು ಹಾಕಿ. ಬೆಳಕಿನ ಬಲೆಗಳನ್ನು ಬಳಸಿ. ಅತಿಯಾದ ಸಾರಜನಕ ತಪ್ಪಿಸಿ.',
        'Monitor using pheromone traps. Bt cotton has built-in resistance. Consult local input dealer.':
            'ಫೆರಮೋನ್ ಬಲೆಗಳ ಮೂಲಕ ಗಮನಿಸಿ. ಬಿಟಿ ಹತ್ತಿಯಲ್ಲಿ ಅಂತರ್ಗತ ನಿರೋಧಕ ಶಕ್ತಿಯಿದೆ. ಸ್ಥಳೀಯ ಕೃಷಿ ಅಧಿಕಾರಿಯನ್ನು ಸಂಪರ್ಕಿಸಿ.',
        'Plant certified disease-free setts. Treat setts with Carbendazim 0.1%. Release Trichogramma parasitoids at 45 days.':
            'ದೃಢೀಕೃತ ರೋಗಮುಕ್ತ ಕಬ್ಬಿನ ತುಂಡುಗಳನ್ನು ನಾಟಿ ಮಾಡಿ. 0.1% ಕಾರ್ಬೆಂಡಾಜಿಮ್‌ನಿಂದ ಉಪಚರಿಸಿ. 45 ದಿನಗಳಲ್ಲಿ ಟ್ರೈಕೊಗ್ರಾಮಾ ಪರಾವಲಂಬಿ ಕೀಟಗಳನ್ನು ಬಿಡಿ.',
        'Disinfect rearing house with 2% bleach solution; dust Vijetha/lime powder; install fine mesh nylon nets on windows and doors.':
            '2% ಬ್ಲೀಚಿಂಗ್ ದ್ರಾವಣದಿಂದ ಕೋಣೆಯನ್ನು ಸೋಂಕುರಹಿತಗೊಳಿಸಿ; ವಿಜೇತಾ/ಸುಣ್ಣದ ಪುಡಿ ಧೂಳೀಕರಿಸಿ; ಕಿಟಕಿ-ಬಾಗಿಲುಗಳಿಗೆ ನೈಲಾನ್ ಜಾಲರಿ ಅಳವಡಿಸಿ.',
        'Spray Neem seed kernel extract (NSKE 5%) or Spinosad 45SC (0.3 ml/L) for borers; apply Mancozeb 75WP (2g/L) for leaf spot.':
            'ಕೊರೆಯುವ ಹುಳುಗಳಿಗೆ ಬೇವಿನ ಬೀಜದ ಕಷಾಯ (NSKE 5%) ಅಥವಾ ಸ್ಪಿನೋಸ್ಯಾಡ್ ಸಿಂಪಡಿಸಿ; ಎಲೆ ಚುಕ್ಕೆಗೆ ಮ್ಯಾಂಕೋಜೆಬ್ 75WP (2ಗ್ರಾಂ/ಲೀ) ಬಳಸಿ.',
        'Spray Chlorantraniliprole 18.5SC (0.3 ml/L) at flower bud initiation; apply Wettable Sulphur (3g/L) or Propargite for mites.':
            'ಮೊಗ್ಗು ಬರುವಾಗ ಕ್ಲೋರಾಂಟ್ರಾನಿಲಿಪ್ರೋಲ್ (0.3 ಮಿ.ಲೀ/ಲೀ) ಸಿಂಪಡಿಸಿ; ನುಸಿಗಳಿಗೆ ಗಂಧಕ (3ಗ್ರಾಂ/ಲೀ) ಅಥವಾ ಪ್ರೊಪರ್ಗೈಟ್ ಬಳಸಿ.',
        'Spray Imidacloprid 17.8SL (0.5 ml/L) or neem oil for aphids; apply Azoxystrobin (1 ml/L) or Mancozeb for rust prevention.':
            'ಹೇನುಗಳಿಗೆ ಇಮಿಡಾಕ್ಲೋಪ್ರಿಡ್ (0.5 ಮಿ.ಲೀ/ಲೀ) ಅಥವಾ ಬೇವಿನ ಎಣ್ಣೆ ಸಿಂಪಡಿಸಿ; ತುಕ್ಕು ರೋಗ ತಡೆಗಟ್ಟಲು ಅಜಾಕ್ಸಿಸ್ಟ್ರೋಬಿನ್ (1 ಮಿ.ಲೀ/ಲೀ) ಅಥವಾ ಮ್ಯಾಂಕೋಜೆಬ್ ಬಳಸಿ.',
        'Remove before flowering. Do not allow seed set. Manual removal is effective in small areas.':
            'ಹೂ ಬಿಡುವ ಮುನ್ನವೇ ಕಳೆ ಕೀಳಬೇಕು. ಬೀಜ ಕಟ್ಟಲು ಬಿಡಬೇಡಿ. ಸಣ್ಣ ಪ್ರದೇಶದಲ್ಲಿ ಕೈಯಿಂದ ಕೀಳುವುದು ಪರಿಣಾಮಕಾರಿ.',
      };
      return map[a] ?? a;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Use resistant varieties (MR6, GPU-28). Spray Tricyclazole 75WP. Consult KVK for timing.':
            'प्रतिरोधी किस्में (MR6, GPU-28) लगाएं। ट्राइसाइक्लाजोल 75WP का छिड़काव करें। समय के लिए केवीके से परामर्श लें।',
        'Apply Chlorpyriphos granules at transplanting. Use light traps. Avoid excess nitrogen.':
            'रोपाई के समय क्लोरपायरीफॉस दाने डालें। प्रकाश प्रपंच का प्रयोग करें। अतिरिक्त नाइट्रोजन से बचें।',
        'Monitor using pheromone traps. Bt cotton has built-in resistance. Consult local input dealer.':
            'फेरोमोन ट्रैप से निगरानी करें। बीटी कपास में अंतर्निहित प्रतिरोध होता है। स्थानीय कृषि अधिकारी से परामर्श करें।',
        'Plant certified disease-free setts. Treat setts with Carbendazim 0.1%. Release Trichogramma parasitoids at 45 days.':
            'प्रमाणित रोगमुक्त गन्ने के टुकड़ों की बुवाई करें। कार्बेन्डाजिम 0.1% से उपचारित करें। 45 दिनों में ट्राइकोग्रामा छोड़ें।',
        'Disinfect rearing house with 2% bleach solution; dust Vijetha/lime powder; install fine mesh nylon nets on windows and doors.':
            '2% ब्लीच घोल से पालन कक्ष को कीटाणुरहित करें; विजेता/चूना पाउडर छिड़कें; खिड़कियों और दरवाजों पर नायलॉन जाली लगाएं।',
        'Spray Neem seed kernel extract (NSKE 5%) or Spinosad 45SC (0.3 ml/L) for borers; apply Mancozeb 75WP (2g/L) for leaf spot.':
            'छेदक के लिए नीम बीज अर्क (NSKE 5%) या स्पिनोसाड 45SC छिड़कें; पत्ती धब्बे के लिए मैंकोजेब 75WP (2 ग्राम/लीटर) डालें।',
        'Spray Chlorantraniliprole 18.5SC (0.3 ml/L) at flower bud initiation; apply Wettable Sulphur (3g/L) or Propargite for mites.':
            'कली बनते समय क्लोरेंट्रानिलिप्रोल (0.3 मिली/लीटर) छिड़कें; माइट्स के लिए घुलनशील गंधक (3 ग्राम/लीटर) का प्रयोग करें।',
        'Spray Imidacloprid 17.8SL (0.5 ml/L) or neem oil for aphids; apply Azoxystrobin (1 ml/L) or Mancozeb for rust prevention.':
            'माहू के लिए इमिडाक्लोप्रिड (0.5 मिली/लीटर) या नीम तेल छिड़कें; रतुआ की रोकथाम के लिए एजोक्सीस्ट्रोबिन (1 मिली/लीटर) डालें।',
        'Remove before flowering. Do not allow seed set. Manual removal is effective in small areas.':
            'फूल आने से पहले उखाड़ें। बीज बनने न दें। छोटे क्षेत्रों में हाथ से उखाड़ना प्रभावी है।',
      };
      return map[a] ?? a;
    }
    return a;
  }

  String translateTwinWeek(String week) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Month 1': 'ತಿಂಗಳು 1',
        'Month 2': 'ತಿಂಗಳು 2',
        'Month 3–4': 'ತಿಂಗಳು 3–4',
        'Month 5–8': 'ತಿಂಗಳು 5–8',
        'Month 9–11': 'ತಿಂಗಳು 9–11',
        'Month 12–14': 'ತಿಂಗಳು 12–14',
        'Week 1–2': 'ವಾರ 1–2',
        'Week 3–4': 'ವಾರ 3–4',
        'Week 5–6': 'ವಾರ 5–6',
        'Week 7': 'ವಾರ 7',
        'Week 7–8': 'ವಾರ 7–8',
        'Week 8': 'ವಾರ 8',
        'Week 9+': 'ವಾರ 9+',
        'Week 9–12': 'ವಾರ 9–12',
        'Week 13+': 'ವಾರ 13+',
        'Week 5–7': 'ವಾರ 5–7',
        'Week 8–10': 'ವಾರ 8–10',
        'Week 11+': 'ವಾರ 11+',
      };
      return map[week] ?? week;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Month 1': 'माह 1',
        'Month 2': 'माह 2',
        'Month 3–4': 'माह 3–4',
        'Month 5–8': 'माह 5–8',
        'Month 9–11': 'माह 9–11',
        'Month 12–14': 'माह 12–14',
        'Week 1–2': 'सप्ताह 1–2',
        'Week 3–4': 'सप्ताह 3–4',
        'Week 5–6': 'सप्ताह 5–6',
        'Week 7': 'सप्ताह 7',
        'Week 7–8': 'सप्ताह 7–8',
        'Week 8': 'सप्ताह 8',
        'Week 9+': 'सप्ताह 9+',
        'Week 9–12': 'सप्ताह 9–12',
        'Week 13+': 'सप्ताह 13+',
        'Week 5–7': 'सप्ताह 5–7',
        'Week 8–10': 'सप्ताह 8–10',
        'Week 11+': 'सप्ताह 11+',
      };
      return map[week] ?? week;
    }
    return week;
  }

  String translateTwinTask(String task) {
    if (locale.languageCode == 'kn') {
      const map = {
        'Land preparation, furrow making, sett treatment with fungicide, planting':
            'ಜಮೀನು ಸಿದ್ಧತೆ, ಸಾಲು ನಿರ್ಮಾಣ, ಶಿಲೀಂಧ್ರನಾಶಕದಿಂದ ಕಬ್ಬಿನ ತುಂಡುಗಳ ಉಪಚಾರ, ನಾಟಿ',
        'First weeding, gap filling, first earthing up & shoot borer scouting':
            'ಮೊದಲ ಕಳೆ ಕೀಳುವುದು, ಅಂತರ ಭರ್ತಿ, ಮೊದಲ ಬುಡಕ್ಕೆ ಮಣ್ಣು ಏರಿಸುವುದು & ಸುಳಿ ಕೊರೆಯುವ ಹುಳು ಪರಿಶೀಲನೆ',
        'Top dressing (Urea/Potash), second earthing up, trash mulching':
            'ಮೇಲುಗೊಬ್ಬರ (ಯೂರಿಯಾ/ಪೊಟ್ಯಾಶ್), ಎರಡನೇ ಬಾರಿ ಮಣ್ಣು ಏರಿಸುವುದು, ಕಬ್ಬಿನ ರವದ ಹೊದಿಕೆ',
        'Grand growth phase — regular irrigation every 8-10 days, propping & detrashing':
            'ಮುಖ್ಯ ಬೆಳವಣಿಗೆಯ ಹಂತ — ಪ್ರತಿ 8-10 ದಿನಕ್ಕೊಮ್ಮೆ ನೀರಾವರಿ, ಆಸರೆ ನೀಡುವುದು ಮತ್ತು ಕೆಳ ಎಲೆ ತೆಗೆಯುವುದು',
        'Sucrose accumulation & ripening — taper down irrigation, stop nitrogen':
            'ಸಕ್ಕರೆ ಅಂಶ ಹೆಚ್ಚಳ & ಮಾಗುವಿಕೆ — ನೀರಾವರಿ ಕಡಿಮೆ ಮಾಡಿ, ಸಾರಜನಕ ಗೊಬ್ಬರ ನಿಲ್ಲಿಸಿ',
        'Brix refractometer check (18-20%), harvest cane close to ground, mill delivery':
            'ಬ್ರಿಕ್ಸ್ ಪರೀಕ್ಷೆ (18-20%), ನೆಲಮಟ್ಟಕ್ಕೆ ಕಬ್ಬು ಕತ್ತರಿಸಿ ಕೊಯ್ಲು, ಕಾರ್ಖಾನೆಗೆ ರವಾನೆ',
        'Mulberry garden pruning, FYM application, irrigation, rearing room 2% bleach disinfection':
            'ಹಿಪ್ಪುನೇರಳೆ ತೋಟ ಕತ್ತರಿಸುವುದು, ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ, ನೀರಾವರಿ, ಕೋಣೆಯನ್ನು 2% ಬ್ಲೀಚ್‌ನಿಂದ ಸೋಂಕುರಹಿತಗೊಳಿಸುವುದು',
        'Procure disease-free Chawki (2nd instar) silkworm larvae; set up rearing beds':
            'ರೋಗಮುಕ್ತ ಚಾಕಿ (2ನೇ ಹಂತದ) ರೇಷ್ಮೆ ಹುಳುಗಳನ್ನು ಪಡೆಯುವುದು; ಸಾಕಣೆ ಹಾಸಿಗೆ ಸಿದ್ಧತೆ',
        '3rd & 4th instar feeding with fresh mulberry leaves, bed cleaning, Vijetha dusting':
            '3ನೇ & 4ನೇ ಹಂತದ ಹುಳುಗಳಿಗೆ ತಾಜಾ ಹಿಪ್ಪುನೇರಳೆ ಎಲೆ ನೀಡುವುದು, ಹಾಸಿಗೆ ಸ್ವಚ್ಛತೆ, ವಿಜೇತಾ ಪುಡಿ ಧೂಳೀಕರಣ',
        '5th instar voracious feeding stage; ensure good ventilation and Uzi fly netting':
            '5ನೇ ಹಂತದ ತೀವ್ರ ಆಹಾರ ಸೇವನೆ ಹಂತ; ಉತ್ತಮ ಗಾಳಿ ಬೆಳಕು ಮತ್ತು ಉಜಿ ನೊಣ ಜಾಲರಿ ಖಚಿತಪಡಿಸಿ',
        'Mounting mature worms on Chandrike spinning frames; 3-4 days cocoon spinning':
            'ಮಾಗಿದ ಹುಳುಗಳನ್ನು ಚಂದ್ರಿಕೆಗೆ ಹಾಕುವುದು; 3-4 ದಿನಗಳ ಗೂಡು ಕಟ್ಟುವ ಪ್ರಕ್ರಿಯೆ',
        'Harvest cocoons, deflossing, sorting, transport to Govt Cocoon Market (Ramanagara)':
            'ಗೂಡುಗಳನ್ನು ಬಿಡಿಸುವುದು, ಕಸ ತೆಗೆಯುವುದು, ವಿಂಗಡಿಸಿ ರಾಮನಗರ ಸರ್ಕಾರಿ ರೇಷ್ಮೆ ಮಾರುಕಟ್ಟೆಗೆ ಸಾಗಿಸುವುದು',
        'Raised bed preparation, FYM incorporation, seedling transplanting in evening':
            'ಏರುಮಡಿ ಸಿದ್ಧತೆ, ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ ಬೆರೆಸುವುದು, ಸಂಜೆ ವೇಳೆಯಲ್ಲಿ ಸಸಿ ನಾಟಿ',
        'Gap filling, weeding, terminal shoot pinching (apical bud removal for bushy growth)':
            'ಅಂತರ ಭರ್ತಿ, ಕಳೆ ತೆಗೆಯುವುದು, ತುದಿ ಕುಡಿ ಚಿವುಟುವುದು (ಕವಲುಗಳು ಹೆಚ್ಚಲು ಪಿಂಚಿಂಗ್)',
        'Drip fertigation / top dressing, bud borer inspection, neem oil 3% spray':
            'ಹನಿ ನೀರಾವರಿ ಮೂಲಕ ಗೊಬ್ಬರ / ಮೇಲುಗೊಬ್ಬರ, ಮೊಗ್ಗು ಕೊರೆಯುವ ಹುಳು ಪರಿಶೀಲನೆ, ಬೇವಿನ ಎಣ್ಣೆ 3% ಸಿಂಪಡಣೆ',
        'Flower bud swelling stage, micronutrient foliar spray, soil moisture management':
            'ಮೊಗ್ಗು ಊದುವ ಹಂತ, ಲಘು ಪೋಷಕಾಂಶಗಳ ಸಿಂಪಡಣೆ, ಮಣ್ಣಿನ ತೇವಾಂಶ ನಿರ್ವಹಣೆ',
        'Peak flower harvest early morning every 3-4 days for festival market (Dasara/Diwali)':
            'ಹಬ್ಬದ ಮಾರುಕಟ್ಟೆಗೆ (ದಸರಾ/ದೀಪಾವಳಿ) ಪ್ರತಿ 3-4 ದಿನಕ್ಕೊಮ್ಮೆ ಮುಂಜಾನೆ ಹೂವು ಕೊಯ್ಲು',
        'Post-harvest irrigation, second flush harvesting or field clearance':
            'ಕೊಯ್ಲಿನ ನಂತರ ನೀರಾವರಿ, ಎರಡನೇ ಬಾರಿಯ ಹೂವು ಕೊಯ್ಲು ಅಥವಾ ಜಮೀನು ಸ್ವಚ್ಛತೆ',
        'Annual pruning of previous wood, basal FYM and fertilizer application around basin':
            'ಹಳೆಯ ಕೊಂಬೆಗಳ ವಾರ್ಷಿಕ ಕತ್ತರಿಸುವಿಕೆ, ಬುಡದ ಸುತ್ತ ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ ಮತ್ತು ರಾಸಾಯನಿಕ ಗೊಬ್ಬರ',
        'New vegetative flush initiation; irrigate every 5-7 days; weed basin area':
            'ಹೊಸ ಚಿಗುರು ಬರುವಿಕೆ; ಪ್ರತಿ 5-7 ದಿನಕ್ಕೊಮ್ಮೆ ನೀರಾವರಿ; ಬುಡದ ಕಳೆ ತೆಗೆಯುವುದು',
        'Flower bud initiation; prophylactic spray against blossom midge and spider mites':
            'ಹೂಮೊಗ್ಗು ಪ್ರಾರಂಭ; ಮೊಗ್ಗು ನೊಣ ಮತ್ತು ಕೆಂಪು ಜೇಡ ನುಸಿ ವಿರುದ್ಧ ಮುನ್ನೆಚ್ಚರಿಕೆ ಸಿಂಪಡಣೆ',
        'Daily morning manual plucking of mature unopened white buds for mandi / garlands':
            'ಮಾರುಕಟ್ಟೆ/ಹಾರಗಳಿಗಾಗಿ ಪ್ರತಿದಿನ ಮುಂಜಾನೆ ಅರಳದ ಬಿಳಿ ಮೊಗ್ಗುಗಳನ್ನು ಕೈಯಿಂದ ಕೊಯ್ಲು',
        'Raised bed preparation, root sucker transplanting, immediate light irrigation':
            'ಏರುಮಡಿ ಸಿದ್ಧತೆ, ಬೇರು ಸಸಿಗಳ ನಾಟಿ, ತಕ್ಷಣವೇ ಲಘು ನೀರಾವರಿ',
        'First pinching of main terminal shoot to stimulate profuse branch development':
            'ಹೆಚ್ಚು ಕವಲುಗಳು ಒಡೆಯಲು ಮುಖ್ಯ ತುದಿ ಕುಡಿಯ ಮೊದಲ ಪಿಂಚಿಂಗ್',
        'Second pinching, plant staking, prophylactic spray for aphids and rust':
            'ಎರಡನೇ ಪಿಂಚಿಂಗ್, ಗಿಡಗಳಿಗೆ ಆಸರೆ ನೀಡುವುದು, ಹೇನು ಮತ್ತು ತುಕ್ಕು ರೋಗ ತಡೆಗೆ ಸಿಂಪಡಣೆ',
        'Deep plowing, FYM application, seed treatment with Rhizobium/Trichoderma':
            'ಆಳವಾದ ಉಳುಮೆ, ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ, ರೈಜೋಬಿಯಂ/ಟ್ರೈಕೋಡರ್ಮಾ ಜೈವಿಕ ಗೊಬ್ಬರದಿಂದ ಬೀಜೋಪಚಾರ',
        'Line sowing / broad bed furrow, light pre-emergence herbicide if needed':
            'ಸಾಲು ಬಿತ್ತನೆ / ಏರುಮಡಿ ಬಿತ್ತನೆ, ಅಗತ್ಯವಿದ್ದರೆ ಕಳೆನಾಶಕ ಸಿಂಪಡಣೆ',
        'First weeding, thinning, gap filling, soil aeration':
            'ಮೊದಲ ಕಳೆ ಕೀಳುವುದು, ಸಸಿ ವಿರಳೀಕರಣ, ಅಂತರ ಭರ್ತಿ, ಮಣ್ಣು ಸಡಿಲಗೊಳಿಸುವಿಕೆ',
        'Vegetative growth phase, first critical irrigation (crown root initiation / tillering)':
            'ಸಸ್ಯ ಬೆಳವಣಿಗೆಯ ಹಂತ, ಮೊದಲ ಪ್ರಮುಖ ನೀರಾವರಿ (ಬೇರು ಬಿಡುವ/ಕವಲೊಡೆಯುವ ಹಂತ)',
        'Top dressing with Urea/potash, stem borer / pest inspection':
            'ಯೂರಿಯಾ/ಪೊಟ್ಯಾಶ್ ಮೇಲುಗೊಬ್ಬರ, ಕಾಂಡ ಕೊರೆಯುವ ಕೀಟ ಪರಿಶೀಲನೆ',
        'Flowering & grain formation stage — second critical irrigation, disease watch':
            'ಹೂವಾಡುವ & ಕಾಳು ಕಟ್ಟುವ ಹಂತ — ಎರಡನೇ ಪ್ರಮುಖ ನೀರಾವರಿ, ರೋಗಗಳ ಬಗ್ಗೆ ನಿಗಾ',
        'Dough / maturity stage — taper off water, watch for earhead bugs/birds':
            'ಕಾಳು ಗಟ್ಟಿಯಾಗುವ ಹಂತ — ನೀರು ನಿಲ್ಲಿಸುವುದು, ತೆನೆ ತಿಗಣೆ/ಪಕ್ಷಿಗಳಿಂದ ರಕ್ಷಣೆ',
        'Harvest at 15-20% grain moisture, threshing, drying to < 12% before storage':
            '15-20% ಕಾಳು ತೇವಾಂಶದಲ್ಲಿ ಕೊಯ್ಲು, ಒಕ್ಕಣೆ, ಸಂಗ್ರಹಣೆಗೆ ಮುನ್ನ < 12% ರವರೆಗೆ ಒಣಗಿಸುವುದು',
      };
      return map[task] ?? task;
    } else if (locale.languageCode == 'hi') {
      const map = {
        'Land preparation, furrow making, sett treatment with fungicide, planting':
            'खेत की तैयारी, नाली बनाना, कवकनाशी से गन्ने के टुकड़ों का उपचार, बुवाई',
        'First weeding, gap filling, first earthing up & shoot borer scouting':
            'पहली निराई, छूटे स्थान भरना, पहली बार मिट्टी चढ़ाना व प्ररोह छेदक की जांच',
        'Top dressing (Urea/Potash), second earthing up, trash mulching':
            'टॉप ड्रेसिंग (यूरिया/पोटाश), दूसरी बार मिट्टी चढ़ाना, सूखी पत्तियों की मल्चिंग',
        'Grand growth phase — regular irrigation every 8-10 days, propping & detrashing':
            'तीव्र वृद्धि चरण — प्रत्येक 8-10 दिनों में नियमित सिंचाई, बंधाई व सूखी पत्ती हटाना',
        'Sucrose accumulation & ripening — taper down irrigation, stop nitrogen':
            'शर्करा संचय एवं परिपक्वता — सिंचाई कम करें, नाइट्रोजन देना बंद करें',
        'Brix refractometer check (18-20%), harvest cane close to ground, mill delivery':
            'ब्रिक्स जांच (18-20%), जमीन की सतह से गन्ने की कटाई, मिल को आपूर्ति',
        'Mulberry garden pruning, FYM application, irrigation, rearing room 2% bleach disinfection':
            'शहतूत बगीचे की छंटाई, गोबर खाद, सिंचाई, पालन कक्ष का 2% ब्लीच से कीटाणुशोधन',
        'Procure disease-free Chawki (2nd instar) silkworm larvae; set up rearing beds':
            'रोगमुक्त चाकी (द्वितीयावस्था) रेशम कीट प्राप्त करना; पालन शैय्या तैयार करना',
        '3rd & 4th instar feeding with fresh mulberry leaves, bed cleaning, Vijetha dusting':
            'तृतीय व चतुर्थ अवस्था को ताजी शहतूत पत्तियां खिलाना, सफाई, विजेता पाउडर छिड़कना',
        '5th instar voracious feeding stage; ensure good ventilation and Uzi fly netting':
            'पंचम अवस्था तीव्र आहार चरण; उचित वेंटिलेशन और उजी मक्खी जाली सुनिश्चित करें',
        'Mounting mature worms on Chandrike spinning frames; 3-4 days cocoon spinning':
            'परिपक्व कीड़ों को चंद्रिका फ्रेम पर चढ़ाना; 3-4 दिन कोकून कताई',
        'Harvest cocoons, deflossing, sorting, transport to Govt Cocoon Market (Ramanagara)':
            'कोकून कटाई, छंटाई, रामनगर सरकारी कोकून मंडी ले जाना',
        'Raised bed preparation, FYM incorporation, seedling transplanting in evening':
            'उठी हुई क्यारी तैयारी, गोबर खाद मिलाना, शाम के समय पौधों की रोपाई',
        'Gap filling, weeding, terminal shoot pinching (apical bud removal for bushy growth)':
            'स्थान भरना, निराई, मुख्य शाखा की नोक तोड़ना (घनी बढ़वार के लिए पिंचिंग)',
        'Drip fertigation / top dressing, bud borer inspection, neem oil 3% spray':
            'ड्रिप फर्टिगेशन / टॉप ड्रेसिंग, कली छेदक निरीक्षण, नीम तेल 3% छिड़काव',
        'Flower bud swelling stage, micronutrient foliar spray, soil moisture management':
            'फूल कली वृद्धि अवस्था, सूक्ष्म पोषक तत्वों का छिड़काव, नमी प्रबंधन',
        'Peak flower harvest early morning every 3-4 days for festival market (Dasara/Diwali)':
            'त्योहारी बाजार के लिए प्रत्येक 3-4 दिन में सुबह जल्दी फूलों की तुड़ाई',
        'Post-harvest irrigation, second flush harvesting or field clearance':
            'तुड़ाई उपरांत सिंचाई, द्वितीय तुड़ाई अथवा खेत की सफाई',
        'Annual pruning of previous wood, basal FYM and fertilizer application around basin':
            'पुरानी टहनियों की वार्षिक छंटाई, थाले में गोबर खाद एवं उर्वरक डालना',
        'New vegetative flush initiation; irrigate every 5-7 days; weed basin area':
            'नई शाखाओं का फुटाव; प्रत्येक 5-7 दिन में सिंचाई; थाले की निराई',
        'Flower bud initiation; prophylactic spray against blossom midge and spider mites':
            'कली बनना प्रारंभ; कली मिज व मकड़ी कीट से बचाव हेतु छिड़काव',
        'Daily morning manual plucking of mature unopened white buds for mandi / garlands':
            'मंडी/मालाओं के लिए प्रतिदिन सुबह बिना खिली सफेद कलियों की तुड़ाई',
        'Raised bed preparation, root sucker transplanting, immediate light irrigation':
            'उठी क्यारी तैयारी, जड़ वाले पौधों की रोपाई, तत्काल हल्की सिंचाई',
        'First pinching of main terminal shoot to stimulate profuse branch development':
            'अधिक शाखाओं के लिए मुख्य तने की पहली पिंचिंग',
        'Second pinching, plant staking, prophylactic spray for aphids and rust':
            'दूसरी पिंचिंग, पौधों को सहारा देना, माहू एवं रतुआ नियंत्रण हेतु छिड़काव',
        'Deep plowing, FYM application, seed treatment with Rhizobium/Trichoderma':
            'गहरी जुताई, गोबर खाद, राइजोबियम/ट्राइकोडर्मा से बीजोपचार',
        'Line sowing / broad bed furrow, light pre-emergence herbicide if needed':
            'कतार बुवाई / उठी क्यारी पद्धति, आवश्यकतानुसार खरपतवार नाशक',
        'First weeding, thinning, gap filling, soil aeration':
            'पहली निराई, विरलीकरण, स्थान भरना, मिट्टी में वायु संचार',
        'Vegetative growth phase, first critical irrigation (crown root initiation / tillering)':
            'वानस्पतिक वृद्धि, पहली महत्वपूर्ण सिंचाई (जड़ विकास/कल्ले फूटना)',
        'Top dressing with Urea/potash, stem borer / pest inspection':
            'यूरिया/पोटाश की टॉप ड्रेसिंग, तना छेदक/कीट निरीक्षण',
        'Flowering & grain formation stage — second critical irrigation, disease watch':
            'फूल व दाना बनने की अवस्था — दूसरी महत्वपूर्ण सिंचाई, रोग निगरानी',
        'Dough / maturity stage — taper off water, watch for earhead bugs/birds':
            'दाना पकने की अवस्था — पानी बंद करें, कीट/पक्षियों से बचाव',
        'Harvest at 15-20% grain moisture, threshing, drying to < 12% before storage':
            '15-20% नमी पर कटाई, मड़ाई, भंडारण से पूर्व < 12% तक सुखाना',
      };
      return map[task] ?? task;
    }
    return task;
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
