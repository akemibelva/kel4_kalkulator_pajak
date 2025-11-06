import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk efek blur (glassmorphism)
import 'package:kalkulator_pajak/service/user_service.dart'; // 🔹 Import AuthService untuk koneksi Hive (database lokal)

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  // --- STATE UTAMA ---
  bool _passwordObscure = true; // Untuk menyembunyikan / menampilkan teks password
  bool _confirmObscure = true; // Untuk konfirmasi password
  bool _isLoading = false; // Untuk menampilkan indikator loading saat proses submit

  // --- FORM & CONTROLLERS ---
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final _username = TextEditingController(); // Controller input username
  final _password = TextEditingController(); // Controller input password
  final _confirmPassword = TextEditingController(); // Controller input konfirmasi password

  @override
  void dispose() {
    // Membersihkan controller agar tidak terjadi memory leak
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // --- VALIDATOR FUNGSI ---
  // Validator wajib diisi
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  // Validator untuk memastikan password dan konfirmasi password cocok
  String? _passwordMatchValidator(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _password.text) return 'Password tidak cocok';
    return null;
  }

  // --- 🔹 FUNGSI REGISTER USER KE DATABASE HIVE ---
  void _submit() async {
    // Jalankan validasi semua field
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Tampilkan loading

      final username = _username.text.trim(); // Hapus spasi di depan/belakang
      final password = _password.text;

      // 🔸 Panggil AuthService untuk registrasi ke database Hive
      final success = await AuthService.registerUser(username, password);

      // Setelah registrasi selesai, pastikan widget masih aktif (mounted)
      if (mounted) {
        setState(() => _isLoading = false); // Matikan loading spinner

        if (success) {
          // ✅ Registrasi berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop(); // Kembali ke halaman login
        } else {
          // ❌ Registrasi gagal (username sudah digunakan)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username sudah digunakan, coba yang lain.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- DEKORASI INPUT DENGAN GAYA GLASSMORPHISM ---
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
      // Membuat AppBar transparan agar menyatu dengan background image
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registrasi Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // Transparan
        elevation: 0, // Tanpa bayangan
        iconTheme: const IconThemeData(color: Colors.white), // Tombol back putih
      ),

      // BODY dengan lapisan-lapisan visual
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Background Image
          Image.asset('image/bs2.jpg', fit: BoxFit.cover),

          // 2️⃣ Lapisan hitam transparan untuk membuat teks lebih jelas
          Container(color: Colors.black.withOpacity(0.5)),

          // 3️⃣ Form registrasi dengan efek blur (Glassmorphism)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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

                    // --- FORM REGISTRASI ---
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 🔹 Judul Form
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
                            validator: _required,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 15),

                          // --- Input Password ---
                          TextFormField(
                            controller: _password,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                                'Password', Icons.lock).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordObscure
                                      ? Icons.visibility // 👁️ Tampilkan password
                                      : Icons.visibility_off, // 🚫 Sembunyikan
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(
                                      () => _passwordObscure = !_passwordObscure,
                                ),
                              ),
                            ),
                            obscureText: _passwordObscure,
                            validator: (v) =>
                            (v == null || v.length < 6)
                                ? 'Password minimal 6 karakter'
                                : null,
                            textInputAction: TextInputAction.next,
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
                                      () => _confirmObscure = !_confirmObscure,
                                ),
                              ),
                            ),
                            obscureText: _confirmObscure,
                            validator: _passwordMatchValidator,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 30),

                          // --- Tombol Daftar ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              // Nonaktifkan tombol saat loading
                              onPressed: _isLoading ? null : _submit,
                              icon: _isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                                  : const Icon(Icons.check, color: Colors.white),
                              label: Text(
                                _isLoading ? 'Mendaftarkan...' : 'Daftar',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF001845),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- AKHIR FORM REGISTRASI ---
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
