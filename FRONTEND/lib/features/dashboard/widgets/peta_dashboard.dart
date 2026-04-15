import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Feature & Service Layers
import '../../../core/services/location_service.dart';
import '../../direktori_usaha/direktori_usaha.dart';
import 'usaha_marker_layer.dart';
import 'floating_map_filter.dart';

const _kPusatSelayar = LatLng(-6.1275, 120.4368);
const _kZoomAwal = 12.0;
const _kZoomDetail = 16.0;

class PetaDashboard extends StatefulWidget {
  final void Function(UsahaModel usaha)? onUsahaDipilih;

  const PetaDashboard({super.key, this.onUsahaDipilih});

  @override
  State<PetaDashboard> createState() => PetaDashboardState();
}

class PetaDashboardState extends State<PetaDashboard> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  void navigasiKe(double latitude, double longitude) {
    _mapController.move(LatLng(latitude, longitude), _kZoomDetail);
  }

  void navigasiKeLatLng(LatLng posisi, {double zoom = _kZoomDetail}) {
    _mapController.move(posisi, zoom);
  }

  /// Zoom ke bounding box dari sekumpulan titik koordinat
  void _fitKeBatas(List<LatLng> titikTitik) {
    if (titikTitik.isEmpty) return;
    double minLat = titikTitik.first.latitude;
    double maxLat = titikTitik.first.latitude;
    double minLng = titikTitik.first.longitude;
    double maxLng = titikTitik.first.longitude;
    for (final t in titikTitik) {
      if (t.latitude  < minLat) minLat = t.latitude;
      if (t.latitude  > maxLat) maxLat = t.latitude;
      if (t.longitude < minLng) minLng = t.longitude;
      if (t.longitude > maxLng) maxLng = t.longitude;
    }
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    _mapController.move(center, 11.0); // zoom ke level kecamatan
  }

  // Action Button Zooms (Dibuat private)
  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  // Tracking GPS Location yang sudah diekstrak refactornya ke LocationService
  Future<void> _ambilLokasiSekarang() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mencari koordinat Anda...')),
      );
    }

    final dynamic result = await LocationService.getCurrentPosition();

    if (result is String) {
      // Menunjukkan Error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } else {
      // Jika berhasil akan return Position
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        setState(() {
          _currentPosition = LatLng(result.latitude, result.longitude);
        });
        _fokusKePengguna();
      }
    }
  }

  void _fokusKePengguna() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer yang mendengarkan jika ada klik marker dan mengupdate UI melalui state
    return BlocConsumer<DirektoriBloc, DirektoriState>(
      listener: (context, state) {
        if (state is DirektoriLoaded && state.usahaTerpilih != null) {
          final usaha = state.usahaTerpilih!;
          navigasiKeLatLng(usaha.toLatLng!);
          widget.onUsahaDipilih?.call(usaha);
          _tampilkanDetailModal(context, usaha);
        } else if (state is DirektoriLoaded && state.usahaTerpilih == null) {
          // Auto-zoom ke batas marker yang baru setelah filter diterapkan
          final titikTitik = state.daftarUsaha
            .where((u) => u.punyaKoordinat)
            .map((u) => u.toLatLng!)
            .toList();
          if (titikTitik.length > 1) {
            _fitKeBatas(titikTitik);
          } else if (titikTitik.length == 1) {
            navigasiKeLatLng(titikTitik.first);
          }
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            _buildMap(state),

            if (state is DirektoriLoading) _buildLoadingIndicator(),

            if (state is DirektoriLoaded) _buildHeaderMarkerInfo(state),

            _buildActionButtons(),

            _buildLegend(),

            if (state is DirektoriError) _buildErrorOverlay(state),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // EKSTRAKSI METHODS RENDER UI (Sub-Widget Breakdowns)
  // -------------------------------------------------------------

  Widget _buildMap(DirektoriState state) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _kPusatSelayar,
        initialZoom: _kZoomAwal,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bps.smartmapping',
        ),

        if (state is DirektoriLoaded)
          UsahaMarkerLayer(
            listUsaha: state.daftarUsaha,
            // Logic klik dipindah murni ke BLoC Triggering, bukan update logic view!
            onMarkerTapped: (usaha) {
              context.read<DirektoriBloc>().add(PilihUsahaEvent(usaha));
            },
          ),

        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 24,
                height: 24,
                child: const _ConstantBlueDot(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Memuat data marker...',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMarkerInfo(DirektoriLoaded state) {
    final jumlahMarker = state.daftarUsaha.where((u) => u.punyaKoordinat).length;
    final adaFilter    = !state.filterSaatIni.isEmpty;

    return Positioned(
      top: 12,
      left: 12,
      right: 80, // beri ruang untuk tombol FAB di kanan
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pill: Marker Aktif ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.orange, size: 16),
                const SizedBox(width: 5),
                Text(
                  '$jumlahMarker marker aktif',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                // Tanda filter aktif
                if (adaFilter) ...[  
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Filter ON',
                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Floating Filter (inline di sebelah kanan marker info) ──
          const FloatingMapFilter(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      right: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'btnMyLocation',
            onPressed: _ambilLokasiSekarang,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'btnZoomIn',
            onPressed: _zoomIn,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'btnZoomOut',
            onPressed: _zoomOut,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 20,
      left: 12,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Status Sensus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem('Selesai', Colors.green),
            const SizedBox(height: 8),
            _buildLegendItem('Dalam Proses', Colors.orange),
            const SizedBox(height: 8),
            _buildLegendItem('Belum Mulai', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildErrorOverlay(DirektoriError state) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gagal memuat data marker: ${state.pesanError}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: Colors.red,
              onPressed: () {
                context.read<DirektoriBloc>().add(AmbilSemuaUntukPetaEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // DIALOG TAMPIL USAHA (MODAL BOX)
  // -------------------------------------------------------------

  void _tampilkanDetailModal(BuildContext context, UsahaModel usaha) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Informasi Usaha',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildModalRow(Icons.confirmation_number, 'IDSBR', usaha.idsbr),
                _buildModalRow(
                  Icons.business_center,
                  'Nama Usaha',
                  usaha.namaUsaha,
                ),
                _buildModalRow(
                  Icons.map,
                  'Alamat',
                  '${usaha.alamatUsaha}, Kec. ${usaha.nmkec}, Kab. ${usaha.nmkab}',
                ),
                _buildModalRow(
                  Icons.location_on,
                  'Koordinat',
                  '${usaha.latitudeGc?.toStringAsFixed(6)}, ${usaha.longitudeGc?.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// HELPER WIDGETS (Stateless, Reusable, Constant Compliant)
// -------------------------------------------------------------

class _ConstantBlueDot extends StatelessWidget {
  const _ConstantBlueDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}
