import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPh Badan)
import 'package:kalkulator_pajak/service/save_history.dart'; // Mengandung SaveHistory
import 'package:kalkulator_pajak/service/user_service.dart';

// Asumsi: TaxLogic sudah diupdate dengan PPH_Badan_Terutang dan _omzetBatasFasilitas4_8M

class Pph2529Calculator extends StatefulWidget {
  final TaxResult? initialData;
  const Pph2529Calculator({super.key, this.initialData});

  @override
  State<Pph2529Calculator> createState() => _Pph2529CalculatorState();
}

class _Pph2529CalculatorState extends State<Pph2529Calculator> {
  // Controllers untuk input Omzet, PKP, dan Kredit Pajak
  final TextEditingController _turnoverController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();

  // State untuk menyimpan hasil angsuran PPh 25 dan rumus yang digunakan
  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  // Konstanta untuk UI (seharusnya merefleksikan nilai di TaxLogic)
  static const double _pphBadanRate = 0.22;
  static const double _omzetBatasFasilitas4_8M = 4800000000.0;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Mengambil dan mengisi data dari riwayat
      final income = data.inputDetails['Perkiraan Laba Tahunan'] as double? ?? 0.0;
      final credit = data.inputDetails['Kredit Pajak Tahunan'] as double? ?? 0.0;
      final turnover = data.inputDetails['Peredaran Bruto Tahunan'] as double? ?? 0.0;

