import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Digunakan untuk memformat Rupiah
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPh 22)
import 'package:kalkulator_pajak/calculation/save_history.dart'; // Mengandung SaveHistory

class Pph22Calculator extends StatefulWidget {
  final TaxResult? initialData;
  const Pph22Calculator({super.key, this.initialData});

  @override
  State<Pph22Calculator> createState() => _Pph22CalculatorState();
}

class _Pph22CalculatorState extends State<Pph22Calculator> {
  final TextEditingController _valueController = TextEditingController();

  // State untuk Dropdown Rate yang ditampilkan dan nilai perhitungannya
  String _rateDisplay = 'Impor API (2.5%)';
  double _rateValue = 0.025;

  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  // Pilihan tarif PPh 22 yang berbeda-beda
  final Map<String, double> _rateOptions = {
    // API = Angka Pengenal Importir. Tarif 2.5% adalah tarif standar importir terdaftar.
    'Impor API (2.5%)': 0.025,
    // Non-API = Tidak memiliki Angka Pengenal Importir. Dikenakan tarif denda yang lebih tinggi.
    'Impor Non-API (7.5%)': 0.075,
    // Penjualan/Penyerahan Barang ke Bendahara Pemerintah
    'Penjualan ke Bendahara (1.5%)': 0.015,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // 1. Ambil nilai Input Utama (DPP)
      final inputValue = data.inputDetails['Nilai Transaksi (DPP)'] as double? ?? 0.0;

      // 2. Ambil rate yang digunakan di history
      final rateValueHistory = data.inputDetails['PPh22Rate'] as double? ?? 0.025;

      _valueController.text = inputValue.toStringAsFixed(0);
      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;

      // 3. Set state dropdown agar sesuai dengan data lama
      _rateValue = rateValueHistory;
      _rateOptions.forEach((key, value) {
        if (value == rateValueHistory) {
          _rateDisplay = key; // Set tampilan string yang sesuai
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
    // Bersihkan input dan konversi ke double
    final value = double.tryParse(_valueController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;

    // Validasi
    if (value <= 0) {
      setState(() { _calculatedTax = 0.0; _formulaUsed = ''; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai dasar pengenaan pajak yang valid.')),
      );
      return;
    }

    // 1. Panggil Logika Perhitungan PPh 22
    final result = TaxLogic.PPH22(
        value,
        rate: _rateValue // Gunakan nilai rate dari state yang dipilih dropdown
    );

    // 2. Panggil Logika Rumus
    final formula = TaxLogic.getFormula(
        'PPh 22',
        value,
        pph22Rate: _rateValue
    );

    // 3. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      taxType: 'PPh 22 (${_rateDisplay.split(' ')[0]})', // Tampilkan jenis transaksi di history
      inputDetails: {
        'Nilai Transaksi (DPP)': value,
        'PPh22Rate': _rateValue,
        'Jenis Transaksi': _rateDisplay, // Simpan deskripsi lengkap
      },
      finalResult: result,
      formulaUsed: formula,
    );

    // 4. Simpan ke riwayat dan perbarui state UI
    await SaveHistory.saveResult(newResult);

    setState(() {
      _calculatedTax = result;
      _formulaUsed = formula;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perhitungan PPh 22 ${_rateDisplay.split(' ')[0]} sebesar ${_formatRupiah(result)} tersimpan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil persentase dari kata terakhir string (contoh: '(2.5%)')
    final String activeRatePercentage = _rateDisplay.split(' ').last;
    // Mengambil nama transaksi dari kata pertama (contoh: 'Impor')
    final String transactionName = _rateDisplay.split(' ')[0];

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
        title: const Text('Kalkulator PPh 22'),
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
              title: "Tarif PPh Pasal 22 Aktif",
              value: activeRatePercentage, // Menampilkan persentase yang dipilih
              description: "Simulasi tarif yang Anda pilih berdasarkan jenis transaksi.",
            ),
            const SizedBox(height: 20),

            // --- Input Nilai Transaksi (DPP) ---
            TextFormField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai Transaksi (DPP)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}), // Memicu rebuild untuk tombol Hitung
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Dasar Pengenaan Pajak (DPP). Jika impor, gunakan Nilai Impor. Jika penjualan, gunakan harga jual (sebelum PPN).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            // --- Dropdown Pilihan Tarif PPh 22 ---
            DropdownButtonFormField<String>(
              value: _rateDisplay,
              decoration: const InputDecoration(
                labelText: 'Jenis Transaksi & Tarif',
                border: OutlineInputBorder(),
              ),
              items: _rateOptions.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _rateDisplay = newValue!;
                  _rateValue = _rateOptions[newValue]!; // Mengupdate nilai rate untuk perhitungan
                });
              },
            ),

            // Keterangan Tambahan untuk API/Non-API/Bendahara
            const Padding(
              padding: EdgeInsets.only(top: 10.0, left: 5.0, bottom: 5.0),
              child: Text(
                'Penjelasan Impor:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5.0, bottom: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• API (Angka Pengenal Importir): Tarif 2.5% berlaku untuk importir terdaftar.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  Text('• Non-API: Tarif 7.5% berlaku untuk importir yang tidak memiliki izin resmi (dikenakan tarif denda).', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  Text('• Bendahara: Tarif 1.5% berlaku untuk penjualan barang ke instansi pemerintah/BUMN.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 5.0, bottom: 30.0),
              child: Text(
                '* PPh 22 adalah pajak potong/pungut yang bersifat tidak final. Biasanya menjadi kredit pajak di akhir tahun.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika DPP > 0
              onPressed: (double.tryParse(_valueController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: Text('Hitung PPh 22 ($activeRatePercentage)', style: const TextStyle(fontSize: 18)),
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
                      Text('PPh 22 Terutang ($transactionName)', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(_formatRupiah(_calculatedTax), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text('Pajak ini umumnya berfungsi sebagai Kredit Pajak yang akan diperhitungkan saat Anda mengisi SPT Tahunan.', style: TextStyle(fontSize: 12)),
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
    bool isActive = title == "Pph 22";

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
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}