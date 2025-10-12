import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter.blur (Efek Glassmorphism)
import 'user_list.dart'; // Asumsi: Kelas untuk menyimpan data user dan logika registrasi

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  // State untuk visibilitas password
  bool _passwordObscure = true;
  bool _confirmObscure = true;
  bool _isLoading = false; // State untuk tampilan loading saat submit

  // Global Key untuk Form (Diperlukan untuk validasi form)
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil input teks
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController(); // Controller konfirmasi password

  @override
  void dispose() {
    // Penting: Membuang controllers saat widget dihancurkan
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // --- Fungsi Validator ---
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib Diisi' : null;

  String? _passwordMatchValidator(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi Password wajib diisi';
    // Membandingkan input konfirmasi dengan nilai di _password controller
    if (v != _password.text) return 'Password tidak cocok';
    return null;
  }
  // --- Akhir Fungsi Validator ---

  // --- Logika Submit Registrasi ---
  void _submit() async {
    // 1. Memvalidasi semua field form
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final username = _username.text.trim();
      final password = _password.text;

      // 2. Panggil fungsi registrasi dari UserList
      final success = await UserList.register(username, password);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // 3. Registrasi Berhasil: Tampilkan notifikasi dan kembali ke halaman Login
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Registrasi Berhasil! Silakan masuk (Login).')));
          Navigator.of(context).pop();
        } else {
          // 4. Registrasi Gagal: Username sudah ada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registrasi Gagal. Username sudah digunakan.')),
          );
        }
      }
    }
  }
  // --- Akhir Logika Submit ---

  // --- Fungsi Pembantu untuk Dekorasi Input (Glassmorphism style) ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      fillColor: Colors.black.withOpacity(0.2), // Latar belakang input transparan
      filled: true,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // === STRUKTUR GLASSMORPHISM ===
    return Scaffold(
      // Memungkinkan body (background image) meluas ke area App Bar (untuk AppBar transparan)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registrasi Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // App Bar diatur transparan
        elevation: 0, // Menghilangkan shadow
        iconTheme: const IconThemeData(color: Colors.white), // Tombol kembali berwarna putih
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND IMAGE
          Image.asset(
            'image/bs2.jpg',
            fit: BoxFit.cover,
          ),

          // 2. TINT OVERLAY (Lapisan gelap untuk kontras)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 3. KOTAK REGISTER DENGAN BLUR EFFECT
          Center(
            child: SingleChildScrollView( // Memastikan form dapat digulir jika keyboard muncul
              padding: const EdgeInsets.all(24),
              child: ClipRRect( // Memastikan blur dan border radius rapi
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Efek Blur
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Kotak transparan
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.3)),
                    ),
                    child: Form( // Membungkus input dengan Form untuk validasi
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Judul
                          const Text(
                            'Daftar Akun Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // --- Input Username ---
                          TextFormField(
                            controller: _username,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                            _buildInputDecoration('Username', Icons.person),
                            validator: _required, // Validator wajib diisi
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: 15),

                          // --- Input Password ---
                          TextFormField(
                            controller: _password,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                                'Password', Icons.lock).copyWith(
                              suffixIcon: IconButton( // Tombol toggle visibility
                                icon: Icon(
                                  _passwordObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(
                                        () => _passwordObscure = !_passwordObscure),
                              ),
                            ),
                            obscureText: _passwordObscure,
                            validator: (v) => (v == null || v.length < 6) // Minimal 6 karakter
                                ? 'Password minimal 6 karakter'
                                : null,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                          ),

                          const SizedBox(height: 15),

                          // --- Input Konfirmasi Password ---
                          TextFormField(
                            controller: _confirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                                'Konfirmasi Password', Icons.lock).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(
                                        () => _confirmObscure = !_confirmObscure),
                              ),
                            ),
                            obscureText: _confirmObscure,
                            validator: _passwordMatchValidator, // Validator harus cocok
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                          ),

                          const SizedBox(height: 30),

                          // --- Tombol Daftar ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit, // Nonaktif saat loading
                              icon: _isLoading
                                  ? const SizedBox( // Tampilkan loading spinner
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check, color: Colors.white),
                              label: Text(
                                  _isLoading ? 'Mendaftarkan...' : 'Daftar',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF001845),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
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