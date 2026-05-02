import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/storage_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final list = await StorageService().getFavorites();
    setState(() => favorites = list);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WeatherProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Favorite Cities"),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text("No favorite cities"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final city = favorites[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(
                      city,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () async {
                        await StorageService()
                            .removeFavorite(city);
                        loadFavorites();
                      },
                    ),
                    onTap: () {
                      provider.fetchWeatherByCity(city);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
    );
  }
}