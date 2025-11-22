// Model Weather digunakan untuk merepresentasikan data cuaca
// yang diambil dari API OpenWeatherMap (https://api.openweathermap.org/).
// Model ini menyimpan informasi seperti suhu, deskripsi cuaca, kecepatan angin, dll.
class Weather {
  // =========================
  // 📦 Deklarasi atribut utama
  // =========================

  final String cityName;     // Nama kota tempat data cuaca diambil
  final double temperature;  // Suhu dalam derajat Celsius
  final String description;  // Deskripsi cuaca (contoh: "clear sky", "rainy")
  final String iconCode;     // Kode ikon cuaca dari API (contoh: "10d")
  final double windSpeed;    // Kecepatan angin dalam meter per detik
  final int humidity;        // Persentase kelembapan udara

  // =========================
  // 🏗️ Konstruktor utama
  // =========================
  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
  });

  // =========================
  // 🧩 Factory Constructor
  // =========================
  // Fungsi ini digunakan untuk membuat objek Weather dari data JSON.
  // Factory constructor sangat berguna untuk parsing data dari API.
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Bagian utama dari data cuaca disimpan dalam beberapa sub-map:
    // - "main" untuk suhu dan kelembapan
    // - "weather" (list) untuk deskripsi dan ikon
    // - "wind" untuk kecepatan angin

    // Ambil data utama (main)
    final mainData = json['main'] as Map<String, dynamic>;

    // Ambil data cuaca pertama dari list "weather"
    final weatherData =
    (json['weather'] as List<dynamic>)[0] as Map<String, dynamic>;

    // Ambil data angin
    final windData = json['wind'] as Map<String, dynamic>;

    // Kembalikan objek Weather berdasarkan data JSON yang diterima
    return Weather(
      // Nama kota
      cityName: json['name'] as String,

      // Suhu (dalam Kelvin oleh default dari API, biasanya diubah ke Celsius di service)
      temperature: (mainData['temp'] as num).toDouble(),

      // Deskripsi cuaca (contoh: "broken clouds")
      description: weatherData['description'] as String,

      // Kode ikon (contoh: "10d")
      iconCode: weatherData['icon'] as String,

      // Kecepatan angin
      windSpeed: (windData['speed'] as num).toDouble(),

      // Kelembapan
      humidity: mainData['humidity'] as int,
    );
  }

  // =========================
  // 🌤️ Getter tambahan
  // =========================
  // Getter ini mengembalikan URL lengkap untuk ikon cuaca berdasarkan kode ikon.
  // Contoh hasil: https://openweathermap.org/img/wn/10d@2x.png
  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
