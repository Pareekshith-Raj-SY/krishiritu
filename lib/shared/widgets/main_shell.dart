import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../localization/app_localizations.dart';
import 'app_background.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  int _currentIndex(String location) {
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/farm-profile')) {
      return 1;
    }
    if (location.startsWith('/crop') || location.startsWith('/season') || location.startsWith('/simulator')) {
      return 2;
    }
    if (location.startsWith('/weather') || location.startsWith('/budget') ||
        location.startsWith('/services') || location.startsWith('/crop-health')) {
      return 3;
    }
    if (location.startsWith('/settings') || location.startsWith('/notifications') ||
        location.startsWith('/history')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _currentIndex(location);
    final l10n = AppLocalizations.of(context);

    final tabs = [
      (icon: Icons.home_outlined, active: Icons.home, label: l10n.t('home'), path: '/home'),
      (icon: Icons.agriculture_outlined, active: Icons.agriculture, label: l10n.t('my_farm'), path: '/farm-profile'),
      (icon: Icons.calendar_month_outlined, active: Icons.calendar_month, label: l10n.t('season_plan'), path: '/crop-planner'),
      (icon: Icons.explore_outlined, active: Icons.explore, label: l10n.t('explore'), path: '/weather'),
      (icon: Icons.person_outline, active: Icons.person, label: l10n.t('profile'), path: '/settings'),
    ];

    return AppBackground(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedItemColor: AppColors.forestGreen,
                unselectedItemColor: AppColors.textMedium,
                currentIndex: idx,
                onTap: (i) => context.go(tabs[i].path),
                items: tabs.map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon, size: 22),
                  activeIcon: Icon(t.active, size: 22),
                  label: t.label,
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
