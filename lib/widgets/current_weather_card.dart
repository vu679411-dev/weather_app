import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: _getGradient(weather),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Text(
            weather.cityName,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          Text(
            DateFormat('EEEE, MMM d').format(weather.dateTime),
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          Image.network(
            "https://openweathermap.org/img/wn/${weather.icon}@4x.png",
            height: 100,
          ),

          Text(
            "${weather.temperature.round()}°",
            style: const TextStyle(
                fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),

          Text(
            "Feels like ${weather.feelsLike.round()}°",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient(WeatherModel weather) {
    final hour = weather.dateTime.hour;

    if (hour >= 18 || hour <= 6) {
      return const LinearGradient(
        colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
      );
    }

    switch (weather.mainCondition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          colors: [Color(0xFFFDB813), Color(0xFF87CEEB)],
        );
      case 'rain':
        return const LinearGradient(
          colors: [Color(0xFF4A5568), Color(0xFF718096)],
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFFA0AEC0), Color(0xFFCBD5E0)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        );
    }
  }
}