import 'package:flutter/material.dart';

// Kelas ini menampilkan panduan dan tips perpajakan menggunakan ExpansionTile.
class Rules extends StatelessWidget {
  const Rules({super.key});

  // Data panduan dan tips - Menggunakan struktur List<Map> untuk konten ExpansionTile
  static const List<Map<String, dynamic>> taxTips = [
    {
      'title': '1. PPh 21 (Pajak Penghasilan Pribadi) 🧑‍💼',
      'subtitle': 'Perhitungan Wajib Pajak Orang Pribadi (WP OP).',
      'content': [
        {
          'point': 'Tarif Progresif Terbaru (UU HPP)',
          'detail': 'Tarif menggunakan 5 lapis: 5% (s.d. Rp 60 Juta), 15% (di atas Rp 60 Juta s.d. Rp 250 Juta), 25% (di atas Rp 250 Juta s.d. Rp 500 Juta), 30% (di atas Rp 500 Juta s.d. Rp 5 Miliar), dan 35% (di atas Rp 5 Miliar).',
          'tips': 'Tips: Manfaatkan batas tarif 5% yang diperluas menjadi Rp 60 Juta/tahun.',
        },
        {
          'point': 'Peran Penting PTKP',
          'detail': 'Penghasilan Tidak Kena Pajak (PTKP) adalah pengurang utama. Status TK/0 adalah Rp 54 Juta/tahun. Jangan lupakan tambahan Rp 4,5 Juta untuk WP yang sudah menikah dan Rp 4,5 Juta per tanggungan (maksimal 3).',
          'tips': 'Tips: Selalu pastikan status PTKP Anda di HRD atau pemberi kerja sudah sesuai dengan status pernikahan dan jumlah tanggungan terbaru.',
        }
      ],
    },
    {
      'title': '2. PPh Final UMKM (PP 55 Tahun 2022) 🛍️',
      'subtitle': 'Tarif PPh Final 0.5% dari omzet bruto.',
      'content': [
        {
          'point': 'Bebas Pajak s.d. Rp 500 Juta (WPOP)',
          'detail': 'WP OP UMKM yang omzetnya TIDAK MELEBIHI Rp 500 Juta dalam setahun TIDAK DIKENAKAN PPh Final (bebas pajak 0.5%). Ini adalah insentif besar dari UU HPP.',
          'tips': 'Tips: Catat omzet bulanan dengan rapi. PPh 0.5% HANYA dikenakan pada omzet yang melebihi batas Rp 500 Juta kumulatif.',
        },
        {
          'point': 'Batas Omzet PPh Final',
          'detail': 'Tarif 0.5% hanya berlaku hingga total omzet Anda mencapai Rp 4,8 Miliar dalam setahun pajak. Jika terlampaui, Anda beralih ke PPh Normal (Badan) pada tahun berikutnya.',
          'tips': 'Tips: Siapkan transisi akuntansi ke PPh Badan Normal segera setelah omzet mendekati Rp 4,8 Miliar.',
        }
      ],
    },
    {
      'title': '3. PPN (Pajak Pertambahan Nilai) 🧾',
      'subtitle': 'Pajak atas Barang/Jasa Kena Pajak.',
      'content': [
        {
          'point': 'Tarif PPN Saat Ini',
          'detail': 'Tarif PPN standar adalah 11% (berlaku sejak 1 April 2022). Tarif ini akan kembali naik menjadi 12% selambat-lambatnya pada 1 Januari 2025.',
          'tips': 'Tips: Perbarui semua sistem *billing* dan faktur Anda untuk mencerminkan tarif PPN 11% saat ini.',
        },
        {
          'point': 'Non-Objek PPN',
          'detail': 'Beberapa barang/jasa dikecualikan atau dibebaskan dari PPN, seperti sembako tertentu, jasa pendidikan, jasa kesehatan, dan jasa keuangan.',
          'tips': 'Tips: Kenali daftar barang/jasa yang dikecualikan. Ini bisa mengurangi beban PPN Anda.',
        }
      ],
    },

    {
      'title': '4. PPh 22 (Impor dan Penjualan Barang Tertentu) 🚢',
      'subtitle': 'Pajak yang dipungut atas perdagangan barang.',
      'content': [
        {
          'point': 'PPh 22 atas Impor Barang',
          'detail': 'PPh 22 dikenakan saat impor. Tarif bervariasi: Impor yang memiliki Angka Pengenal Importir (API) dikenakan 2.5% dari Nilai Impor. Jika tidak punya API, tarifnya 7.5% dari Nilai Impor.',
          'tips': 'Tips: Selalu pastikan dokumen impor (API) lengkap untuk mendapatkan tarif PPh 22 terendah.',
        },
        {
          'point': 'PPh 22 Penjualan ke Bendahara',
          'detail': 'Penjualan ke Bendahara Pemerintah, BUMN/BUMD, atau institusi tertentu (misalnya Bank Indonesia) dikenakan PPh 22 sebesar 1.5% dari harga jual (tidak termasuk PPN).',
          'tips': 'Tips: PPh 22 yang dipotong oleh Bendahara adalah kredit pajak, jangan lupa minta Bukti Potong.',
        },
      ],
    },

    {
      'title': '5. PPh 23 (Dividen, Bunga, Royalti, Sewa, Jasa) 💵',
      'subtitle': 'Pemotongan atas penghasilan modal dan jasa.',
      'content': [
        {
          'point': 'Tarif PPh 23 Dasar',
          'detail': 'Tarif PPh 23 terbagi dua: 15% dari penghasilan bruto (untuk dividen, bunga, royalti, hadiah/penghargaan, dan sewa aset selain tanah/bangunan) dan 2% dari penghasilan bruto (untuk jasa seperti jasa manajemen, konsultan, akuntansi, dll.).',
          'tips': 'Tips: Untuk tarif 2% atas jasa, pastikan tagihan jasa Anda terperinci dan didukung kontrak kerja/SPK.',
        },
        {
          'point': 'NPWP vs Non-NPWP',
          'detail': 'Jika penerima penghasilan (pihak yang dibayar) tidak memiliki NPWP, maka tarif PPh 23 yang dipotong adalah 100% lebih tinggi (menjadi 30% atau 4%).',
          'tips': 'Tips: Selalu minta NPWP rekanan bisnis Anda sebelum melakukan pembayaran untuk menghindari potongan yang lebih besar.',
        },
      ],
    },

    {
      'title': '6. PPh 25 & PPh 29 (Angsuran & Pelunasan Tahunan) 💰',
      'subtitle': 'Pembayaran PPh Badan Normal tahun berjalan dan pelunasan.',
      'content': [
        {
          'point': 'PPh Pasal 25 (Angsuran)',
          'detail': 'PPh Badan saat ini bertarif umum 22% (sejak 2022). Angsuran bulanan PPh 25 dihitung dari PPh Terutang Tahunan dikurangi Kredit Pajak, kemudian dibagi 12.',
          'tips': 'Tips: Wajib Pajak Badan dengan omzet di bawah Rp50 M berhak mendapat fasilitas PPh 11% untuk bagian omzet s.d. Rp4.8 M. Ini harus dihitung dalam angsuran Anda.',
        },
        {
          'point': 'PPh Pasal 29 (Pelunasan Akhir)',
          'detail': 'PPh 29 adalah PPh yang kurang dibayar di akhir tahun pajak. Nilainya adalah PPh Terutang Tahunan dikurangi total Kredit Pajak dan PPh 25 yang sudah dibayar.',
          'tips': 'Tips: Jika PPh 29 Anda besar, periksa kembali perhitungan dan kredit pajak yang sudah Anda kumpulkan (Bukti Potong) sepanjang tahun.',
        },
      ],
    },

    {
      'title': '7. PBB (Pajak Bumi dan Bangunan) 🏠',
      'subtitle': 'Pajak atas kepemilikan properti (PBB-P2).',
      'content': [
        {
          'point': 'Dasar Pengenaan PBB',
          'detail': 'PBB dihitung berdasarkan Nilai Jual Objek Pajak (NJOP). PBB yang terutang adalah Tarif (biasanya ditetapkan Pemda, maks 0.5%) dikalikan Nilai Jual Kena Pajak (NJKP).',
          'tips': 'Tips: PBB-P2 adalah pajak daerah. Cek Peraturan Daerah (Perda) setempat Anda untuk mengetahui tarif pasti dan diskon/pembebasan PBB.',
        },
        {
          'point': 'NJKP dan NJOPTKP',
          'detail': 'Nilai Jual Kena Pajak (NJKP) adalah persentase dari NJOP (20% atau 40%). Ada juga NJOP Tidak Kena Pajak (NJOPTKP) yang merupakan batas NJOP yang tidak dikenakan PBB. Nilainya berbeda di setiap daerah.',
          'tips': 'Tips: Pastikan NJOP tanah/bangunan Anda sesuai dengan harga pasar. Jika terlalu tinggi, Anda berhak mengajukan keberatan ke Pemda setempat.',
        },
      ],
    },

    {
      'title': '8. Kewajiban Pelaporan SPT Tahunan 🗓️',
      'subtitle': 'Batas waktu dan denda.',
      'content': [
        {
          'point': 'Batas Waktu Pelaporan',
          'detail': 'Batas waktu PPh OP adalah 31 Maret. Batas waktu PPh Badan adalah 30 April.',
          'tips': 'Tips: Laporkan secepatnya setelah mendapatkan bukti potong 1721 A1 (untuk karyawan) di Januari/Februari untuk menghindari *rush* dan *server down* DJP.',
        },
        {
          'point': 'Sanksi Keterlambatan',
          'detail': 'Denda keterlambatan pelaporan SPT PPh OP adalah Rp 100.000. Untuk SPT PPh Badan, denda adalah Rp 1.000.000.',
          'tips': 'Tips: Manfaatkan fitur draf di e-Filing DJP Online untuk memastikan data Anda lengkap sebelum *deadline*.',
        }
      ],
    },
  ];

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
              child: Text("Menu", style: TextStyle(color: Color(0xFFe2eafc), fontSize: 20)),
            ),
            // Panggil item drawer (memerlukan BuildContext)
            buildDrawerItem(context, "Home", '/home'),
            buildDrawerItem(context, "Pph 21", '/pph21'),
            buildDrawerItem(context, "Pph 22", '/pph22'),
            buildDrawerItem(context, "Pph 23", '/pph23'),
            buildDrawerItem(context, "Pph 25/29", '/pph2529'),
            buildDrawerItem(context, "UMKM", '/umkm'),
            buildDrawerItem(context, "Ppn", '/ppn'),
            buildDrawerItem(context, "PBB", '/pbb'),
            buildDrawerItem(context, "History", '/history'),
            buildDrawerItem(context, "News", '/news'),
            buildDrawerItem(context, "Guide", '/guide'),
            buildDrawerItem(context, "Logout", '/login'),
          ],
        ),
      ),

      // --- APP BAR ---
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFFe2eafc)),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Membuka Drawer
            },
          ),
        ),
        title: const Text('Panduan & Tips Perpajakan'),
        backgroundColor: const Color(0xFF001845),
        foregroundColor: Color(0xFFe2eafc),
      ),

      // --- BODY: ListView berisi ExpansionTile ---
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        // Mapping data tips (taxTips) ke dalam widget Card dan ExpansionTile
        children: taxTips.map((tip) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              // Poin utama (Title)
              title: Text(tip['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // Penjelasan singkat (Subtitle)
              subtitle: Text(tip['subtitle']!),
              leading: const Icon(Icons.info_outline, color: Color(0xFF001845)), // Ikon info

              // Detail yang dapat diperluas (Children)
              children: (tip['content'] as List<Map<String, String>>)
                  .map((subItem) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub Poin Detail
                      Text(
                        '➡️ ${subItem['point']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001845)),
                      ),
                      const SizedBox(height: 4),
                      // Penjelasan Detail
                      Text(subItem['detail']!),
                      const SizedBox(height: 4),
                      // Kotak Tips Menonjol
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber, width: 0.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.emoji_objects, size: 18, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subItem['tips']!,
                                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, indent: 20, endIndent: 20), // Garis pemisah antar sub-item
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Fungsi untuk Item Drawer ---
  // Dibuat sebagai fungsi pembantu untuk konsistensi menu
  Widget buildDrawerItem(BuildContext context, String title, String routeName) {
    bool isActive = title == "Guide"; // Highlight item jika ini halaman aktif

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