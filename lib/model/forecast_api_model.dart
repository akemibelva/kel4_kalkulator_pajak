// Model Forecast digunakan untuk merepresentasikan data prakiraan cuaca
// (biasanya dari API seperti OpenWeatherMap)
class Forecast {
  // Deklarasi atribut utama yang merepresentasikan tiap data prakiraan cuaca
  final DateTime date;         // Tanggal dan waktu prakiraan cuaca
  final double temperature;    // Suhu dalam derajat Celsius (atau Kelvin, tergantung API)
  final String description;    // Deskripsi kondisi cuaca, misalnya: "clear sky", "light rain"
  final String iconCode;       // Kode ikon cuaca, digunakan untuk menampilkan gambar cuaca dari API

  // Konstruktor utama untuk membuat objek Forecast
  Forecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  // Factory constructor untuk membuat objek Forecast dari data JSON
  // Biasanya data ini berasal dari API OpenWeatherMap (endpoint /forecast)
  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      // Mengambil tanggal & waktu prakiraan dari field 'dt_txt'
      // Contoh: "2025-11-02 12:00:00"
      date: DateTime.parse(json['dt_txt']),

      // Mengambil nilai suhu dari 'main' → 'temp'
      // dan mengonversinya ke tipe double
      temperature: json['main']['temp'].toDouble(),

      // Mengambil deskripsi cuaca dari elemen pertama list 'weather'
      // Contoh: "clear sky", "light rain"
      description: json['weather'][0]['description'],

      // Mengambil kode ikon dari 'weather' → 'icon'
      // Misalnya: "10d", "01n" → bisa dipakai untuk URL gambar seperti:
      // https://openweathermap.org/img/wn/10d@2x.png
      iconCode: json['weather'][0]['icon'],
    );
  }
}
