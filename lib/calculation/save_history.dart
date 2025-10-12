import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:kalkulator_pajak/model/hasil_tax.dart'; // Import model TaxResult (yang memiliki toMap dan fromMap)

// Kelas ini berfungsi sebagai service layer untuk menyimpan dan mengambil riwayat
// perhitungan pajak dari penyimpanan lokal (SharedPreferences).
class SaveHistory {
  static const String _historyKey = 'tax_history'; // Kunci unik untuk menyimpan data di SharedPreferences

  // --- Fungsi: Menyimpan Hasil Perhitungan Baru ---
  static Future<void> saveResult(TaxResult result) async {
    final prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences

    // Dapatkan riwayat yang sudah ada
    List<TaxResult> existingResults = await getAllResults();

    // Tambahkan hasil baru di posisi awal (indeks 0) agar yang terbaru muncul paling atas
    existingResults.insert(0, result);

    // Konversi list objek TaxResult ke list Map<String, dynamic>
    List<Map<String, dynamic>> jsonList = existingResults.map((r) => r.toMap()).toList();

    // Konversi list Map menjadi String JSON dan simpan ke SharedPreferences
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // --- Fungsi: Mengambil Semua Riwayat Perhitungan ---
  static Future<List<TaxResult>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_historyKey); // Ambil String JSON dari kunci riwayat

    if (jsonString == null) {
      return []; // Kembalikan list kosong jika belum ada data
    }

    // 1. Konversi String JSON ke List<dynamic>
    List<dynamic> jsonList = jsonDecode(jsonString);

    // 2. Konversi setiap Map di dalam list menjadi objek TaxResult menggunakan constructor fromMap
    return jsonList.map((map) => TaxResult.fromMap(map as Map<String, dynamic>)).toList();
  }

  // --- Fungsi: Menghapus Satu Entri Riwayat Berdasarkan ID ---
  static Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<TaxResult> results = await getAllResults(); // Dapatkan semua riwayat

    // Filter list untuk menghapus entri yang memiliki ID yang cocok
    results.removeWhere((result) => result.id == id);

    // Konversi kembali list yang telah diperbarui ke format JSON
    List<Map<String, dynamic>> jsonList = results.map((r) => r.toMap()).toList();

    // Simpan kembali list JSON yang sudah terfilter ke SharedPreferences
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // --- Fungsi: Menghapus Semua Riwayat ---
  static Future<void> clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus key yang menyimpan seluruh list riwayat dari penyimpanan lokal
    await prefs.remove(_historyKey);
  }
}