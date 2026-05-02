import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/weather_detail_card.dart';

import '../services/storage_service.dart';

import 'search_screen.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import 'forecast_screen.dart'; //  

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    ///  Background theo thời tiết
    Color bgColor = Colors.grey[100]!;

if (provider.currentWeather != null) {
  if (provider.isNight()) {
    bgColor = const Color(0xFF1A202C); // 🌙 dark
  } else {
    switch (provider.currentWeather!.mainCondition.toLowerCase()) {
      case 'clear':
        bgColor = const Color(0xFF87CEEB);
        break;
      case 'rain':
        bgColor = const Color(0xFF718096);
        break;
      case 'clouds':
        bgColor = const Color(0xFFCBD5E0);
        break;
    }
  }
}

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          ///  SEARCH
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );

              if (city != null && city is String) {
                context.read<WeatherProvider>().fetchWeatherByCity(city);
              }
            },
          ),

          ///  FORECAST 5 DAY
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForecastScreen(),
                ),
              );
            },
          ),

          ///  FAVORITE ADD
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              if (provider.currentWeather != null) {
                StorageService().addFavorite(
                  provider.currentWeather!.cityName,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to favorites")),
                );
              }
            },
          ),

          ///  SETTINGS
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          ///  GPS
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<WeatherProvider>().fetchWeatherByLocation();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          /// 🔌 OFFLINE BAR
          if (provider.isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange,
              child: const Text(
                "Offline Mode (Showing cached data)",
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.refreshWeather(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ///  SEARCH INPUT
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Enter city",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                           icon: const Icon(Icons.search),
                               onPressed: () async {
                          final city = controller.text.trim();
                           if (city.isEmpty) return;

                       await StorageService().saveSearch(city);
                               provider.fetchWeatherByCity(city);
                      },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ///  HISTORY
                    FutureBuilder(
                      future: StorageService().getHistory(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        final list = snapshot.data as List<String>;
                        if (list.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recent Searches",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: list.map((city) {
                                return GestureDetector(
                                  onTap: () {
                                    context
                                        .read<WeatherProvider>()
                                        .fetchWeatherByCity(city);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(city),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),

                    ///  OPEN FAVORITES
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    ///  MAIN CONTENT
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          switch (provider.state) {
                            case WeatherState.loading:
                              return const LoadingShimmer();

                            case WeatherState.error:
                              return Center(
                                child: Text(provider.errorMessage),
                              );

                            case WeatherState.loaded:
                              if (provider.currentWeather == null) {
                                return const Center(child: Text("No data"));
                              }

                              final hourly =
                                  provider.getHourlyForecast();

                              return SingleChildScrollView(
                                 child: Column(
                                     children: [
                                  CurrentWeatherCard(
                                    weather: provider.currentWeather!,
                                     ),

                                 const SizedBox(height: 20),

                                     WeatherDetailCard(
                                       weather: provider.currentWeather!,
                                           ),

                                    const SizedBox(height: 20),

                                    ///  HOURLY
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: hourly.length,
                                        itemBuilder: (context, index) {
                                          final item = hourly[index];

                                          return Container(
                                            width: 90,
                                            margin: const EdgeInsets.only(right: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                )
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  DateFormat('HH:mm')
                                                      .format(item.dateTime),
                                                ),
                                                Image.network(
                                                  "https://openweathermap.org/img/wn/${item.icon}.png",
                                                  height: 40,
                                                ),
                                                Text(
                                                  "${provider.convertTemp(item.temperature).round()}°",
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );

                            default:
                              return const Center(
                                child: Text("Start searching..."),
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}