import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/authentication/screens/splash_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/farms/screens/farm_setup_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/crop_planner/screens/crop_planner_screen.dart';
import '../../features/crop_planner/screens/crop_detail_screen.dart';
import '../../features/season_twin/screens/season_twin_screen.dart';
import '../../features/scenario_simulator/screens/scenario_simulator_screen.dart';
import '../../features/crop_health/screens/crop_health_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/services_map/screens/services_map_screen.dart';
import '../../features/season_history/screens/season_history_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/farms/screens/farm_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/farm-setup', builder: (c, s) => const FarmSetupScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const DashboardScreen()),
          GoRoute(path: '/crop-planner', builder: (c, s) => const CropPlannerScreen()),
          GoRoute(
            path: '/crop-detail/:cropId',
            builder: (c, s) => CropDetailScreen(cropId: s.pathParameters['cropId'] ?? ''),
          ),
          GoRoute(path: '/season-twin', builder: (c, s) => const SeasonTwinScreen()),
          GoRoute(path: '/simulator', builder: (c, s) => const ScenarioSimulatorScreen()),
          GoRoute(path: '/crop-health', builder: (c, s) => const CropHealthScreen()),
          GoRoute(path: '/weather', builder: (c, s) => const WeatherScreen()),
          GoRoute(path: '/budget', builder: (c, s) => const BudgetScreen()),
          GoRoute(path: '/services-map', builder: (c, s) => const ServicesMapScreen()),
          GoRoute(path: '/history', builder: (c, s) => const SeasonHistoryScreen()),
          GoRoute(path: '/notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          GoRoute(path: '/farm-profile', builder: (c, s) => const FarmProfileScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
