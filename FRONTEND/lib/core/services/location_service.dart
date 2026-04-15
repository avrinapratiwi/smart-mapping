import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Memeriksa status izin lokasi dan mengambil posisi pengguna saat ini.
  /// Mengembalikan pesan error (String) jika gagal, atau Position jika berhasil.
  static Future<dynamic> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Periksa apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Layanan lokasi belum diaktifkan. Harap nyalakan GPS Anda.';
    }

    // Periksa izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Izin lokasi ditolak.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Izin lokasi ditolak secara permanen. Aktifkan dari pengaturan HP Anda.';
    }

    // Dapatkan posisi GPS dengan tingkat akurasi tinggi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
