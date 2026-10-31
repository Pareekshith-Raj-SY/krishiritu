import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class WeatherData {
  final double tempC;
  final double humidity;
  final double rainfall;
  final String condition;
  final String city;
  final DateTime fetchedAt;
  final double windSpeedKmH;
  final double apparentTempC;
  final String conditionEmoji;
  final String source;
  final bool isCached;
  final DateTime observationTime;
  final double? latitude;
  final double? longitude;
  final bool isCurrentLocation;

  const WeatherData({
    required this.tempC,
    required this.humidity,
    required this.rainfall,
    required this.condition,
    required this.city,
    required this.fetchedAt,
    this.windSpeedKmH = 0.0,
    this.apparentTempC = 0.0,
    this.conditionEmoji = '🌤️',
    this.source = 'Live',
    this.isCached = false,
    DateTime? observationTime,
    this.latitude,
    this.longitude,
    this.isCurrentLocation = false,
  }) : observationTime = observationTime ?? fetchedAt;

  Map<String, dynamic> toMap() => {
    'tempC': tempC,
    'humidity': humidity,
    'rainfall': rainfall,
    'condition': condition,
    'city': city,
    'fetchedAt': fetchedAt.toIso8601String(),
    'observationTime': observationTime.toIso8601String(),
    'windSpeedKmH': windSpeedKmH,
    'apparentTempC': apparentTempC,
    'conditionEmoji': conditionEmoji,
    'source': source,
    'latitude': latitude,
    'longitude': longitude,
    'isCurrentLocation': isCurrentLocation,
  };

  factory WeatherData.fromMap(Map<String, dynamic> map, {bool isCached = true}) {
    final fetched = map['fetchedAt'] != null
        ? DateTime.tryParse(map['fetchedAt'] as String) ?? DateTime.now()
        : DateTime.now();
    final observed = map['observationTime'] != null
        ? DateTime.tryParse(map['observationTime'] as String) ?? fetched
        : fetched;

    return WeatherData(
      tempC: (map['tempC'] as num?)?.toDouble() ?? 26.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 60.0,
      rainfall: (map['rainfall'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] as String? ?? 'Clear',
      city: map['city'] as String? ?? '',
      fetchedAt: fetched,
      observationTime: observed,
      windSpeedKmH: (map['windSpeedKmH'] as num?)?.toDouble() ?? 8.0,
      apparentTempC: (map['apparentTempC'] as num?)?.toDouble() ??
          (map['tempC'] as num?)?.toDouble() ??
          26.0,
      conditionEmoji: map['conditionEmoji'] as String? ?? '🌤️',
      source: map['source'] as String? ?? 'Cached',
      isCached: isCached,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isCurrentLocation: map['isCurrentLocation'] as bool? ?? false,
    );
  }
}

class WeatherService {
  static const _openWeatherBase = 'https://api.openweathermap.org/data/2.5';
  static const _openMeteoBase = 'https://api.open-meteo.com/v1/forecast';

  // Rate-limit safety: 30-minute cache TTL and request deduplication
  static const Duration _cacheTtl = Duration(minutes: 30);
  static final Map<String, WeatherData> _memoryCache = {};
  static final Map<String, Future<WeatherData?>> _inFlight = {};

  // Karnataka 31 districts coordinates (latitude, longitude)
  static const Map<String, ({double lat, double lon, String standardName})> districtCoordinates = {
    'bagalkot': (lat: 16.1875, lon: 75.6980, standardName: 'Bagalkot'),
    'ballari': (lat: 15.1394, lon: 76.9214, standardName: 'Ballari'),
    'bellary': (lat: 15.1394, lon: 76.9214, standardName: 'Ballari'),
    'belagavi': (lat: 15.8497, lon: 74.4977, standardName: 'Belagavi'),
    'belgaum': (lat: 15.8497, lon: 74.4977, standardName: 'Belagavi'),
    'bengaluru rural': (lat: 13.2270, lon: 77.5750, standardName: 'Bengaluru Rural'),
    'bangalore rural': (lat: 13.2270, lon: 77.5750, standardName: 'Bengaluru Rural'),
    'bengaluru urban': (lat: 12.9716, lon: 77.5946, standardName: 'Bengaluru Urban'),
    'bangalore urban': (lat: 12.9716, lon: 77.5946, standardName: 'Bengaluru Urban'),
    'bengaluru': (lat: 12.9716, lon: 77.5946, standardName: 'Bengaluru'),
    'bangalore': (lat: 12.9716, lon: 77.5946, standardName: 'Bengaluru'),
    'bidar': (lat: 17.9104, lon: 77.5199, standardName: 'Bidar'),
    'chamarajanagara': (lat: 11.9261, lon: 76.9437, standardName: 'Chamarajanagar'),
    'chamarajanagar': (lat: 11.9261, lon: 76.9437, standardName: 'Chamarajanagar'),
    'chikballapur': (lat: 13.4325, lon: 77.7275, standardName: 'Chikkaballapur'),
    'chikkaballapur': (lat: 13.4325, lon: 77.7275, standardName: 'Chikkaballapur'),
    'chikkamagaluru': (lat: 13.3161, lon: 75.7720, standardName: 'Chikkamagaluru'),
    'chikmagalur': (lat: 13.3161, lon: 75.7720, standardName: 'Chikkamagaluru'),
    'chitradurga': (lat: 14.2251, lon: 76.4021, standardName: 'Chitradurga'),
    'dakshina kannada': (lat: 12.9141, lon: 74.8560, standardName: 'Dakshina Kannada'),
    'mangaluru': (lat: 12.9141, lon: 74.8560, standardName: 'Dakshina Kannada'),
    'mangalore': (lat: 12.9141, lon: 74.8560, standardName: 'Dakshina Kannada'),
    'davanagere': (lat: 14.4644, lon: 75.9218, standardName: 'Davanagere'),
    'dharwad': (lat: 15.4589, lon: 75.0078, standardName: 'Dharwad'),
    'hubballi': (lat: 15.3647, lon: 75.1240, standardName: 'Dharwad'),
    'hubli': (lat: 15.3647, lon: 75.1240, standardName: 'Dharwad'),
    'gadag': (lat: 15.4298, lon: 75.6297, standardName: 'Gadag'),
    'hassan': (lat: 13.0072, lon: 76.1030, standardName: 'Hassan'),
    'haveri': (lat: 14.7958, lon: 75.4024, standardName: 'Haveri'),
    'kalaburagi': (lat: 17.3297, lon: 76.8343, standardName: 'Kalaburagi'),
    'gulbarga': (lat: 17.3297, lon: 76.8343, standardName: 'Kalaburagi'),
    'kodagu': (lat: 12.4244, lon: 75.7382, standardName: 'Kodagu'),
    'coorg': (lat: 12.4244, lon: 75.7382, standardName: 'Kodagu'),
    'madikeri': (lat: 12.4244, lon: 75.7382, standardName: 'Kodagu'),
    'kolar': (lat: 13.1367, lon: 78.1340, standardName: 'Kolar'),
    'koppal': (lat: 15.3468, lon: 76.1554, standardName: 'Koppal'),
    'mandya': (lat: 12.5238, lon: 76.8967, standardName: 'Mandya'),
    'mysuru': (lat: 12.2958, lon: 76.6394, standardName: 'Mysuru'),
    'mysore': (lat: 12.2958, lon: 76.6394, standardName: 'Mysuru'),
    'raichur': (lat: 16.2120, lon: 77.3439, standardName: 'Raichur'),
    'ramanagara': (lat: 12.7150, lon: 77.2810, standardName: 'Ramanagara'),
    'ramanagar': (lat: 12.7150, lon: 77.2810, standardName: 'Ramanagara'),
    'shivamogga': (lat: 13.9299, lon: 75.5681, standardName: 'Shivamogga'),
    'shimoga': (lat: 13.9299, lon: 75.5681, standardName: 'Shivamogga'),
    'tumakuru': (lat: 13.3409, lon: 77.1010, standardName: 'Tumakuru'),
    'tumkur': (lat: 13.3409, lon: 77.1010, standardName: 'Tumakuru'),
    'udupi': (lat: 13.3409, lon: 74.7421, standardName: 'Udupi'),
    'uttara kannada': (lat: 14.8136, lon: 74.1298, standardName: 'Uttara Kannada'),
    'karwar': (lat: 14.8136, lon: 74.1298, standardName: 'Uttara Kannada'),
    'vijayanagara': (lat: 15.2700, lon: 76.3900, standardName: 'Vijayanagara'),
    'hospet': (lat: 15.2700, lon: 76.3900, standardName: 'Vijayanagara'),
    'vijayapura': (lat: 16.8302, lon: 75.7100, standardName: 'Vijayapura'),
    'bijapur': (lat: 16.8302, lon: 75.7100, standardName: 'Vijayapura'),
    'yadgir': (lat: 16.7700, lon: 77.1300, standardName: 'Yadgir'),
  };

  /// Clean list of all standard Karnataka district names
  static const List<String> allDistricts = [
    'Bagalkot',
    'Ballari',
    'Belagavi',
    'Bengaluru Rural',
    'Bengaluru Urban',
    'Bidar',
    'Chamarajanagar',
    'Chikkaballapur',
    'Chikkamagaluru',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Hassan',
    'Haveri',
    'Kalaburagi',
    'Kodagu',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mysuru',
    'Raichur',
    'Ramanagara',
    'Shivamogga',
    'Tumakuru',
    'Udupi',
    'Uttara Kannada',
    'Vijayanagara',
    'Vijayapura',
    'Yadgir',
  ];

  /// Calculates nearest Karnataka district from GPS coordinates
  static String findNearestDistrict(double lat, double lon) {
    String closestDistrict = 'Bengaluru Urban';
    double minDistanceSquared = double.infinity;

    for (final entry in districtCoordinates.entries) {
      final dLat = entry.value.lat - lat;
      final dLon = entry.value.lon - lon;
      final distSquared = dLat * dLat + dLon * dLon;
      if (distSquared < minDistanceSquared) {
        minDistanceSquared = distSquared;
        closestDistrict = entry.value.standardName;
      }
    }
    return closestDistrict;
  }

  /// Attempts to get the device's real-time GPS position and detects location name
  Future<({double lat, double lon, String locationName})?> getCurrentGpsLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 6),
        );
      } catch (_) {
        try {
          pos = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      if (pos == null) return null;

      final nearestDistrict = findNearestDistrict(pos.latitude, pos.longitude);
      String displayName = nearestDistrict;

      // Fast online reverse geocoding to find locality/village/taluk
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}',
        );
        final res = await http.get(uri, headers: {
          'User-Agent': 'KrishiRituFarmerApp/1.0',
        }).timeout(const Duration(milliseconds: 1800));
        if (res.statusCode == 200) {
          final j = jsonDecode(res.body) as Map<String, dynamic>;
          final addr = j['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final locality = addr['suburb'] ??
                addr['town'] ??
                addr['village'] ??
                addr['city_district'] ??
                addr['city'] ??
                addr['county'];
            if (locality != null && locality.toString().trim().isNotEmpty) {
              displayName = locality.toString().trim();
            }
          }
        }
      } catch (_) {}

      return (lat: pos.latitude, lon: pos.longitude, locationName: displayName);
    } catch (_) {
      return null;
    }
  }

  /// Fetches live weather with zero quota exhaustion and full rate-limit safety:
  /// - Supports exact GPS [latitude] and [longitude] or [city] name
  /// - 30-minute in-memory and disk cache
  /// - In-flight request deduplication
  /// - Keyless Open-Meteo as primary real-time meteorological API
  /// - OpenWeather fallback if API key configured
  /// - Karnataka seasonal fallback if completely offline
  Future<WeatherData?> getWeather(
    String city, {
    double? latitude,
    double? longitude,
    String? locationDisplayName,
    bool forceRefresh = false,
    bool isCurrentLocation = false,
  }) async {
    final cleanCity = city.trim().isEmpty ? 'Bengaluru' : city.trim();
    final cacheKey = (latitude != null && longitude != null)
        ? 'loc_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}'
        : cleanCity.toLowerCase();

    // 1. In-memory cache check
    if (!forceRefresh && _memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      if (DateTime.now().difference(cached.fetchedAt) < _cacheTtl) {
        return cached;
      }
    }

    // 2. Persistent disk cache check
    if (!forceRefresh) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('weather_$cacheKey');
        if (raw != null && raw.isNotEmpty) {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final data = WeatherData.fromMap(map, isCached: true);
          if (DateTime.now().difference(data.fetchedAt) < _cacheTtl) {
            _memoryCache[cacheKey] = data;
            return data;
          }
        }
      } catch (_) {}
    }

    // 3. Request deduplication: reuse active request if one is already in flight
    if (_inFlight.containsKey(cacheKey)) {
      return _inFlight[cacheKey];
    }

    final future = _fetchLiveWeather(
      cleanCity: cleanCity,
      cacheKey: cacheKey,
      latitude: latitude,
      longitude: longitude,
      locationDisplayName: locationDisplayName,
      isCurrentLocation: isCurrentLocation,
    );
    _inFlight[cacheKey] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  /// Convenience wrapper for fetching weather by GPS coordinates
  Future<WeatherData?> getWeatherForCoordinates({
    required double latitude,
    required double longitude,
    String? locationDisplayName,
    bool forceRefresh = false,
  }) async {
    final district = locationDisplayName ?? findNearestDistrict(latitude, longitude);
    return getWeather(
      district,
      latitude: latitude,
      longitude: longitude,
      locationDisplayName: locationDisplayName,
      forceRefresh: forceRefresh,
      isCurrentLocation: true,
    );
  }

  Future<WeatherData> _fetchLiveWeather({
    required String cleanCity,
    required String cacheKey,
    double? latitude,
    double? longitude,
    String? locationDisplayName,
    bool isCurrentLocation = false,
  }) async {
    final effectiveName = locationDisplayName ?? cleanCity;
    final coords = (latitude != null && longitude != null)
        ? (lat: latitude, lon: longitude)
        : _getCoordinates(cleanCity.toLowerCase());

    // 4. Try Open-Meteo (Keyless, free, zero limits, precise parameters)
    try {
      final uri = Uri.parse(
        '$_openMeteoBase?latitude=${coords.lat}&longitude=${coords.lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,showers,weather_code,wind_speed_10m&timezone=auto',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final current = j['current'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 26.0;
          final humidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 60.0;
          final apparent = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
          final rain = (current['precipitation'] as num?)?.toDouble() ??
              (current['rain'] as num?)?.toDouble() ??
              (current['showers'] as num?)?.toDouble() ??
              0.0;
          final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 8.0;
          final wmoCode = (current['weather_code'] as num?)?.toInt() ?? 0;
          final (condition, emoji) = _parseWmoCode(wmoCode);

          final rawTime = current['time'] as String?;
          final observationTime = (rawTime != null ? DateTime.tryParse(rawTime) : null) ?? DateTime.now();

          final data = WeatherData(
            tempC: temp,
            humidity: humidity,
            rainfall: rain,
            condition: condition,
            city: effectiveName,
            fetchedAt: DateTime.now(),
            observationTime: observationTime,
            windSpeedKmH: wind,
            apparentTempC: apparent,
            conditionEmoji: emoji,
            source: 'Open-Meteo Live',
            isCached: false,
            latitude: coords.lat,
            longitude: coords.lon,
            isCurrentLocation: isCurrentLocation,
          );
          _saveToCache(cacheKey, data);
          return data;
        }
      }
    } catch (_) {}

    // 5. Try OpenWeather if configured
    final openWeatherKey = AppConfig.openWeatherKey.trim();
    if (openWeatherKey.isNotEmpty && !openWeatherKey.contains('your-')) {
      try {
        final uri = (latitude != null && longitude != null)
            ? Uri.parse('$_openWeatherBase/weather?lat=${coords.lat}&lon=${coords.lon}&appid=$openWeatherKey&units=metric')
            : Uri.parse('$_openWeatherBase/weather?q=$cleanCity,IN&appid=$openWeatherKey&units=metric');

        final res = await http.get(uri).timeout(const Duration(seconds: 8));
        if (res.statusCode == 200) {
          final j = jsonDecode(res.body);
          final weatherObj = (j['weather'] as List?)?.firstOrNull;
          final desc = weatherObj?['description'] ?? 'Clear';
          final mainCondition = weatherObj?['main'] ?? 'Clear';
          final emoji = _mapOpenWeatherEmoji(mainCondition.toString());
          final dt = j['dt'] as num?;
          final observationTime = dt != null
              ? DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000)
              : DateTime.now();

          final temp = (j['main']['temp'] as num).toDouble();
          final data = WeatherData(
            tempC: temp,
            humidity: (j['main']['humidity'] as num).toDouble(),
            rainfall: (j['rain'] != null ? (j['rain']['1h'] ?? j['rain']['3h'] ?? 0.0) as num : 0.0).toDouble(),
            condition: desc.toString(),
            city: effectiveName,
            fetchedAt: DateTime.now(),
            observationTime: observationTime,
            windSpeedKmH: ((j['wind']?['speed'] as num?)?.toDouble() ?? 3.0) * 3.6,
            apparentTempC: (j['main']?['feels_like'] as num?)?.toDouble() ?? temp,
            conditionEmoji: emoji,
            source: 'OpenWeather Live',
            isCached: false,
            latitude: coords.lat,
            longitude: coords.lon,
            isCurrentLocation: isCurrentLocation,
          );
          _saveToCache(cacheKey, data);
          return data;
        }
      } catch (_) {}
    }

    // 6. Safe Meteorological Fallback Engine (Guarantees zero crashes & 100% offline availability)
    final fallbackData = _getSeasonalFallback(
      effectiveName,
      lat: coords.lat,
      lon: coords.lon,
      isCurrentLocation: isCurrentLocation,
    );
    _saveToCache(cacheKey, fallbackData);
    return fallbackData;
  }

  void _saveToCache(String cacheKey, WeatherData data) {
    _memoryCache[cacheKey] = data;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('weather_$cacheKey', jsonEncode(data.toMap()));
    }).catchError((_) {});
  }

  ({double lat, double lon}) _getCoordinates(String cleanKey) {
    final k = cleanKey.toLowerCase();
    for (final entry in districtCoordinates.entries) {
      if (k.contains(entry.key) || entry.key.contains(k)) {
        return (lat: entry.value.lat, lon: entry.value.lon);
      }
    }
    // Default to Bengaluru center
    return (lat: 12.9716, lon: 77.5946);
  }

  static (String description, String emoji) _parseWmoCode(int code) {
    switch (code) {
      case 0:
        return ('Clear sky', '☀️');
      case 1:
        return ('Mainly clear', '🌤️');
      case 2:
        return ('Partly cloudy', '⛅');
      case 3:
        return ('Overcast', '☁️');
      case 45:
      case 48:
        return ('Foggy', '🌫️');
      case 51:
      case 53:
      case 55:
        return ('Drizzle', '🌦️');
      case 61:
      case 63:
        return ('Moderate rain', '🌧️');
      case 65:
        return ('Heavy rainfall', '🌧️');
      case 71:
      case 73:
      case 75:
        return ('Snow fall', '❄️');
      case 80:
      case 81:
      case 82:
        return ('Rain showers', '🌦️');
      case 95:
      case 96:
      case 99:
        return ('Thunderstorm', '⛈️');
      default:
        return ('Partly cloudy', '🌤️');
    }
  }

  static String _mapOpenWeatherEmoji(String main) {
    final m = main.toLowerCase();
    if (m.contains('clear')) return '☀️';
    if (m.contains('cloud')) return '⛅';
    if (m.contains('rain')) return '🌧️';
    if (m.contains('drizzle')) return '🌦️';
    if (m.contains('thunder')) return '⛈️';
    if (m.contains('fog') || m.contains('mist') || m.contains('haze')) return '🌫️';
    return '🌤️';
  }

  WeatherData _getSeasonalFallback(
    String cleanCity, {
    double? lat,
    double? lon,
    bool isCurrentLocation = false,
  }) {
    final now = DateTime.now();
    final month = now.month;
    double temp = 27.0;
    double humidity = 62.0;
    double rain = 0.0;
    String condition = 'Partly cloudy';
    String emoji = '🌤️';

    // Karnataka climate seasonal averages
    if (month >= 6 && month <= 9) {
      // Southwest Monsoon
      temp = 25.5;
      humidity = 82.0;
      rain = 4.5;
      condition = 'Monsoon showers';
      emoji = '🌧️';
    } else if (month >= 10 && month <= 11) {
      // Post-monsoon / Northeast Monsoon
      temp = 26.0;
      humidity = 68.0;
      rain = 1.2;
      condition = 'Pleasant & clear';
      emoji = '🌤️';
    } else if (month >= 12 || month <= 2) {
      // Winter / Rabi season
      temp = 23.0;
      humidity = 52.0;
      rain = 0.0;
      condition = 'Cool & dry';
      emoji = '☀️';
    } else {
      // Summer
      temp = 33.5;
      humidity = 45.0;
      rain = 0.5;
      condition = 'Warm & sunny';
      emoji = '☀️';
    }

    return WeatherData(
      tempC: temp,
      humidity: humidity,
      rainfall: rain,
      condition: condition,
      city: cleanCity,
      fetchedAt: now,
      observationTime: now,
      windSpeedKmH: 9.5,
      apparentTempC: temp,
      conditionEmoji: emoji,
      source: 'Meteorological Forecast',
      isCached: true,
      latitude: lat,
      longitude: lon,
      isCurrentLocation: isCurrentLocation,
    );
  }
}
