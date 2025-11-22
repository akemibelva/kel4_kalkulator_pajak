import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kalkulator_pajak/model/weather_api_model.dart';
import 'package:kalkulator_pajak/model/forecast_api_model.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['OPENWEATHER_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Validasi API Key
  static void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('❌ API Key OpenWeather belum diatur di file .env');
    }
  }

  // =========================================================
  // FUNGSI BANTUAN INTERNAL
  // =========================================================

  /// Mendapatkan Latitude dan Longitude dari nama kota
  static Future<Map<String, double>> _getCoordinatesFromCity(String cityName) async {
    _checkApiKey();
    final encodedCity = Uri.encodeComponent("$cityName,id");
    final url = Uri.parse(
      '$_baseUrl/weather?q=$encodedCity&appid=$_apiKey&lang=id',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'lat': data['coord']['lat'] as double,
        'lon': data['coord']['lon'] as double,
      };
    } else if (response.statusCode == 404) {
      throw Exception('Kota "$cityName" tidak ditemukan. (Kode 404)');
    } else {
      throw Exception('Gagal mendapatkan koordinat. Status ${response.statusCode}');
    }
  }


  /// 📅 Fungsi internal: Mengambil Forecast 5 hari menggunakan Lat/Lon
  static Future<List<Forecast>> _fetchForecastByCoordinates(
      double lat, double lon) async {
    _checkApiKey();

    // Validasi range koordinat Indonesia
    if (!(lat >= -11 && lat <= 6 && lon >= 95 && lon <= 141)) {
      // Ini mungkin terlalu ketat, tapi jika hanya ingin di Indonesia, ini membantu.
      // throw Exception("❌ Lokasi berada di luar wilayah Indonesia.");
    }

    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey&lang=id',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];
      return list.map((json) => Forecast.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat forecast. Status ${response.statusCode}');
    }
  }

  // =========================================================
  // FUNGSI PUBLIK YANG DIGUNAKAN DI HOME.dart
  // =========================================================

  /// 🌆 Cuaca sekarang — hanya kota Indonesia
  static Future<Weather> fetchWeatherIndonesia(String cityName) async {
    _checkApiKey();
    final encodedCity = Uri.encodeComponent("$cityName,id");

    final url = Uri.parse(
      '$_baseUrl/weather?q=$encodedCity&appid=$_apiKey&units=metric&lang=id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Kota "$cityName" tidak ditemukan di Indonesia.');
      } else if (response.statusCode == 401) {
        throw Exception('API Key tidak valid.');
      } else {
        throw Exception('Gagal memuat cuaca. Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error jaringan atau parsing: $e');
    }
  }

  /// 🕒 Prakiraan Cuaca 5 Hari per 3 Jam berdasarkan Nama Kota
  /// Fungsi ini yang harus dipanggil di home.dart
  static Future<List<Forecast>> fetchWeatherForecast(String cityName) async {
    try {
      // 1. Dapatkan koordinat dari nama kota
      final coords = await _getCoordinatesFromCity(cityName);
      final lat = coords['lat']!;
      final lon = coords['lon']!;

      // 2. Gunakan koordinat untuk mendapatkan prakiraan (forecast)
      return await _fetchForecastByCoordinates(lat, lon);

    } catch (e) {
      // Propagasi error yang terjadi saat mendapatkan koordinat atau forecast
      throw Exception('Gagal memuat prakiraan cuaca: ${e.toString()}');
    }
  }
}