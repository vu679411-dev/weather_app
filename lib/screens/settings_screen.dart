import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Use Celsius (°C)"),
            value: provider.isCelsius,
            onChanged: (value) {
              provider.toggleUnit(value);
            },
          ),
          const Divider(),
          const ListTile(
            title: Text("About"),
            subtitle: Text("Weather App v1.0"),
            leading: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}