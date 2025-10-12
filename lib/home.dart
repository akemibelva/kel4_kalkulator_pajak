import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

    // --- Logika Auto-Scroll untuk Big Card ---
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Timer.periodic(const Duration(seconds: 3), (Timer timer) {
          // Logika loop halaman
          if (_currentPage < 3) { // Sesuaikan batas dengan jumlah gambar (4 gambar -> 3 indeks)
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
        title: const Text(''), // Judul kosong
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
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
}