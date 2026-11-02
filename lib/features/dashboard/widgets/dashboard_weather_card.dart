import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/providers/weather_provider.dart';
import '../../../data/services/weather_service.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../farms/providers/farm_provider.dart';
import '../../../app.dart';

class DashboardWeatherCard extends ConsumerWidget {
  const DashboardWeatherCard({super.key});

  void _showLocationPicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final farm = ref.read(farmProvider);
    final weatherNotifier = ref.read(weatherProvider.notifier);
    final currentState = ref.read(weatherProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredDistricts = WeatherService.allDistricts.where((d) {
              final translated = l10n.translateDistrict(d).toLowerCase();
              final raw = d.toLowerCase();
              final q = searchQuery.toLowerCase().trim();
              return raw.contains(q) || translated.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 12, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.forestGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          l10n.t('select_district'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textMedium),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Live GPS button + Farm Profile button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Live GPS Auto-detect Button
                        InkWell(
                          onTap: () async {
                            Navigator.pop(ctx);
                            final success = await weatherNotifier.detectGps();
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.t('location_denied')),
                                  backgroundColor: AppColors.warmAmber,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.my_location, color: AppColors.forestGreen, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.t('use_gps_location'),
                                    style: const TextStyle(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                if (currentState.isGpsActive)
                                  const Icon(Icons.check_circle, color: AppColors.forestGreen, size: 18),
                              ],
                            ),
                          ),
                        ),

                        // Farm District Button (if configured)
                        if (farm != null && farm.district.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              weatherNotifier.setDistrict(farm.district, forceRefresh: true);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F7F4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.agriculture, color: AppColors.earthBrown, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${l10n.t('use_farm_district')}: ${l10n.translateDistrict(farm.district)}',
                                      style: const TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (val) {
                        setSheetState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: l10n.t('search_district'),
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.forestGreen),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  // District List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filteredDistricts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, idx) {
                        final d = filteredDistricts[idx];
                        final translatedName = l10n.translateDistrict(d);
                        final isSelected = !currentState.isGpsActive &&
                            (currentState.activeDistrict.toLowerCase() == d.toLowerCase());

                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_city,
                            color: isSelected ? AppColors.forestGreen : AppColors.textMedium,
                            size: 20,
                          ),
                          title: Text(
                            translatedName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.forestGreen : AppColors.textDark,
                            ),
                          ),
                          subtitle: translatedName != d
                              ? Text(d, style: const TextStyle(fontSize: 11, color: AppColors.textLight))
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.forestGreen, size: 18)
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            weatherNotifier.setDistrict(d, forceRefresh: true);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final weatherState = ref.watch(weatherProvider);
    final weatherNotifier = ref.read(weatherProvider.notifier);

    final weather = weatherState.weather;
    final isLoading = weatherState.isLoading;

    // Determine display location name
    final rawLocation = weatherState.locationDisplayName.isNotEmpty
        ? weatherState.locationDisplayName
        : weatherState.activeDistrict;
    final translatedLocation = l10n.translateDistrict(rawLocation);
    final displayLocation = translatedLocation.isNotEmpty ? translatedLocation : rawLocation;

    final temp = weather != null ? '${weather.tempC.toStringAsFixed(1)}°C' : '--°C';
    final conditionText = weather != null
        ? l10n.translateWeatherCondition(weather.condition)
        : l10n.t('clear_sky');
    final emoji = weather?.conditionEmoji ?? '🌤️';

    return GestureDetector(
      onTap: () => context.push('/weather'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Weather API Title + Live Sync Status + Refresh Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.cloud, color: AppColors.forestGreen, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('weather_api'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      Text(
                        l10n.t('weather_api_live_status'),
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Quick Refresh Button
                  IconButton(
                    tooltip: l10n.t('refresh_weather'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                          )
                        : const Icon(Icons.refresh, size: 18, color: AppColors.forestGreen),
                    onPressed: isLoading ? null : () => weatherNotifier.refresh(),
                  ),
                  const SizedBox(width: 4),

                  // Configured status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.leafGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.leafGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoading ? Icons.sync : Icons.check_circle,
                          size: 12,
                          color: AppColors.leafGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLoading ? 'Syncing...' : l10n.t('configured'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textLight),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Live Weather Overview: Temp, Condition, Resolved Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              temp,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                conditionText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location row with interactive picker button & GPS tag
                        GestureDetector(
                          onTap: () => _showLocationPicker(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.earthBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 13, color: AppColors.earthBrown),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    displayLocation,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.earthBrown,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (weatherState.isGpsActive) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.leafGreen.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10n.t('live_gps'),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.forestGreen,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 4),
                                const Icon(Icons.edit_location_alt_outlined, size: 12, color: AppColors.earthBrown),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Metric chips: Humidity, Rain, Wind with both value & sub-label
              Row(
                children: [
                  _metricChip(
                    icon: Icons.water_drop_outlined,
                    label: '${weather?.humidity.toInt() ?? 60}%',
                    sub: l10n.t('humidity'),
                  ),
                  const SizedBox(width: 8),
                  _metricChip(
                    icon: Icons.umbrella_outlined,
                    label: '${weather?.rainfall.toStringAsFixed(1) ?? '0.0'} mm',
                    sub: l10n.t('rain_prob'),
                  ),
                  const SizedBox(width: 8),
                  _metricChip(
                    icon: Icons.air_outlined,
                    label: '${weather?.windSpeedKmH.toStringAsFixed(1) ?? '10.0'} km/h',
                    sub: l10n.t('wind_speed'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom footer: Observation Time & Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 13, color: AppColors.forestGreen),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        weather != null
                            ? AppDateUtils.formatPresentDateTime(weather.observationTime, locale.languageCode)
                            : l10n.t('tap_to_view_forecast'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.forestGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l10n.t('view_details'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricChip({required IconData icon, required String label, required String sub}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: AppColors.forestGreen),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
