import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Digunakan untuk memformat angka menjadi mata uang (Rupiah)
// Asumsi path import ini benar di proyek Anda
import 'package:kalkulator_pajak/model/tax_constant_box.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
import 'package:kalkulator_pajak/model/tax.dart'; // Mengandung TaxLogic (rumus PPh 21)
import 'package:kalkulator_pajak/service/save_history.dart'; // Mengandung SaveHistory
import 'package:kalkulator_pajak/service/user_service.dart';

class PphCalculator extends StatefulWidget {
  final TaxResult? initialData;
  const PphCalculator({super.key, this.initialData});

  @override
  State<PphCalculator> createState() => _PphCalculatorState();
}

class _PphCalculatorState extends State<PphCalculator> {
  // Controllers untuk input gaji
  final TextEditingController _salaryController = TextEditingController();

  // State untuk status PTKP yang dipilih
  String _ptkpStatus = 'Tk/0';

  // State untuk menyimpan hasil perhitungan dan rumus
  double _calculatedTax = 0.0;
  String _formulaUsed = '';

  // Daftar status PTKP yang tersedia untuk Dropdown
  final List<String> _ptkpOptions = [
    'Tk/0', 'Tk/1', 'Tk/2', 'Tk/3',
    'K/0', 'K/1', 'K/2', 'K/3',
  ];

  @override
  void initState() {
    super.initState();
    // Memuat data lama jika ada (dari History Screen)
    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Mengambil dan mengisi data dari riwayat
      final salaryValue = data.inputDetails['Gaji Tahunan'] as double? ?? 0.0;
      final status = data.inputDetails['Status PTKP'] as String? ?? 'TK/0';

      _salaryController.text = salaryValue.toStringAsFixed(0);
      _ptkpStatus = status;
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

    // 1. Bersihkan input dan konversi ke double
    final salary = double.tryParse(_salaryController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0;

    // Validasi
    if (salary <= 0) {
      setState(() {
        _calculatedTax = 0.0;
        _formulaUsed = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan gaji tahunan yang valid.')),
      );
      return;
    }

    // 2. Panggil Logika Perhitungan PPh 21 (sudah otomatis menggunakan tarif progresif)
    final result = TaxLogic.PPH21(
      annualGrossSalary: salary,
      ptkpStatus: _ptkpStatus,
    );
    // Panggil logika untuk mendapatkan string rumus
    final formula = TaxLogic.getFormula('PPh 21', salary, ptkpStatus: _ptkpStatus);

    // 3. Buat objek TaxResult untuk riwayat
    final newResult = TaxResult(
      id: const Uuid().v4(), // ID unik
      date: DateTime.now(),
      taxType: 'PPh 21 (Pribadi)',
      inputDetails: {'Gaji Tahunan': salary, 'Status PTKP': _ptkpStatus},
      finalResult: result,
      formulaUsed: formula,
      username: currentUsername,
    );

    // 4. Simpan ke riwayat dan perbarui state UI
    await SaveHistory.saveResult(newResult);

    setState(() {
      _calculatedTax = result;
      _formulaUsed = formula;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perhitungan PPh Rp${_formatRupiah(result)} tersimpan!')),
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
        title: const Text('Kalkulator PPh 21'),
        backgroundColor: const Color(0xFF001845), // Warna gelap untuk App Bar
        foregroundColor: Color(0xFFe2eafc), // Warna teks/ikon App Bar
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Kotak Info: Tarif PPh 21 Progresif (5% - 35%)
            const TaxConstantBox(
              title: "Tarif PPh 21 (Progresif)",
              value: "5% - 35%",
              description: "Berlaku 5 lapisan: 5% (s.d. 60 Juta), 15%, 25%, 30%, 35% (di atas 5 Miliar).",
            ),
            const SizedBox(height: 20),

            // Kotak Info: PTKP Dasar (Rp 54 Juta)
            const TaxConstantBox(
              title: "PTKP Dasar Wajib Pajak (WP)",
              value: "Rp 54.000.000",
              description: "Angka minimal bebas pajak untuk status TK/0.",
            ),
            const SizedBox(height: 20),

            // --- Input Gaji Tahunan Bruto ---
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Gaji Bruto Tahunan (sebelum PPh)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {}), // Memicu update state untuk tombol Hitung
            ),

            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 15.0),
              child: Text(
                '* Total gaji, tunjangan, dan bonus dalam 1 tahun. Angka ini digunakan untuk menentukan PKP (Penghasilan Kena Pajak).',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey),
              ),
            ),

            const SizedBox(height: 20),

            // --- Dropdown Status PTKP ---
            DropdownButtonFormField<String>(
              initialValue: _ptkpStatus,
              decoration: const InputDecoration(
                labelText: 'Status PTKP',
                border: OutlineInputBorder(),
              ),
              items: _ptkpOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _ptkpStatus = newValue!; // Update status PTKP
                });
              },
            ),
            const SizedBox(height: 30),

            // --- CATATAN PENJELASAN UNTUK PENGGUNA (PTKP) ---
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                'Catatan: PTKP menentukan batas penghasilan bebas pajak Anda.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• TK/0 (Tidak Kawin / 0 Tanggungan): PTKP Dasar Rp54 Juta.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('• K/0 (Kawin / 0 Tanggungan): PTKP Dasar + Tambahan Kawin (Rp4.5 Juta).', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('• Angka /1, /2, /3: Menunjukkan jumlah Tanggungan (maks 3) yang menambah PTKP sebesar Rp4.5 Juta per tanggungan.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 30,),

            // --- Tombol Hitung ---
            ElevatedButton(
              // Tombol aktif jika Gaji > 0
              onPressed: (double.tryParse(_salaryController.text.replaceAll(RegExp(r'\D'), '')) ?? 0.0) > 0 ? _calculateAndSave : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF001845),
                foregroundColor: Color(0xFFe2eafc),
              ),
              child: const Text('Hitung PPh 21', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),

            // --- Tampilan Hasil ---
            if (_calculatedTax > 0) // Hanya tampilkan jika pajak terutang > 0
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PPh 21 Terutang Tahunan', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        _formatRupiah(_calculatedTax),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const Divider(height: 30),
                      Text('Rumus: $_formulaUsed', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Text(
                        'Pajak ini dihitung menggunakan tarif progresif setelah dikurangi PTKP.',
                        style: TextStyle(fontSize: 12),
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
    bool isActive = title == "Pph 21"; // Highlight item jika ini adalah halaman aktif

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