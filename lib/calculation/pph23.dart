import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPh 23)
import 'package:kalkulator_pajak/service/save_history.dart'; // Mengandung SaveHistory
import 'package:kalkulator_pajak/service/user_service.dart';

class Pph23Calculator extends StatefulWidget {
  final TaxResult? initialData;
  const Pph23Calculator({super.key, this.initialData});

  @override
  State<Pph23Calculator> createState() => _Pph23CalculatorState();
}

class _Pph23CalculatorState extends State<Pph23Calculator> {
  final TextEditingController _valueController = TextEditingController();

  // State untuk menyimpan hasil dan rumus
  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  // State untuk Dropdown Rate
  String _rateDisplay = 'Jasa, Sewa Aset (2%)';
  double _rateValue = 0.02;

  // Opsi tarif PPh 23
  final Map<String, double> _rateOptions = {
    'Jasa, Sewa Aset (2%)': 0.02,
    'Dividen, Bunga, Royalti (15%)': 0.15,
    // Catatan: PPh 23 memiliki banyak jenis jasa lain, namun ini adalah dua tarif utama.
  };


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Ambil nilai Input Utama (Kunci harus konsisten: 'Penghasilan Bruto')
      final inputValue = data.inputDetails['Penghasilan Bruto'] as double? ?? 0.0;
      final rateValueHistory = data.inputDetails['PPh23Rate'] as double? ?? 0.02;

      _valueController.text = inputValue.toStringAsFixed(0);
      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;

      // Set state dropdown agar sesuai dengan data lama
      _rateValue = rateValueHistory;
      _rateOptions.forEach((key, value) {
        if (value == rateValueHistory) {
          _rateDisplay = key;
        }
      });
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

    // 1. Bersihkan input dan konversi ke double
    final value = double.tryParse(_valueController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;

    // Validasi
    if (value <= 0) {
      setState(() { _calculatedTax = 0.0; _formulaUsed = ''; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan penghasilan bruto yang valid.')),
      );
      return;
    }

    // 2. Panggil Logika Perhitungan PPh 23 (menggunakan rate yang dipilih)
    final result = TaxLogic.PPH23(value, rate: _rateValue);

    // 3. Panggil Logika Rumus
    final formula = TaxLogic.getFormula('PPh 23', value, pph23Rate: _rateValue);

    // 4. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      taxType: 'PPh 23 (${_rateDisplay.split(' ')[0]})', // Tampilkan jenis transaksi
      inputDetails: {'Penghasilan Bruto': value, 'PPh23Rate': _rateValue}, // Simpan input dan rate
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
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil persentase dari kata terakhir string (contoh: '(2%)')
    final String activeRatePercentage = _rateDisplay.split(' ').last;

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
        title: const Text('Kalkulator PPh 23'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Info: Tarif Aktif
            TaxConstantBox(
              title: "Tarif PPh Pasal 23 Aktif",
              value: activeRatePercentage, // Menampilkan persentase yang dipilih
              description: "Dikenakan atas penghasilan bruto yang Anda pilih.",
            ),
            const SizedBox(height: 20),

            // --- Input Penghasilan Bruto ---
            TextFormField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Penghasilan Bruto (belum dipotong PPh)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}), // Memicu rebuild untuk tombol Hitung
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Nilai kotor (sebelum dipotong pajak) dari dividen, bunga, sewa, atau jasa yang dibayarkan.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 30),

            // --- Dropdown Pilihan Tarif PPh 23 ---
            DropdownButtonFormField<String>(
              initialValue: _rateDisplay,
              decoration: const InputDecoration(
                labelText: 'Jenis Penghasilan & Tarif',
                border: OutlineInputBorder(),
              ),
              items: _rateOptions.keys.map((String key) {
                return DropdownMenuItem<String>(value: key, child: Text(key));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _rateDisplay = newValue!;
                  _rateValue = _rateOptions[newValue]!; // Mengupdate nilai rate untuk perhitungan
                });
              },
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 30.0),
              child: Text(
                '* Tarif 2% berlaku untuk jasa/sewa aset selain tanah. Tarif 15% berlaku untuk dividen, bunga, dan royalti.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),


            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika Penghasilan Bruto > 0
              onPressed: (double.tryParse(_valueController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              // Menampilkan tarif yang dipilih di tombol
              child: Text('Hitung PPh 23 ($activeRatePercentage)', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil ---
            if (_calculatedTax > 0) // Hanya tampilkan jika ada pajak terutang
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PPh 23 Dipotong', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(_formatRupiah(_calculatedTax), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text(
                          'Pajak ini bersifat tidak final dan merupakan Kredit Pajak bagi pihak yang dipotong.',
                          style: TextStyle(fontSize: 12)
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
    bool isActive = title == "Pph 23"; // Highlight item jika ini adalah halaman PPh 23

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