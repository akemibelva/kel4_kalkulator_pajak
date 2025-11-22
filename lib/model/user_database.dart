// lib/database/user_database.dart
import 'package:hive/hive.dart';
part 'user_database.g.dart'; // Diperlukan untuk kode generator Hive (adapter)

// ✨ Model User untuk menyimpan data user di Hive
@HiveType(typeId: 1) // typeId unik untuk Hive, pastikan tidak bentrok dengan model lain
class User extends HiveObject {
  @HiveField(0)
  late String username; // Nama user, wajib diisi dan unik

  @HiveField(1)
  late String password; // Password user, untuk contoh sederhana disimpan plain text

  @HiveField(2)
  late String gender; // Untuk Radio Button (misalnya: 'Pria', 'Wanita')

  @HiveField(3)
  late DateTime dateOfBirth; // Untuk Pickers (Tanggal Lahir)

  // Konstruktor untuk membuat instance User baru
  User({
    required this.username, // Username wajib diisi
    required this.password, // Password wajib diisi
    required this.gender,
    required this.dateOfBirth,
  });
}