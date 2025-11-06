import 'package:hive_flutter/hive_flutter.dart';
import 'package:kalkulator_pajak/model/user_database.dart';

class AuthService {
  static const String _userBox = 'user_box'; // Nama box untuk menyimpan data user
  static const String _appSettingsBox = 'app_settings_box'; // Box untuk menyimpan setting (misal login status)

  static late Box<User> _userBoxInstance; // Instance Hive untuk user
  static late Box _appSettings; // Instance Hive untuk settings

  /// 🔹 Inisialisasi Hive box
  /// Bisa langsung dipanggil dari main.dart: await AuthService.init();
  static Future<void> init() async {
    await Hive.initFlutter(); // Inisialisasi Hive untuk Flutter

    // Pastikan adapter terdaftar sebelum buka box
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Buka box user jika belum terbuka
    if (!Hive.isBoxOpen(_userBox)) {
      _userBoxInstance = await Hive.openBox<User>(_userBox);
    } else {
      _userBoxInstance = Hive.box<User>(_userBox);
    }

    // Buka box settings jika belum terbuka
    if (!Hive.isBoxOpen(_appSettingsBox)) {
      _appSettings = await Hive.openBox(_appSettingsBox);
    } else {
      _appSettings = Hive.box(_appSettingsBox);
    }
  }

  // --- Fungsi Authentication ---

  /// Simpan status login di box settings
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    await _appSettings.put('isLoggedIn', isLoggedIn);
  }

  /// Ambil status login dari box settings
  static bool getLoginStatus() {
    return _appSettings.get('isLoggedIn') ?? false; // default false jika belum ada
  }

  /// Registrasi user baru
  /// Return false jika username sudah dipakai
  static Future<bool> registerUser(String username, String password) async {
    // Cek apakah username sudah ada di Hive
    final existingUser =
    _userBoxInstance.values.where((user) => user.username == username);

    if (existingUser.isNotEmpty) {
      return false; // Username sudah digunakan
    }

    // Jika belum ada, buat user baru dan simpan ke Hive
    final newUser = User(username: username, password: password);
    await _userBoxInstance.add(newUser);
    return true;
  }

  /// Login user
  /// Return true jika login berhasil
  static bool loginUser(String username, String password) {
    final user = _userBoxInstance.values.firstWhere(
          (user) => user.username == username && user.password == password,
      orElse: () => User(username: '', password: ''), // default jika tidak ada
    );

    if (user.username.isNotEmpty) {
      setLoginStatus(true);
      return true;
    }
    return false;
  }

  /// Logout user
  static Future<void> logoutUser() async {
    await setLoginStatus(false);
  }
}
