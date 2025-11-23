import 'package:flutter/material.dart';
import 'package:kalkulator_pajak/model/news_api_model.dart'; // Model data berita
import 'package:kalkulator_pajak/service/news_service.dart'; // Service untuk fetch berita dari API

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // Future yang akan menyimpan hasil fetch news
  Future<List<News>> _futureNews = Future.value([]);

  @override
  void initState() {
    super.initState();
    // Load berita saat halaman pertama kali dibuka
    _futureNews = NewsService.fetchIndonesianNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================================
      // DRAWER (MENU SAMPING)
      // ================================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF001845)),
              child: Text(
                "Menu",
                style: TextStyle(color: Color(0xFFe2eafc), fontSize: 20),
              ),
            ),
            // daftar menu drawer
            buildDrawerItem(context, "Home", '/home'),
            buildDrawerItem(context, "Pph 21", '/pph21'),
            buildDrawerItem(context, "Pph 22", '/pph22'),
            buildDrawerItem(context, "Pph 23", '/pph23'),
            buildDrawerItem(context, "Pph 25/29", '/pph2529'),
            buildDrawerItem(context, "UMKM", '/umkm'),
            buildDrawerItem(context, "Ppn", '/ppn'),
            buildDrawerItem(context, "PBB", '/pbb'),
            buildDrawerItem(context, "History", '/history'),
            buildDrawerItem(context, "News", '/news'), // halaman aktif
            buildDrawerItem(context, "Guide", '/guide'),
            buildDrawerItem(context, "Logout", '/login'),
          ],
        ),
      ),

      backgroundColor: const Color(0xFFe2eafc),

      // ================================
      // APPBAR
      // ================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Colors.white,
        title: const Text("Berita Terkini"),
      ),

      // ================================
      // BODY: FutureBuilder untuk fetch berita
      // ================================
      body: FutureBuilder<List<News>>(
        future: _futureNews,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error fetch API
          else if (snapshot.hasError) {
            return Center(child: Text("⚠️ Error: ${snapshot.error}"));
          }

          // Jika data kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada berita ditemukan."));
          }

          // Data ada — tampilkan list berita
          final newsList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];

              return GestureDetector(
                // Saat card berita diklik → buka halaman detail
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/news_detail',
                    arguments: news, // Kirim seluruh model news
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),

                  // ================================
                  // ISI CARD BERITA
                  // ================================
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------
                      // GAMBAR BERITA
                      // -------------------------------------------------
                      if (news.imageLink != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            news.imageLink!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 80),
                                ),
                          ),
                        ),

                      // -------------------------------------------------
                      // TEKS BERITA (judul, sumber, deskripsi)
                      // -------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Berita
                            Text(
                              news.titleNews ?? "(Tanpa Judul)",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001845),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Sumber berita
                            Text(
                              news.source,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Deskripsi berita (dipotong 3 baris)
                            Text(
                              news.newsDesc ?? "",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==================================================
  // WIDGET: Item menu di Drawer
  // ==================================================
  Widget buildDrawerItem(BuildContext context, String title, String routeName) {
    bool isActive = title == "News"; // "News" adalah halaman aktif

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF001845) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Tutup drawer

        // Hanya navigasi jika bukan halaman aktif
        if (!isActive) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}
