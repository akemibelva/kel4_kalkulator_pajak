import 'dart:convert';
import 'package:http/http.dart' as http; // Library untuk request HTTP
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk membaca API key dari file .env
import 'package:kalkulator_pajak/model/weather_api_model.dart'; // Model untuk cuaca saat ini
import 'package:kalkulator_pajak/model/forecast_api_model.dart'; // Model untuk prakiraan cuaca 5 hari

class WeatherService {
  // Ambil API key dari file .env
  static final String _apiKey = dotenv.env['OPENWEATHER_KEY'] ?? '';

  // Base URL API OpenWeatherMap
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // =========================================================
  // VALIDASI API KEY
  // =========================================================
  static void _checkApiKey() {
    if (_apiKey.isEmpty) {
      // Jika API key tidak ditemukan → lempar error
      throw Exception('❌ API Key OpenWeather belum diatur di file .env');
    }
  }

  // =========================================================
  // FUNGSI INTERNAL
  // Fungsi-fungsi ini tidak dipanggil langsung dari UI,
  // tetapi digunakan sebagai fungsi pendukung.
  // =========================================================

  // ---------------------------------------------------------
  // Mendapatkan Latitude & Longitude berdasarkan nama kota
  // ---------------------------------------------------------
  static Future<Map<String, double>> _getCoordinatesFromCity(String cityName) async {
    _checkApiKey();

    // Encode nama kota agar aman digunakan pada URL (contoh: Jakarta → Jakarta,id)
    final encodedCity = Uri.encodeComponent("$cityName,id");

    final url = Uri.parse(
      '$_baseUrl/weather?q=$encodedCity&appid=$_apiKey&lang=id',
    );

    final response = await http.get(url);

    // Jika berhasil
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Return lat & lon dalam bentuk Map
      return {
        'lat': data['coord']['lat'] as double,
        'lon': data['coord']['lon'] as double,
      };
    }

    // Jika kota tidak ditemukan
    else if (response.statusCode == 404) {
      throw Exception('Kota "$cityName" tidak ditemukan. (Kode 404)');
    }

    // Error lainnya
    else {
      throw Exception('Gagal mendapatkan koordinat. Status ${response.statusCode}');
    }
  }

  /// ---------------------------------------------------------
  /// Mengambil prakiraan cuaca 5 hari berdasarkan koordinat
  /// OpenWeather memberikan forecast setiap 3 jam
  /// ---------------------------------------------------------
  static Future<List<Forecast>> _fetchForecastByCoordinates(double lat, double lon) async {
    _checkApiKey();

    // Validasi range koordinat Indonesia (opsional)
    if (!(lat >= -11 && lat <= 6 && lon >= 95 && lon <= 141)) {
      // Jika ingin membatasi hanya Indonesia, aktifkan throw
      // throw Exception("❌ Lokasi berada di luar wilayah Indonesia.");
    }

    final url = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey&lang=id',
    );

    final response = await http.get(url);

    // Jika berhasil
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list']; // Data list forecast

      // Mapping tiap item JSON menjadi object Forecast
      return list.map((json) => Forecast.fromJson(json)).toList();
    }

    // Jika gagal
    else {
      throw Exception('Gagal memuat forecast. Status ${response.statusCode}');
    }
  }

  // =========================================================
  // FUNGSI PUBLIK YANG DIPAKAI DI HOME.DART
  // =========================================================

  /// ---------------------------------------------------------
  /// CUACA SEKARANG (CURRENT WEATHER)
  /// ---------------------------------------------------------
  static Future<Weather> fetchWeatherIndonesia(String cityName) async {
    _checkApiKey();
    final encodedCity = Uri.encodeComponent("$cityName,id");

    final url = Uri.parse(
      '$_baseUrl/weather?q=$encodedCity&appid=$_apiKey&units=metric&lang=id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Convert JSON menjadi model Weather
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      }

      // Jika kota tidak ditemukan
      else if (response.statusCode == 404) {
        throw Exception('Kota "$cityName" tidak ditemukan di Indonesia.');
      }

      // Jika API key salah
      else if (response.statusCode == 401) {
        throw Exception('API Key tidak valid.');
      }

      // Error lainnya
      else {
        throw Exception('Gagal memuat cuaca. Status ${response.statusCode}');
      }
    } catch (e) {
      // Tangani error jaringan atau parsing
      throw Exception('Error jaringan atau parsing: $e');
    }
  }

  /// ---------------------------------------------------------
  /// PRAKIRAAN CUACA 5 HARI (SETIAP 3 JAM)
  /// Ini yang dipanggil di HomePage untuk menampilkan forecast
  /// ---------------------------------------------------------
  static Future<List<Forecast>> fetchWeatherForecast(String cityName) async {
    try {
      // 1. Ambil koordinat berdasarkan nama kota
      final coords = await _getCoordinatesFromCity(cityName);
      final lat = coords['lat']!;
      final lon = coords['lon']!;

      // 2. Ambil forecast menggunakan lat & lon
      return await _fetchForecastByCoordinates(lat, lon);
    } catch (e) {
      // Jika ada error dari _getCoordinates atau _fetchForecast
      throw Exception('Gagal memuat prakiraan cuaca: ${e.toString()}');
    }
  }
}
