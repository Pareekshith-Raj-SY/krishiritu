import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class WeatherData {
  final double tempC;
  final double humidity;
  final double rainfall;
  final String condition;
  final String city;
  final DateTime fetchedAt;

  const WeatherData({
    required this.tempC, required this.humidity, required this.rainfall,
    required this.condition, required this.city, required this.fetchedAt,
  });
}

class WeatherService {
  static const _base = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData?> getWeather(String city) async {
    if (!AppConfig.hasWeather) return null;
    try {
      final uri = Uri.parse(
        '$_base/weather?q=$city,IN&appid=${AppConfig.openWeatherKey}&units=metric');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final j = jsonDecode(res.body);
      return WeatherData(
        tempC: (j['main']['temp'] as num).toDouble(),
        humidity: (j['main']['humidity'] as num).toDouble(),
        rainfall: j['rain'] != null ? (j['rain']['1h'] ?? 0.0).toDouble() : 0.0,
        condition: j['weather'][0]['description'] ?? '',
        city: j['name'] ?? city,
        fetchedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
