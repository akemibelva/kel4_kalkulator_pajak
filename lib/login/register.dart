import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk efek blur (glassmorphism)
import 'package:intl/intl.dart'; // Untuk format tanggal (DateFormat)
import 'package:kalkulator_pajak/service/user_service.dart'; // Service penyimpanan user ke Hive

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {

  // ---------------------------------------------------------
  // 🔹 STATE UTAMA
  // ---------------------------------------------------------

  bool _passwordObscure = true;     // State untuk show/hide password
  bool _confirmObscure = true;      // State untuk show/hide konfirmasi password
  bool _isLoading = false;          // Indikator loading tombol submit

  // ---------------------------------------------------------
  // 🔹 STATE BARU (keperluan UAS)
  // ---------------------------------------------------------

  String? _selectedGender;          // Untuk pilihan Radio (Pria/Wanita)
  DateTime? _selectedDate;          // Untuk Date Picker
  bool _isAgreed = false;           // Checkbox “setuju syarat dan ketentuan”

  // ---------------------------------------------------------
  // 🔹 CONTROLLER
  // ---------------------------------------------------------

  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _dateController = TextEditingController(); // Controller hanya untuk menampilkan tanggal

  @override
  void dispose() {
    // Dispose untuk menghindari memory leak
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // 📅 FUNGSI DATE PICKER
  // ---------------------------------------------------------
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Default: Hari ini
      firstDate: DateTime(1900),                    // Range awal
      lastDate: DateTime.now(),                    // Tidak boleh melebihi hari ini
      builder: (context, child) {
        // Custom theme untuk dark mode dan efek futuristik
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF001845),
              onPrimary: Colors.white,
              surface: Colors.black38,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black.withOpacity(0.8),
          ),
          child: child!,
        );
      },
    );

    // Jika user memilih tanggal baru
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        // Format tampilan tanggal ke dalam TextField
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  // ---------------------------------------------------------
  // VALIDATOR INPUT
  // ---------------------------------------------------------

  // Validator untuk field yang wajib diisi
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  // Validator cocok password
  String? _passwordMatchValidator(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _password.text) return 'Password tidak cocok';
    return null;
  }

  // Validator gender, tanggal lahir, dan checkbox
  String? _validateRequiredFields() {
    if (_selectedGender == null) return 'Jenis kelamin wajib dipilih';
    if (_selectedDate == null) return 'Tanggal lahir wajib diisi';
    if (!_isAgreed) return 'Anda harus menyetujui syarat dan ketentuan';
    return null;
  }

  // ---------------------------------------------------------
  // 🔹 FUNGSI SUBMIT / REGISTER
  // ---------------------------------------------------------
  void _submit() async {
    // Validasi semua TextFormField
    if (!_formKey.currentState!.validate()) return;

    // Validasi tambahan Radio, Checkbox dan Date Picker
    final requiredError = _validateRequiredFields();
    if (requiredError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(requiredError), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Ambil value input
    final username = _username.text.trim();
    final password = _password.text;
    final gender = _selectedGender!;
    final dateOfBirth = _selectedDate!;

    // Simpan user melalui UserService ke Hive database
    final success = await UserService.registerUser(
      username,
      password,
      gender,
      dateOfBirth,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Jika berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Kembali ke halaman login
      } else {
        // Jika username duplikat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah digunakan, coba yang lain.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------
  // Dekorasi Input dengan Tema Glassmorphism
  // ---------------------------------------------------------
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),

      // Border normal
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),

      // Border saat fokus
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),

      filled: true,
      fillColor: Colors.black.withOpacity(0.2), // Transparan khas glass effect
      contentPadding:
      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  // ---------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Background full screen
      appBar: AppBar(
        title: const Text('Registrasi Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [

          // Background Image
          Image.asset(
            'image/bs2.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFF001845),
                    child: const Center(
                      child: Text(
                        "Background Placeholder",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
          ),

          // Layer hitam transparan di atas background
          Container(color: Colors.black.withOpacity(0.5)),

          // FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),

                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.3)),
                    ),

                    // FORM REGISTRASI
                    child: Form(
                      key: _formKey,
                      child: Column(
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

                          // -----------------------
                          // Input Username
                          // -----------------------
                          TextFormField(
                            controller: _username,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Username', Icons.person),
                            validator: _required,
                          ),

                          const SizedBox(height: 15),

                          // -----------------------
                          // Input Password
                          // -----------------------
                          TextFormField(
                            controller: _password,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration('Password', Icons.lock)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    setState(() => _passwordObscure = !_passwordObscure),
                              ),
                            ),
                            obscureText: _passwordObscure,
                            validator: (v) =>
                            (v == null || v.length < 6)
                                ? 'Password minimal 6 karakter'
                                : null,
                          ),

                          const SizedBox(height: 15),

                          // -----------------------
                          // Input Konfirmasi Password
                          // -----------------------
                          TextFormField(
                            controller: _confirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration:
                            _buildInputDecoration('Konfirmasi Password', Icons.lock)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    setState(() => _confirmObscure = !_confirmObscure),
                              ),
                            ),
                            obscureText: _confirmObscure,
                            validator: _passwordMatchValidator,
                          ),

                          const SizedBox(height: 20),

                          // -----------------------
                          // RADIO JENIS KELAMIN
                          // -----------------------
                          const Text(
                            'Jenis Kelamin:',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Pria', style: TextStyle(color: Colors.white)),
                                  value: 'Pria',
                                  groupValue: _selectedGender,
                                  onChanged: (value) =>
                                      setState(() => _selectedGender = value),
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Wanita', style: TextStyle(color: Colors.white)),
                                  value: 'Wanita',
                                  groupValue: _selectedGender,
                                  onChanged: (value) =>
                                      setState(() => _selectedGender = value),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // -----------------------
                          // INPUT TANGGAL LAHIR
                          // -----------------------
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              'Tanggal Lahir',
                              Icons.calendar_today,
                            ).copyWith(
                              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                            ),
                            onTap: _selectDate,
                          ),

                          const SizedBox(height: 10),

                          // -----------------------
                          // CHECKBOX S&K
                          // -----------------------
                          Row(
                            children: [
                              Checkbox(
                                value: _isAgreed,
                                onChanged: (value) =>
                                    setState(() => _isAgreed = value!),
                                activeColor: const Color(0xFF001845),
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isAgreed = !_isAgreed),
                                  child: const Text(
                                    'Saya menyetujui syarat dan ketentuan.',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // -----------------------
                          // Tombol Daftar
                          // -----------------------
                          ElevatedButton.icon(
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
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
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
