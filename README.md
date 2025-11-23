# kalkulator_pajak
Aplikasi yang membantu pengguna menghitung pajak pribadi atau bisnis berdasarkan aturan perpajakan yang berlaku.

## Ketentuan Fitur
Fitur Utama (wajib)
1. Perhitungan pajak penghasilan (PPh) berdasarkan pendapatan.
2. Simulasi pajak untuk usaha atau bisnis kecil.
3. Fitur kalkulasi pajak tambahan (PBB, PPn, dll).
4. Riwayat perhitungan pajak untuk keperluan arsip.
5. Panduan dan tips perpajakan sesuai aturan terbaru.

## Penyajian Proyek
Fitur Utama Proyek ini 
1. Autentikasi (Simulasi): Pengguna dapat melakukan Login dan Register. Data akun dan sesi disimpan secara aman dan persisten menggunakan Hive Database.
2. Navigasi Intuitif: Dilengkapi dengan Drawer menu lengkap, Auto-scroll carousel di homepage, dan Autocomplete Search untuk memudahkan pencarian kalkulator.
3. Perhitungan Pajak Akurat: Mencakup 7 jenis kalkulasi yang disesuaikan dengan regulasi terbaru UU HPP (termasuk tarif PPh Badan 22%, lapisan PPh 21 baru, dan pembebasan PPh UMKM Rp500 Juta).
4. Riwayat Perhitungan: Semua hasil perhitungan disimpan secara lokal menggunakn Hive. Pengguna dapat melihat riwayat, menghapusnya, atau menavigasi kembali ke kalkulator yang relevan dengan data input lama.
5. Edukasi Pajak: Halaman Panduan (Rules) menyediakan tips praktis dan penjelasan regulasi pajak utama dalam format yang mudah dibaca.
6. Integrasi Layanan Eksternal Application Programming Interface (API): Aplikasi ini terintegrasi dengan layanan API pihak ketiga, antara lain;
   - Prakiraan Cuaca Real-time (OpenWeatherMap API): Mengambil data cuaca terkini dan prakiraan per jam berdasarkan lokasi pengguna (default: Jakarta). Membantu pengguna merencanakan aktivitas bisnis dengan mengetahui kondisi cuaca.
   - Berita Ekonomi & Pajak (NewsAPI): Melakukan *fetching* berita terbaru (Top Headlines) seputar bisnis dan ekonomi di Indonesia. Memastikan pengguna tetap *up-to-date* dengan regulasi atau tren ekonomi terkini langsung dari dashboard aplikasi.

### File dart dan class yang terdapat dalam proyek:
### A. Lapisan Model dan Logika Service (Inti Data Aplikasi)
Bagian ini berfokus pada struktur data, aturan bisnis, dan manajemen penyimpanan.

1. TaxLogic (tax.dart): Ini adalah otak aplikasi. File ini berisi semua konstanta pajak (_pphBadanRate, PTKP, dll.) dan mengimplementasikan semua rumus perhitungan yang kompleks. Fitur utamanya adalah:
   - Logika PPh Badan Pasal 31E (menentukan tarif 11% vs 22% berdasarkan omzet bruto).
   - Sistem tarif PPh 21 Progresif 5 Lapisan.
   - Logika PPh Final UMKM yang menghitung pembebasan pajak Rp500 Juta untuk WP Orang Pribadi.
2. TaxResult (hasil_tax.dart): Berfungsi sebagai model data untuk satu entri riwayat. Strukturnya mencakup id unik, taxType, finalResult, dan inputDetails (Map yang menyimpan semua input pengguna). Ini menyediakan metode toMap() dan fromMap() untuk penyimpanan data.
3. SaveHistory (save_history.dart): Service untuk menyimpan dan memuat riwayat kalkulasi dari database lokal. Fitur utamanya mencakup penyimpanan data baru di awal (latest first), pengambilan semua riwayat, dan fungsi untuk menghapus seluruh riwayat sekaligus. Menggunakan SharedPreferences dengan mekanisme filtering berbasis username agar data riwayat antar pengguna tidak tercampur.
4. User (user_database.dart) dan UserService (user_service.dart): Mengelola logika autentikasi (Login/Register) dan penyimpanan data pengguna menggunakan Hive Box.

