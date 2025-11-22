import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk efek blur (glassmorphism)
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:kalkulator_pajak/service/user_service.dart'; // 🔹 Import AuthService

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  // --- STATE UTAMA ---
  bool _passwordObscure = true;
  bool _confirmObscure = true;
  bool _isLoading = false;

  // 🔽 STATE BARU UNTUK PERSYARATAN UAS 🔽
  String? _selectedGender; // Radio Button state
  DateTime? _selectedDate; // Pickers state
  bool _isAgreed = false; // Checkbox state
  // 🔼 STATE BARU UNTUK PERSYARATAN UAS 🔼

  // --- FORM & CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _dateController = TextEditingController(); // Controller untuk menampilkan tanggal

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // --- 📅 FUNGSI DATE PICKER ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF001845),
              onPrimary: Colors.white,
              surface: Colors.black54,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black.withOpacity(0.8),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  // --- VALIDATOR FUNGSI ---
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  String? _passwordMatchValidator(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
    if (v != _password.text) return 'Password tidak cocok';
    return null;
  }

  // Validator untuk Radio Button dan Date Picker
  String? _validateRequiredFields() {
    if (_selectedGender == null) {
      return 'Jenis kelamin wajib dipilih';
    }
    if (_selectedDate == null) {
      return 'Tanggal lahir wajib diisi';
    }
    if (!_isAgreed) {
      return 'Anda harus menyetujui syarat dan ketentuan';
    }
    return null;
  }

  // --- 🔹 FUNGSI REGISTER USER KE DATABASE HIVE ---
  void _submit() async {
    // 1. Validasi TextFormField
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi Radio Button, Picker, dan Checkbox
    final requiredError = _validateRequiredFields();
    if (requiredError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(requiredError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final username = _username.text.trim();
    final password = _password.text;
    final gender = _selectedGender!; // Dipastikan tidak null oleh validator
    final dateOfBirth = _selectedDate!; // Dipastikan tidak null oleh validator

    // 🔸 Panggil AuthService.registerUser dengan 4 parameter baru
    final success = await UserService.registerUser(
      username,
      password,
      gender,
      dateOfBirth,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username sudah digunakan, coba yang lain.'),
            backgroundColor: Colors.red,
          ),
        );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registrasi Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('image/bs2.jpg', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
            // Placeholder jika asset tidak ditemukan
            return Container(color: Color(0xFF001845), child: Center(child: Text("Background Placeholder", style: TextStyle(color: Colors.white))));
          }),
          Container(color: Colors.black.withOpacity(0.5)),

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

                    // --- FORM REGISTRASI ---
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                          const SizedBox(height: 20),

                          const Text(
                            'Jenis Kelamin:',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Pria', style: TextStyle(color: Colors.white)),
                                  value: 'Pria',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value);
                                  },
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Wanita', style: TextStyle(color: Colors.white)),
                                  value: 'Wanita',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() => _selectedGender = value);
                                  },
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),


                          TextFormField(
                            controller: _dateController,
                            readOnly: true, // Membuat field hanya bisa dipilih (bukan diketik)
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                                'Tanggal Lahir', Icons.calendar_today).copyWith(
                              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                            ),
                            onTap: _selectDate, // Memicu Date Picker
                            // Validasi akan dilakukan di _validateRequiredFields
                          ),
                          const SizedBox(height: 10),

                          // 🔽 3. CHECKBOX (Syarat & Ketentuan) - Elemen Wajib UAS 🔽
                          Row(
                            children: [
                              Checkbox(
                                value: _isAgreed,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _isAgreed = newValue!;
                                  });
                                },
                                activeColor: const Color(0xFF001845),
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _isAgreed = !_isAgreed); // Toggle saat teks diklik
                                  },
                                  child: const Text(
                                    'Saya menyetujui syarat dan ketentuan.',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- Tombol Daftar ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
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