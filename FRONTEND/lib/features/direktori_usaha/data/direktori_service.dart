import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'usaha_model.dart';
import 'filter_model.dart';

/// ============================================================
/// KONFIGURASI BASE URL API
/// ============================================================
///
/// Untuk Flutter Web di localhost → gunakan 'localhost' langsung.
///
/// ⚠️ CATATAN PENTING untuk pengujian di perangkat fisik (Android/iOS):
///   - Ganti 'localhost' dengan IP komputer Anda, contoh:
///     const String baseUrl = 'http://192.168.1.100/smart-mapping/backend/api';
///   - Pastikan perangkat dan komputer berada di jaringan WiFi yang sama.
///   - Untuk Android Emulator, gunakan: 'http://10.0.2.2/...'
const String baseUrl = 'http://localhost/smart-mapping/backend/api';

/// Hasil query dengan informasi pagination
class HasilPaginasi {
  final List<UsahaModel> daftarUsaha;
  final int totalData; // Total keseluruhan data (untuk menghitung halaman)

  const HasilPaginasi({
    required this.daftarUsaha,
    required this.totalData,
  });
}

/// ============================================================
/// SERVICE: DirektoriService
/// ============================================================
///
/// Bertanggung jawab untuk komunikasi dengan API PHP.
/// Menggantikan koneksi Supabase yang sebelumnya digunakan.
class DirektoriService {
  // Instance HTTP client yang bisa di-reuse
  final http.Client _client;

  /// Constructor — menerima [http.Client] opsional untuk keperluan testing.
  /// Jika tidak diberikan, akan membuat client baru.
  DirektoriService({http.Client? client}) : _client = client ?? http.Client();

