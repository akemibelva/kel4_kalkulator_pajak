// Model News digunakan untuk merepresentasikan data berita
// (biasanya berasal dari API seperti NewsAPI.org)
class News {
  // Deklarasi atribut utama yang ada di dalam data berita
  final String source;        // Nama sumber berita, misalnya: "BBC News"
  final String? titleNews;    // Judul berita
  final String? newsDesc;     // Deskripsi singkat isi berita
  final String link;          // URL/link untuk membuka berita lengkap
  final String? imageLink;    // URL gambar berita (jika tersedia)

  // Konstruktor utama untuk membuat objek News secara manual
  News({
    required this.source,
    required this.titleNews,
    required this.newsDesc,
    required this.link,
    required this.imageLink,
  });

  // Factory constructor digunakan untuk membuat objek News dari data JSON
  // Biasanya JSON ini berasal dari response API berita
  factory News.fromJson(Map<String, dynamic> json) {
    // Beberapa API memiliki struktur nested untuk source,
    // misalnya: "source": { "id": "bbc-news", "name": "BBC News" }
    // Jadi kita ambil dulu map-nya, dan kalau null beri map kosong.
    final sourceData = json['source'] as Map<String, dynamic>? ?? {};

    return News(
      // Ambil nama sumber berita dari field 'source.name'
      // Jika tidak ada, tampilkan 'Unknown Source'
      source: sourceData['name'] ?? 'Unknown Source',

      // Ambil judul berita dari field 'title'
      titleNews: json['title'] as String?,

      // Ambil deskripsi singkat berita dari field 'description'
      newsDesc: json['description'] as String?,

      // Ambil link berita (URL ke artikel aslinya)
      // Jika tidak ada, set ke string kosong untuk mencegah error
      link: json['url'] as String? ?? '',

      // Ambil link gambar dari field 'urlToImage' jika tersedia
      imageLink: json['urlToImage'] as String?,
    );
  }
}
