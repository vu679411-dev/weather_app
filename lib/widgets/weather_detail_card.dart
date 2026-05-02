import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherDetailCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailCard({super.key, required this.weather});

  Widget buildItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildItem("Humidity", "${weather.humidity}%", Icons.water_drop),
          buildItem("Wind", "${weather.windSpeed} m/s", Icons.air),
          buildItem("Pressure", "${weather.pressure} hPa", Icons.speed),
        ],
      ),
    );
  }
}