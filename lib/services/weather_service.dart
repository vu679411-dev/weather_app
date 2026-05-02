import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {

  ///  CURRENT WEATHER
  Future<WeatherModel> getWeather(String city) async {
    final url = ApiConfig.buildUrl('/weather', {
      'q': '$city,VN',
    });

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Server error');
    }
  }

  ///  FORECAST
  Future<List<ForecastModel>> getForecast(String city) async {
    final url = ApiConfig.buildUrl('/forecast', {
      'q': '$city,VN',
    });

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];

      return list.map((e) => ForecastModel.fromJson(e)).toList();
    } else {
      throw Exception("Forecast error");
    }
  }

  ///  GPS WEATHER
  Future<WeatherModel> getWeatherByLocation(
      double lat, double lon) async {
    final url = ApiConfig.buildUrl('/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Location error');
    }
  }
}