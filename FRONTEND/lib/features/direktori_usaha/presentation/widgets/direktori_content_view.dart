import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../direktori_bloc.dart';
import 'kartu_usaha.dart';
import 'kontrol_paginasi.dart';

class DirektoriContentView extends StatelessWidget {
  final DirektoriState state;

  const DirektoriContentView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is DirektoriLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFA500)),
            SizedBox(height: 16),
            Text(
              'Mengambil data dari database...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state is DirektoriError) {
      return _buildTampilanError(context, (state as DirektoriError).pesanError);
    }

    if (state is DirektoriLoaded) {
      final loadedState = state as DirektoriLoaded;
      if (loadedState.daftarUsaha.isEmpty) {
        return _buildTampilanKosong(context);
      }
      return _buildTampilanData(context, loadedState);
    }

    // Initial state
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFFA500)),
    );
  }

  Widget _buildTampilanData(BuildContext context, DirektoriLoaded loadedState) {
    return Column(
      children: [
        // Info ringkasan pagination
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFFFF8E1),
          child: Text(
            'Menampilkan data ke ${loadedState.dataMulai}–${loadedState.dataSampai} '
            'dari ${loadedState.totalData} usaha  '
            '(Halaman ${loadedState.halamanSaatIni} dari ${loadedState.totalHalaman})',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF795548),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // List kartu direktori
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: loadedState.daftarUsaha.length,
            itemBuilder: (context, index) {
              return KartuUsaha(usaha: loadedState.daftarUsaha[index]);
            },
          ),
        ),

        // Kontrol Pagination
        KontrolPaginasi(
          halamanSaatIni: loadedState.halamanSaatIni,
          totalHalaman: loadedState.totalHalaman,
          perHalaman: loadedState.perHalaman,
          totalData: loadedState.totalData,
          dataMulai: loadedState.dataMulai,
          dataSampai: loadedState.dataSampai,
          onGantiHalaman: (halamanBaru) {
            context.read<DirektoriBloc>().add(GantiHalamanEvent(halamanBaru));
          },
          onGantiPerHalaman: (pilihanPerHalamanBaru) {
            context.read<DirektoriBloc>().add(GantiPerHalamanEvent(pilihanPerHalamanBaru));
          },
        ),
      ],
    );
  }

  Widget _buildTampilanKosong(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data usaha yang ditemukan',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian Anda.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Jika filter tidak kosong, berarti kita coba bersihkan filter
              context.read<DirektoriBloc>().add(
                AmbilDirektoriEvent(halaman: 1, perHalaman: 10),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang Semua Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTampilanError(BuildContext context, String pesanError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            Text(pesanError, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final state = context.read<DirektoriBloc>().state;
                final perHalaman = state is DirektoriLoaded ? state.perHalaman : 10;
                context.read<DirektoriBloc>().add(
                  AmbilDirektoriEvent(halaman: 1, perHalaman: perHalaman),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA500),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
