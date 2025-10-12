import 'dart:math';

// Kelas statis yang berisi seluruh logika dan rumus perhitungan pajak di Indonesia.
class TaxLogic {
  // --- Konstanta Standar Perpajakan (Mengacu pada UU HPP terbaru) ---
  static const double _ptkpTK0 = 54000000.0; // PTKP untuk status Tidak Kawin (TK/0)
  static const double _ptkpTambahanKawin = 4500000.0; // Tambahan PTKP bagi yang sudah kawin
  static const double _ptkpTambahanTanggungan = 4500000.0; // Tambahan PTKP per tanggungan (maks 3)

  static const double _ppnRate = 0.11; // Tarif PPN standar (11% sejak April 2022)

  static const double _pphUmkmRate = 0.005; // Tarif PPh Final UMKM (0.5%)
  static const double _omzetBatasBebasPajakUMKM = 500000000.0; // Batas omzet bebas PPh Final (WPOP)

  static const double _biayaJabatanRate = 0.05; // Tarif Biaya Jabatan (5%)
  static const double _biayaJabatanMax = 6000000.0; // Batas maksimum Biaya Jabatan per tahun

  // Tarif PPh 22 (Potong/Pungut)
  static const double _pph22ImportRate = 0.025; // 2.5% (Impor dengan Angka Pengenal Importir/API)
  static const double _pph22ImportNonApiRate = 0.075; // 7.5% (Impor tanpa API)
  static const double _pph22BendaharaRate = 0.015;    // 1.5% (Penjualan ke Bendahara)

  // Tarif PPh 23 (Potong/Pungut)
  static const double _pph23GeneralRate = 0.02; // 2% (Jasa, Sewa, dll.)

  // Tarif PPh Badan
  static const double _pphBadanRate = 0.22; // Tarif PPh Badan Umum (22% sejak 2022)
  static const double _pphBadanFasilitasRate = 0.11; // Tarif PPh Badan 50% * 22% = 11% (Fasilitas 31E)
  static const double _omzetBatasFasilitas4_8M = 4800000000.0; // Batas omzet untuk mendapat fasilitas 50%

  // Tarif PBB (Pajak Bumi dan Bangunan)
  static const double _pbbTarifMax = 0.005; // Tarif PBB-P2 Maksimum (0.5%)
  static const double _njoptkpMin = 10000000.0; // Asumsi Nilai Jual Objek Pajak Tidak Kena Pajak (NJOPTKP)
  static const double _njkpRate20 = 0.20; // NJKP 20% (untuk NJOP rendah/umum)
  static const double _njkpRate40 = 0.40; // NJKP 40% (untuk NJOP tinggi)

  // --- Fungsi: Penentuan PTKP (Penghasilan Tidak Kena Pajak) ---
  static double getPTKPValue(String status) {
    final parts = status.split('/');
    if (parts.length != 2) return _ptkpTK0;

    final maritalStatus = parts[0];
    final dependents = int.tryParse(parts[1]) ?? 0;

    double basePTKP = _ptkpTK0; // Mulai dari PTKP TK/0 (Rp 54 Juta)

    if (maritalStatus.contains('K')) {
      basePTKP += _ptkpTambahanKawin; // Tambah Rp 4.5 Juta jika Kawin
    }

    // Tambah tanggungan (maksimal 3)
    final dependentAddition = (dependents.clamp(0, 3) * _ptkpTambahanTanggungan);

    return basePTKP + dependentAddition;
  }

  // --- LOGIKA PERHITUNGAN PAJAK ---

