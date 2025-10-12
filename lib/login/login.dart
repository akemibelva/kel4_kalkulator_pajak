import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur
import 'user_list.dart'; // Asumsi: Kelas untuk menyimpan data user dan logika login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers untuk mengambil input dari TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk mengontrol tampilan loading dan visibilitas password
  bool _isLoading = false;
  bool _obscurePassword = true;


  // --- Logika Penanganan Login ---
  void _handleLogin() async {
    // Aktifkan loading saat proses dimulai
    setState(() {
      _isLoading = true;
    });

    // Panggil fungsi login dari UserList
    final success = await UserList.login(
      _usernameController.text,
      _passwordController.text,
    );

    // Nonaktifkan loading setelah proses selesai
    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Jika berhasil, navigasi ke halaman home dan hapus riwayat navigasi sebelumnya
      Navigator.of(context).pushReplacementNamed('/home', arguments: _usernameController.text);
    } else {
      // Jika gagal, tampilkan Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Gagal. Cek username dan password.')),
      );
    }
  }
  // --- Akhir Logika Login ---


  // --- Fungsi Pembantu untuk Dekorasi Input (Glassmorphism style) ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      // Border saat tidak fokus
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      // Border saat fokus
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      // Latar belakang input transparan
      fillColor: Colors.black.withOpacity(0.2),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND IMAGE
          Image.asset(
            'image/bs2.jpg', // GANTI DENGAN PATH ASSET GAMBAR ANDA
            fit: BoxFit.cover,
          ),

          // 2. TINT OVERLAY (Lapisan warna gelap agar teks putih lebih kontras)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 3. KOTAK LOGIN DENGAN BLUR EFFECT (Glassmorphism)
          Center(
            child: ClipRRect( // Memotong konten agar border radius berlaku untuk blur
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter( // Widget utama yang menciptakan efek BLUR
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(30),
                  // Dekorasi kotak transparan
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // Warna latar belakang transparan
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Menggunakan ruang minimum yang diperlukan
                    children: [
                      // Judul
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Email/Username
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                            'Username', Icons.person),
                      ),
                      const SizedBox(height: 20),

                      // Input Password
                      TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // State untuk menyembunyikan teks
                          style: const TextStyle(color: Colors.white),
                          // Menambahkan ikon visibility ke InputDecoration
                          decoration: _buildInputDecoration(
                              'Password', Icons.lock).copyWith(suffixIcon: IconButton(
                            icon: Icon(
                              // Mengganti ikon berdasarkan state _obscurePassword
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              // Mengubah state visibilitas password
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          )

                      ),

                      const SizedBox(height: 30),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin, // Nonaktifkan tombol saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF001845), // Warna tombol gelap
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                          // Tampilkan indikator loading jika _isLoading true
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          // Tampilkan teks 'Login' jika _isLoading false
                              : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Navigasi ke Register
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text(
                          "Don't have an account? Register",
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