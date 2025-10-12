import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'save_history.dart';
import 'package:kalkulator_pajak/model/hasil_tax.dart';
// Import Halaman Kalkulator untuk Navigasi Balik
import 'package:kalkulator_pajak/calculation/pph.dart';
import 'package:kalkulator_pajak/calculation/pph22.dart';
import 'package:kalkulator_pajak/calculation/pph23.dart';
import 'package:kalkulator_pajak/calculation/pph2529.dart';
import 'package:kalkulator_pajak/calculation/umkm.dart';
import 'ppn.dart';
import 'pbb.dart';


class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  // Kunci unik yang digunakan untuk me-refresh FutureBuilder secara manual
  // setelah riwayat dihapus (clear history).
  Key _futureBuilderKey = UniqueKey();

  // --- Fungsi Utility ---
  String _formatRupiah(double value) {
    // Digunakan untuk menampilkan hasil dengan format Rp. (Rupiah)
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(value);
  }


  // --- Fungsi Navigasi ke Kalkulator Spesifik ---
  void _navigateToCalculator(BuildContext context, TaxResult result) {
    // Tentukan widget tujuan berdasarkan jenis pajak
    Widget destinationScreen;

    // Logika navigasi menggunakan .contains() untuk mencocokkan jenis pajak
    if (result.taxType.contains('PPh 21')) {
      destinationScreen = PphCalculator(initialData: result);
    } else if (result.taxType.contains('UMKM')) {
      destinationScreen = UmkmSimulasi(initialData: result);
    } else if (result.taxType.contains('PPN')) {
      destinationScreen = PpnCalculator(initialData: result);
    } else if (result.taxType.contains('PBB')) {
      destinationScreen = PbbCalculator(initialData: result);
    } else if (result.taxType.contains('PPh 22')) {
      destinationScreen = Pph22Calculator(initialData: result);
    } else if (result.taxType.contains('PPh 23')) {
      destinationScreen = Pph23Calculator(initialData: result);
    } else if (result.taxType.contains('PPh 25/29')) {
      destinationScreen = Pph2529Calculator(initialData: result);
    } else {
      // Jika jenis pajak tidak dikenali
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis kalkulator tidak dikenali.')),
      );
      return;
    }

    // Navigasi dengan mengirim data lama (initialData) ke halaman kalkulator
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destinationScreen));
  }


  // --- Widget untuk Menampilkan Setiap Item Riwayat ---
  Widget _buildHistoryItem(BuildContext context, TaxResult result) {
    // Mengambil nilai input utama (asumsi inputDetails memiliki 1 nilai utama)
    final inputKey = result.inputDetails.keys.first;
    final inputValue = result.inputDetails[inputKey] as double;

    // Formatting tanggal dan waktu
    final timeFormatted = DateFormat('h:mm a').format(result.date);
    final dateFormatted = DateFormat('EEEE, d MMMM yyyy').format(result.date);

    // Membuat string perhitungan ringkas
    final calculationSummary = '${result.taxType} dari ${_formatRupiah(inputValue)}';
    final finalResult = _formatRupiah(result.finalResult);

    return InkWell(
      onTap: () => _navigateToCalculator(context, result), // Memicu navigasi saat diklik
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Baris 1: Waktu & Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeFormatted,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  dateFormatted,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Baris 2: Detail Perhitungan dan Hasil Akhir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ringkasan Perhitungan Pajak
                Flexible(
                  child: Text(
                    calculationSummary,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                // Hasil Akhir
                Text(
                  finalResult,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, // Hasil menonjol
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Fungsi Menghapus Seluruh Riwayat ---
  void _clearHistory() async {
    // 1. Panggil service untuk menghapus semua data
    await SaveHistory.clearAllResults();

    // 2. Beri notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua riwayat telah dihapus!'))
    );

    // 3. Refresh UI: mengubah key _futureBuilderKey memaksa FutureBuilder untuk
    //    memuat ulang (re-run future: getAllResults()).
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
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
        backgroundColor: Color(0xFF001845),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFe2eafc)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('History', style: TextStyle(color: Color(0xFFe2eafc))),
        actions: [
          // Tombol Clear History
          IconButton(
            icon: const Text('Clear', style: TextStyle(color: Colors.orange)),
            onPressed: _clearHistory,
          ),
        ],
      ),

      backgroundColor: Color(0xFF001845), // Latar belakang utama layar (gelap)

      // --- BODY: FUTURE BUILDER ---
      body: FutureBuilder<List<TaxResult>>(
        key: _futureBuilderKey, // Memicu rebuild dan muat ulang data
        future: SaveHistory.getAllResults(), // Memanggil fungsi pemuatan data dari storage
        builder: (context, snapshot) {

          // Status 1: Sedang menunggu data dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final historyList = snapshot.data ?? [];

          // Status 2: Data sudah dimuat tapi list kosong
          if (historyList.isEmpty) {
            return const Center(child: Text('Belum ada riwayat perhitungan.', style: TextStyle(color: Colors.grey)));
          }

          // Status 3: Data berhasil dimuat
          // Menampilkan daftar menggunakan ListView.builder
          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(context, historyList[index]);
            },
          );
        },
      ),
    );
  }

  // --- Fungsi untuk Item Drawer ---
  Widget buildDrawerItem(String title, String routeName) {
    bool isActive = title == "History"; // Highlight item jika ini adalah halaman aktif

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          // Menyesuaikan warna agar kontras dengan latar belakang Drawer (putih)
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