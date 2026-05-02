import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5';

  static String get apiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static String buildUrl(
      String endpoint, Map<String, dynamic> params) {
    params['appid'] = apiKey;
    params['units'] = 'metric';

    final uri = Uri.parse('$baseUrl$endpoint');
    return uri.replace(queryParameters: params).toString();
  }
}