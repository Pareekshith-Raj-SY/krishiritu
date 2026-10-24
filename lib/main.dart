import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'data/services/supabase_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env safely
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Init Hive
  await Hive.initFlutter();

  // Initialize cached Supabase state
  await SupabaseService.init();

  // Init Supabase only if valid non-placeholder configuration is provided
  if (AppConfig.hasSupabase) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (_) {
      // Graceful offline fallback
    }
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable true edge-to-edge full display with transparent system bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load saved language preference
  String initialLang = 'en';
  try {
    final prefs = await SharedPreferences.getInstance();
    initialLang = prefs.getString('app_language') ?? 'en';
  } catch (_) {}
  if (!['en', 'kn', 'hi'].contains(initialLang)) {
    initialLang = 'en';
  }

  runApp(ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => Locale(initialLang)),
    ],
    child: const KrishiRituApp(),
  ));
}
