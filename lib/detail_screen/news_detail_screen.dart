import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kalkulator_pajak/model/news_api_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe2eafc),

      appBar: AppBar(
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Colors.white,
        title: Text(
          news.titleNews ?? 'Detail Berita',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR BERITA ---
            if (news.imageLink != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    news.imageLink!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image, size: 120),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // --- JUDUL BERITA ---
            Text(
              news.titleNews ?? '(Tanpa Judul)',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001845),
              ),
            ),
            const SizedBox(height: 10),

            // --- SUMBER BERITA ---
            Text(
              'Sumber: ${news.source ?? '-'}',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // --- DESKRIPSI BERITA ---
            Text(
              news.newsDesc ?? 'Deskripsi tidak tersedia.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),

            // --- TOMBOL LINK ASLI ---
            if (news.link != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001845),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final url = Uri.parse(news.link!);
                    if (await canLaunchUrl(url)) {
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