      _incomeController.text = income.toStringAsFixed(0);
      _creditController.text = credit.toStringAsFixed(0);
      _turnoverController.text = turnover.toStringAsFixed(0);

      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;
    }
  }

  // Fungsi utilitas untuk format angka ke Rupiah (menggunakan abs() untuk formatting)
  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value.abs());
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

    // 1. Bersihkan input dan konversi ke double
    final turnover = double.tryParse(_turnoverController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
    final income = double.tryParse(_incomeController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
    final credit = double.tryParse(_creditController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;

    // Validasi input
    if (income <= 0 || turnover <= 0) {
      setState(() { _calculatedTax = 0.0; _formulaUsed = ''; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan laba dan omzet tahunan yang valid.')),
      );
      return;
    }

    // 2. Hitung PPh Terutang Tahunan (menggunakan fasilitas 31E)
    final pphTerutangTahunan = TaxLogic.PPH_Badan_Terutang(
      annualNetIncome: income,
      annualGrossTurnover: turnover,
    );

    // 3. Hitung Dasar Angsuran PPh 25 (PPh Terutang - Kredit Pajak). Hasil tidak boleh negatif (minimal 0)
    final pphDasarAngsuran = max(0.0, pphTerutangTahunan - credit);

    // 4. Hitung Angsuran PPh Pasal 25 Bulanan (Inilah hasil yang disimpan di _calculatedTax)
    final pph25Monthly = pphDasarAngsuran / 12.0;
    final result = pph25Monthly;

    // 5. Buat string formula berdasarkan kelayakan fasilitas
    final String formulaText;
    if (turnover <= _omzetBatasFasilitas4_8M) {
      // Omzet rendah: PPh 11% (Fasilitas Penuh)
      formulaText = '(([${_formatRupiah(income)} x 11%] - ${_formatRupiah(credit)}) / 12)';
    } else {
      // Omzet menengah/tinggi: PPh Terutang campuran/penuh
      formulaText = '([PPh Terutang Tahunan (${_formatRupiah(pphTerutangTahunan)}) - ${_formatRupiah(credit)}] / 12)';
    }

    // 6. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      taxType: 'PPh 25/29 Badan',
      inputDetails: {
        'Peredaran Bruto Tahunan': turnover,
        'Perkiraan Laba Tahunan': income,
        'Kredit Pajak Tahunan': credit,
      },
      finalResult: result,
      formulaUsed: formulaText,
      username: currentUsername,
    );

    // 7. Simpan ke riwayat dan perbarui state UI
    await SaveHistory.saveResult(newResult);

    setState(() {
      _calculatedTax = result;
      _formulaUsed = formulaText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data input saat ini untuk menghitung status PPh 29 (kurang/lebih bayar) di UI
    final income = double.tryParse(_incomeController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
    final turnover = double.tryParse(_turnoverController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;
    final credit = double.tryParse(_creditController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;

    // Hitung total PPh terutang tahunan lagi (hanya untuk tampilan di UI)
    final pphTerutangTahunan = TaxLogic.PPH_Badan_Terutang(
      annualNetIncome: income,
      annualGrossTurnover: turnover,
    );
    // Hitung PPh Kurang/Lebih Bayar (positif = PPh 29 Kurang Bayar, negatif = Lebih Bayar)
    final pphKurangLebihBayar = pphTerutangTahunan - credit;

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
        title: const Text('Kalkulator PPh 25/29'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Info: Tarif PPh Badan (22%)
            TaxConstantBox(
              title: "Tarif PPh Badan (Umum)",
              value: "${(_pphBadanRate * 100).toStringAsFixed(0)}%",
              description: "Tarif PPh Badan normal yang berlaku sejak 2022. Mendapat fasilitas 50% (11%) untuk omzet di bawah Rp4.8 M.",
            ),
            const SizedBox(height: 20),

            // --- Input Omzet Bruto Tahunan ---
            TextFormField(
              controller: _turnoverController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peredaran Bruto Tahunan (Omzet)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Diperlukan untuk menentukan kelayakan fasilitas PPh 31E (tarif 11%).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            // --- Input Laba Bersih Tahunan (PKP) ---
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Penghasilan Kena Pajak Tahunan (PKP)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Angka ini adalah dasar PPh Badan. Harus berupa Penghasilan Neto Fiskal.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            // --- Input Kredit Pajak Tahunan ---
            TextFormField(
              controller: _creditController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Kredit Pajak Tahun Lalu (PPh 22, 23, dll.)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 30.0),
              child: Text(
                '* Kredit Pajak adalah total PPh yang sudah dipotong. Angka ini mengurangi PPh terutang.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 30),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika Omzet dan PKP sudah diisi
              onPressed: (_incomeController.text.isNotEmpty && _turnoverController.text.isNotEmpty)
                  ? _calculateAndSave
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: const Text('Hitung Angsuran PPh 25 Bulanan'),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil ---
            // Tampilkan hasil jika input utama sudah diisi (asumsi perhitungan sudah selesai)
            if (_incomeController.text.isNotEmpty && _turnoverController.text.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PPh 25 Bulanan ---
                      const Text('Angsuran PPh Pasal 25 Bulanan', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(
                          _formatRupiah(_calculatedTax), // Menampilkan hasil Angsuran PPh 25
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              // Warna biru jika angsuran > 0, hijau jika 0 (karena lebih bayar)
                              color: _calculatedTax > 0 ? Colors.blue : Colors.green.shade700
                          )
                      ),
                      const Divider(height: 30),

                      // --- PPh Terutang Tahunan & Status 29/Lebih Bayar ---
                      Text('PPh Terutang Tahunan: ${_formatRupiah(pphTerutangTahunan)}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(
                          pphKurangLebihBayar > 0
                              ? 'Sisa PPh Kurang Bayar (PPh 29): ${_formatRupiah(pphKurangLebihBayar)}'
                              : 'Status: PPh Lebih Bayar: ${_formatRupiah(pphKurangLebihBayar)}',
                          style: TextStyle(
                              fontSize: 14,
                              // Merah jika Kurang Bayar (PPh 29), Hijau jika Lebih Bayar
                              color: pphKurangLebihBayar > 0 ? Colors.red : Colors.green.shade800,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      const Divider(height: 30),

                      // --- Rumus & Catatan ---
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const Text('Catatan: Angsuran PPh 25 dihitung dari PPh Terutang Tahunan dikurangi Kredit Pajak. Nilai angsuran tidak boleh negatif (minimal Rp 0).', style: TextStyle(fontSize: 12)),
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
    bool isActive = title == "Pph 25/29"; // Highlight item jika ini adalah halaman PPh 25/29

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF001845) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // tutup drawer
        if (!isActive) {
          Navigator.of(context).pushNamed(routeName); // Navigasi ke halaman lain
        }
      },
    );
  }
}