/// ============================================================
/// MODEL DATA: UsahaModel
/// Smart Mapping BPS - Sensus Ekonomi 2026
/// ============================================================
///
/// Model ini merepresentasikan satu baris data dari tabel
/// `direktori_usaha` yang dikirim oleh API PHP.
///
/// Field disesuaikan dengan kolom database MySQL:
/// idsbr, nama_usaha, alamat_usaha, nmkab, nmkec, nmdesa,
/// latitude_gc, longitude_gc

// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class UsahaModel {
  final String idsbr;
  final String namaUsaha;
  final String alamatUsaha;
  final String nmkab; // Nama Kabupaten/Kota
  final String nmkec; // Nama Kecamatan
  final String nmdesa; // Nama Desa/Kelurahan
  final String skalaUsaha; // Skala usaha: UMKM / UB
  final double? latitudeGc; // Koordinat latitude (dari kolom latitude_gc)
  final double? longitudeGc; // Koordinat longitude (dari kolom longitude_gc)

  UsahaModel({
    required this.idsbr,
    required this.namaUsaha,
    required this.alamatUsaha,
    required this.nmkab,
    required this.nmkec,
    required this.nmdesa,
    this.skalaUsaha = '',
    this.latitudeGc,
    this.longitudeGc,
  });

  /// Factory constructor untuk parsing JSON dari API PHP.
  ///
  /// Catatan penting:
  /// - PHP mengirim semua nilai sebagai String dalam JSON
  /// - Koordinat perlu dikonversi ke double secara aman menggunakan tryParse
  /// - Null-safety diterapkan di setiap field untuk mencegah crash
  factory UsahaModel.fromJson(Map<String, dynamic> json) {
    return UsahaModel(
      // Field teks — gunakan toString() sebagai fallback aman
      idsbr: json['idsbr']?.toString() ?? '',
      namaUsaha: json['nama_usaha']?.toString() ?? 'Tidak Ada Nama',
      alamatUsaha: json['alamat_usaha']?.toString() ?? '',
      nmkab: json['nmkab']?.toString() ?? '',
      nmkec: json['nmkec']?.toString() ?? '',
      nmdesa: json['nmdesa']?.toString() ?? '',
      skalaUsaha: json['skala_usaha']?.toString() ?? '',

      latitudeGc: double.tryParse(json['latitude_gc']?.toString() ?? ''),
      longitudeGc: double.tryParse(json['longitude_gc']?.toString() ?? ''),
    );
  }

  /// Cek apakah usaha ini memiliki koordinat yang valid
  bool get punyaKoordinat => latitudeGc != null && longitudeGc != null;

  /// Format koordinat sebagai string untuk ditampilkan di UI
  String get koordinatTeks => punyaKoordinat
      ? '${latitudeGc.toString()}, ${longitudeGc.toString()}'
      : 'Tidak tersedia';

  /// Konversi ke objek LatLng dari package latlong2.
  /// Digunakan langsung oleh flutter_map dan flutter_map_marker_cluster
  /// untuk merender marker di widget PetaDashboard.
  ///
  /// Mengembalikan null jika koordinat tidak tersedia,
  /// sehingga widget cukup melakukan null-check sebelum menambahkan marker.
  LatLng? get toLatLng =>
      punyaKoordinat ? LatLng(latitudeGc!, longitudeGc!) : null;

  @override
  String toString() =>
      'UsahaModel(idsbr: $idsbr, nama: $namaUsaha, kab: $nmkab, kec: $nmkec)';
}
