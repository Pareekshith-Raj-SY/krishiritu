import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../../features/farms/providers/farm_provider.dart';

class WeatherState {
  final WeatherData? weather;
  final String activeDistrict;
  final String locationDisplayName;
  final bool isGpsActive;
  final double? activeLat;
  final double? activeLon;
  final bool isLoading;
  final bool isDetectingGps;
  final String? errorMessage;

  const WeatherState({
    this.weather,
    this.activeDistrict = 'Bengaluru',
    this.locationDisplayName = 'Bengaluru',
    this.isGpsActive = false,
    this.activeLat,
    this.activeLon,
    this.isLoading = true,
    this.isDetectingGps = false,
    this.errorMessage,
  });

  WeatherState copyWith({
    WeatherData? weather,
    String? activeDistrict,
    String? locationDisplayName,
    bool? isGpsActive,
    double? activeLat,
    double? activeLon,
    bool? isLoading,
    bool? isDetectingGps,
    String? errorMessage,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      activeDistrict: activeDistrict ?? this.activeDistrict,
      locationDisplayName: locationDisplayName ?? this.locationDisplayName,
      isGpsActive: isGpsActive ?? this.isGpsActive,
      activeLat: activeLat ?? this.activeLat,
      activeLon: activeLon ?? this.activeLon,
      isLoading: isLoading ?? this.isLoading,
      isDetectingGps: isDetectingGps ?? this.isDetectingGps,
      errorMessage: errorMessage,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final Ref _ref;
  final WeatherService _service = WeatherService();

  static const String _keyDistrict = 'weather_active_district';
  static const String _keyIsGps = 'weather_is_gps';
  static const String _keyLat = 'weather_lat';
  static const String _keyLon = 'weather_lon';
  static const String _keyDisplayName = 'weather_display_name';

  WeatherNotifier(this._ref) : super(const WeatherState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final savedDistrict = prefs.getString(_keyDistrict);
      final isGps = prefs.getBool(_keyIsGps) ?? false;
      final lat = prefs.getDouble(_keyLat);
      final lon = prefs.getDouble(_keyLon);
      final displayName = prefs.getString(_keyDisplayName);

      if (isGps && lat != null && lon != null) {
        if (!mounted) return;
        state = state.copyWith(
          activeDistrict: savedDistrict ?? 'Bengaluru',
          locationDisplayName: displayName ?? savedDistrict ?? 'Bengaluru',
          isGpsActive: true,
          activeLat: lat,
          activeLon: lon,
          isLoading: true,
        );
        await _fetchCoordinatesWeather(lat, lon, displayName ?? savedDistrict ?? 'Bengaluru', forceRefresh: false);
        return;
      }

      if (savedDistrict != null && savedDistrict.isNotEmpty) {
        if (!mounted) return;
        state = state.copyWith(
          activeDistrict: savedDistrict,
          locationDisplayName: displayName ?? savedDistrict,
          isGpsActive: false,
          isLoading: true,
        );
        await _fetchDistrictWeather(savedDistrict, forceRefresh: false);
        return;
      }

      // Check farm profile
      final farm = _ref.read(farmProvider);
      if (farm != null && farm.district.isNotEmpty) {
        if (!mounted) return;
        state = state.copyWith(
          activeDistrict: farm.district,
          locationDisplayName: farm.district,
          isGpsActive: false,
          isLoading: true,
        );
        await _fetchDistrictWeather(farm.district, forceRefresh: false);
        return;
      }

      // Try GPS first before falling back to default
      final gpsSuccess = await detectGps(silently: true);
      if (!mounted) return;
      if (!gpsSuccess) {
        // Fall back to Bengaluru
        state = state.copyWith(
          activeDistrict: 'Bengaluru',
          locationDisplayName: 'Bengaluru',
          isGpsActive: false,
          isLoading: true,
        );
        await _fetchDistrictWeather('Bengaluru', forceRefresh: false);
      }
    } catch (_) {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Detect device GPS location and update weather
  Future<bool> detectGps({bool silently = false}) async {
    if (!mounted) return false;
    state = state.copyWith(isDetectingGps: true, isLoading: true, errorMessage: null);

    try {
      final gps = await _service.getCurrentGpsLocation();
      if (!mounted) return false;
      if (gps != null) {
        final nearestDistrict = WeatherService.findNearestDistrict(gps.lat, gps.lon);
        final displayName = gps.locationName;

        state = state.copyWith(
          isGpsActive: true,
          activeLat: gps.lat,
          activeLon: gps.lon,
          activeDistrict: nearestDistrict,
          locationDisplayName: displayName,
          isDetectingGps: false,
        );

        // Save preferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_keyIsGps, true);
          await prefs.setDouble(_keyLat, gps.lat);
          await prefs.setDouble(_keyLon, gps.lon);
          await prefs.setString(_keyDistrict, nearestDistrict);
          await prefs.setString(_keyDisplayName, displayName);
        } catch (_) {}

        if (mounted) {
          await _fetchCoordinatesWeather(gps.lat, gps.lon, displayName, forceRefresh: true);
        }
        return true;
      } else {
        if (mounted) {
          state = state.copyWith(isDetectingGps: false, isLoading: false);
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isDetectingGps: false, isLoading: false, errorMessage: e.toString());
      }
      return false;
    }
  }

  /// Set user-selected district manually
  Future<void> setDistrict(String district, {bool forceRefresh = false}) async {
    final clean = district.trim().isEmpty ? 'Bengaluru' : district.trim();
    state = state.copyWith(
      activeDistrict: clean,
      locationDisplayName: clean,
      isGpsActive: false,
      activeLat: null,
      activeLon: null,
      isLoading: true,
      errorMessage: null,
    );

    // Save preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsGps, false);
      await prefs.remove(_keyLat);
      await prefs.remove(_keyLon);
      await prefs.setString(_keyDistrict, clean);
      await prefs.setString(_keyDisplayName, clean);
    } catch (_) {}

    await _fetchDistrictWeather(clean, forceRefresh: forceRefresh);
  }

  /// Refresh weather for the current location
  Future<void> refresh() async {
    if (state.isGpsActive && state.activeLat != null && state.activeLon != null) {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _fetchCoordinatesWeather(
        state.activeLat!,
        state.activeLon!,
        state.locationDisplayName,
        forceRefresh: true,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _fetchDistrictWeather(state.activeDistrict, forceRefresh: true);
    }
  }

  Future<void> _fetchDistrictWeather(String district, {required bool forceRefresh}) async {
    try {
      final data = await _service.getWeather(district, forceRefresh: forceRefresh);
      if (!mounted) return;
      state = state.copyWith(weather: data, isLoading: false, errorMessage: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> _fetchCoordinatesWeather(double lat, double lon, String displayName, {required bool forceRefresh}) async {
    try {
      final data = await _service.getWeatherForCoordinates(
        latitude: lat,
        longitude: lon,
        locationDisplayName: displayName,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      state = state.copyWith(weather: data, isLoading: false, errorMessage: null);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref);
});
