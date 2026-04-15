import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/direktori_service.dart';
import '../data/filter_model.dart';
import '../data/usaha_model.dart';

// =========================================================
// EVENTS
// =========================================================

abstract class DirektoriEvent {}

/// Event: Ambil data dengan filter & pagination
class AmbilDirektoriEvent extends DirektoriEvent {
  final FilterDirektori filter;
  final int halaman;
  final int perHalaman;

  AmbilDirektoriEvent({
    this.filter = const FilterDirektori(),
    this.halaman = 1,
    this.perHalaman = 10,
  });
}

/// Event: Ganti halaman (tanpa mengubah filter)
class GantiHalamanEvent extends DirektoriEvent {
  final int halaman;
  GantiHalamanEvent(this.halaman);
}

/// Event: Ganti jumlah data per halaman, reset ke halaman 1
class GantiPerHalamanEvent extends DirektoriEvent {
  final int perHalaman;
  GantiPerHalamanEvent(this.perHalaman);
}

/// Event: Pilih satu usaha (dari klik marker di PetaDashboard)
class PilihUsahaEvent extends DirektoriEvent {
  final UsahaModel usaha;
  PilihUsahaEvent(this.usaha);
}

/// Event: Ambil SEMUA data usaha untuk ditampilkan di peta (tanpa paginasi).
class AmbilSemuaUntukPetaEvent extends DirektoriEvent {}

/// Event: Terapkan filter peta secara lokal (tanpa re-fetch API).
/// Filter diterapkan terhadap semua data yang sudah di-cache di state.
class TerapkanFilterPetaEvent extends DirektoriEvent {
  final FilterDirektori filter;
  TerapkanFilterPetaEvent(this.filter);
}

// =========================================================
// STATES
// =========================================================

abstract class DirektoriState {}

class DirektoriInitial extends DirektoriState {}

class DirektoriLoading extends DirektoriState {}

class DirektoriLoaded extends DirektoriState {
  final List<UsahaModel> daftarUsaha;       // Data aktif (sudah difilter)
  final List<UsahaModel> semuaDataCache;    // Cache semua data dari API (untuk filter lokal)
  final int totalData;       // Total seluruh data (untuk hitung total halaman)
  final int halamanSaatIni; // Halaman yang sedang aktif
  final int perHalaman;      // Jumlah data per halaman
  final UsahaModel? usahaTerpilih; // Usaha yang dipilih dari klik marker peta
  final FilterDirektori filterSaatIni; // Persistent Filter

  DirektoriLoaded({
    required this.daftarUsaha,
    required this.totalData,
    required this.halamanSaatIni,
    required this.perHalaman,
    List<UsahaModel>? semuaDataCache,
    this.usahaTerpilih,
    this.filterSaatIni = const FilterDirektori(),
  }) : semuaDataCache = semuaDataCache ?? daftarUsaha;

  /// Total halaman berdasarkan totalData dan perHalaman
  int get totalHalaman => (totalData / perHalaman).ceil();

  /// Nomor urut data pertama yang ditampilkan (untuk label "X - Y dari Z")
  int get dataMulai => totalData == 0 ? 0 : (halamanSaatIni - 1) * perHalaman + 1;

  /// Nomor urut data terakhir yang ditampilkan
  int get dataSampai {
    final sampai = halamanSaatIni * perHalaman;
    return sampai > totalData ? totalData : sampai;
  }

  /// Buat salinan state dengan usahaTerpilih yang berbeda
  DirektoriLoaded copyWithUsahaTerpilih(UsahaModel? usaha) {
    return DirektoriLoaded(
      daftarUsaha: daftarUsaha,
      semuaDataCache: semuaDataCache,
      totalData: totalData,
      halamanSaatIni: halamanSaatIni,
      perHalaman: perHalaman,
      usahaTerpilih: usaha,
      filterSaatIni: filterSaatIni,
    );
  }

  /// Terapkan filter secara lokal dari cache — tidak perlu re-fetch API
  DirektoriLoaded copyWithFilter(FilterDirektori filter) {
    var hasil = semuaDataCache;

    // Filter Kabupaten
    if (filter.kabupaten != 'Semua') {
      hasil = hasil.where((u) =>
        u.nmkab.toLowerCase().contains(filter.kabupaten.toLowerCase())).toList();
    }
    // Filter Kecamatan
    if (filter.kecamatan != 'Semua') {
      hasil = hasil.where((u) =>
        u.nmkec.toLowerCase().contains(filter.kecamatan.toLowerCase())).toList();
    }
    // Filter Skala Usaha
    if (filter.skalaUsaha != 'Semua') {
      hasil = hasil.where((u) =>
        u.skalaUsaha.toLowerCase() == filter.skalaUsaha.toLowerCase()).toList();
    }
    // Filter teks (idsbr / namaUsaha)
    if (filter.idsbr.isNotEmpty) {
      hasil = hasil.where((u) =>
        u.idsbr.toLowerCase().contains(filter.idsbr.toLowerCase())).toList();
    } else if (filter.namaUsaha.isNotEmpty) {
      hasil = hasil.where((u) =>
        u.namaUsaha.toLowerCase().contains(filter.namaUsaha.toLowerCase())).toList();
    }

    return DirektoriLoaded(
      daftarUsaha: hasil,
      semuaDataCache: semuaDataCache,  // cache tidak berubah!
      totalData: totalData,
      halamanSaatIni: halamanSaatIni,
      perHalaman: perHalaman,
      usahaTerpilih: null,
      filterSaatIni: filter,
    );
  }
}

