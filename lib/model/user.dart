// Model class ini digunakan untuk merepresentasikan dan menyimpan data dasar
// setiap pengguna yang terdaftar di aplikasi.
class User {
  final String username; // Username unik pengguna
  final String password; // Password pengguna (disimpan dalam bentuk teks biasa dalam simulasi ini)
  // Anda bisa menambahkan field lain seperti String fullName

  // Constructor utama
  User({required this.username, required this.password});

  // --- Factory Constructor: Konversi dari Map ---
  // Digunakan saat mengambil data pengguna dari penyimpanan atau dari respon API
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  // --- Metode Instans: Konversi ke Map ---
  // Digunakan saat menyimpan objek User ke penyimpanan lokal (misalnya SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}