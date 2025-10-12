import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // TaxLogic
import 'package:kalkulator_pajak/calculation/save_history.dart';

class PbbCalculator extends StatefulWidget {
  final TaxResult? initialData;
  // Di sini, initialData dibuat required. Pastikan di onGenerateRoute Main.dart,
  // parameter ini selalu dilewatkan, meskipun nilainya null saat navigasi baru.
  const PbbCalculator({super.key, required this.initialData});

  @override
  State<PbbCalculator> createState() => _PbbCalculatorState();

}

class _PbbCalculatorState extends State<PbbCalculator> {

  // Controllers untuk input user
  final TextEditingController _njopController = TextEditingController();
  final TextEditingController _njoptkpController = TextEditingController();

  // State untuk Dropdown NJKP (Nilai Jual Kena Pajak)
  String _njkpRateString = '20%'; // Tampilan default
  double _njkpRateValue = 0.20;    // Nilai rate yang digunakan dalam perhitungan
  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  // Fungsi utilitas untuk format angka
  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  void initState() {
    super.initState();
    // Memuat data lama jika ada (dari History Screen)
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Mengambil nilai-nilai input dari data riwayat
      final njopValue = data.inputDetails['NJOP'] as double;
      final njoptkpValue = data.inputDetails['NJOPTKP'] as double? ?? 10000000.0;
      final njkpRate = data.inputDetails['NJKPRate'] as double? ?? 0.20;

      // Mengisi Controller dan State dari data lama
      _njopController.text = njopValue.toStringAsFixed(0);
      _njoptkpController.text = njoptkpValue.toStringAsFixed(0);
      _njkpRateString = njkpRate == 0.40 ? '40%' : '20%';
      _njkpRateValue = njkpRate;

      _calculatedTax = data.finalResult;
      _formulaUsed = data.formulaUsed;
    }
  }

  @override
  void dispose() {
    // Penting: Membuang controller saat widget dihancurkan
    _njopController.dispose();
    _njoptkpController.dispose();
    super.dispose();
  }

  void _calculateAndSave() async {
    // 1. Membersihkan input (menghapus karakter non-angka) dan mengkonversi ke double
    final njopValue = double.tryParse(_njopController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    final njoptkpValue = double.tryParse(_njoptkpController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    // Validasi input
    if (njopValue <= 0) {
      setState(() {
        _calculatedTax = 0.0;
        _formulaUsed = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai NJOP yang valid.')),
      );
      return;
    }

    // 2. Panggil Logika Perhitungan PBB dari TaxLogic
    final result = TaxLogic.PBB(
        njop: njopValue,
        njoptkp: njoptkpValue,
        njkpRate: _njkpRateValue // Nilai 0.20 atau 0.40 dikirim ke TaxLogic
    );

    // 3. Panggil Logika Rumus dari TaxLogic
    final formula = TaxLogic.getFormula(
        'PBB',
        njopValue,
        njoptkpValue: njoptkpValue,
        njkpRate: _njkpRateValue
    );

    // 4. Buat objek TaxResult untuk disimpan
    final newResult = TaxResult(
      id: const Uuid().v4(), // Membuat ID unik
      date: DateTime.now(),
      taxType: 'PBB',
      inputDetails: {
        'NJOP': njopValue,
        'NJOPTKP': njoptkpValue,
        'NJKPRate': _njkpRateValue,
      },
      finalResult: result,
      formulaUsed: formula,
    );

    // 5. Simpan ke riwayat dan perbarui UI
    await SaveHistory.saveResult(newResult);
    setState(() {
      _calculatedTax = result;
      _formulaUsed = formula;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PBB Rp${_formatRupiah(result)} tersimpan!')),
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
        title: const Text('Kalkulator PBB'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Informasi Tarif PBB
            const TaxConstantBox(
              title: "Tarif PBB",
              value: "0.5%", // Tarif PBB Maksimum P2
              description: "Asumsi tarif simulasi dikenakan dari NJOP.",
            ),
            const SizedBox(height: 20),

            // --- Input NJOP (Nilai Jual Objek Pajak) ---
            TextFormField(
              controller: _njopController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai Jual Objek Pajak (NJOP)',
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
                '* Masukkan total nilai tanah dan bangunan.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            // --- Input NJOPTKP (Nilai Jual Objek Pajak Tidak Kena Pajak) ---
            TextFormField(
              controller: _njoptkpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NJOPTKP (Nilai Tidak Kena Pajak)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Nilai yang ditetapkan Pemda sebagai batas PBB bebas pajak. Variatif tiap daerah.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            // --- Dropdown NJKP Rate (Nilai Jual Kena Pajak) ---
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'NJKP Rate (Nilai Jual Kena Pajak)',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _njkpRateString,
                  isDense: true,
                  items: <String>['20%', '40%']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _njkpRateString = newValue!;
                      // Mengupdate nilai double untuk perhitungan
                      _njkpRateValue = newValue == '40%' ? 0.40 : 0.20;
                    });
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* NJKP adalah persentase dari (NJOP - NJOPTKP) yang dikenakan pajak. Umumnya 20% untuk properti nilai rendah dan 40% untuk nilai tinggi.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 30),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol hanya aktif jika NJOP > 0
              onPressed: (double.tryParse(_njopController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: const Text('Hitung PBB', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil ---
            if (_calculatedTax > 0) // Hanya tampilkan jika hasil > 0
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PBB Terutang (Simulasi)', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatRupiah(_calculatedTax),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text('Catatan: PBB riil dipengaruhi NJKP dan N-NJOPTKP yang berbeda tiap daerah.', style: TextStyle(fontSize: 12)),
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
    bool isActive = title == "PBB"; // Highlight item jika ini adalah halaman PBB

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
          Navigator.of(context).pushNamed(routeName); // Navigasi
        }
      },
    );
  }
}