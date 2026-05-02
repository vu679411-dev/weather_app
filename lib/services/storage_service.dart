import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class StorageService {
  static const _favKey = "favorite_cities";

  ///  NORMALIZE CITY KEY
  /// =========================
  String _normalizeCity(String city) {
    return city.toLowerCase().replaceAll(" ", "").trim();
  }

  /// FAVORITES
  /// =========================
  Future<void> addFavorite(String city) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_favKey) ?? []; // 

  if (!list.contains(city)) {
    if (list.length >= 5) list.removeLast();
    list.insert(0, city);
  }

  await prefs.setStringList(_favKey, list);
}

  Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favKey) ?? [];

    list.remove(city);

    await prefs.setStringList(_favKey, list);
  }

  /// =========================
  
  /// 🌤 WEATHER CACHE
  /// =========================
  Future<void> saveWeather(WeatherModel weather) async {
  final prefs = await SharedPreferences.getInstance();

  final key = "weather_${_normalizeCity(weather.cityName)}";

  await prefs.setString(key, jsonEncode(weather.toJson()));

  await prefs.setInt(
    "last_update",
    DateTime.now().millisecondsSinceEpoch,
  );
}
Future<List<String>> getFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_favKey) ?? [];
}

  Future<WeatherModel?> getWeatherByCity(String city) async {
    final prefs = await SharedPreferences.getInstance();

    final key = "weather_${_normalizeCity(city)}";

    final data = prefs.getString(key);

    if (data == null) return null;

    return WeatherModel.fromJson(jsonDecode(data));
  }

  /// =========================
  /// 🌦 FORECAST CACHE
  /// =========================
  Future<void> saveForecast(
      String city, List<ForecastModel> list) async {
    final prefs = await SharedPreferences.getInstance();

    final key = "forecast_${_normalizeCity(city)}";

    final jsonList = list
        .map((e) => {
              "dt": e.dateTime.millisecondsSinceEpoch ~/ 1000,
              "temp": e.temperature,
              "description": e.description,
              "icon": e.icon,
              "temp_min": e.tempMin,
              "temp_max": e.tempMax,
            })
        .toList();

    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt("last_update");

    if (last == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - last) < 30 * 60 * 1000;
  }

  Future<List<ForecastModel>> getForecast(String city) async {
    final prefs = await SharedPreferences.getInstance();

    final key = "forecast_${_normalizeCity(city)}";

    final data = prefs.getString(key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);

    return decoded
        .map((item) => ForecastModel(
              dateTime: DateTime.fromMillisecondsSinceEpoch(
                  item['dt'] * 1000),
              temperature: item['temp'],
              description: item['description'],
              icon: item['icon'],
              tempMin: item['temp_min'],
              tempMax: item['temp_max'],
            ))
        .toList();
  }

  /// SEARCH HISTORY
  /// =========================
  Future<void> saveSearch(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('history') ?? [];

    if (!list.contains(city)) {
      list.insert(0, city);
    }

    await prefs.setStringList('history', list.take(5).toList());
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history') ?? [];
  }
}
