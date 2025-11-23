import 'package:hive_flutter/hive_flutter.dart';
import 'package:kalkulator_pajak/model/user_database.dart';

class UserService {
  static const String _userBox = 'user_box'; // Nama box untuk menyimpan data user
  static const String _appSettingsBox = 'app_settings_box'; // Box untuk menyimpan setting (misal login status)

  static late Box<User> _userBoxInstance; // Instance Hive untuk user
  static late Box _appSettings; // Instance Hive untuk settings

  // Inisialisasi Hive box
  // Bisa langsung dipanggil dari main.dart: await AuthService.init();
  static Future<void> init() async {
    await Hive.initFlutter(); // Inisialisasi Hive untuk Flutter

    // Pastikan adapter terdaftar sebelum buka box
    // Pastikan typeId 1 sudah terdaftar untuk User (sesuai user_database.dart)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAdapter());
    }
    // Jika ada model lain (seperti TaxResult), pastikan adapter-nya juga terdaftar di sini

    // Buka box user
    if (!Hive.isBoxOpen(_userBox)) {
      _userBoxInstance = await Hive.openBox<User>(_userBox);
    } else {
      _userBoxInstance = Hive.box<User>(_userBox);
    }

    // Buka box settings
    if (!Hive.isBoxOpen(_appSettingsBox)) {
      _appSettings = await Hive.openBox(_appSettingsBox);
    } else {
      _appSettings = Hive.box(_appSettingsBox);
    }
  }

  // --- Fungsi Authentication ---

  // Simpan status login di box settings, sekaligus menyimpan username yang aktif.
  static Future<void> setLoginStatus(bool isLoggedIn, {String? username}) async {
    await _appSettings.put('isLoggedIn', isLoggedIn);

    // Jika login berhasil, simpan username aktif
    if (isLoggedIn && username != null) {
      await _appSettings.put('currentUsername', username);
    }
    // Jika logout (isLoggedIn=false), hapus username aktif
    else if (!isLoggedIn) {
      await _appSettings.delete('currentUsername');
    }
  }

  // Ambil status login dari box settings
  static bool getLoginStatus() {
    return _appSettings.get('isLoggedIn') ?? false; // default false jika belum ada
  }

  // Ambil username yang sedang login (PENTING untuk HistoryService)
  static String? getCurrentUsername() {
    return _appSettings.get('currentUsername');
  }

  // Registrasi user baru
  // Disesuaikan untuk menerima gender dan dateOfBirth
  static Future<bool> registerUser(
      String username,
      String password,
      String gender, // Parameter baru
      DateTime dateOfBirth, // Parameter baru
      ) async {
    // Cek apakah username sudah ada di Hive
    final existingUser =
    _userBoxInstance.values.where((user) => user.username == username);

    if (existingUser.isNotEmpty) {
      return false; // Username sudah digunakan
    }

    // Jika belum ada, buat user baru dan simpan ke Hive
    final newUser = User(
      username: username,
      password: password,
      gender: gender, // Nilai baru
      dateOfBirth: dateOfBirth, // Nilai baru
    );
    await _userBoxInstance.add(newUser);
    return true;
  }

  // Login user
  static bool loginUser(String username, String password) {
    final user = _userBoxInstance.values.firstWhere(
          (user) => user.username == username && user.password == password,
      // WAJIB: Sediakan nilai default untuk gender dan dateOfBirth di orElse
      orElse: () => User(
        username: '',
        password: '',
        gender: '', // Nilai default
        dateOfBirth: DateTime(1900), // Nilai default
      ),
    );

    if (user.username.isNotEmpty) {
      // Panggil fungsi baru dan masukkan username aktif
      setLoginStatus(true, username: username);
      return true;
    }
    return false;
  }

  // Logout user
  static Future<void> logoutUser() async {
    // Panggil fungsi baru dengan isLoggedIn=false dan username=null
    await setLoginStatus(false, username: null);
  }
}