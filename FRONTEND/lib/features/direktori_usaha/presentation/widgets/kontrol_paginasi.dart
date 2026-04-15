import 'package:flutter/material.dart';

/// Widget kontrol pagination: navigator halaman dan pilihan jumlah per halaman.
/// Menampilkan:
/// - Dropdown pilih perHalaman (10 / 50 / 100)
/// - Info "X - Y dari Z data"
/// - Tombol navigasi: First, Prev, nomor halaman, Next, Last
class KontrolPaginasi extends StatelessWidget {
  final int halamanSaatIni;
  final int totalHalaman;
  final int perHalaman;
  final int totalData;
  final int dataMulai;
  final int dataSampai;
  final void Function(int halaman) onGantiHalaman;
  final void Function(int perHalaman) onGantiPerHalaman;

  static const List<int> _pilihanPerHalaman = [10, 50, 100];
  static const Color _warnaOrange = Color(0xFFFFA500);

  const KontrolPaginasi({
    super.key,
    required this.halamanSaatIni,
    required this.totalHalaman,
    required this.perHalaman,
    required this.totalData,
    required this.dataMulai,
    required this.dataSampai,
    required this.onGantiHalaman,
    required this.onGantiPerHalaman,
  });

  /// Hitung nomor halaman yang ditampilkan di sekitar halaman aktif
  List<int> _halamanYangDitampilkan() {
    const int maxTampil = 5;
    if (totalHalaman <= maxTampil) {
      return List.generate(totalHalaman, (i) => i + 1);
    }
    int mulai = halamanSaatIni - 2;
    int selesai = halamanSaatIni + 2;
    if (mulai < 1) {
      mulai = 1;
      selesai = maxTampil;
    }
    if (selesai > totalHalaman) {
      selesai = totalHalaman;
      mulai = totalHalaman - maxTampil + 1;
    }
    return List.generate(selesai - mulai + 1, (i) => i + mulai);
  }

  @override
  Widget build(BuildContext context) {
    final halamanList = _halamanYangDitampilkan();
    final bool bisaKiri = halamanSaatIni > 1;
    final bool bisaKanan = halamanSaatIni < totalHalaman;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // ── Pilihan jumlah per halaman ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tampilkan:',
                style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: perHalaman,
                    isDense: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: _warnaOrange,
                      size: 20,
                    ),
                    items: _pilihanPerHalaman.map((int nilai) {
                      return DropdownMenuItem<int>(
                        value: nilai,
                        child: Text(
                          '$nilai',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? nilai) {
                      if (nilai != null && nilai != perHalaman) {
                        onGantiPerHalaman(nilai);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'data per halaman',
                style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
              ),
            ],
          ),

          // ── Navigator Halaman dan Info Data──
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              // Info "X - Y dari Z data"
              Text(
                '$dataMulai - $dataSampai dari $totalData data',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Navigator Halaman
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol First
                  _TombolNavigasi(
                    icon: Icons.first_page,
                    aktif: bisaKiri,
                    tooltip: 'Halaman Pertama',
                    onTap: () => onGantiHalaman(1),
                  ),
                  const SizedBox(width: 4),
                  // Tombol Prev
                  _TombolNavigasi(
                    icon: Icons.chevron_left,
                    aktif: bisaKiri,
                    tooltip: 'Halaman Sebelumnya',
                    onTap: () => onGantiHalaman(halamanSaatIni - 1),
                  ),
                  const SizedBox(width: 4),

                  // Ellipsis awal jika halaman pertama tidak tampil
                  if (halamanList.first > 1) ...[
                    const _TombolEllipsis(),
                    const SizedBox(width: 4),
                  ],

                  // Nomor halaman
                  ...halamanList.map((h) {
                    final bool aktif = h == halamanSaatIni;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _TombolHalaman(
                        nomor: h,
                        aktif: aktif,
                        onTap: aktif ? null : () => onGantiHalaman(h),
                      ),
                    );
                  }),

                  // Ellipsis akhir jika halaman terakhir tidak tampil
                  if (halamanList.last < totalHalaman) ...[
                    const _TombolEllipsis(),
                    const SizedBox(width: 4),
                  ],

                  // Tombol Next
                  _TombolNavigasi(
                    icon: Icons.chevron_right,
                    aktif: bisaKanan,
                    tooltip: 'Halaman Berikutnya',
                    onTap: () => onGantiHalaman(halamanSaatIni + 1),
                  ),
                  const SizedBox(width: 4),
                  // Tombol Last
                  _TombolNavigasi(
                    icon: Icons.last_page,
                    aktif: bisaKanan,
                    tooltip: 'Halaman Terakhir',
                    onTap: () => onGantiHalaman(totalHalaman),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget: Tombol navigasi panah ──────────────────────────────
class _TombolNavigasi extends StatelessWidget {
  final IconData icon;
  final bool aktif;
  final String tooltip;
  final VoidCallback onTap;

  const _TombolNavigasi({
    required this.icon,
    required this.aktif,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: aktif ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: aktif ? const Color(0xFFE0E0E0) : const Color(0xFFF5F5F5),
            ),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Icon(
            icon,
            size: 18,
            color: aktif ? const Color(0xFF424242) : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

// ── Widget: Tombol nomor halaman ───────────────────────────────
class _TombolHalaman extends StatelessWidget {
  final int nomor;
  final bool aktif;
  final VoidCallback? onTap;

  const _TombolHalaman({required this.nomor, required this.aktif, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFFFFA500) : Colors.white,
          border: Border.all(
            color: aktif ? const Color(0xFFFFA500) : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$nomor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
            color: aktif ? Colors.white : const Color(0xFF424242),
          ),
        ),
      ),
    );
  }
}

// ── Widget: Ellipsis "..." ─────────────────────────────────────
class _TombolEllipsis extends StatelessWidget {
  const _TombolEllipsis();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: const Text('...', style: TextStyle(color: Colors.grey)),
    );
  }
}