  /// Ambil data usaha dengan pagination dan filter opsional.
  ///
  /// [halaman]    : halaman ke-berapa (dimulai dari 1)
  /// [perHalaman] : jumlah data per halaman (10, 50, atau 100)
  /// [filter]     : objek FilterDirektori berisi kata kunci & filter wilayah
  Future<HasilPaginasi> ambilDenganPaginasi({
    int halaman = 1,
    int perHalaman = 10,
    FilterDirektori filter = const FilterDirektori(),
  }) async {
    try {
      debugPrint('=== DirektoriService: Fetch dari API PHP ===');
      debugPrint('URL Base: $baseUrl');
      debugPrint('Halaman: $halaman | Per Halaman: $perHalaman');

      // ─── Langkah 1: Bangun parameter query ───
      final Map<String, String> queryParams = {};

      // Gabungkan semua filter teks menjadi satu parameter 'search'
      // API PHP kita mendukung pencarian di kolom nama_usaha dan idsbr
      final String kataKunci = _gabungkanKataKunci(filter);
      if (kataKunci.isNotEmpty) {
        queryParams['search'] = kataKunci;
        debugPrint('Kata kunci pencarian: $kataKunci');
      }

      // ─── Langkah 2: Bangun URL lengkap ───
      final Uri url = Uri.parse('$baseUrl/ambil_usaha.php').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      debugPrint('Request URL: $url');

      // ─── Langkah 3: Kirim HTTP GET request ───
      final http.Response response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('Status Code: ${response.statusCode}');

      // ─── Langkah 4: Validasi respons ───
      if (response.statusCode != 200) {
        throw Exception(
          'Server mengembalikan status ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // ─── Langkah 5: Parse JSON ───
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      // Cek apakah API mengembalikan status sukses
      if (jsonBody['sukses'] != true) {
        throw Exception(
          jsonBody['pesan'] ?? 'API mengembalikan error tidak dikenal.',
        );
      }

      // ─── Langkah 6: Konversi data JSON ke List<UsahaModel> ───
      final List<dynamic> dataRaw = jsonBody['data'] ?? [];
      debugPrint('Total data dari API: ${dataRaw.length}');

      // Konversi setiap item JSON menjadi UsahaModel
      final List<UsahaModel> semuaData =
          dataRaw.map((item) => UsahaModel.fromJson(item)).toList();

      // ─── Langkah 7: Terapkan filter tambahan di sisi client ───
      // (Filter wilayah, skala, dll. yang belum didukung API PHP)
      final List<UsahaModel> dataFiltered = _terapkanFilterLokal(semuaData, filter);

      // ─── Langkah 8: Terapkan pagination di sisi client ───
      // Karena API PHP saat ini mengembalikan semua data,
      // kita potong (slice) di sini sesuai halaman yang diminta.
      final int totalData = dataFiltered.length;
      final int mulaiDari = (halaman - 1) * perHalaman;

      // Pastikan index tidak melebihi panjang list
      final int sampaiDi = (mulaiDari + perHalaman).clamp(0, totalData);

      final List<UsahaModel> dataHalaman = mulaiDari < totalData
          ? dataFiltered.sublist(mulaiDari, sampaiDi)
          : [];

      debugPrint('Data halaman ini: ${dataHalaman.length} dari $totalData total');

      return HasilPaginasi(
        daftarUsaha: dataHalaman,
        totalData: totalData,
      );
    } on http.ClientException catch (e) {
      // Error koneksi jaringan (server mati, DNS gagal, dll.)
      debugPrint('=== ClientException: $e ===');
      throw Exception(
        'Gagal terhubung ke server.\n'
        'Pastikan Laragon/XAMPP aktif dan API bisa diakses.\n'
        'Detail: $e',
      );
    } on FormatException catch (e) {
      // Error parsing JSON (respons bukan JSON valid)
      debugPrint('=== FormatException: $e ===');
      throw Exception(
        'Respons dari server bukan format JSON yang valid.\n'
        'Kemungkinan ada error PHP di sisi server.',
      );
    } catch (e) {
      // Error umum lainnya
      debugPrint('=== Error Umum: $e ===');
      throw Exception('Gagal mengambil data usaha: $e');
    }
  }

  /// Gabungkan filter teks (idsbr / namaUsaha) menjadi satu kata kunci.
  /// API PHP hanya mendukung satu parameter 'search', jadi kita prioritaskan:
  /// 1. IDSBR jika diisi
  /// 2. Nama Usaha jika diisi
  /// 3. Alamat jika diisi
  String _gabungkanKataKunci(FilterDirektori filter) {
    if (filter.idsbr.isNotEmpty) return filter.idsbr;
    if (filter.namaUsaha.isNotEmpty) return filter.namaUsaha;
    if (filter.alamatUsaha.isNotEmpty) return filter.alamatUsaha;
    return '';
  }

  /// Terapkan filter tambahan yang belum didukung API PHP.
  /// Filter ini dijalankan di sisi client (Flutter) setelah data diterima.
  List<UsahaModel> _terapkanFilterLokal(
    List<UsahaModel> data,
    FilterDirektori filter,
  ) {
    var hasil = data;

    // Filter Kabupaten
    if (filter.kabupaten != 'Semua' && filter.kabupaten.isNotEmpty) {
      hasil = hasil
          .where((u) =>
              u.nmkab.toLowerCase().contains(filter.kabupaten.toLowerCase()))
          .toList();
    }

    // Filter Kecamatan
    if (filter.kecamatan != 'Semua' && filter.kecamatan.isNotEmpty) {
      hasil = hasil
          .where((u) =>
              u.nmkec.toLowerCase().contains(filter.kecamatan.toLowerCase()))
          .toList();
    }

    // Filter Desa
    if (filter.desa != 'Semua' && filter.desa.isNotEmpty) {
      hasil = hasil
          .where((u) =>
              u.nmdesa.toLowerCase().contains(filter.desa.toLowerCase()))
          .toList();
    }

    return hasil;
  }

  /// Bersihkan resource HTTP client saat service tidak dipakai lagi
  void dispose() {
    _client.close();
  }
}