  /// Menghitung PPh Pasal 21 Tahunan (menggunakan Tarif Progresif 5 Lapisan).
  static double PPH21({
    required double annualGrossSalary,
    required String ptkpStatus,
  }) {
    // 1. Hitung Biaya Jabatan (maksimal Rp 6 Juta setahun)
    double biayaJabatan = (annualGrossSalary * _biayaJabatanRate).clamp(0, _biayaJabatanMax);

    // 2. Hitung Penghasilan Neto
    double annualNetIncome = annualGrossSalary - biayaJabatan;

    // 3. Hitung PKP (Penghasilan Kena Pajak)
    double ptkpAmount = getPTKPValue(ptkpStatus);
    double pkp = (annualNetIncome - ptkpAmount).clamp(0.0, double.infinity); // PKP tidak boleh negatif

    double pph = 0.0;
    double currentPKP = pkp;

    // Lapisan Tarif Progresif (UU HPP): [Batas Lapisan : Tarif]
    final tiers = {
      60000000.0: 0.05, 250000000.0: 0.15, 500000000.0: 0.25, 5000000000.0: 0.30, double.infinity: 0.35,
    };

    double previousLimit = 0.0;
    // Iterasi melalui setiap lapisan tarif
    for (var entry in tiers.entries) {
      double limit = entry.key;
      double rate = entry.value;

      if (currentPKP <= 0) break; // Berhenti jika PKP habis

      // Tentukan dasar pengenaan pajak pada lapisan saat ini
      double taxBase = limit == double.infinity
          ? currentPKP // Lapisan terakhir mengambil sisa PKP
          : (limit - previousLimit).clamp(0.0, currentPKP); // Lapisan tengah

      pph += taxBase * rate; // Hitung PPh lapisan ini
      currentPKP -= taxBase; // Kurangi PKP yang sudah dikenakan
      previousLimit = limit;
    }

    return pph; // Total PPh 21 Terutang setahun
  }

  /// Menghitung PPh Pasal 22 (Pajak Potong/Pungut atas Impor/Penjualan Barang).
  static double PPH22(double value, {double rate = _pph22ImportRate}) {
    // PPh 22 = DPP (Dasar Pengenaan Pajak) x Tarif
    return value * rate;
  }

  /// Menghitung PPh Pasal 23 (Pajak Potong/Pungut atas Jasa/Modal).
  static double PPH23(double grossIncome, {double rate = _pph23GeneralRate}) {
    // PPh 23 = Penghasilan Bruto x Tarif
    return grossIncome * rate;
  }

  /// Menghitung PPh Badan Terutang Tahunan (Mempertimbangkan Fasilitas Pasal 31E).
  static double PPH_Badan_Terutang({
    required double annualNetIncome,
    required double annualGrossTurnover
  }) {
    double pkp = annualNetIncome.clamp(0.0, double.infinity);

    if (pkp <= 0) return 0.0;

    if (annualGrossTurnover <= _omzetBatasFasilitas4_8M) {
      // Kasus 1: Omzet ≤ 4.8 Miliar (Fasilitas Penuh)
      // PPh Terutang = PKP x 11%
      return pkp * _pphBadanFasilitasRate;
    } else if (annualGrossTurnover > _omzetBatasFasilitas4_8M && annualGrossTurnover <= 50000000000.0) {
      // Kasus 2: Omzet 4.8 M s/d 50 Miliar (Fasilitas Sebagian)

      // 1. Hitung Proporsi PKP yang mendapat fasilitas (11%)
      double pkpFasil = (_omzetBatasFasilitas4_8M / annualGrossTurnover) * pkp;
      double pkpNormal = pkp - pkpFasil;

      // 2. Hitung PPh Terutang
      double pphFasil = pkpFasil * _pphBadanFasilitasRate; // Tarif 11%
      double pphNormal = pkpNormal * _pphBadanRate; // Tarif 22%

      return pphFasil + pphNormal;
    } else {
      // Kasus 3: Omzet > 50 Miliar (Tidak ada fasilitas)
      // PPh Terutang = PKP x 22%
      return pkp * _pphBadanRate;
    }
  }

  /// Menghitung PPh Final UMKM (0.5%) dengan mempertimbangkan batas bebas pajak Rp 500 Juta (WPOP).
  static double PPH_UMKM_OP({
    required double monthlyTurnover,
    required double cumulativeTurnoverToDate,
  }) {
    double omzetBebas = _omzetBatasBebasPajakUMKM;
    double omzetSaatIniTotal = cumulativeTurnoverToDate + monthlyTurnover;

    // Hitung sisa batas bebas pajak yang belum terpakai
    double sisaOmzetBebas = omzetBebas - cumulativeTurnoverToDate;

    // Jika omzet bulan ini menyebabkan total omzet melewati batas Rp 500 Juta
    if (omzetSaatIniTotal > omzetBebas && cumulativeTurnoverToDate < omzetBebas) {
      // Hanya omzet yang melebihi batas yang dikenakan 0.5%
      double omzetKenaPajak = monthlyTurnover - sisaOmzetBebas;
      return omzetKenaPajak.clamp(0.0, double.infinity) * _pphUmkmRate;
    } else if (cumulativeTurnoverToDate >= omzetBebas) {
      // Jika batas sudah terlampaui di bulan sebelumnya, seluruh omzet bulan ini dikenakan 0.5%
      return monthlyTurnover * _pphUmkmRate;
    }

    // Jika total omzet masih di bawah Rp 500 Juta, PPh = 0
    return 0.0;
  }

