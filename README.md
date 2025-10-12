# kalkulator_pajak

Fitur Utama (wajib) 
1. Perhitungan pajak penghasilan (PPh) berdasarkan pendapatan.
2. Simulasi pajak untuk usaha atau bisnis kecil.
3. Fitur kalkulasi pajak tambahan (PBB, PPn, dll).
4. Riwayat perhitungan pajak untuk keperluan arsip.
5. Panduan dan tips perpajakan sesuai aturan terbaru.

Fitur Utama Proyek ini 
1. Autentikasi (Simulasi): Pengguna dapat melakukan Login dan Register untuk menyimpan sesi. Manajemen akun disimulasikan secara lokal (in-memory) melalui kelas UserList.
2. Navigasi Intuitif: Dilengkapi dengan Drawer menu lengkap, Auto-scroll carousel di homepage, dan Autocomplete Search untuk memudahkan pencarian kalkulator.
3. Perhitungan Pajak Akurat: Mencakup 7 jenis kalkulasi yang disesuaikan dengan regulasi terbaru UU HPP (termasuk tarif PPh Badan 22%, lapisan PPh 21 baru, dan pembebasan PPh UMKM Rp500 Juta).
4. Riwayat Perhitungan: Semua hasil perhitungan disimpan ke local storage (SharedPreferences). Pengguna dapat melihat riwayat, menghapusnya, atau menavigasi kembali ke kalkulator yang relevan dengan data input lama.
5. Edukasi Pajak: Halaman Panduan (Rules) menyediakan tips praktis dan penjelasan regulasi pajak utama dalam format yang mudah dibaca.

File dart yang berada di dalam proyek : 
A. Lapisan Model dan Logika Service (Inti Data Aplikasi)
Bagian ini berfokus pada struktur data, aturan bisnis, dan manajemen penyimpanan.

1. TaxLogic.dart: Ini adalah otak aplikasi. File ini berisi semua konstanta pajak (_pphBadanRate, PTKP, dll.) dan mengimplementasikan semua rumus perhitungan yang kompleks. Fitur utamanya adalah:
   - Logika PPh Badan Pasal 31E (menentukan tarif 11% vs 22% berdasarkan omzet bruto).
   - Sistem tarif PPh 21 Progresif 5 Lapisan.
   - Logika PPh Final UMKM yang menghitung pembebasan pajak Rp500 Juta untuk WP Orang Pribadi.

2. TaxResult.dart: Berfungsi sebagai model data untuk satu entri riwayat. Strukturnya mencakup id unik, taxType, finalResult, dan inputDetails (Map yang menyimpan semua input pengguna). Ini menyediakan metode toMap() dan fromMap() untuk penyimpanan data.
   
3. SaveHistory.dart: Kelas service yang mengelola penyimpanan riwayat perhitungan ke SharedPreferences. Fitur utamanya mencakup penyimpanan data baru di awal (latest first), pengambilan semua riwayat, dan fungsi untuk menghapus seluruh riwayat sekaligus.

4. User.dart dan UserList.dart: File-file ini menyajikan simulasi sistem autentikasi. UserList.dart adalah service yang menyediakan fungsi login(), register(), dan logout() dengan data pengguna disimpan secara in-memory.

B. Halaman Kalkulator (Implementasi Logika Bisnis)
Setiap kalkulator adalah view yang berinteraksi langsung dengan TaxLogic.dart dan SaveHistory.dart.

1. Pph.dart (PPh 21): Kalkulator PPh Pribadi. Memerlukan input Gaji Bruto Tahunan dan Status PTKP. Outputnya adalah PPh 21 Tahunan setelah dikurangi Biaya Jabatan dan dikenakan Tarif Progresif.

2. Pph2529Calculator.dart (PPh Badan): Menghitung Angsuran PPh Pasal 25 bulanan. Fitur kuncinya adalah:
   - Memerlukan input Omzet Bruto Tahunan untuk memicu logika Fasilitas PPh Badan 31E (tarif 11% atau 22%) di TaxLogic.
   - Secara terpisah menghitung dan menampilkan status PPh Kurang Bayar (PPh 29) atau Lebih Bayar di UI.

3. UmkmSimulasi.dart (PPh Final UMKM): Menghitung PPh Final 0.5%. Ini adalah kalkulator paling kompleks karena memerlukan input Omzet Kumulatif Sebelumnya untuk menentukan kapan batas pembebasan pajak Rp500 Juta terlampaui.

4. Pph22Calculator.dart: Kalkulator PPh Potong/Pungut atas Impor dan Penjualan Barang. Fitur utamanya adalah pemilihan tarif melalui Dropdown (2.5% API, 7.5% Non-API, atau 1.5% Bendahara), dilengkapi dengan penjelasan singkat di UI.

5. Pph23Calculator.dart: Kalkulator PPh Potong/Pungut atas Modal dan Jasa. Memungkinkan pemilihan tarif utama (2% Jasa/Sewa atau 15% Dividen/Bunga) melalui Dropdown.

6. Ppn.dart: Kalkulator PPN (menghitung 11% dari DPP) dan
7. Pbb.dart: PBB (menghitung berdasarkan NJOP, NJKP, dan NJOPTKP).

C. Lapisan Presentasi dan Manajemen Rute (Views)
Bagian ini bertanggung jawab atas antarmuka pengguna, navigasi, dan tema visual.

1. MyApp (main.dart): File konfigurasi utama. Di sini ditetapkan Material 3 Theme aplikasi dengan skema warna primary custom. Fitur pentingnya adalah sistem navigasi Rute Dinamis (onGenerateRoute) yang memfasilitasi pemuatan kembali data lama (TaxResult) dari halaman History.

2. HomePage.dart: Dashboard utama pengguna. Fitur kunci yang ada:
   - Auto-scroll Carousel (Big Card) menggunakan PageController dan Timer.periodic.
   - Autocomplete Search untuk navigasi cepat ke kalkulator manapun.
   - Pengaturan Drawer Menu dan Grid Menu kalkulasi.

3. History.dart: Halaman yang menampilkan semua riwayat. Menggunakan FutureBuilder untuk memuat data secara asinkron dari SaveHistory. Fitur kuncinya adalah kemampuan untuk mengklik item dan kembali ke kalkulator dengan data tersebut.

4. Rules.dart: Halaman edukasi. Menyajikan informasi dan regulasi pajak dalam format ExpansionTile yang rapi.

5. LoginPage.dart / Register.dart: Halaman autentikasi. Menampilkan desain Glassmorphism dengan latar belakang blur. Menangani validasi form dan loading state saat proses login/register.

6. TaxConstantBox.dart: Komponen UI yang dapat digunakan kembali untuk menyorot konstanta pajak di halaman kalkulator, meningkatkan transparansi dan edukasi pengguna.

## Getting Started

Setelah mengunduh zip file, jalankan sesuai alurnya:
1. Lakukan registrasi
2. Lakukan login
3. Mengakses melalui menu atau memencet opsi yang terdapat pada halaman utama untuk mengakses fitur kalkulator.
4. Bisa melakukan search juga sesuai nama pajak kalkulator yang ada dan panduannya.
5. Untuk per kalkulator, ada petunjuk untuk cara penggunaannya.
6. Kalau ingin melihat riwayat semua perhitungan kalkulator, bisa cek di bagian history. Di dalam history terdapat seluruh riwayat perhitungan kalkulasi pajak. Di dalam history ini pun ada fitur clear yang berada di atas kanan, berfungsi untuk menghapus seluruh riwayat perhitungan.
