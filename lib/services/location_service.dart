import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Xin quyền GPS
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Lấy tọa độ
  Future<Position> getCurrentLocation() async {
    final hasPermission = await checkPermission();

    if (!hasPermission) {
      throw Exception("Location permission denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getBetterCity(double lat, double lon) async {
    final placemarks = await placemarkFromCoordinates(lat, lon);

    if (placemarks.isEmpty) return "Ho Chi Minh";

    final place = placemarks.first;

    return place.administrativeArea ??   // VD: Ho Chi Minh
           place.subAdministrativeArea ?? // Quận
           place.locality ??             // City
           "Ho Chi Minh";
  }
  String normalizeVietnamCity(String city) {
  city = city.toLowerCase();

  if (city.contains("hồ chí minh") ||
      city.contains("ho chi minh") ||
      city.contains("sài gòn")) {
    return "Ho Chi Minh City";
  }

  if (city.contains("bình dương") ||
      city.contains("binh duong")) {
    return "Binh Duong";
  }

  if (city.contains("hà nội") ||
      city.contains("ha noi")) {
    return "Hanoi";
  }

  return "Ho Chi Minh City"; // fallback an toàn
}
}