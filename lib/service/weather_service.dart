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

  /// 🌆 Cuaca sekarang — hanya kota Indonesia
  static Future<Weather> fetchWeatherIndonesia(String cityName) async {
    _checkApiKey();

    // Tambah “,id” agar OpenWeather hanya mencari kota di Indonesia
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

  /// 📅 Forecast 5 hari — hanya wilayah Indonesia
  static Future<List<Forecast>> fetchForecastIndonesia(
      double lat, double lon) async {

    // Range koordinat Indonesia
    if (!(lat >= -11 && lat <= 6 && lon >= 95 && lon <= 141)) {
      throw Exception("❌ Lokasi berada di luar wilayah Indonesia.");
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
}
