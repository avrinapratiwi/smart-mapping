import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/usaha_model.dart';

/// ============================================================
/// WIDGET: KartuUsaha
/// ============================================================
///
/// Menampilkan satu item data usaha dalam bentuk Card.
/// Field sudah disesuaikan dengan struktur UsahaModel baru
/// yang mengambil data dari API PHP (bukan Supabase).
class KartuUsaha extends StatelessWidget {
  final UsahaModel usaha;

  const KartuUsaha({super.key, required this.usaha});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Penting agar efek InkWell tidak keluar dari border
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _tampilkanDetailModal(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Usaha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usaha.namaUsaha.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFFA500), // Orange BPS
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'IDSBR: ${usaha.idsbr}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Alamat lengkap: alamat, desa, kecamatan, kabupaten
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatAlamat(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Badge Wilayah dan Skala Usaha
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (usaha.nmkab.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA500).withValues(alpha: 0.1),
                              border: Border.all(color: const Color(0xFFFFA500)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              usaha.nmkab,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFFA500),
                              ),
                            ),
                          ),
                        if (usaha.skalaUsaha.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                              border: Border.all(color: const Color(0xFF1976D2)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              usaha.skalaUsaha,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Lokasi — aktif jika punya koordinat
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.map,
                  // Warna berubah tergantung ada/tidaknya koordinat
                  color: usaha.punyaKoordinat
                      ? const Color(0xFFFFA500)
                      : Colors.grey.shade300,
                ),
                tooltip: usaha.punyaKoordinat
                    ? 'Lihat Lokasi (${usaha.koordinatTeks})'
                    : 'Koordinat tidak tersedia',
                style: IconButton.styleFrom(
                  backgroundColor: usaha.punyaKoordinat
                      ? const Color(0xFFFFA500).withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: usaha.punyaKoordinat
                    ? () {
                        // Pindah ke dashboard dan kirim data usaha
                        context.go('/dashboard', extra: usaha);
                      }
                    : null, // Nonaktifkan tombol jika tidak ada koordinat
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gabungkan alamat, desa, kecamatan menjadi satu string yang rapi.
  /// Hanya tampilkan bagian yang tidak kosong.
  String _formatAlamat() {
    final bagian = <String>[
      if (usaha.alamatUsaha.isNotEmpty) usaha.alamatUsaha,
      if (usaha.nmdesa.isNotEmpty) usaha.nmdesa,
      if (usaha.nmkec.isNotEmpty) 'Kec. ${usaha.nmkec}',
    ];
    return bagian.isNotEmpty ? bagian.join(', ') : 'Alamat tidak tersedia';
  }

  /// Menampilkan popup dialog modern dengan semua data usaha
  void _tampilkanDetailModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _BuildIsiDialog(usaha: usaha, konteksAwal: context),
        );
      },
    );
  }
}

/// Widget helper untuk isi dialog agar UI tetap rapi
class _BuildIsiDialog extends StatelessWidget {
  final UsahaModel usaha;
  final BuildContext konteksAwal;

  const _BuildIsiDialog({required this.usaha, required this.konteksAwal});

  @override
  Widget build(BuildContext context) {
    const Color orangeBps = Color(0xFFFFA500);
    const Color navyBps = Color(0xFF1A1A2E);

    return Container(
      width: 450, // Max width agar aman di web
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER DIALOG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: navyBps,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: orangeBps),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Perusahaan',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usaha.namaUsaha.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          // ISI DIALOG
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identitas & Badge
                Row(
                  children: [
                    _buildBadge('IDSBR', usaha.idsbr, Icons.tag_rounded, Colors.grey.shade700),
                    const SizedBox(width: 12),
                    if (usaha.skalaUsaha.isNotEmpty)
                      _buildBadge('Skala', usaha.skalaUsaha, Icons.business_center_rounded, const Color(0xFF1976D2)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Detail Data Alamat & Lokasi
                const Text(
                  'ALAMAT & WILAYAH',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildBarisInfo(Icons.location_city_rounded, 'Alamat', usaha.alamatUsaha.isEmpty ? '-' : usaha.alamatUsaha),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBarisInfo(Icons.map_rounded, 'Desa/Kel', usaha.nmdesa.isEmpty ? '-' : usaha.nmdesa)),
                    Expanded(child: _buildBarisInfo(Icons.apartment_rounded, 'Kecamatan', usaha.nmkec.isEmpty ? '-' : usaha.nmkec)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildBarisInfo(Icons.account_balance_rounded, 'Kab/Kota', usaha.nmkab.isEmpty ? '-' : usaha.nmkab),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                const Text(
                  'DATA GEOGRASIF',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBarisInfo(
                        Icons.explore_rounded, 
                        'Garis Lintang (Lat)', 
                        usaha.latitudeGc?.toString() ?? 'Tidak ada',
                        isError: usaha.latitudeGc == null,
                      ),
                    ),
                    Expanded(
                      child: _buildBarisInfo(
                        Icons.explore_outlined, 
                        'Garis Bujur (Long)', 
                        usaha.longitudeGc?.toString() ?? 'Tidak ada',
                        isError: usaha.longitudeGc == null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FOOTER / ACTION DIALOG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: usaha.punyaKoordinat
                      ? () {
                          // Tutup popup lalu pindah map
                          Navigator.of(context).pop();
                          konteksAwal.go('/dashboard', extra: usaha);
                        }
                      : null,
                  icon: const Icon(Icons.location_on_rounded, size: 18),
                  label: const Text('Lihat di Peta', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeBps,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisInfo(IconData icon, String title, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: isError ? Colors.red.shade300 : Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isError ? Colors.red.shade400 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