### B. Halaman Kalkulator (Implementasi Logika Bisnis)
Setiap kalkulator adalah view yang berinteraksi langsung dengan TaxLogic dan SaveHistory.

1. PphCalculator (pph.dart; PPh 21): Kalkulator PPh Pribadi. Memerlukan input Gaji Bruto Tahunan dan Status PTKP. Outputnya adalah PPh 21 Tahunan setelah dikurangi Biaya Jabatan dan dikenakan Tarif Progresif.

2. Pph2529Calculator (pph2529.dart; PPh Badan): Menghitung Angsuran PPh Pasal 25 bulanan. Fitur kuncinya adalah:
   - Memerlukan input Omzet Bruto Tahunan untuk memicu logika Fasilitas PPh Badan 31E (tarif 11% atau 22%) di TaxLogic.
   - Secara terpisah menghitung dan menampilkan status PPh Kurang Bayar (PPh 29) atau Lebih Bayar di UI.

3. UmkmSimulasi (umkm.dart; PPh Final UMKM): Menghitung PPh Final 0.5%. Ini adalah kalkulator paling kompleks karena memerlukan input Omzet Kumulatif Sebelumnya untuk menentukan kapan batas pembebasan pajak Rp500 Juta terlampaui.

4. Pph22Calculator (pph22.dart): Kalkulator PPh Potong/Pungut atas Impor dan Penjualan Barang. Fitur utamanya adalah pemilihan tarif melalui Dropdown (2.5% API, 7.5% Non-API, atau 1.5% Bendahara), dilengkapi dengan penjelasan singkat di UI.

5. Pph23Calculator (pph23.dart): Kalkulator PPh Potong/Pungut atas Modal dan Jasa. Memungkinkan pemilihan tarif utama (2% Jasa/Sewa atau 15% Dividen/Bunga) melalui Dropdown.

6. PpnCalculator (ppn.dart): Kalkulator PPN (menghitung 11% dari DPP)

7. PbbCalculator (pbb.dart): PBB (menghitung berdasarkan NJOP, NJKP, dan NJOPTKP).

### C. Lapisan Presentasi dan Manajemen Rute (Views)
Bagian ini bertanggung jawab atas antarmuka pengguna, navigasi, dan tema visual.

1. MyApp (main.dart): File konfigurasi utama. Di sini ditetapkan Material 3 Theme aplikasi dengan skema warna primary custom. Fitur pentingnya adalah sistem navigasi Rute Dinamis (onGenerateRoute) yang memfasilitasi pemuatan kembali data lama (TaxResult) dari halaman History.

2. HomePage (home.dart): Dashboard utama pengguna. Fitur kunci yang ada:
   - Auto-scroll Carousel (Big Card) menggunakan PageController dan Timer.periodic.
   - Autocomplete Search untuk navigasi cepat ke kalkulator manapun.
   - Pengaturan Drawer Menu dan Grid Menu kalkulasi.

3. History (history.dart): Halaman yang menampilkan semua riwayat. Menggunakan FutureBuilder untuk memuat data secara asinkron dari SaveHistory. Fitur kuncinya adalah kemampuan untuk mengklik item dan kembali ke kalkulator dengan data tersebut.

4. Rules (rules.dart): Halaman edukasi. Menyajikan informasi dan regulasi pajak dalam format ExpansionTile yang rapi.

5. LoginPage (login.dart) / Register (register.dart): Halaman autentikasi. Menampilkan desain Glassmorphism dengan latar belakang blur. Menangani validasi form dan loading state saat proses login/register.

6. TaxConstantBox (tax_constant_box.dart): Komponen UI yang dapat digunakan kembali untuk menyorot konstanta pajak di halaman kalkulator, meningkatkan transparansi dan edukasi pengguna.

### D. Konfigurasi & Aset
Dalam menjalankan program, terdapat file konfigurasi `.env` untuk menyimpan kredensial API (Weather API Key & News API Key). Wajib dibuat sebelum menjalankan aplikasi.

