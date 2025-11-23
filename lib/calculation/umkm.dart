import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPh UMKM)
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/service/save_history.dart'; // Mengandung SaveHistory
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/service/user_service.dart';

class UmkmSimulasi extends StatefulWidget {
  final TaxResult? initialData;
  const UmkmSimulasi({super.key, this.initialData});

  @override
  State<UmkmSimulasi> createState() => _UmkmSimulasiState();
}

class _UmkmSimulasiState extends State<UmkmSimulasi> {
  // Controllers untuk input omzet bulanan dan omzet kumulatif
  final TextEditingController _omzetController = TextEditingController();
  final TextEditingController _cumulativeController = TextEditingController();

  // State untuk menyimpan hasil dan rumus
  double _calculatedTax = 0.0;
  String _formulaUsed = '';
  String _statusMessage = '';

  // State untuk melacak apakah tombol 'Hitung' sudah pernah diklik
  bool _calculationRun = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Memuat data lama jika ada (dari History Screen)
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Mengambil data Omzet Bulanan dan Omzet Kumulatif
      final omzetValue = data.inputDetails['Omzet Bulanan'] as double? ?? 0.0;
      final cumulativeValue = data.inputDetails['Omzet Kumulatif Sebelumnya'] as double? ?? 0.0;

      // Isi Controller dan State
      _omzetController.text = omzetValue.toStringAsFixed(0);
      _cumulativeController.text = cumulativeValue.toStringAsFixed(0);
      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;
      _statusMessage = 'Hasil dimuat dari riwayat.';
      _calculationRun = true; // Set true jika memuat data lama
    }
  }

  // Fungsi utilitas untuk format angka ke Rupiah
  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value);
  }

  void _calculateAndSave() async {

    // Ambil Username Aktif dan Cek Login
    final String? currentUsername = UserService.getCurrentUsername();

    // Periksa apakah pengguna sudah login. Jika tidak, proses tidak dapat dilanjutkan.
    if (currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login untuk menyimpan riwayat perhitungan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1. Membersihkan input dan konversi ke double
    final omzetBulanan = double.tryParse(_omzetController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
    final omzetKumulatif = double.tryParse(_cumulativeController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;

    // Validasi
    if (omzetBulanan <= 0) {
      setState(() { _calculatedTax = 0.0; _formulaUsed = ''; _statusMessage = 'Masukkan omzet bulanan yang valid.'; _calculationRun = false; });
      return;
    }

    // 2. Panggil Logika Perhitungan PPh UMKM (menggunakan fungsi PPH_UMKM_OP yang menghitung batas Rp500 Juta)
    final result = TaxLogic.PPH_UMKM_OP(
      monthlyTurnover: omzetBulanan,
      cumulativeTurnoverToDate: omzetKumulatif,
    );

    // Asumsi: formula disederhanakan di sini
    final formula = '(([Omzet Bulanan] - Batas Bebas Pajak) x 0.5%)';

    // 3. Tentukan pesan status berdasarkan hasil perhitungan batas Rp500 Juta
    String newStatusMessage;
    if (omzetKumulatif < 500000000.0 && (omzetKumulatif + omzetBulanan) > 500000000.0) {
      newStatusMessage = 'Catatan: Omzet Anda sudah melampaui batas bebas pajak Rp500 Juta bulan ini.';
    } else if (omzetKumulatif >= 500000000.0) {
      newStatusMessage = 'Catatan: Batas bebas pajak Rp500 Juta sudah terlampaui di bulan sebelumnya.';
    } else {
      newStatusMessage = 'Selamat! Omzet kumulatif Anda masih di bawah batas bebas pajak Rp500 Juta.';
    }

    // 4. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      taxType: 'PPh Final UMKM (0.5%) OP',
      inputDetails: {
        'Omzet Bulanan': omzetBulanan,
        'Omzet Kumulatif Sebelumnya': omzetKumulatif, // Simpan input kumulatif
      },
      finalResult: result,
      formulaUsed: formula,
      username: currentUsername,
    );

    // 5. Simpan ke riwayat dan perbarui state UI
    await SaveHistory.saveResult(newResult);

    setState(() {
      _calculatedTax = result;
      _formulaUsed = formula;
      _statusMessage = newStatusMessage;
      _calculationRun = true; // Set TRUE agar kotak hasil muncul
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PPh UMKM ${_formatRupiah(result)} tersimpan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- DRAWER (Menu Samping) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF001845)),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Color(0xFFe2eafc),
                  fontSize: 20,
                ),
              ),
            ),
            buildDrawerItem("Home", '/home'),
            buildDrawerItem("Pph 21", '/pph21'),
            buildDrawerItem("Pph 22", '/pph22'),
            buildDrawerItem("Pph 23", '/pph23'),
            buildDrawerItem("Pph 25/29", '/pph2529'),
            buildDrawerItem("UMKM", '/umkm'),
            buildDrawerItem("Ppn", '/ppn'),
            buildDrawerItem("PBB", '/pbb'),
            buildDrawerItem("History", '/history'),
            buildDrawerItem("News", '/news'),
            buildDrawerItem("Guide", '/guide'),
            buildDrawerItem("Logout", '/login'),
          ],
        ),
      ),

      // --- APP BAR ---
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFe2eafc)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Simulasi PPh Final UMKM'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Info: Tarif UMKM dan Batas Bebas Pajak
            const TaxConstantBox(
              title: "Tarif PPh Final UMKM & Batas Bebas Pajak",
              value: "0.5%",
              description: "Bebas PPh Final (0%) untuk WPOP dengan omzet kumulatif hingga Rp500 Juta setahun.",
            ),
            const SizedBox(height: 20),

            // --- Input Omzet Kumulatif Bulan Sebelumnya ---
            TextFormField(
              controller: _cumulativeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Omzet Kumulatif Bulan Sebelumnya (Tahun Berjalan)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Total pendapatan kotor dari bulan Januari s.d. bulan sebelumnya. (Cukup isi 0 jika ini perhitungan bulan Januari).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.redAccent),
              ),
            ),

            const SizedBox(height: 20),

            // --- Input Omzet Bulanan Ini ---
            TextFormField(
              controller: _omzetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Omzet Penjualan Bruto Bulan Ini',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 30.0),
              child: Text(
                '* Perhitungan ini hanya berlaku untuk Wajib Pajak Orang Pribadi (OP) dan hanya s.d. omzet tahunan Rp4.8 Miliar.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika omzet bulanan > 0
              onPressed: (double.tryParse(_omzetController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: const Text('Hitung PPh Final (0.5%)', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil (Dikontrol oleh _calculationRun) ---
            if (_calculationRun)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PPh Final Terutang Bulan Ini', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatRupiah(_calculatedTax),
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            // Warna Hijau jika 0 (Bebas Pajak), Biru jika ada yang dibayar
                            color: _calculatedTax == 0.0 ? Colors.green.shade700 : Colors.blue
                        ),
                      ),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      // Pesan Status Khusus (Menjelaskan status batas Rp500 Juta)
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: _calculatedTax == 0.0 ? Colors.green.shade800 : Colors.red,
                          fontWeight: _calculatedTax == 0.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Fungsi untuk Item Drawer ---
  Widget buildDrawerItem(String title, String routeName) {
    bool isActive = title == "UMKM"; // Highlight item jika ini adalah halaman UMKM

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF001845) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Tutup drawer
        if (!isActive) {
          Navigator.of(context).pushNamed(routeName); // Navigasi ke halaman lain
        }
      },
    );
  }
}