class DirektoriError extends DirektoriState {
  final String pesanError;
  DirektoriError(this.pesanError);
}

// =========================================================
// BLOC
// =========================================================

class DirektoriBloc extends Bloc<DirektoriEvent, DirektoriState> {
  final DirektoriService _service;

  // Simpan filter terakhir agar bisa dipakai saat ganti halaman / per-halaman
  FilterDirektori _filterTerakhir = const FilterDirektori();
  int _perHalamanTerakhir = 10;

  DirektoriBloc(this._service) : super(DirektoriInitial()) {
    // Handler: Ambil data dengan filter baru (reset ke halaman 1)
    on<AmbilDirektoriEvent>((event, emit) async {
      emit(DirektoriLoading());

      // Simpan filter yang dipakai
      _filterTerakhir = event.filter;
      _perHalamanTerakhir = event.perHalaman;

      try {
        final hasil = await _service.ambilDenganPaginasi(
          halaman: event.halaman,
          perHalaman: event.perHalaman,
          filter: event.filter,
        );
        emit(DirektoriLoaded(
          daftarUsaha: hasil.daftarUsaha,
          totalData: hasil.totalData,
          halamanSaatIni: event.halaman,
          perHalaman: event.perHalaman,
          filterSaatIni: event.filter,
        ));
      } catch (e) {
        emit(DirektoriError(e.toString()));
      }
    });

    // Handler: Ganti halaman (gunakan filter terakhir)
    on<GantiHalamanEvent>((event, emit) async {
      // Simpan state sebelumnya agar tetap tampil saat loading
      final stateLama = state;
      emit(DirektoriLoading());

      try {
        final hasil = await _service.ambilDenganPaginasi(
          halaman: event.halaman,
          perHalaman: _perHalamanTerakhir,
          filter: _filterTerakhir,
        );
        emit(DirektoriLoaded(
          daftarUsaha: hasil.daftarUsaha,
          totalData: hasil.totalData,
          halamanSaatIni: event.halaman,
          perHalaman: _perHalamanTerakhir,
          filterSaatIni: _filterTerakhir,
        ));
      } catch (e) {
        // Kembalikan state lama jika error saat ganti halaman
        if (stateLama is DirektoriLoaded) {
          emit(stateLama);
        }
        emit(DirektoriError(e.toString()));
      }
    });

    // Handler: Ganti jumlah per halaman, reset ke halaman 1
    on<GantiPerHalamanEvent>((event, emit) async {
      emit(DirektoriLoading());
      _perHalamanTerakhir = event.perHalaman;

      try {
        final hasil = await _service.ambilDenganPaginasi(
          halaman: 1, // Reset selalu ke halaman pertama
          perHalaman: event.perHalaman,
          filter: _filterTerakhir,
        );
        emit(DirektoriLoaded(
          daftarUsaha: hasil.daftarUsaha,
          totalData: hasil.totalData,
          halamanSaatIni: 1,
          perHalaman: event.perHalaman,
          filterSaatIni: _filterTerakhir,
        ));
      } catch (e) {
        emit(DirektoriError(e.toString()));
      }
    });

    // Handler: Pilih usaha dari klik marker di peta
    on<PilihUsahaEvent>((event, emit) {
      final currentState = state;
      if (currentState is DirektoriLoaded) {
        emit(currentState.copyWithUsahaTerpilih(event.usaha));
      }
    });

    // Handler: Ambil semua data untuk peta (tanpa paginasi, batas 9999)
    on<AmbilSemuaUntukPetaEvent>((event, emit) async {
      emit(DirektoriLoading());
      try {
        final hasil = await _service.ambilDenganPaginasi(
          halaman: 1,
          perHalaman: 9999, // Ambil semua data untuk marker peta
          filter: const FilterDirektori(),
        );
        emit(DirektoriLoaded(
          daftarUsaha: hasil.daftarUsaha,
          semuaDataCache: hasil.daftarUsaha, // simpan cache penuh
          totalData: hasil.totalData,
          halamanSaatIni: 1,
          perHalaman: 9999,
          filterSaatIni: const FilterDirektori(),
        ));
      } catch (e) {
        emit(DirektoriError(e.toString()));
      }
    });

    // Handler: Filter peta secara lokal (instant, tanpa re-fetch API)
    on<TerapkanFilterPetaEvent>((event, emit) {
      final currentState = state;
      if (currentState is DirektoriLoaded) {
        emit(currentState.copyWithFilter(event.filter));
      }
    });
  }
}