# Alur Menjalankan Aplikasi
Setelah mengunduh dan ekstrak zip file, jalankan sesuai alur penggunaan aplikasi berikut. Pastikan sebelum menggunakan, file `.env` sudah ada di folder root dan mengandung API Key (Weather & News) agar fitur Home berjalan normal. Lalu jalankan `flutter pub get` dan `flutter run`.
1. Lakukan registrasi: Masukkan nama, password, dan kondirmasi password untuk membuat akun baru.
2. Lakukan login: Setelah berhasil daftar, masuk dengan menggunakan akun yang sudah dibuat.
3. Mengakses melalui menu atau klik opsi yang terdapat pada halaman utama untuk mengakses fitur kalkulator.
4. Pilih jenis pajak yang ingin dihitung: Setiap jenis pajak yang dipilih, masing-masing terdapat form input dan penjelasan panduan? di bagian bawahnya.
6. Lakukan pengisian data jika memilih PPh 21 dan klik tombol "Hitung PPh 21" 
7. Melihat riwayat semua perhitungan kalkulator: Cek di bagian history. Di dalam history terdapat seluruh riwayat perhitungan kalkulasi pajak. Di dalam history ini pun ada fitur clear yang berada di atas kanan, berfungsi untuk menghapus seluruh riwayat perhitungan.
8. Tersedia "search" untuk mencari nama pajak kalkulator yang tersedia. 
9. Gunakan Panduan dan tips Pajak untuk melihat aturan singkat. Berisi informasi tambahan tentang tarif pajak dan ketentuan umum perpajakan. 

## Penjelasan umum fitur perhitungan pajak yang ada di halaman utama
1.	Kalkulator PPh 21
Digunakan untuk menghitung pajak penghasilan pribadi.
Bisa memasukkan gaji bruto tahunan, memilih status PTKP (seperti TK/0, K/1, dst), lalu aplikasi akan menampilkan hasil perhitungan sesuai tarif progresif 5%–35%.
2.	Kalkulator PPh 22
Dipakai untuk menghitung pajak impor atau penjualan barang tertentu.
Pengguna cukup memasukkan nilai transaksi (DPP) dan memilih jenis transaksi seperti Impor API (2.5%), lalu sistem akan menampilkan tarif yang sesuai dengan ketentuan.
3.	Kalkulator PPh 23
Menampilkan simulasi pajak atas penghasilan dari jasa, sewa, dividen, royalti, dan bunga.
Pengguna bisa memilih jenis penghasilan (misalnya Jasa/Sewa Aset 2%) dan melihat total pajak terutang.
4.	Kalkulator PPh 25/29
Digunakan untuk menghitung angsuran dan pelunasan tahunan.
Pengguna dapat memasukkan omzet, penghasilan kena pajak, serta kredit pajak tahun sebelumnya, dan aplikasi akan menghitung besarnya pajak yang masih harus dibayar.
5.	Kalkulator PPN (Pajak Pertambahan Nilai)
Digunakan untuk menghitung PPN standar 11% sesuai tarif nasional yang berlaku sejak April 2022.
Pengguna cukup memasukkan nilai transaksi (DPP), dan sistem otomatis menampilkan besarnya PPN yang harus dibayar.
6.	Kalkulator PBB (Pajak Bumi dan Bangunan)
Fitur ini membantu pengguna menghitung PBB berdasarkan nilai jual objek pajak (NJOP) dan NJOPTKP (nilai tidak kena pajak).
Pengguna dapat memilih persentase NJKP (nilai jual kena pajak), dan aplikasi akan menghitung total pajak sesuai ketentuan umum PBB di daerah.
7.	Simulasi PPh Final UMKM (0.5%)
Digunakan untuk menghitung PPh Final bagi pelaku UMKM dengan tarif 0.5%.
Cukup memasukkan omzet kumulatif bulan sebelumnya dan omzet bulan ini, lalu aplikasi otomatis menghitung total pajak final berdasarkan batas omzet Rp4.8 miliar per tahun.
