import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka link berita asli di browser
import 'package:kalkulator_pajak/model/news_api_model.dart'; // Model data berita

// Halaman detail berita menerima satu objek "News"
class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe2eafc), // Warna background halaman

      // =======================
      // APP BAR / HEADER
      // =======================
      appBar: AppBar(
        backgroundColor: const Color(0xFF001845), // Warna biru gelap
        foregroundColor: Colors.white, // Warna icon back & teks
        title: Text(
          news.titleNews ?? 'Detail Berita', // Judul di AppBar
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // =======================
      // ISI HALAMAN
      // =======================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // Jarak dari pinggir
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------
            // GAMBAR BERITA
            // -----------------------
            if (news.imageLink != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Efek shadow pada gambar
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  // Membuat ujung gambar melengkung (rounded)
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    news.imageLink!, // URL gambar
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image, size: 120), // Jika gagal load
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // -----------------------
            // JUDUL BERITA
            // -----------------------
            Text(
              news.titleNews ?? '(Tanpa Judul)',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001845),
              ),
            ),

            const SizedBox(height: 10),

            // -----------------------
            // SUMBER BERITA
            // -----------------------
            Text(
              'Sumber: ${news.source ?? '-'}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------
            // DESKRIPSI BERITA
            // -----------------------
            Text(
              news.newsDesc ?? 'Deskripsi tidak tersedia.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5, // Jarak antar baris
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify, // Teks rata kanan–kiri
            ),

            const SizedBox(height: 30),

            // -----------------------
            // TOMBOL UNTUK BUKA LINK ASLI
            // -----------------------
            if (news.link != null)
              SizedBox(
                width: double.infinity, // Tombol lebar penuh
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001845),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // Tombol rounded
                    ),
                  ),
                  onPressed: () async {
                    final url = Uri.parse(news.link!);
                    // Cek apakah URL bisa dibuka
                    if (await canLaunchUrl(url)) {
                      // Buka di browser luar
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text(
                    "Baca di Sumber Asli",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
