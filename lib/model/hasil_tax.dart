// Model class ini digunakan untuk merepresentasikan dan menyimpan satu entri
// riwayat perhitungan pajak.
class TaxResult {
  final String id; // ID unik untuk identifikasi, misalnya UUID atau timestamp
  final DateTime date; // Waktu dan tanggal perhitungan dilakukan
  final String taxType; // Jenis pajak yang dihitung (Contoh: 'PPh 21', 'UMKM')
  final Map<String, dynamic> inputDetails; // Detail input user (gaji, omzet, NJOP, dll.)
  final double finalResult; // Hasil akhir pajak yang dihitung (dalam Rupiah)
  final String formulaUsed; // Rumus atau langkah-langkah yang digunakan untuk transparansi

  // Constructor utama
  TaxResult({
    required this.id,
    required this.date,
    required this.taxType,
    required this.inputDetails,
    required this.finalResult,
    required this.formulaUsed,
  });

  // --- Factory Constructor: Konversi dari Map ---
  // Digunakan saat mengambil data dari penyimpanan lokal (SharedPreferences/Hive)
  factory TaxResult.fromMap(Map<String, dynamic> map) {
    return TaxResult(
      id: map['id'] as String,
      // Konversi string ISO 8601 kembali ke objek DateTime
      date: DateTime.parse(map['date'] as String),
      taxType: map['taxType'] as String,
      // Cast Map dinamis dari penyimpanan
      inputDetails: map['inputDetails'] as Map<String, dynamic>,
      finalResult: map['finalResult'] as double,
      formulaUsed: map['formulaUsed'] as String,
    );
  }

  // --- Metode Instans: Konversi ke Map ---
  // Digunakan saat menyimpan objek ke penyimpanan lokal (SharedPreferences/Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Konversi DateTime ke string format ISO 8601 agar dapat disimpan oleh SharedPreferences
      'date': date.toIso8601String(),
      'taxType': taxType,
      'inputDetails': inputDetails,
      'finalResult': finalResult,
      'formulaUsed': formulaUsed,
    };
  }
}