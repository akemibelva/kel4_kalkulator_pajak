import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/service/user_service.dart';

// Kelas ini berfungsi sebagai service layer untuk menyimpan dan mengambil riwayat
// perhitungan pajak dari penyimpanan lokal (SharedPreferences).
class SaveHistory {
  // Key ini sekarang menyimpan SEMUA riwayat dari SEMUA pengguna
  static const String _historyKey = 'tax_history';

  // --- Fungsi Pembantu: Mengambil SEMUA data riwayat dari SharedPreferences ---
  // Data dikembalikan dalam bentuk mentah (raw), tanpa filter
  static Future<List<TaxResult>> _fetchAllRawResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey);

    if (jsonString == null) {
      return []; // Kembalikan list kosong jika belum ada data
    }
    // Konversi String JSON ke List<dynamic>
    List<dynamic> jsonList = jsonDecode(jsonString);
    // Konversi setiap Map di dalam list menjadi objek TaxResult
    return jsonList.map((map) => TaxResult.fromMap(map as Map<String, dynamic>)).toList();
  }

  // --- Fungsi Penyimpanan: Menyimpan Hasil Perhitungan Baru ---
  // Pastikan TaxResult yang diinput sudah memiliki field 'username'
  static Future<void> saveResult(TaxResult result) async {
    final prefs = await SharedPreferences.getInstance();

    // Dapatkan SEMUA riwayat yang sudah ada
    List<TaxResult> existingResults = await _fetchAllRawResults();

    // Tambahkan hasil baru di posisi awal (indeks 0)
    existingResults.insert(0, result);

    // Konversi SEMUA list objek TaxResult ke JSON
    List<Map<String, dynamic>> jsonList = existingResults.map((r) => r.toMap()).toList();

    // Simpan SEMUA data kembali ke SharedPreferences
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // --- Fungsi Pengambilan: Mengambil Riwayat HANYA untuk User yang Sedang Login ---
  static Future<List<TaxResult>> getAllResults() async {
    final String? currentUsername = UserService.getCurrentUsername(); // Ambil username aktif dari AuthService

    if (currentUsername == null || currentUsername.isEmpty) {
      return []; // Jika tidak ada user login, kembalikan list kosong
    }

    // 1. Ambil SEMUA riwayat yang ada
    List<TaxResult> allResults = await _fetchAllRawResults();

    // 2. Filter list agar hanya menampilkan riwayat yang username-nya cocok
    return allResults
        .where((result) => result.username == currentUsername)
        .toList();
  }

  // --- Fungsi: Menghapus Satu Entri Riwayat Berdasarkan ID ---
  static Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Dapatkan SEMUA riwayat (tidak perlu filter, karena ID unik secara global)
    List<TaxResult> allResults = await _fetchAllRawResults();

    // Filter list untuk menghapus entri yang memiliki ID yang cocok
    allResults.removeWhere((result) => result.id == id);

    // Konversi kembali SELURUH list yang telah diperbarui ke format JSON
    List<Map<String, dynamic>> jsonList = allResults.map((r) => r.toMap()).toList();

    // Simpan kembali list JSON yang sudah terfilter ke SharedPreferences
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // --- Fungsi: Menghapus Riwayat HANYA milik User Aktif ---
  static Future<void> clearAllResults() async {
    final String? currentUsername = UserService.getCurrentUsername();
    if (currentUsername == null || currentUsername.isEmpty) return; // Tidak ada user login, tidak melakukan apa-apa

    // Dapatkan SEMUA riwayat
    List<TaxResult> allResults = await _fetchAllRawResults();

    // Filter list: Simpan kembali hanya riwayat yang TIDAK dimiliki oleh user aktif
    List<TaxResult> remainingResults = allResults
        .where((result) => result.username != currentUsername)
        .toList();

    // Simpan kembali list yang sudah difilter (hanya menyisakan riwayat user lain)
    List<Map<String, dynamic>> jsonList = remainingResults.map((r) => r.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }
}