class FilterDirektori {
  // --- Pencarian Dasar ---
  final String idsbr;
  final String namaUsaha;
  final String alamatUsaha;

  // --- Filter Wilayah (Dropdown) ---
  final String provinsi;
  final String kabupaten;
  final String kecamatan;
  final String desa;

  // --- Filter Lanjutan ---
  final String skalaUsaha;

  const FilterDirektori({
    this.idsbr = '',
    this.namaUsaha = '',
    this.alamatUsaha = '',
    this.provinsi = 'Semua',
    this.kabupaten = 'Semua',
    this.kecamatan = 'Semua',
    this.desa = 'Semua',
    this.skalaUsaha = 'Semua',
  });

  /// Salin filter dengan nilai baru (immutable update)
  FilterDirektori copyWith({
    String? idsbr,
    String? namaUsaha,
    String? alamatUsaha,
    String? provinsi,
    String? kabupaten,
    String? kecamatan,
    String? desa,
    String? skalaUsaha,
  }) {
    return FilterDirektori(
      idsbr: idsbr ?? this.idsbr,
      namaUsaha: namaUsaha ?? this.namaUsaha,
      alamatUsaha: alamatUsaha ?? this.alamatUsaha,
      provinsi: provinsi ?? this.provinsi,
      kabupaten: kabupaten ?? this.kabupaten,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      skalaUsaha: skalaUsaha ?? this.skalaUsaha,
    );
  }

  /// Mengembalikan true jika tidak ada filter aktif sama sekali
  bool get isEmpty {
    return idsbr.isEmpty &&
        namaUsaha.isEmpty &&
        alamatUsaha.isEmpty &&
        provinsi == 'Semua' &&
        kabupaten == 'Semua' &&
        kecamatan == 'Semua' &&
        desa == 'Semua' &&
        skalaUsaha == 'Semua';
  }

  /// Apakah ada filter pencarian teks aktif?
  bool get adaFilterCari => idsbr.isNotEmpty || namaUsaha.isNotEmpty;

  /// Apakah ada filter wilayah aktif?
  bool get adaFilterWilayah => kabupaten != 'Semua' || kecamatan != 'Semua';

  /// Apakah ada filter skala usaha aktif?
  bool get adaFilterSkala => skalaUsaha != 'Semua';
}