  /// Menghitung PPN (Pajak Pertambahan Nilai).
  static double Ppn(double transactionValue) {
    // PPN = DPP (Nilai Transaksi) x 11%
    return transactionValue * _ppnRate;
  }

  /// Menghitung PBB (Pajak Bumi dan Bangunan).
  static double PBB({
    required double njop,
    double njoptkp = _njoptkpMin,
    double njkpRate = _njkpRate20,
    double pbbRate = _pbbTarifMax,
  }) {
    // 1. Hitung Dasar Pengenaan PBB (DPP): NJOP dikurangi NJOPTKP
    double dppPBB = (njop - njoptkp).clamp(0.0, double.infinity);

    // 2. Hitung NJKP (Nilai Jual Kena Pajak)
    double njkp = dppPBB * njkpRate;

    // 3. Hitung PBB Terutang: NJKP x Tarif PBB
    double pbbTerutang = njkp * pbbRate;

    return pbbTerutang;
  }

  // --- FUNGSI UTILITY: GET RUMUS ---

  /// Mendapatkan string representasi rumus yang digunakan untuk hasil akhir (untuk tampilan di UI).
  static String getFormula(String taxType, double inputValue, {
    String ptkpStatus = 'TK/0',
    double njoptkpValue = _njoptkpMin,
    double njkpRate = _njkpRate20,
    double pph22Rate = _pph22ImportRate,
    double pph23Rate = _pph23GeneralRate}) {

    // Logika ini memilih format rumus berdasarkan jenis pajak (taxType)
    switch (taxType) {
      case 'PPh 21':
        double ptkp = getPTKPValue(ptkpStatus);
        double pkp = (inputValue - ptkp).clamp(0.0, double.infinity);
        return 'PKP (Rp${pkp.toStringAsFixed(0)}) x Tarif Progresif (5%-35%)';
      case 'PPh 22':
        String rateDisplay = '';
        if (pph22Rate == _pph22ImportRate) {
          rateDisplay = '2.5% (Impor API)';
        } else if (pph22Rate == _pph22ImportNonApiRate) {
          rateDisplay = '7.5% (Impor Non-API)';
        } else if (pph22Rate == _pph22BendaharaRate) {
          rateDisplay = '1.5% (Penjualan ke Bendahara)';
        } else {
          rateDisplay = '${(pph22Rate * 100).toStringAsFixed(1)}%';
        }
        return 'DPP (Rp${inputValue.toStringAsFixed(0)}) x $rateDisplay';
      case 'PPh 23':
        String rateDisplay = (pph23Rate * 100).toStringAsFixed(0) + '%';
        String detail = pph23Rate == 0.02 ? 'Asumsi Jasa Umum' : 'Asumsi Modal (Dividen/Bunga)';
        return 'Penghasilan Bruto (Rp${inputValue.toStringAsFixed(0)}) x $rateDisplay ($detail)';
      case 'PPh 25/29':
        return 'Angsuran Bulanan = (PPh Terutang Tahunan - Kredit Pajak) / 12 (Asumsi PPh Badan 22%)';
      case 'UMKM':
        return 'Omzet Bulanan (Rp${inputValue.toStringAsFixed(0)}) x 0.5% (PPh Final UMKM)';
      case 'PPN':
        return 'Nilai Transaksi (Rp${inputValue.toStringAsFixed(0)}) x 11%';
      case 'PBB':
        String njkpRateDisplay = njkpRate == _njkpRate40 ? '40%' : '20%';
        return '(NJOP - NJOPTKP) x $njkpRateDisplay (NJKP) x 0.3% (Tarif Maks)';
      default:
        return 'Rumus tidak ditemukan.';
    }
  }
}