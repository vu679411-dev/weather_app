import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = "favorite_cities";

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    if (!list.contains(city)) {
      list.add(city);
    }

    await prefs.setStringList(_key, list);
  }

  Future<void> remove(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.remove(city);

    await prefs.setStringList(_key, list);
  }
}