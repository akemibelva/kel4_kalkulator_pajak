import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk efek blur (Glassmorphism)
import 'package:kalkulator_pajak/service/user_service.dart'; // 🔹 Koneksi ke Hive untuk login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Controller untuk menangkap input dari TextField ---
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- State untuk loading dan toggle password visibility ---
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Membersihkan controller agar tidak ada kebocoran memori
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 🔹 Logika Proses Login ke Hive (via AuthService) ---
  void _handleLogin() async {
    setState(() {
      _isLoading = true; // Aktifkan indikator loading
    });

    // Ambil nilai input dari form
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // 🔸 Gunakan AuthService untuk login user dari database Hive
    final success = AuthService.loginUser(username, password);

    setState(() {
      _isLoading = false; // Matikan indikator loading setelah proses selesai
    });

    if (success) {
      // ✅ Jika login berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigasi ke halaman home dan hapus riwayat sebelumnya
      Navigator.of(context).pushReplacementNamed(
        '/home',
        arguments: username, // Kirim nama user ke halaman berikutnya
      );
    } else {
      // ❌ Jika login gagal (username atau password salah)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal. Periksa username dan password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Fungsi dekorasi input field (gaya glassmorphism) ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      fillColor: Colors.black.withOpacity(0.2), // Transparan gelap
      filled: true,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY dengan beberapa lapisan visual
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Latar belakang gambar penuh
          Image.asset(
            'image/bs2.jpg', // Pastikan path sesuai dengan folder project kamu
            fit: BoxFit.cover,
          ),

          // 2️⃣ Overlay gelap agar teks lebih kontras
          Container(color: Colors.black.withOpacity(0.5)),

          // 3️⃣ Kotak login dengan efek blur (Glassmorphism)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Efek blur
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // Transparan putih
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.3)),
                  ),

                  // --- Form Login ---
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔹 Judul form
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Input Username ---
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Username', Icons.person),
                      ),
                      const SizedBox(height: 20),

                      // --- Input Password ---
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, // Sembunyikan teks password
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Password', Icons.lock)
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Ganti ikon sesuai status sembunyikan password
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              // Toggle tampilkan/sembunyikan password
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Tombol Login ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin, // Nonaktifkan tombol saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF001845),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                          // 🔹 Jika sedang loading, tampilkan spinner
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                          // 🔹 Jika tidak loading, tampilkan teks
                              : const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Tombol ke halaman Register ---
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text(
                          "Belum punya akun? Daftar di sini",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
