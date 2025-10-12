import 'package:flutter/material.dart';
import 'login/login.dart'; // Import halaman tujuan (Login)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menjalankan fungsi setelah penundaan waktu (delay)
    Future.delayed(const Duration(seconds: 3), () {
      // Navigasi ke halaman Login dan menggantikan (replace) rute saat ini.
      // Penggunaan pushReplacement mencegah pengguna kembali ke splash screen dengan tombol back.
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFe2eafc), // Warna latar belakang cerah
      body: Center(
        // Menggunakan Column untuk menumpuk widget secara vertikal (Logo dan Teks)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
          children: [
            // --- Logo ---
            Image(
              image: AssetImage('image/log.png'), // GANTI dengan path logo Anda
              width: 300,
              height: 300,
            ),

            SizedBox(height: 20), // Memberi jarak antara logo dan teks

            // --- Teks Judul ---
            Text(
              "CALCULATOR",
              style: TextStyle(
                color: Color(0xFF001845), // Warna teks gelap
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}