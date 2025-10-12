import 'package:kalkulator_pajak/model/user.dart'; // Import model data User

// Kelas ini mensimulasikan database atau service API untuk manajemen pengguna (Login/Register).
// Data disimpan secara statis dalam memori.
class UserList {
  // List simulasi pengguna terdaftar
  static List<User> _registeredUsers = [
    User(username: 'admin', password: 'password') // Pengguna default
  ];

  // Status login global aplikasi
  static bool _isLoggedIn = false;

  // Getter publik untuk memeriksa status login
  static bool get isLoggedIn => _isLoggedIn;

  // --- Fungsi: Simulasi Login ---
  static Future<bool> login(String username, String password) async {
    // Simulasi penundaan jaringan (network delay) selama 500ms
    await Future.delayed(const Duration(milliseconds: 500));

    // Mencari pengguna di list yang sesuai dengan username dan password yang diberikan
    final user = _registeredUsers.firstWhere(
          (u) => u.username == username && u.password == password,
      // Jika tidak ditemukan, kembalikan objek User kosong
      orElse: () => User(username: '', password: ''),
    );

    // Cek apakah pengguna ditemukan
    if (user.username.isNotEmpty) {
      _isLoggedIn = true; // Set status login menjadi true
      return true; // Login berhasil
    }
    _isLoggedIn = false;
    return false; // Login gagal
  }

  // --- Fungsi: Simulasi Register ---
  static Future<bool> register(String username, String password) async {
    // Simulasi penundaan jaringan
    await Future.delayed(const Duration(milliseconds: 500));

    // Cek apakah username sudah ada (Mencegah duplikasi)
    if (_registeredUsers.any((u) => u.username == username)) {
      return false; // Register gagal, username sudah terdaftar
    }

    // Tambahkan pengguna baru ke list
    _registeredUsers.add(User(username: username, password: password));
    return true; // Register berhasil
  }

  // --- Fungsi: Logout ---
  static void logout() {
    // Mengatur status login kembali ke false
    _isLoggedIn = false;
  }
}