import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/farms/providers/farm_provider.dart';
import '../../../shared/localization/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning 🌅';
    if (h < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  String _currentSeason() {
    final m = DateTime.now().month;
    if (m >= 6 && m <= 10) return 'Kharif Season (Jun–Oct)';
    if (m >= 11 || m <= 2) return 'Rabi Season (Nov–Feb)';
    return 'Summer Season (Mar–May)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.forestGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.forestGreen, AppColors.leafGreen],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('🌿', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 8),
                          const Text('KrishiRitu AI',
                              style: TextStyle(color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () => context.push('/notifications'),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(_greeting(), style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                        Text(
                          farm != null ? '${farm.name} · ${farm.district}' : 'Welcome, Farmer!',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seasonCard(context),
                  const SizedBox(height: 16),
                  _sectionTitle('Quick Actions'),
                  const SizedBox(height: 10),
                  _quickActions(context),
                  const SizedBox(height: 16),
                  if (farm != null) _farmSummaryCard(context, farm),
                  const SizedBox(height: 16),
                  _sectionTitle('Explore Features'),
                  const SizedBox(height: 10),
                  _featureGrid(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seasonCard(BuildContext context) {
    return Card(
      color: AppColors.warmAmber.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.warmAmber, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('🗓️', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Current Season', style: TextStyle(
                fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
            Text(_currentSeason(), style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.earthBrown)),
            const Text('Tap Season Plan to get crop recommendations →',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
          ])),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark));

  Widget _quickActions(BuildContext context) {
    final actions = [
      ('🌾', 'Crop Plan', '/crop-planner'),
      ('🌿', 'Farm Twin', '/season-twin'),
      ('💰', 'Budget', '/budget'),
      ('📍', 'Services', '/services-map'),
    ];
    return Row(
      children: actions.map((a) => Expanded(
        child: GestureDetector(
          onTap: () => context.push(a.$3),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                Text(a.$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(a.$2, style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _farmSummaryCard(BuildContext context, farm) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🏡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('Farm Summary', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/farm-profile'),
              child: const Text('Edit'),
            ),
          ]),
          const Divider(),
          _farmRow('District', farm.district),
          _farmRow('Land Area', '${farm.landAreaAcres} acres'),
          _farmRow('Soil Type', farm.soilType),
          _farmRow('Irrigation', farm.irrigationMethod),
          if (farm.currentCrop != null && farm.currentCrop!.isNotEmpty)
            _farmRow('Current Crop', farm.currentCrop!),
        ]),
      ),
    );
  }

  Widget _farmRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text('$k: ', style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    ]),
  );

  Widget _featureGrid(BuildContext context) {
    final features = [
      ('🌦️', 'Weather & Risks', '/weather', AppColors.skyBlue.withOpacity(0.1)),
      ('🔬', 'Crop Health', '/crop-health', AppColors.leafGreen.withOpacity(0.1)),
      ('📊', 'What-If Sim', '/simulator', AppColors.warmAmber.withOpacity(0.1)),
      ('📖', 'Season Memory', '/history', AppColors.earthBrown.withOpacity(0.1)),
      ('🔔', 'Tasks', '/notifications', AppColors.errorRed.withOpacity(0.1)),
      ('⚙️', 'Settings', '/settings', AppColors.textLight.withOpacity(0.1)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: features.map((f) => GestureDetector(
        onTap: () => context.push(f.$3),
        child: Container(
          decoration: BoxDecoration(
            color: f.$4, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(f.$1, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(f.$2, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      )).toList(),
    );
  }
}
