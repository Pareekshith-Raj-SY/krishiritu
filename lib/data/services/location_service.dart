import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'weather_service.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  error,
}

class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? district;
  final String? locationName;
  final LocationStatus status;
  final String? errorMessage;

  const LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.district,
    this.locationName,
    required this.status,
    this.errorMessage,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    required String district,
    required String locationName,
  }) {
    return LocationResult(
      success: true,
      latitude: latitude,
      longitude: longitude,
      district: district,
      locationName: locationName,
      status: LocationStatus.success,
    );
  }

  factory LocationResult.failure({
    required LocationStatus status,
    required String errorMessage,
  }) {
    return LocationResult(
      success: false,
      status: status,
      errorMessage: errorMessage,
    );
  }
}

class LocationService {
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  /// Check whether GPS / location service is enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Check current runtime permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Request runtime location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  /// Open device app settings so user can grant permanently denied permissions
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Open device location settings so user can enable GPS
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  /// Obtains current GPS coordinates with Android runtime permission flow,
  /// GPS service check, robust timeout, and fallback to last known location.
  Future<LocationResult> getCurrentLocation({bool requestIfNeeded = true}) async {
    // 1. Check if GPS / Location services are enabled on device
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult.failure(
        status: LocationStatus.serviceDisabled,
        errorMessage: 'GPS location service is disabled on your device. Please turn on GPS in device settings.',
      );
    }

    // 2. Check and request runtime permission
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      if (requestIfNeeded) {
        permission = await requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return LocationResult.failure(
          status: LocationStatus.permissionDenied,
          errorMessage: 'Location permission was denied. Please allow location access to detect your farm position.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult.failure(
        status: LocationStatus.permissionDeniedForever,
        errorMessage: 'Location permission is permanently denied. Please enable location permissions in App Settings.',
      );
    }

    // 3. Retrieve accurate coordinates from GPS / Network
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}
    } catch (_) {
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}
    }

    if (position == null) {
      return LocationResult.failure(
        status: LocationStatus.timeout,
        errorMessage: 'Could not obtain accurate GPS signal. Please check your GPS or select your district manually.',
      );
    }

    final lat = position.latitude;
    final lon = position.longitude;

    // 4. Resolve Karnataka nearest district
    final nearestDistrict = WeatherService.findNearestDistrict(lat, lon);
    String detectedName = nearestDistrict;

    // 5. Reverse geocoding to find locality / village / taluk name
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
      );
      final res = await _client.get(uri, headers: {
        'User-Agent': 'KrishiRituFarmerApp/1.0',
      }).timeout(const Duration(seconds: 3));

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
            detectedName = locality.toString().trim();
          }
        }
      }
    } catch (_) {}

    return LocationResult.success(
      latitude: lat,
      longitude: lon,
      district: nearestDistrict,
      locationName: detectedName,
    );
  }
}
