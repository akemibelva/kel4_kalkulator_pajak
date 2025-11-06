import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Import Halaman-halaman Kalkulator
import 'calculation/pbb.dart';
import 'calculation/pph.dart';
import 'calculation/pph22.dart';
import 'calculation/pph23.dart';
import 'calculation/pph2529.dart';
import 'calculation/ppn.dart';
import 'calculation/umkm.dart';
// Import Halaman Navigasi/Utilitas
import 'login/login.dart';
import 'splash_opening.dart';
import 'home.dart';
import 'login/register.dart';
import 'rules.dart';
import 'calculation/history.dart';
// Import Model
import 'package:kalkulator_pajak/model/hasil_tax.dart'; // TaxResult
import 'package:kalkulator_pajak/model/user_database.dart';
//import service
import 'service/user_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter siap sebelum async
  await AuthService.init(); // Inisialisasi Hive (database lokal)
  Hive.registerAdapter(UserAdapter()); // Daftarkan adapter untuk User

  // Buka semua box Hive sebelum menjalankan app
  await Hive.openBox<User>('user_box'); // Box untuk data user
  await Hive.openBox('app_settings_box'); // Box untuk data setting

  // Memastikan semua widget sudah diinisialisasi sebelum menjalankan aplikasi (penting untuk async tasks)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Definisikan warna primer custom yang digunakan di seluruh aplikasi
  static const Color customPrimaryColor = Color(0xFF001845); // Biru tua gelap

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Pajak',

      // --- KONFIGURASI TEMA (MATERIAL 3) ---
      theme: ThemeData(
        useMaterial3: true, // Mengaktifkan Material 3

        // Skema warna utama (dihasilkan dari customPrimaryColor)
        colorScheme: ColorScheme.fromSeed(
          seedColor: customPrimaryColor, // Warna dasar skema
        ).copyWith(
          primary: customPrimaryColor, // Mengatur warna primer (tombol, App Bar, dll)
        ),

        // Pengaturan App Bar secara global
        appBarTheme: const AppBarTheme(
          backgroundColor: customPrimaryColor,
          foregroundColor: Color(0xFFe2eafc), // Warna teks/ikon AppBar (putih kebiruan)
          elevation: 4.0,
        ),

        // Pengaturan Tombol Elevasi secara global
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customPrimaryColor,
            foregroundColor: const Color(0xFFe2eafc),
          ),
        ),
      ),
      initialRoute: '/splash', // Rute awal yang dimuat

      // --- 1. Rute Statis (Tidak Menerima Argumen Khusus) ---
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => const Register(),
        '/guide': (context) => const Rules(),
        '/splash': (context) => const SplashScreen(),
        '/history': (context) => const History(),
      },

      // --- 2. Rute Dinamis (Menerima Argumen, khususnya TaxResult dari History) ---
      onGenerateRoute: (settings) {
        // Map rute kalkulator yang perlu menerima data lama (TaxResult)
        final calculatorRoutes = {
          '/pph21': (args) => PphCalculator(initialData: args),
          '/ppn': (args) => PpnCalculator(initialData: args),
          '/pbb': (args) => PbbCalculator(initialData: args),
          '/umkm': (args) => UmkmSimulasi(initialData: args),
          '/pph22': (args) => Pph22Calculator(initialData: args),
          '/pph23': (args) => Pph23Calculator(initialData: args),
          '/pph2529': (args) => Pph2529Calculator(initialData: args),
        };

        if (calculatorRoutes.containsKey(settings.name)) {
          // Mengambil argumen (diharapkan berupa TaxResult atau null)
          final args = settings.arguments as TaxResult?;
          final builderFunction = calculatorRoutes[settings.name]!;

          // Mengarahkan ke halaman kalkulator dengan argumen (data lama)
          return MaterialPageRoute(
            builder: (context) => builderFunction(args),
          );
        }

        // Jika rute tidak ditemukan di sini, biarkan rute statis (routes:) yang mencarinya.
        return null;
      },
    );
  }
}