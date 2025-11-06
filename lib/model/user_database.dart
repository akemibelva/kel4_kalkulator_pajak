// lib/database/user_database.dart
import 'package:hive/hive.dart';
part 'user_database.g.dart'; // Diperlukan untuk kode generator Hive (adapter)

// ✨ Model User untuk menyimpan data user di Hive
@HiveType(typeId: 3) // typeId unik untuk Hive, pastikan tidak bentrok dengan model lain
class User extends HiveObject {
  @HiveField(0)
  late String username; // Nama user, wajib diisi dan unik

  @HiveField(1)
  late String password; // Password user, untuk contoh sederhana disimpan plain text

  // Konstruktor untuk membuat instance User baru
  User({
    required this.username, // Username wajib diisi
    required this.password, // Password wajib diisi
  });
}
