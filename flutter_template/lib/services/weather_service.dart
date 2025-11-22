import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherInfo {
  WeatherInfo({
    required this.city,
    required this.condition,
    required this.temperature,
    required this.high,
    required this.low,
  });

  final String city;
  final String condition;
  final int temperature;
  final int high;
  final int low;
}

class WeatherService {
  static const double _seoulLat = 37.5665;
  static const double _seoulLon = 126.9780;

  Future<WeatherInfo> fetchWeather() async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': _seoulLat.toString(),
        'longitude': _seoulLon.toString(),
        'current': 'temperature_2m,weather_code',
        'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
        'timezone': 'Asia/Seoul',
      },
    );
    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Weather API error ${response.statusCode}');
    }
    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = (json['daily'] as Map<String, dynamic>? ?? {});
    final tempsMax = daily['temperature_2m_max'] as List<dynamic>? ?? [0];
    final tempsMin = daily['temperature_2m_min'] as List<dynamic>? ?? [0];
    final weatherCode = current['weather_code'] ?? 0;
    return WeatherInfo(
      city: json['timezone']?.toString().split('/').last ?? 'Seoul',
      condition: _describeWeather(weatherCode),
      temperature: (current['temperature_2m'] as num?)?.round() ?? 0,
      high: (tempsMax.first as num?)?.round() ?? 0,
      low: (tempsMin.first as num?)?.round() ?? 0,
    );
  }

  String _describeWeather(dynamic code) {
    final int normalized =
        code is int ? code : int.tryParse(code.toString()) ?? 0;
    if ({0, 1}.contains(normalized)) return 'Sunny';
    if ({2}.contains(normalized)) return 'Partly Cloudy';
    if ({3}.contains(normalized)) return 'Overcast';
    if ({45, 48}.contains(normalized)) return 'Foggy';
    if ({51, 53, 55}.contains(normalized)) return 'Drizzle';
    if ({61, 63, 65}.contains(normalized)) return 'Rainy';
    if ({71, 73, 75}.contains(normalized)) return 'Snowy';
    if ({95, 96, 99}.contains(normalized)) return 'Stormy';
    return 'Cloudy';
  }
}
