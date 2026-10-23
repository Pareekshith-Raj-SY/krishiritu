import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../features/farms/providers/farm_provider.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return '${l10n.t('good_morning')} 🌅';
    if (h < 17) return '${l10n.t('good_afternoon')} ☀️';
    return '${l10n.t('good_evening')} 🌙';
  }

  String _currentSeason(AppLocalizations l10n) {
    final m = DateTime.now().month;
    if (m >= 6 && m <= 10) return l10n.t('kharif_season');
    if (m >= 11 || m <= 2) return l10n.t('rabi_season');
    return l10n.t('summer_season');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.50),
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🌿', style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 8),
                            const Text(
                              'KrishiRitu AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                            ),
                            const Spacer(),
                            _languageSelectorMenu(context, ref, locale),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () => context.push('/notifications'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _greeting(l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          farm != null ? '${farm.name} · ${farm.district}' : l10n.t('welcome_farmer'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Present Date Display
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppDateUtils.formatPresentDate(DateTime.now(), locale.languageCode),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Language Selector on Dashboard (Kannada, English, Hindi)
                        _languageToggleBar(ref, locale),
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
                  _seasonCard(context, l10n),
                  const SizedBox(height: 16),
                  _sectionTitle(l10n.t('quick_actions')),
                  const SizedBox(height: 10),
                  _quickActions(context, l10n),
                  const SizedBox(height: 16),
                  if (farm != null) _farmSummaryCard(context, farm, l10n),
                  const SizedBox(height: 16),
                  _sectionTitle(l10n.t('explore_features')),
                  const SizedBox(height: 10),
                  _featureGrid(context, l10n),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageToggleBar(WidgetRef ref, Locale locale) {
    final current = locale.languageCode;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton(ref, 'kn', 'ಕನ್ನಡ', current == 'kn'),
          _langButton(ref, 'en', 'English', current == 'en'),
          _langButton(ref, 'hi', 'हिंदी', current == 'hi'),
        ],
      ),
    );
  }

  Widget _langButton(WidgetRef ref, String code, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).state = Locale(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.forestGreen : Colors.white,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            shadows: isSelected
                ? null
                : const [Shadow(color: Colors.black54, blurRadius: 2)],
          ),
        ),
      ),
    );
  }

  Widget _languageSelectorMenu(BuildContext context, WidgetRef ref, Locale locale) {
    return PopupMenuButton<String>(
      initialValue: locale.languageCode,
      onSelected: (code) {
        ref.read(localeProvider.notifier).state = Locale(code);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 38),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              locale.languageCode == 'kn'
                  ? 'ಕನ್ನಡ'
                  : locale.languageCode == 'hi'
                      ? 'हिंदी'
                      : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'kn',
          child: Row(
            children: [
              Text('🌾', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('ಕನ್ನಡ (Kannada)', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'hi',
          child: Row(
            children: [
              Text('🇮🇳', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('हिंदी (Hindi)', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _seasonCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.warmAmber, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Text('🗓️', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('current_season'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _currentSeason(l10n),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.earthBrown,
                  ),
                ),
                Text(
                  l10n.t('tap_season_plan'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.forestGreen,
          shadows: [Shadow(color: Colors.white, blurRadius: 3)],
        ),
      );

  Widget _quickActions(BuildContext context, AppLocalizations l10n) {
    final actions = [
      ('🌾', l10n.t('crop_plan'), '/crop-planner'),
      ('🌿', l10n.t('farm_twin'), '/season-twin'),
      ('💰', l10n.t('budget'), '/budget'),
      ('📍', l10n.t('services'), '/services-map'),
    ];
    return Row(
      children: actions.map((a) => Expanded(
        child: GestureDetector(
          onTap: () => context.push(a.$3),
          child: Card(
            color: Colors.white.withOpacity(0.92),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                Text(a.$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  a.$2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _farmSummaryCard(BuildContext context, farm, AppLocalizations l10n) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🏡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              l10n.t('farm_summary'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/farm-profile'),
              child: Text(l10n.t('edit')),
            ),
          ]),
          const Divider(),
          _farmRow(l10n.t('district'), farm.district),
          _farmRow(l10n.t('land_area'), '${farm.landAreaAcres} ${l10n.t('acres')}'),
          _farmRow(l10n.t('soil_type'), farm.soilType),
          _farmRow(l10n.t('irrigation'), farm.irrigationMethod),
          if (farm.currentCrop != null && farm.currentCrop!.isNotEmpty)
            _farmRow(l10n.t('current_crop'), farm.currentCrop!),
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

  Widget _featureGrid(BuildContext context, AppLocalizations l10n) {
    final features = [
      ('🌦️', l10n.t('weather_risks'), '/weather', AppColors.skyBlue.withOpacity(0.12)),
      ('🔬', l10n.t('crop_health_title'), '/crop-health', AppColors.leafGreen.withOpacity(0.12)),
      ('📊', l10n.t('what_if_sim'), '/simulator', AppColors.warmAmber.withOpacity(0.12)),
      ('📖', l10n.t('season_memory'), '/history', AppColors.earthBrown.withOpacity(0.12)),
      ('🔔', l10n.t('tasks'), '/notifications', AppColors.errorRed.withOpacity(0.12)),
      ('⚙️', l10n.t('settings'), '/settings', AppColors.textLight.withOpacity(0.12)),
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
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(f.$1, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                f.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      )).toList(),
    );
  }
}
