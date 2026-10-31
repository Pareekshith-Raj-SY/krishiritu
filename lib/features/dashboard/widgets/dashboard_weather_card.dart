import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/services/weather_service.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../farms/providers/farm_provider.dart';
import '../../../app.dart';

class DashboardWeatherCard extends ConsumerStatefulWidget {
  const DashboardWeatherCard({super.key});

  @override
  ConsumerState<DashboardWeatherCard> createState() => _DashboardWeatherCardState();
}

class _DashboardWeatherCardState extends ConsumerState<DashboardWeatherCard> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardWeather();
    });
  }

  Future<void> _loadDashboardWeather() async {
    final farm = ref.read(farmProvider);
    final district = farm?.district ?? 'Bengaluru';

    try {
      final data = await _weatherService.getWeather(district, forceRefresh: false);
      if (mounted) {
        setState(() {
          _weather = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final farm = ref.watch(farmProvider);
    final districtName = farm != null
        ? l10n.translateDistrict(farm.district)
        : l10n.translateDistrict('Bengaluru');

    final weather = _weather;
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
          color: Colors.white.withValues(alpha: 0.94),
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
              // Header: Weather API Title + Configured ✓ Badge + Arrow
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
                          _isLoading ? Icons.sync : Icons.check_circle,
                          size: 12,
                          color: AppColors.leafGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isLoading ? 'Syncing...' : l10n.t('configured'),
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

              // Live Weather Overview: Temp, Condition, District
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 13, color: AppColors.earthBrown),
                            const SizedBox(width: 2),
                            Text(
                              districtName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.earthBrown,
                              ),
                            ),
                            if (weather?.isCached == true) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.t('cached'),
                                  style: const TextStyle(fontSize: 9.5, color: AppColors.textMedium),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Metric chips: Humidity, Rain, Wind
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

              const SizedBox(height: 10),

              // Bottom footer: Observation Time & Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        child: Row(
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
      ),
    );
  }
}
