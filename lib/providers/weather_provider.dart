import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();
  final LocationService _locationService = LocationService();
  final StorageService _storage = StorageService();
  final ConnectivityService _connectivity = ConnectivityService();

  WeatherModel? currentWeather;
  List<ForecastModel> forecast = [];

  WeatherState state = WeatherState.initial;
  String errorMessage = '';

  bool isCelsius = true;
  bool isOffline = false;

  ///  CONVERT TEMP
  double convertTemp(double temp) {
    if (isCelsius) return temp;
    return (temp * 9 / 5) + 32;
  }

  void toggleUnit(bool value) async {
    isCelsius = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCelsius', value);

    notifyListeners();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isCelsius = prefs.getBool('isCelsius') ?? true;
    notifyListeners();
  }

  ///  HOURLY FORECAST (24h)
  List<ForecastModel> getHourlyForecast() {
    return forecast.take(8).toList(); // 8 * 3h = 24h
  }

  ///  DAILY FORECAST (5 DAYS)
  
 List<ForecastModel> getDailyForecast() {
  final Map<String, List<ForecastModel>> grouped = {};

  for (var item in forecast) {
    final key =
        "${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}";

    grouped.putIfAbsent(key, () => []).add(item);
  }

  List<ForecastModel> result = [];

  grouped.forEach((key, list) {
    double minTemp = list.first.tempMin;
    double maxTemp = list.first.tempMax;

    for (var item in list) {
      if (item.tempMin < minTemp) minTemp = item.tempMin;
      if (item.tempMax > maxTemp) maxTemp = item.tempMax;
    }

    final mid = list[list.length ~/ 2];

    result.add(
      ForecastModel(
        dateTime: mid.dateTime,
        temperature: mid.temperature,
        description: mid.description,
        icon: mid.icon,
        tempMin: minTemp,
        tempMax: maxTemp,
      ),
    );
  });

  return result.take(5).toList();
}

  /// FETCH BY CITY
  Future<void> fetchWeatherByCity(String city) async {
    state = WeatherState.loading;
    notifyListeners();

    final hasInternet = await _connectivity.isConnected();
    isOffline = !hasInternet;

    /// OFFLINE MODE
    if (!hasInternet) {
      final cacheWeather = await _storage.getWeatherByCity(city);

      if (cacheWeather != null) {
        final cityKey = cacheWeather.cityName;
        final cacheForecast = await _storage.getForecast(cityKey);

        currentWeather = cacheWeather;
        forecast = cacheForecast;
        state = WeatherState.loaded;
      } else {
        errorMessage = "No Internet & No Cached Data";
        state = WeatherState.error;
      }

      notifyListeners();
      return;
    }

    /// ONLINE MODE
    try {
      currentWeather = await _service.getWeather(city);
      final cityKey = currentWeather!.cityName;

      forecast = await _service.getForecast(cityKey);

      await _storage.saveWeather(currentWeather!);
      await _storage.saveForecast(cityKey, forecast);

      await _storage.saveSearch(city); //  lưu history

      errorMessage = '';
      state = WeatherState.loaded;
    } catch (e) {
      errorMessage = "City not found";
      state = WeatherState.error;
    }

    notifyListeners();
  }

  ///  FETCH BY GPS
  Future<void> fetchWeatherByLocation() async {
    state = WeatherState.loading;
    notifyListeners();

    try {
      final pos = await _locationService.getCurrentLocation();

      isOffline = false;

      currentWeather = await _service.getWeatherByLocation(
        pos.latitude,
        pos.longitude,
      );

      final cityKey = currentWeather!.cityName;

      forecast = await _service.getForecast(cityKey);

      await _storage.saveWeather(currentWeather!);
      await _storage.saveForecast(cityKey, forecast);

      state = WeatherState.loaded;
    } catch (e) {
      isOffline = true;
      errorMessage = "Location error";
      state = WeatherState.error;
    }

    notifyListeners();
  }

  ///  REFRESH
  Future<void> refreshWeather() async {
    if (currentWeather != null) {
      await fetchWeatherByCity(currentWeather!.cityName);
    } else {
      await fetchWeatherByLocation();
    }
  }
  bool isNight() {
  if (currentWeather == null) return false;

  final now = DateTime.now();
  final sunrise = currentWeather!.sunrise;
  final sunset = currentWeather!.sunset;

  if (sunrise == null || sunset == null) return false;

  return now.isBefore(sunrise) || now.isAfter(sunset);
}
}