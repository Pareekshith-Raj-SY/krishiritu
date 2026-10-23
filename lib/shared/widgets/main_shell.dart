import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'app_background.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home, label: 'Home', path: '/home'),
    (icon: Icons.agriculture_outlined, active: Icons.agriculture, label: 'My Farm', path: '/farm-profile'),
    (icon: Icons.calendar_month_outlined, active: Icons.calendar_month, label: 'Season Plan', path: '/crop-planner'),
    (icon: Icons.explore_outlined, active: Icons.explore, label: 'Explore', path: '/weather'),
    (icon: Icons.person_outline, active: Icons.person, label: 'Profile', path: '/settings'),
  ];

  int _currentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/farm-profile')) return 1;
    if (location.startsWith('/crop') || location.startsWith('/season') || location.startsWith('/simulator')) return 2;
    if (location.startsWith('/weather') || location.startsWith('/budget') ||
        location.startsWith('/services') || location.startsWith('/crop-health')) return 3;
    if (location.startsWith('/settings') || location.startsWith('/notifications') ||
        location.startsWith('/history')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _currentIndex(location);

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
              color: Colors.white.withOpacity(0.92),
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
                selectedItemColor: AppColors.leafGreen,
                unselectedItemColor: AppColors.textLight,
                currentIndex: idx,
                onTap: (i) => context.go(_tabs[i].path),
                items: _tabs.map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.active),
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
