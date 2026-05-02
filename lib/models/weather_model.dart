class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime dateTime;
  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final int? cloudiness;

  final DateTime? sunrise;
  final DateTime? sunset;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.dateTime,
    this.tempMin,
    this.tempMax,
    this.visibility,
    this.cloudiness,
    this.sunrise,
    this.sunset,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      country: json['sys']['country'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      mainCondition: json['weather'][0]['main'],
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),

      tempMin: json['main']['temp_min']?.toDouble(),
      tempMax: json['main']['temp_max']?.toDouble(),
      visibility: json['visibility'],
      cloudiness: json['clouds']?['all'],

      /// ✅ FIX: thêm parse sunrise/sunset
      sunrise: json['sys']['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['sys']['sunrise'] * 1000)
          : null,
      sunset: json['sys']['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['sys']['sunset'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {
        'country': country,
        'sunrise': sunrise?.millisecondsSinceEpoch != null
            ? sunrise!.millisecondsSinceEpoch ~/ 1000
            : null,
        'sunset': sunset?.millisecondsSinceEpoch != null
            ? sunset!.millisecondsSinceEpoch ~/ 1000
            : null,
      },
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
        'temp_min': tempMin,
        'temp_max': tempMax,
      },
      'wind': {
        'speed': windSpeed,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
          'main': mainCondition,
        }
      ],
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'visibility': visibility,
      'clouds': {
        'all': cloudiness,
      },
    };
  }
}