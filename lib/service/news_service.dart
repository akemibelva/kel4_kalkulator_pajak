import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kalkulator_pajak/model/news_api_model.dart';

class NewsService {
  static final String _apiKey = dotenv.env['NEWSAPI_KEY'] ?? '';

  static const String _baseUrl = 'https://newsapi.org/v2';

  static void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception('❌ API Key NewsAPI belum diatur di file .env');
    }
  }

  /// 📰 Ambil berita Indonesia (query: indonesia)
  static Future<List<News>> fetchIndonesianNews() async {
    _checkApiKey();

    final url = Uri.parse(
      '$_baseUrl/everything?q=indonesia&sortBy=publishedAt&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      print("📡 URL REQUEST: $url");
      print("📥 RAW RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] != 'ok') {
          throw Exception('❌ Error API: ${jsonResponse['message']}');
        }

        final List articles = jsonResponse['articles'];

        // Convert JSON → List<News>
        return articles.map((json) => News.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil berita. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}
