import 'dart:convert';
import 'package:http/http.dart' as http; // Library HTTP untuk request API
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Untuk mengambil API KEY dari .env
import 'package:kalkulator_pajak/model/news_api_model.dart'; // Model data News

class NewsService {
  // Ambil API Key dari file .env
  static final String _apiKey = dotenv.env['NEWSAPI_KEY'] ?? '';

  // Base URL dari NewsAPI
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Fungsi untuk mengecek apakah API key ada
  static void _checkApiKey() {
    if (_apiKey.isEmpty) {
      // Jika API key kosong, lempar error
      throw Exception('❌ API Key NewsAPI belum diatur di file .env');
    }
  }

  /// ============================================================
  /// FETCH BERITA INDONESIA
  /// query=indonesia → mencari semua berita terkait Indonesia
  /// ============================================================
  static Future<List<News>> fetchIndonesianNews() async {
    _checkApiKey(); // Pastikan API key tersedia

    // URL lengkap endpoint NewsAPI
    final url = Uri.parse(
      '$_baseUrl/everything?q=indonesia&sortBy=publishedAt&apiKey=$_apiKey',
    );

    try {
      // Kirim HTTP GET ke API News
      final response = await http.get(url);

      print("📡 URL REQUEST: $url"); // Debug URL
      print("📥 RAW RESPONSE: ${response.body}"); // Print raw JSON responsenya

      // Jika status 200 → berhasil
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body); // Decode JSON ke Map

        // Jika API tidak memberikan status "ok", anggap error
        if (jsonResponse['status'] != 'ok') {
          throw Exception('❌ Error API: ${jsonResponse['message']}');
        }

        // Ambil list artikel dari field "articles"
        final List articles = jsonResponse['articles'];

        // Convert setiap JSON artikel → object News
        return articles.map((json) => News.fromJson(json)).toList();
      }
      // Jika status code bukan 200 → error
      else {
        throw Exception(
          'Gagal mengambil berita. Status: ${response.statusCode}',
        );
      }

    } catch (e) {
      // Tangani error jaringan / parsing
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}
