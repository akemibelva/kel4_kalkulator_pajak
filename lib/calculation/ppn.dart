import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPN)
import 'package:kalkulator_pajak/service/save_history.dart'; // Mengandung SaveHistory
import 'package:kalkulator_pajak/service/user_service.dart';

class PpnCalculator extends StatefulWidget {
  final TaxResult? initialData;
  const PpnCalculator({super.key, required this.initialData});

  @override
  State<PpnCalculator> createState() => _PpnCalculatorState();
}

class _PpnCalculatorState extends State<PpnCalculator> {
  // Controller untuk input nilai transaksi
  final TextEditingController _transactionController = TextEditingController();

  // State untuk menyimpan hasil perhitungan dan rumus
  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  @override
  void initState() {
    super.initState();
    // Memuat data lama jika ada (dari History Screen)
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Mengambil dan mengisi data dari riwayat
      final transactionValue = data.inputDetails['Nilai Transaksi'] as double? ?? 0.0;

      // Isi Controller dan State
      _transactionController.text = transactionValue.toStringAsFixed(0);
      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;
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

    // 1. Bersihkan input dan konversi ke double (Dasar Pengenaan Pajak / DPP)
    final transactionValue = double.tryParse(_transactionController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    // Validasi
    if (transactionValue <= 0) {
      setState(() {
        _calculatedTax = 0.0;
        _formulaUsed = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai transaksi yang valid.')),
      );
      return;
    }

    // 2. Panggil Logika Perhitungan PPN (TaxLogic.Ppn * 0.11)
    final result = TaxLogic.Ppn(transactionValue);

    // 3. Panggil Logika Rumus
    final formula = TaxLogic.getFormula('PPN', transactionValue);

    // 4. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      taxType: 'PPN (11%)',
      inputDetails: {'Nilai Transaksi': transactionValue}, // Simpan nilai DPP
      finalResult: result,
      formulaUsed: formula,
      username: currentUsername,
    );

    // 5. Simpan ke riwayat dan perbarui state UI
    await SaveHistory.saveResult(newResult);

    setState(() {
      _calculatedTax = result;
      _formulaUsed = formula;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PPN Rp${_formatRupiah(result)} tersimpan!')),
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
        title: const Text('Kalkulator PPN (11%)'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Info: Tarif PPN Aktif
            const TaxConstantBox(
              title: "Tarif PPN Saat Ini",
              value: "11%",
              description: "Tarif standar PPN di Indonesia sejak April 2022.",
            ),
            const SizedBox(height: 20),

            // --- Input Nilai Transaksi (DPP) ---
            TextFormField(
              controller: _transactionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai Transaksi (DPP)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                // SetState dipanggil untuk mengaktifkan/menonaktifkan tombol Hitung
                setState(() {});
              },
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Dasar Pengenaan Pajak (DPP). Masukkan nilai harga jual/beli BKP/JKP sebelum PPN. Asumsi tarif standar PPN adalah 11%.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 30),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika Nilai Transaksi > 0
              onPressed: (double.tryParse(_transactionController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: const Text('Hitung PPN', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil ---
            if (_calculatedTax > 0) // Hanya tampilkan jika PPN terutang > 0
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PPN Terutang (11%)', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatRupiah(_calculatedTax),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text('Catatan: PPN dihitung dari Dasar Pengenaan Pajak (DPP).', style: TextStyle(fontSize: 12)),
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
    bool isActive = title == "Ppn"; // Highlight item jika ini adalah halaman PPN

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