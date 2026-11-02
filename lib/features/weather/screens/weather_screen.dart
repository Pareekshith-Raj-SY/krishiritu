import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/services/weather_service.dart';
import '../../../data/providers/weather_provider.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';
import '../../farms/providers/farm_provider.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weather;
  bool _isLoading = true;
  bool _isDetectingLocation = false;
  String? _errorMessage;

  String _activeLocationName = 'Bengaluru';
  String _activeDistrict = 'Bengaluru';
  bool _isGpsActive = false;
  double? _activeLat;
  double? _activeLon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = ref.read(weatherProvider);
      if (wp.weather != null) {
        setState(() {
          _weather = wp.weather;
          _isLoading = false;
          _activeDistrict = wp.activeDistrict;
          _activeLocationName = wp.locationDisplayName;
          _isGpsActive = wp.isGpsActive;
          _activeLat = wp.activeLat;
          _activeLon = wp.activeLon;
        });
      } else {
        _initWeather();
      }
    });
  }

  Future<void> _initWeather() async {
    final wp = ref.read(weatherProvider);
    if (wp.weather != null) {
      if (mounted) {
        setState(() {
          _weather = wp.weather;
          _isLoading = false;
          _activeDistrict = wp.activeDistrict;
          _activeLocationName = wp.locationDisplayName;
          _isGpsActive = wp.isGpsActive;
          _activeLat = wp.activeLat;
          _activeLon = wp.activeLon;
        });
      }
      return;
    }

    final farm = ref.read(farmProvider);
    final fallbackDistrict = farm?.district ?? 'Bengaluru';

    setState(() {
      _isDetectingLocation = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First try to auto-detect device's live GPS location
      final gps = await _weatherService.getCurrentGpsLocation();
      if (gps != null && mounted) {
        final nearestDistrict = WeatherService.findNearestDistrict(gps.lat, gps.lon);
        setState(() {
          _isGpsActive = true;
          _activeLat = gps.lat;
          _activeLon = gps.lon;
          _activeLocationName = gps.locationName;
          _activeDistrict = nearestDistrict;
          _isDetectingLocation = false;
        });

        final data = await _weatherService.getWeatherForCoordinates(
          latitude: gps.lat,
          longitude: gps.lon,
          locationDisplayName: gps.locationName,
          forceRefresh: false,
        );

        if (mounted) {
          setState(() {
            _weather = data;
            _isLoading = false;
          });
        }
        ref.read(weatherProvider.notifier).detectGps();
        return;
      }
    } catch (_) {}

    // Fall back to farm district or Bengaluru
    if (mounted) {
      setState(() {
        _isGpsActive = false;
        _activeLocationName = fallbackDistrict;
        _activeDistrict = fallbackDistrict;
        _isDetectingLocation = false;
      });
      _loadDistrictWeather(fallbackDistrict);
    }
  }

  Future<void> _loadDistrictWeather(String district, {bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getWeather(
        district,
        forceRefresh: forceRefresh,
        isCurrentLocation: false,
      );
      if (mounted) {
        setState(() {
          _weather = data;
          _isLoading = false;
        });
      }
      ref.read(weatherProvider.notifier).setDistrict(district, forceRefresh: forceRefresh);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _detectCurrentGpsLocation() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isDetectingLocation = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gps = await _weatherService.getCurrentGpsLocation();
      if (gps != null) {
        final nearestDistrict = WeatherService.findNearestDistrict(gps.lat, gps.lon);
        setState(() {
          _isGpsActive = true;
          _activeLat = gps.lat;
          _activeLon = gps.lon;
          _activeLocationName = gps.locationName;
          _activeDistrict = nearestDistrict;
          _isDetectingLocation = false;
        });

        final data = await _weatherService.getWeatherForCoordinates(
          latitude: gps.lat,
          longitude: gps.lon,
          locationDisplayName: gps.locationName,
          forceRefresh: true,
        );

        if (mounted) {
          setState(() {
            _weather = data;
            _isLoading = false;
          });
          ref.read(weatherProvider.notifier).detectGps();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 ${l10n.t('gps_detected')}: ${gps.locationName}'),
              backgroundColor: AppColors.forestGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isDetectingLocation = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.t('location_denied')),
              backgroundColor: AppColors.warmAmber,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _refreshWeather() async {
    if (_isGpsActive && _activeLat != null && _activeLon != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await _weatherService.getWeatherForCoordinates(
        latitude: _activeLat!,
        longitude: _activeLon!,
        locationDisplayName: _activeLocationName,
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _weather = data;
          _isLoading = false;
        });
      }
    } else {
      _loadDistrictWeather(_activeDistrict, forceRefresh: true);
    }
  }

  void _openDistrictPicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = WeatherService.allDistricts.where((d) {
              final translated = l10n.translateDistrict(d).toLowerCase();
              final raw = d.toLowerCase();
              final q = query.toLowerCase().trim();
              return translated.contains(q) || raw.contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.t('all_districts'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: l10n.t('select_district'),
                          prefixIcon: const Icon(Icons.search, color: AppColors.forestGreen),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            query = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final districtName = filtered[index];
                            final isSelected = !_isGpsActive && _activeDistrict == districtName;
                            final translatedName = l10n.translateDistrict(districtName);

                            return ListTile(
                              leading: Icon(
                                isSelected ? Icons.check_circle : Icons.location_city_rounded,
                                color: isSelected ? AppColors.forestGreen : AppColors.textLight,
                              ),
                              title: Text(
                                translatedName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.forestGreen : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                districtName,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.leafGreen.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l10n.t('current_location'),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.forestGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _isGpsActive = false;
                                  _activeLocationName = districtName;
                                  _activeDistrict = districtName;
                                  _activeLat = null;
                                  _activeLon = null;
                                });
                                _loadDistrictWeather(districtName, forceRefresh: true);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('weather_seasonal_risk')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
        actions: [
          // GPS Location Button
          IconButton(
            icon: _isDetectingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                  )
                : Icon(
                    _isGpsActive ? Icons.my_location_rounded : Icons.location_searching_rounded,
                    color: _isGpsActive ? AppColors.forestGreen : AppColors.textMedium,
                  ),
            tooltip: l10n.t('use_current_location'),
            onPressed: (_isLoading || _isDetectingLocation) ? null : _detectCurrentGpsLocation,
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.forestGreen),
            tooltip: l10n.t('refresh_weather'),
            onPressed: _isLoading ? null : _refreshWeather,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _liveWeatherCard(l10n, locale.languageCode, farm?.district),
          const SizedBox(height: 12),
          _quickActionButtons(l10n),
          const SizedBox(height: 16),
          _seasonalRisk(_activeDistrict, l10n, locale.languageCode),
          const SizedBox(height: 16),
          _riskCalendar(l10n, locale.languageCode),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _quickActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        // Button: Use Current GPS Location
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (_isLoading || _isDetectingLocation) ? null : _detectCurrentGpsLocation,
            icon: _isDetectingLocation
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                  )
                : const Icon(Icons.my_location_rounded, size: 16),
            label: Text(
              l10n.t('use_current_location'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isGpsActive
                  ? AppColors.leafGreen.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.92),
              foregroundColor: AppColors.forestGreen,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isGpsActive ? AppColors.leafGreen : Colors.black12,
                  width: _isGpsActive ? 1.5 : 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Button: Change Karnataka District
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _openDistrictPicker(context, l10n),
            icon: const Icon(Icons.map_outlined, size: 16),
            label: Text(
              l10n.t('change_district'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.92),
              foregroundColor: AppColors.forestGreen,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _liveWeatherCard(AppLocalizations l10n, String langCode, String? farmDistrict) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.skyBlue),
              const SizedBox(height: 14),
              Text(
                _isDetectingLocation ? l10n.t('detecting_gps') : 'Fetching live meteorological weather...',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final data = _weather;
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage ?? 'Weather temporarily unavailable. Please retry.',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: _refreshWeather,
              child: Text(l10n.t('retry')),
            ),
          ],
        ),
      );
    }

    final isGps = _isGpsActive || data.isCurrentLocation;
    final displayLoc = isGps ? data.city : l10n.translateDistrict(data.city);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF155E75),
            Color(0xFF0E7490),
            Color(0xFF0284C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7490).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Location, GPS status, and Provider Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isGps ? Icons.my_location_rounded : Icons.location_on,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$displayLoc · ${l10n.t('live_weather')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isGps)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.t('gps_live'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Live source pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      data.source,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Present Date & Time Banner (Inside Weather API Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppDateUtils.formatPresentDateTime(data.observationTime, langCode),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.t('present_information'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Main Temperature & Weather Condition
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                data.conditionEmoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.tempC.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translateWeatherCondition(data.condition),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.t('feels_like')}: ${data.apparentTempC.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // 4. Weather Metrics Grid: Humidity, Rainfall, Wind
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Humidity
              _metricPill(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF67E8F9),
                label: l10n.t('humidity'),
                value: '${data.humidity.toStringAsFixed(0)}%',
                subtitle: '% RH',
              ),
              // Rainfall / Precipitation
              _metricPill(
                icon: Icons.umbrella_rounded,
                iconColor: const Color(0xFF93C5FD),
                label: l10n.t('rainfall'),
                value: '${data.rainfall.toStringAsFixed(1)} mm',
                subtitle: data.rainfall > 0 ? l10n.t('rain_active') : l10n.t('dry'),
              ),
              // Wind Speed
              _metricPill(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF6EE7B7),
                label: l10n.t('wind'),
                value: '${data.windSpeedKmH.toStringAsFixed(0)} km/h',
                subtitle: 'Speed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.90),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _seasonalRisk(String district, AppLocalizations l10n, String langCode) {
    final month = DateTime.now().month;
    final risks = _getRisks(month, langCode, l10n);
    final districtName = l10n.translateDistrict(district);

    return Card(
      color: Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '📍 ${l10n.t('seasonal_risks')} — $districtName',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.t('based_on_conditions')} ${_monthName(month, langCode)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
          const Divider(height: 20),
          ...risks.map((r) => _riskRow(r)),
        ]),
      ),
    );
  }

  List<Map<String, String>> _getRisks(int month, String lang, AppLocalizations l10n) {
    if (month >= 6 && month <= 9) {
      if (lang == 'kn') {
        return [
          {'icon': '🌧️', 'risk': 'ಭಾರೀ ಮುಂಗಾರು ಮಳೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಜಮೀನಿನಲ್ಲಿ ಬಸಿಗಾಲುವೆ ಒದಗಿಸಿ; ನೀರು ನಿಂತಿದ್ದರೆ ಬಿತ್ತನೆ ಮುಂದೂಡಿ'},
          {'icon': '🍄', 'risk': 'ಶಿಲೀಂಧ್ರ ರೋಗಗಳು (ಬೆಂಕಿ, ಅಂಗಮಾರಿ)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಬೆಳೆ ಪರಿಶೀಲಿಸಿ; ಮುನ್ನೆಚ್ಚರಿಕೆಯಾಗಿ ಶಿಲೀಂಧ್ರನಾಶಕ ಸಿಂಪಡಿಸಿ'},
          {'icon': '🐛', 'risk': 'ಕಾಂಡ ಕೊರೆಯುವ ಕೀಟ', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಫೆರಮೋನ್ ಬಲೆಗಳನ್ನು ಬಳಸಿ; ವಾರಕ್ಕೊಮ್ಮೆ ಪರಿಶೀಲಿಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '🌧️', 'risk': 'भारी मानसूनी बारिश', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'खेत में जल निकासी सुनिश्चित करें; जलभराव हो तो बुवाई टालें'},
          {'icon': '🍄', 'risk': 'फंगल रोग (ब्लास्ट, झुलसा)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'फसल की निगरानी करें; कवकनाशी का छिड़काव करें'},
          {'icon': '🐛', 'risk': 'तना छेदक कीट', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'फेरोमोन ट्रैप लगाएं; साप्ताहिक निगरानी करें'},
        ];
      }
      return [
        {'icon': '🌧️', 'risk': 'Heavy Monsoon Rainfall', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Ensure field drainage; delay sowing if waterlogged'},
        {'icon': '🍄', 'risk': 'Fungal Diseases (Blast, Blight)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Monitor crop; apply fungicide preventively'},
        {'icon': '🐛', 'risk': 'Stem Borer Activity', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Deploy pheromone traps; scout weekly'},
      ];
    }
    if (month >= 10 && month <= 11) {
      if (lang == 'kn') {
        return [
          {'icon': '🌾', 'risk': 'ಖರೀಫ್ ಕೊಯ್ಲು ಅವಧಿ', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'ಕೊಯ್ಲು ಯೋಜಿಸಿ; ಒಣಗಿಸುವ ಮತ್ತು ಸಂಗ್ರಹಣಾ ಸ್ಥಳವನ್ನು ವ್ಯವಸ್ಥೆ ಮಾಡಿ'},
          {'icon': '💨', 'risk': 'ಈಶಾನ್ಯ ಮಾನ್ಸೂನ್', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಕೊಯ್ಲಿನ ಸಮಯದಲ್ಲಿ ಅಕಾಲಿಕ ಮಳೆಯನ್ನು ಗಮನಿಸಿ'},
          {'icon': '🌱', 'risk': 'ರಬಿ ಬಿತ್ತನೆ ಅವಧಿ', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'ಜಮೀನು ಸಿದ್ಧಪಡಿಸಿ; ರಬಿ ಬೀಜದ ತಳಿಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '🌾', 'risk': 'खरीफ कटाई अवधि', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'कटाई की योजना बनाएं; सुखाने और भंडारण की व्यवस्था करें'},
          {'icon': '💨', 'risk': 'उत्तर-पूर्वी मानसून', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'कटाई के समय बेमौसम बारिश पर नज़र रखें'},
          {'icon': '🌱', 'risk': 'रबी बुवाई खिड़की', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'भूमि तैयार करें; रबी बीज किस्मों की व्यवस्था करें'},
        ];
      }
      return [
        {'icon': '🌾', 'risk': 'Kharif Harvest Period', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'Plan harvest; arrange drying and storage space'},
        {'icon': '💨', 'risk': 'North-East Monsoon', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Watch for unseasonal rains during harvest'},
        {'icon': '🌱', 'risk': 'Rabi Sowing Window', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'Prepare land; procure Rabi seed varieties'},
      ];
    }
    if (month >= 12 || month <= 2) {
      if (lang == 'kn') {
        return [
          {'icon': '❄️', 'risk': 'ತಂಪಾದ ರಾತ್ರಿಗಳು (ಉತ್ತರ ಕರ್ನಾಟಕದಲ್ಲಿ < 10°C)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಸಸಿಮಡಿಗಳನ್ನು ರಕ್ಷಿಸಿ; ಶೀತದ ಸಮಯದಲ್ಲಿ ನಾಟಿ ಮುಂದೂಡಿ'},
          {'icon': '💧', 'risk': 'ನೀರಾವರಿ ಅವಲಂಬನೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ನೀರಿನ ಲಭ್ಯತೆ ಖಚಿತಪಡಿಸಿ; ದಕ್ಷತೆಗಾಗಿ ಹನಿ ನೀರಾವರಿ ಬಳಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '❄️', 'risk': 'ठंडी रातें (उत्तर कर्नाटक में < 10°C)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'नर्सरी की रक्षा करें; अत्यधिक ठंड में रोपाई टालें'},
          {'icon': '💧', 'risk': 'सिंचाई निर्भरता', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'पानी की उपलब्धता सुनिश्चित करें; ड्रिप सिंचाई अपनाएं'},
        ];
      }
      return [
        {'icon': '❄️', 'risk': 'Cold Nights (< 10°C in north Karnataka)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Protect nursery beds; delay transplanting during cold spells'},
        {'icon': '💧', 'risk': 'Irrigation Dependency', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Ensure water availability; use drip for efficiency'},
      ];
    }
    if (lang == 'kn') {
      return [
        {'icon': '☀️', 'risk': 'ಶಾಖದ ಒತ್ತಡ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಸಂಜೆ ನೀರಾವರಿ ಮಾಡಿ; ತೇವಾಂಶ ಉಳಿಸಿಕೊಳ್ಳಲು ಹೊದಿಕೆ ಬಳಸಿ'},
        {'icon': '💧', 'risk': 'ನೀರಿನ ಕೊರತೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಮಳೆಯಾಶ್ರಿತ ಬೆಳೆಗಳು ಮಾತ್ರ; ನೀರನ್ನು ಕಟ್ಟುನಿಟ್ಟಾಗಿ ಉಳಿಸಿ'},
      ];
    } else if (lang == 'hi') {
      return [
        {'icon': '☀️', 'risk': 'गर्मी का तनाव', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'शाम को सिंचाई करें; नमी बनाए रखने के लिए मल्चिंग करें'},
        {'icon': '💧', 'risk': 'पानी की कमी', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'केवल वर्षा आधारित फसलें; पानी की बचत करें'},
      ];
    }
    return [
      {'icon': '☀️', 'risk': 'Heat Stress', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Irrigate in evening; use mulching to retain moisture'},
      {'icon': '💧', 'risk': 'Water Scarcity', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Only rainfed crops; conserve water strictly'},
    ];
  }

  Widget _riskRow(Map<String, String> r) {
    final rawLevel = r['rawLevel'] ?? 'Low';
    final levelColor = rawLevel == 'High'
        ? AppColors.errorRed
        : rawLevel == 'Medium'
            ? AppColors.warmAmber
            : AppColors.leafGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r['icon']!, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(r['risk']!, style: const TextStyle(fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r['level']!,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: levelColor),
                ),
              ),
            ]),
            const SizedBox(height: 3),
            Text(r['action']!, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
          ]),
        ),
      ]),
    );
  }

  Widget _riskCalendar(AppLocalizations l10n, String langCode) => Card(
        color: Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '📅 ${l10n.t('crop_risk_calendar')}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._calendarRows(langCode),
          ]),
        ),
      );

  List<Widget> _calendarRows(String lang) {
    final rowsEn = [
      ('June–July', 'Kharif sowing; monsoon onset; flood risk in lowlands'),
      ('August', 'Peak monsoon; disease pressure high; waterlogging in clay soils'),
      ('September', 'Late monsoon; blast risk in ragi/paddy; check drainage'),
      ('October', 'Monsoon withdrawal; kharif harvest begins; rabi preparation'),
      ('November–February', 'Rabi season; fog/cold in north KA; irrigation critical'),
      ('March–May', 'Summer crops only; extreme heat; borewell water stress'),
    ];

    final rowsKn = [
      ('ಜೂನ್–ಜುಲೈ', 'ಖರೀಫ್ ಬಿತ್ತನೆ; ಮುಂಗಾರು ಆರಂಭ; ತಗ್ಗು ಪ್ರದೇಶಗಳಲ್ಲಿ ಪ್ರವಾಹದ ಅಪಾಯ'),
      ('ಆಗಸ್ಟ್', 'ಗರಿಷ್ಠ ಮುಂಗಾರು; ರೋಗದ ಒತ್ತಡ ಹೆಚ್ಚು; ಜೇಡಿಮಣ್ಣಿನಲ್ಲಿ ನೀರು ನಿಲ್ಲುವಿಕೆ'),
      ('ಸೆಪ್ಟೆಂಬರ್', 'ಮುಂಗಾರು ಮುಕ್ತಾಯ; ರಾಗಿ/ಭತ್ತದಲ್ಲಿ ಬೆಂಕಿ ರೋಗದ ಅಪಾಯ; ಬಸಿಗಾಲುವೆ ಪರಿಶೀಲಿಸಿ'),
      ('ಅಕ್ಟೋಬರ್', 'ಮುಂಗಾರು ನಿರ್ಗಮನ; ಖರೀಫ್ ಕೊಯ್ಲು ಆರಂಭ; ರಬಿ ಸಿದ್ಧತೆ'),
      ('ನವೆಂಬರ್–ಫೆಬ್ರವರಿ', 'ರಬಿ ಋತು; ಉತ್ತರ ಕರ್ನಾಟಕದಲ್ಲಿ ಮಂಜು/ಚಳಿ; ನೀರಾವರಿ ಮುಖ್ಯ'),
      ('ಮಾರ್ಚ್–ಮೇ', 'ಬೇಸಿಗೆ ಬೆಳೆಗಳು ಮಾತ್ರ; ತೀವ್ರ ಶಾಖ; ಕೊಳವೆಬಾವಿ ನೀರಿನ ಕೊರತೆ'),
    ];

    final rowsHi = [
      ('जून–जुलाई', 'खरीफ बुवाई; मानसून आगमन; निचले इलाकों में बाढ़ का जोखिम'),
      ('अगस्त', 'चरम मानसून; रोग का दबाव अधिक; चिकनी मिट्टी में जलभराव'),
      ('सितंबर', 'देर से मानसून; रागी/धान में ब्लास्ट रोग जोखिम; जल निकासी जांचें'),
      ('अक्टूबर', 'मानसून वापसी; खरीफ कटाई प्रारंभ; रबी की तैयारी'),
      ('नवंबर–फरवरी', 'रबी मौसम; उत्तर कर्नाटक में कोहरा/ठंड; सिंचाई महत्वपूर्ण'),
      ('मार्च–मई', 'केवल ग्रीष्मकालीन फसलें; अत्यधिक गर्मी; बोरवेल पानी की कमी'),
    ];

    final rows = (lang == 'kn') ? rowsKn : (lang == 'hi') ? rowsHi : rowsEn;

    return rows.map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 110,
              child: Text(
                r.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.leafGreen,
                ),
              ),
            ),
            Expanded(child: Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.textMedium))),
          ]),
        )).toList();
  }

  String _monthName(int m, String lang) {
    final en = ['', 'January','February','March','April','May','June','July','August','September','October','November','December'];
    final kn = ['', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್'];
    final hi = ['', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

    if (lang == 'kn') return kn[m];
    if (lang == 'hi') return hi[m];
    return en[m];
  }
}
