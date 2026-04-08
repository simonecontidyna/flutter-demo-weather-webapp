import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  String _apiKey;

  WeatherService({String apiKey = ''}) : _apiKey = apiKey;

  String get apiKey => _apiKey;

  set apiKey(String value) {
    _apiKey = value.trim();
  }

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Validates the API key by making a test request
  Future<bool> validateApiKey(String key) async {
    if (key.trim().isEmpty) return false;
    try {
      final url =
          '$_baseUrl/weather?q=London&appid=${key.trim()}&units=metric';
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<WeatherData> getCurrentWeather(String city) async {
    if (!hasApiKey) return _getMockCurrentWeather(city);

    final url =
        '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=it';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('API key non valida o scaduta');
    } else if (response.statusCode == 404) {
      throw Exception('Città "$city" non trovata');
    } else {
      throw Exception('Errore nel caricamento meteo: ${response.statusCode}');
    }
  }

  Future<List<ForecastData>> getForecast(String city) async {
    if (!hasApiKey) return _getMockForecast();

    final url =
        '$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&lang=it';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;
      return list.map((item) => ForecastData.fromJson(item)).toList();
    } else {
      throw Exception(
        'Errore nel caricamento previsioni: ${response.statusCode}',
      );
    }
  }

  Future<List<DailyForecast>> getDailyForecast(String city) async {
    final hourlyForecast = await getForecast(city);
    return _aggregateToDailyForecast(hourlyForecast);
  }

  List<DailyForecast> _aggregateToDailyForecast(
    List<ForecastData> hourlyData,
  ) {
    final Map<String, List<ForecastData>> grouped = {};

    for (final item in hourlyData) {
      final key =
          '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final today =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

    return grouped.entries
        .where((e) => e.key != today)
        .take(5)
        .map((entry) {
          final items = entry.value;
          final tempMin = items
              .map((e) => e.tempMin)
              .reduce((a, b) => a < b ? a : b);
          final tempMax = items
              .map((e) => e.tempMax)
              .reduce((a, b) => a > b ? a : b);
          final midday = items.firstWhere(
            (e) => e.dateTime.hour >= 12 && e.dateTime.hour <= 15,
            orElse: () => items.first,
          );

          return DailyForecast(
            date: items.first.dateTime,
            tempMin: tempMin,
            tempMax: tempMax,
            icon: midday.icon,
            description: midday.description,
            humidity: midday.humidity,
            windSpeed: midday.windSpeed,
            pop: items.map((e) => e.pop).reduce((a, b) => a > b ? a : b),
          );
        })
        .toList();
  }

  // --- Mock data for demo without API key ---

  WeatherData _getMockCurrentWeather(String city) {
    final now = DateTime.now();
    return WeatherData(
      cityName: city,
      country: 'IT',
      temperature: 22.5,
      feelsLike: 21.8,
      tempMin: 18.0,
      tempMax: 26.0,
      humidity: 58,
      windSpeed: 3.6,
      pressure: 1015,
      description: 'parzialmente nuvoloso',
      icon: '02d',
      visibility: 10000,
      clouds: 40,
      sunrise: DateTime(now.year, now.month, now.day, 6, 42),
      sunset: DateTime(now.year, now.month, now.day, 19, 55),
    );
  }

  List<ForecastData> _getMockForecast() {
    final now = DateTime.now();
    final List<ForecastData> forecast = [];

    final icons = ['01d', '02d', '03d', '10d', '01d', '02d', '04d', '01d'];
    final descriptions = [
      'cielo sereno',
      'poche nuvole',
      'nubi sparse',
      'pioggia leggera',
      'cielo sereno',
      'poche nuvole',
      'nubi',
      'cielo sereno',
    ];

    for (int i = 0; i < 40; i++) {
      final dt = now.add(Duration(hours: (i + 1) * 3));
      final baseTemp = 20.0 + (5 * _sinWave(dt.hour));
      final dayOffset = (dt.day % 5) * 1.5;

      forecast.add(
        ForecastData(
          dateTime: dt,
          temperature: baseTemp + dayOffset,
          tempMin: baseTemp + dayOffset - 3,
          tempMax: baseTemp + dayOffset + 3,
          humidity: 45 + (dt.hour % 12) * 3,
          windSpeed: 2.0 + (dt.hour % 6) * 0.8,
          description: descriptions[i % descriptions.length],
          icon: icons[i % icons.length],
          pop: (i % 5 == 3) ? 65 : (i % 3 == 0) ? 20 : 5,
        ),
      );
    }

    return forecast;
  }

  double _sinWave(int hour) {
    final radians = ((hour - 5) / 24) * 3.14159 * 2;
    return (radians.abs() < 3.14159) ? (radians / 3.14159) : 0;
  }
}
