import 'package:flutter/material.dart';

// Kelas ini adalah widget stateless yang berfungsi menampilkan konstanta, tarif,
// atau informasi kunci perpajakan dalam kotak yang menonjol dan informatif.
class TaxConstantBox extends StatelessWidget {
  final String title; // Judul informasi (contoh: "Tarif PPN")
  final String value; // Nilai kunci (contoh: "11%" atau "Rp 54.000.000")
  final String description; // Penjelasan singkat tentang konstanta tersebut

  const TaxConstantBox({
    super.key,
    required this.title,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFe2eafc), // Warna latar belakang cerah untuk kotak
        borderRadius: BorderRadius.circular(10), // Sudut melengkung
        border: Border.all(color: Colors.blueGrey.shade100), // Garis tepi tipis
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
        children: [
          // --- Judul (Title) ---
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001845), // Warna gelap untuk judul
            ),
          ),
          const SizedBox(height: 5),

          // --- Nilai/Angka Utama (Value) ---
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900, // Sangat tebal
              color: Colors.redAccent, // Menonjolkan angka/tarif
            ),
          ),
          const SizedBox(height: 5),

          // --- Deskripsi/Penjelasan Singkat ---
          Text(
            description,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey, // Warna abu-abu untuk teks pendukung
            ),
          ),
        ],
      ),
    );
  }
}