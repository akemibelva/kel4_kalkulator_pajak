import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kalkulator_pajak/model/news_api_model.dart';
import 'package:kalkulator_pajak/service/news_service.dart';
import 'package:kalkulator_pajak/model/weather_api_model.dart';
import 'package:kalkulator_pajak/service/weather_service.dart';
import 'package:kalkulator_pajak/model/forecast_api_model.dart';

// Asumsi model Forecast sudah di-import melalui weather_api_model.dart
// import 'package:kalkulator_pajak/model/forecast_api_model.dart';
// Jika model Forecast ada di file terpisah, pastikan sudah diimport.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<News>> _futureNews = Future.value([]);
  Future<Weather> _futureWeather = Future.value(
    // Default value/placeholder sebelum fetching pertama berhasil
      Weather(
          cityName: 'N/A',
          temperature: 0,
          description: '',
          iconCode: '01d',
          windSpeed: 0,
          humidity: 0));

  // =========================================================
  // 1. TAMBAH FUTURE UNTUK PRAKIRAAN CUACA
  // =========================================================
  Future<List<Forecast>> _futureForecast = Future.value([]);


  // Kota default untuk fetching cuaca
  final String _defaultCity = 'Jakarta';
  String _usernameFromRoute = 'User'; // State untuk menyimpan nama pengguna yang masuk
  int selectedIndex = 0;
  final PageController _pageController = PageController(); // Controller untuk menggeser kartu
  int _currentPage = 0; // Indeks halaman saat ini untuk auto-scroll

  // Controller untuk input pencarian
  final TextEditingController _searchController = TextEditingController();

  // Daftar kalkulasi dan rute yang tersedia untuk GridView dan Autocomplete
  final List<Map<String, String>> _calculationRoutes = const [
    {'title': 'Pph 21', 'route': '/pph21'},
    {'title': 'Pph 22', 'route': '/pph22'},
    {'title': 'Pph 23', 'route': '/pph23'},
    {'title': 'Pph 25/29', 'route': '/pph2529'},
    {'title': 'Ppn', 'route': '/ppn'},
    {'title': 'PBB', 'route': '/pbb'},
    {'title': 'UMKM', 'route': '/umkm'},
    {'title': 'Guide & Tips', 'route': '/guide'},
  ];

  void _fetchAllData() {
    setState(() {
      // 1. Fetch Cuaca & Forecast
      _futureWeather = WeatherService.fetchWeatherIndonesia(_defaultCity);
      // Panggil juga fetch prakiraan
      _futureForecast = WeatherService.fetchWeatherForecast(_defaultCity);

      // 2. Fetch Berita (default Indonesia)
      _futureNews = NewsService.fetchIndonesianNews();
    });
    // Menampilkan notifikasi bahwa data sedang diperbarui (opsional)
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Memperbarui cuaca dan berita...'),
            duration: Duration(seconds: 1)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Mengambil argumen (username) yang dilewatkan dari halaman Login/Register
    final args = ModalRoute
        .of(context)
        ?.settings
        .arguments;

    if (args is String && args != _usernameFromRoute) {
      setState(() {
        _usernameFromRoute = args;
      });
    }
  }

  @override
  void dispose() {
    // Membuang controllers untuk mencegah memory leak
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Fungsi Penanganan Pencarian saat Tombol Enter Ditekan ---
  void _handleSearch(String query) {
    if (query.isEmpty) return;

    final normalizedQuery = query.toLowerCase().replaceAll(' ', '');

    // Mencari rute yang cocok berdasarkan input
    final match = _calculationRoutes.firstWhere(
          (item) => item['title']!.toLowerCase().replaceAll(' ', '').contains(normalizedQuery),
      orElse: () => {'title': '', 'route': ''},
    );

    if (match['route']!.isNotEmpty) {
      Navigator.of(context).pushNamed(match['route']!);
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kalkulasi "$query" tidak ditemukan.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Pastikan kode initState tidak terulang. Hapus initState ganda.
    // Kode asli yang benar harus seperti ini:

    // Ambil prakiraan cuaca
    // WeatherService memiliki method fetchWeatherForecast(city)
    // dan model Forecast sudah tersedia/diimpor.
    _futureForecast = WeatherService.fetchWeatherForecast(_defaultCity); // 👈 TAMBAH: Fetch Forecast

    // Ambil berita (default Indonesia)
    _futureNews = NewsService.fetchIndonesianNews();

    // --- Logika Auto-Scroll untuk Big Card ---
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Timer.periodic(const Duration(seconds: 3), (Timer timer) {
          if (_currentPage < 3) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }

          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe2eafc), // Warna latar belakang terang

      // --- DRAWER (Menu Samping) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF001845)),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Color(0xFFe2eafc),
                  fontSize: 20,
                ),
              ),
            ),
            // Daftar item menu drawer
            buildDrawerItem("Home", '/home'),
            buildDrawerItem("Pph 21", '/pph21'),
            buildDrawerItem("Pph 22", '/pph22'),
            buildDrawerItem("Pph 23", '/pph23'),
            buildDrawerItem("Pph 25/29", '/pph2529'),
            buildDrawerItem("UMKM", '/umkm'),
            buildDrawerItem("Ppn", '/ppn'),
            buildDrawerItem("PBB", '/pbb'),
            buildDrawerItem("History", '/history'),
            buildDrawerItem("News", '/news'),
            buildDrawerItem("Guide", '/guide'),
            buildDrawerItem("Logout", '/login'),
          ],
        ),
      ),

      // --- APP BAR (Hanya menampilkan tombol menu) ---
      appBar:AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFe2eafc)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(''),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),

        // --- Aksi AppBar: Tombol Refresh ---
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFe2eafc)),
            onPressed: _fetchAllData, // Panggil fungsi refresh
            tooltip: 'Refresh Data',
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Konten Utama Dibungkus di dalam Expanded ListView
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 20),
                children: [

                  // --- Sapaan Selamat Datang ---
                  Text(
                    "Welcome, $_usernameFromRoute",
                    style: TextStyle(
                      color: Color(0xFF001845),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20,),

                  // --- Bagian Kartu Geser (Big Card) ---
                  buildBigCard([
                    "image/bg3.jpg",
                    "image/bs2.jpg",
                    "image/g11.jpg",
                    "image/g1.jpg",
                  ]),

                  const SizedBox(height: 20),

                  // --- Autocomplete Search Bar ---
                  // ... (Kode Autocomplete Search Bar tidak berubah)
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      // Logika filter untuk saran
                      return _calculationRoutes
                          .where((item) =>
                          item['title']!.toLowerCase().replaceAll(' ', '').contains(
                              textEditingValue.text.toLowerCase().replaceAll(' ', '')))
                          .map((item) => item['title']!);
                    },

                    onSelected: (String selection) {
                      // Logika navigasi saat item dipilih dari dropdown
                      final selectedRoute = _calculationRoutes.firstWhere(
                            (item) => item['title'] == selection,
                        orElse: () => {'title': '', 'route': ''},
                      );
                      if (selectedRoute['route']!.isNotEmpty) {
                        Navigator.of(context).pushNamed(selectedRoute['route']!);
                      }
                      _searchController.clear();
                    },

                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      // Mendesain input field
                      _searchController.text = textEditingController.text;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onSubmitted: _handleSearch, // Memanggil fungsi saat Enter
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: "Search calculation",
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    },

                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options) {
                      // Mendesain tampilan dropdown saran
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 350,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option, style: const TextStyle(
                                      color: Color(0xFF001845))),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30,),

                  buildWeatherSectionCombined(),

                  const SizedBox(height: 10,),

                  //News API
                  const Text(
                    '📰 Berita Terkini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  // FutureBuilder untuk menampilkan berita
                  FutureBuilder<List<News>>(
                    future: _futureNews,   // 🔗 Future berita yang akan ditampilkan
                    builder: (context, snapshot) {

                      // ⏳ Tampilkan loading saat data masih diambil
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // ❌ Jika error saat fetch API
                      else if (snapshot.hasError) {
                        return Text('⚠️ ${snapshot.error}');
                      }

                      // 📭 Jika API berhasil tapi tidak ada data
                      else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Tidak ada berita ditemukan.');
                      }

                      // 🎉 Jika data tersedia → tampilkan 3 berita teratas
                      final newsList = snapshot.data!;

                      return Column(
                        children: newsList.take(3).map((news) {
                          return Card(
                            color: const Color(0xFF001845),

                            child: ListTile(
                              // 🖼 Tampilkan gambar berita jika tersedia
                              leading: news.imageLink != null
                                  ? Image.network(
                                news.imageLink!,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 60);
                                },
                              )
                                  : const Icon(Icons.article_outlined),

                              title: Text(
                                news.titleNews ?? '(Tanpa Judul)',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                news.source,
                                style: const TextStyle(color: Colors.white70), // putih sedikit transparan
                              ),

                              // 🔗 Klik → buka halaman detail berita
                              onTap: () {
                                Navigator.pushNamed(context, '/news_detail', arguments: news);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // --- Judul Grid ---
                  Text(
                    "Calculation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001845),
                    ),
                  ),

                  const SizedBox(height: 20),


                  // --- Grid Menu Kalkulasi ---
                  // ... (Kode Grid Menu Kalkulasi tidak berubah)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Non-scrollable
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,

                    children: [
                      buildMenuCard("Pph 21", "image/g4.jpg", '/pph21'),
                      buildMenuCard("Pph 22", "image/g7.jpg", '/pph22'),
                      buildMenuCard("Pph 23", "image/bg1.jpg", '/pph23'),
                      buildMenuCard("Pph 25/29", "image/bg.jpg", '/pph2529'),
                      buildMenuCard("Ppn", "image/g8.jpg", '/ppn'),
                      buildMenuCard("PBB", "image/g9.jpg", '/pbb'),
                      buildMenuCard("UMKM", "image/g10.jpg", '/umkm'),
                      buildMenuCard("Guide & Tips", "image/g11.jpg", '/guide'),
                    ],
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===== Custom Big Card (Untuk Carousel/Slider) =====
  Widget buildBigCard(List<String> imagePaths) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF001845), Color(0xFF3d5a80)], // Contoh gradasi warna
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Bagian gambar yang bisa digeser (dengan efek darken)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    imagePaths[index],
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3), // Lapisan gelap 30%
                    colorBlendMode: BlendMode.darken,
                  );
                },
              ),
            ),
          ),
          // Title + Subtitle yang diletakkan di atas gambar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Are you ready ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Let's start our tax calculations",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ===== Widget Kartu Menu Grid (Stateless) =====
  Widget buildMenuCard(String title, String imagePath, String routeName) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke rute yang sesuai
        Navigator.of(context).pushNamed(routeName);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              // 1. Gambar Asli (Background)
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 2. Lapisan Gelap (Overlay)
              Positioned.fill(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.3), // Efek darken
                  ),
                ),
              ),
              // 3. Teks (diposisikan di tengah bawah Stack)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white, // Teks putih di atas gambar gelap
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Widget Item Drawer (Menu Samping) =====
  Widget buildDrawerItem(String title, String routeName) {
    bool isActive = title == "Home";

    if (title == "Logout") {
      return ListTile(
        title: Text(title, style: TextStyle(color: Colors.red)),
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(routeName); // Navigasi ke Login
        },
      );
    }

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

        if (isActive) {
          // Navigasi ke Home dengan mengganti rute, membawa username
          Navigator.of(context).pushReplacementNamed(
              routeName, arguments: _usernameFromRoute);
        } else {
          // Navigasi ke rute kalkulator lainnya
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }

  // ===== Widget Kartu Cuaca (Weather Card) =====

  Widget buildWeatherSectionCombined() {
    return FutureBuilder<Weather>(
      future: _futureWeather,
      builder: (context, weatherSnapshot) {

        // ---- 1. WEATHER LOADING ----
        if (weatherSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        // ---- 2. WEATHER ERROR ----
        if (weatherSnapshot.hasError) {
          return Card(
            color: const Color(0xFFffb5a7),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat cuaca: ${weatherSnapshot.error}',
                style: const TextStyle(color: Color(0xFF6d0000)),
              ),
            ),
          );
        }

        // ---- 3. WEATHER OK ----
        if (!weatherSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final weather = weatherSnapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3d5a80),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==========================
              //   BAGIAN WEATHER (ATAS)
              // ==========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kota + Suhu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 ${weather.cityName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Ikon cuaca
                  weather.iconUrl.isNotEmpty
                      ? Image.network(
                    weather.iconUrl,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.wb_sunny,
                          size: 60, color: Colors.yellow);
                    },
                  )
                      : const Icon(Icons.wb_sunny,
                      size: 60, color: Colors.yellow),
                ],
              ),

              const SizedBox(height: 15),

              // Detail
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    weather.description.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          size: 18, color: Colors.lightBlueAccent),
                      const SizedBox(width: 4),
                      Text('${weather.humidity}%',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 12),
                      const Icon(Icons.air, size: 18, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('${weather.windSpeed.toStringAsFixed(1)} m/s',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================================
              //   BAGIAN FORECAST (BAWAH)
              // ================================
              FutureBuilder<List<Forecast>>(
                future: _futureForecast,
                builder: (context, forecastSnapshot) {
                  if (forecastSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 10,
                      child: LinearProgressIndicator(
                        color: Color(0xFF001845),
                      ),
                    );
                  }

                  if (forecastSnapshot.hasError) {
                    return Text(
                      '⚠️ Gagal memuat prakiraan: ${forecastSnapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                    );
                  }

                  if (!forecastSnapshot.hasData ||
                      forecastSnapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // 🎉 Forecast tersedia (ambi hanya 8 data teratas)
                  final forecasts = forecastSnapshot.data!.take(10).toList();

                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecasts.length,
                      itemBuilder: (context, index) {
                        final f = forecasts[index];
                        final time = '${f.date.hour.toString().padLeft(2, '0')}:00';
                        final dateText =
                            '${f.date.day.toString().padLeft(2, '0')}/${f.date.month.toString().padLeft(2, '0')}';

                        return Container(
                          width: 65,
                          margin: EdgeInsets.only(
                            right: index == forecasts.length - 1 ? 0 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF415a77),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 🗓 Tanggal
                              Text(
                                dateText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Jam
                              Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),

                              // Icon Forecast
                              Image.network(
                                'https://openweathermap.org/img/wn/${f.iconCode}@2x.png',
                                width: 35,
                                height: 35,
                                errorBuilder: (c, e, s) =>
                                const Icon(Icons.cloud, size: 35, color: Colors.white),
                              ),

                              // Suhu
                              Text(
                                '${f.temperature.toStringAsFixed(0)}°',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );

                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

}