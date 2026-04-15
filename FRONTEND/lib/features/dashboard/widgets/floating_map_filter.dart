import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../direktori_usaha/direktori_usaha.dart';

/// ============================================================
/// FLOATING MAP FILTER BAR
/// ============================================================
///
/// Filter bar melayang di atas PetaDashboard.
/// Menggunakan Overlay (CompositedTransformTarget/Follower)
/// agar dropdown muncul tepat di bawah tombol yang ditekan.
///
/// Setiap perubahan filter mengirim [TerapkanFilterPetaEvent]
/// ke [DirektoriBloc] — filter diterapkan secara lokal dari
/// data cache (tidak re-fetch API) sehingga respons instan.
/// ============================================================

// --------------- Konstanta Data Wilayah -------------------------
const _kKabupaten = ['KEPULAUAN SELAYAR'];

const _kKecamatanPerKabupaten = <String, List<String>>{
  'KEPULAUAN SELAYAR': [
    'Benteng', 'Bontoharu', 'Bontomanai', 'Bontomatene',
    'Bontosikuyu', 'Buki', 'Pasilambena', 'Pasimarannu',
    'Pasimasunggu', 'Pasimasunggu Timur', 'Takabonerate',
  ],
};

const _kSkalaUsaha = ['UMKM', 'UB'];

class FloatingMapFilter extends StatefulWidget {
  const FloatingMapFilter({super.key});

  @override
  State<FloatingMapFilter> createState() => _FloatingMapFilterState();
}

class _FloatingMapFilterState extends State<FloatingMapFilter> {
  // ---- Overlay management ----
  OverlayEntry? _overlayEntry;
  String? _openPanel; // 'search' | 'wilayah' | 'skala' | null
  final _layerLink = LayerLink(); // shared link for all dropdowns

  // ---- Keys per tombol agar bisa anchor overlay ----
  final _keySearch  = GlobalKey();
  final _keyWilayah = GlobalKey();
  final _keySkala   = GlobalKey();

  // ---- State lokal (dipakai untuk membangun filter sebelum dispatch) ----
  final _ctrlCari = TextEditingController();
  String _kabupaten = 'Semua';
  String _kecamatan = 'Semua';
  String _skala     = 'Semua';

  @override
  void dispose() {
    _tutupOverlay();
    _ctrlCari.dispose();
    super.dispose();
  }

  // ================================================================
  //  OVERLAY HELPERS
  // ================================================================

  void _togglePanel(String panel, GlobalKey anchorKey) {
    if (_openPanel == panel) {
      _tutupOverlay();
      return;
    }
    _tutupOverlay();
    setState(() => _openPanel = panel);
    _overlayEntry = _buatOverlay(panel, anchorKey);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _tutupOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _openPanel = null);
  }

  OverlayEntry _buatOverlay(String panel, GlobalKey anchorKey) {
    final renderBox = anchorKey.currentContext!.findRenderObject() as RenderBox;
    final position  = renderBox.localToGlobal(Offset.zero);
    final size      = renderBox.size;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _tutupOverlay,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height + 8,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {}, // cegah tap menutup saat klik dalam panel
                  child: _buildPanelKonten(panel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelKonten(String panel) {
    switch (panel) {
      case 'search':  return _buildPanelSearch();
      case 'wilayah': return _buildPanelWilayah();
      case 'skala':   return _buildPanelSkala();
      default:        return const SizedBox.shrink();
    }
  }

  // ================================================================
  //  PANEL: SEARCH
  // ================================================================

  Widget _buildPanelSearch() {
    return _PanelWrapper(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PanelJudul(label: 'Cari Usaha'),
          TextField(
            controller: _ctrlCari,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'IDSBR atau Nama Usaha...',
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.orange),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onSubmitted: (_) => _terapkan(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _TombolBatal(onTap: () { _ctrlCari.clear(); _terapkan(); })),
            const SizedBox(width: 8),
            Expanded(child: _TombolTerapkan(onTap: _terapkan)),
          ]),
        ],
      ),
    );
  }

  // ================================================================
  //  PANEL: WILAYAH (Hierarki Kabupaten → Kecamatan)
  // ================================================================

  Widget _buildPanelWilayah() {
    final listKec = _kabupaten != 'Semua'
      ? (_kKecamatanPerKabupaten[_kabupaten] ?? [])
      : <String>[];

    return _PanelWrapper(
      width: 280,
      child: StatefulBuilder(builder: (ctx, setInner) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PanelJudul(label: 'Filter Wilayah'),
            const Text('Kabupaten / Kota', style: TextStyle(fontSize: 11, color: Colors.black45)),
            const SizedBox(height: 4),
            // Chips kabupaten
            Wrap(spacing: 6, runSpacing: 6,
              children: ['Semua', ..._kKabupaten].map((kab) {
                final aktif = _kabupaten == kab;
                return _Chip(
                  label: kab == 'Semua' ? 'Semua Kabupaten' : kab.titleCase,
                  aktif: aktif,
                  onTap: () {
                    setInner(() {
                      _kabupaten = kab;
                      _kecamatan = 'Semua'; // reset kecamatan
                    });
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            if (_kabupaten != 'Semua') ...[
              const SizedBox(height: 12),
              const Text('Kecamatan', style: TextStyle(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 6,
                children: ['Semua', ...listKec].map((kec) {
                  final aktif = _kecamatan == kec;
                  return _Chip(
                    label: kec == 'Semua' ? 'Semua Kecamatan' : kec,
                    aktif: aktif,
                    onTap: () {
                      setInner(() => _kecamatan = kec);
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _TombolBatal(onTap: () {
                setInner(() { _kabupaten = 'Semua'; _kecamatan = 'Semua'; });
                setState(() {});
                _terapkan();
              })),
              const SizedBox(width: 8),
              Expanded(child: _TombolTerapkan(onTap: _terapkan)),
            ]),
          ],
        );
      }),
    );
  }

  // ================================================================
  //  PANEL: SKALA USAHA
  // ================================================================

  Widget _buildPanelSkala() {
    return _PanelWrapper(
      width: 220,
      child: StatefulBuilder(builder: (ctx, setInner) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PanelJudul(label: 'Skala Usaha'),
            Wrap(spacing: 8, runSpacing: 8,
              children: ['Semua', ..._kSkalaUsaha].map((s) {
                final aktif = _skala == s;
                return _Chip(
                  label: s == 'Semua' ? 'Semua Skala' : s,
                  aktif: aktif,
                  onTap: () {
                    setInner(() => _skala = s);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _TombolBatal(onTap: () {
                setInner(() => _skala = 'Semua');
                setState(() {});
                _terapkan();
              })),
              const SizedBox(width: 8),
              Expanded(child: _TombolTerapkan(onTap: _terapkan)),
            ]),
          ],
        );
      }),
    );
  }

  // ================================================================
  //  DISPATCH EVENT KE BLOC
  // ================================================================

  void _terapkan() {
    _tutupOverlay();
    final teks = _ctrlCari.text.trim();
    final filter = FilterDirektori(
      namaUsaha:  teks.contains(RegExp(r'[a-zA-Z]{3,}')) ? teks : '',
      idsbr:      teks.replaceAll(RegExp(r'[^0-9]'), '').length > 5 ? teks : '',
      kabupaten:  _kabupaten,
      kecamatan:  _kecamatan,
      skalaUsaha: _skala,
    );
    context.read<DirektoriBloc>().add(TerapkanFilterPetaEvent(filter));
  }

  void _resetSemua() {
    _tutupOverlay();
    setState(() {
      _ctrlCari.clear();
      _kabupaten = 'Semua';
      _kecamatan = 'Semua';
      _skala     = 'Semua';
    });
    context.read<DirektoriBloc>().add(TerapkanFilterPetaEvent(const FilterDirektori()));
  }

  // ================================================================
  //  BUILD UTAMA
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DirektoriBloc, DirektoriState>(
      builder: (context, state) {
        final filter = state is DirektoriLoaded ? state.filterSaatIni : const FilterDirektori();
        final adaFilter = !filter.isEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Tombol Search ───
              _FilterButton(
                key: _keySearch,
                icon: Icons.search,
                label: filter.adaFilterCari ? '\"${filter.namaUsaha.isNotEmpty ? filter.namaUsaha : filter.idsbr}\"' : 'Cari',
                aktif: filter.adaFilterCari,
                terbuka: _openPanel == 'search',
                onTap: () => _togglePanel('search', _keySearch),
              ),
              const _Divider(),

              // ─── Tombol Wilayah ───
              _FilterButton(
                key: _keyWilayah,
                icon: Icons.location_city_rounded,
                label: filter.adaFilterWilayah
                  ? (filter.kecamatan != 'Semua' ? filter.kecamatan : filter.kabupaten.titleCase)
                  : 'Wilayah',
                aktif: filter.adaFilterWilayah,
                terbuka: _openPanel == 'wilayah',
                onTap: () => _togglePanel('wilayah', _keyWilayah),
              ),
              const _Divider(),

              // ─── Tombol Skala ───
              _FilterButton(
                key: _keySkala,
                icon: Icons.business_center_rounded,
                label: filter.adaFilterSkala ? filter.skalaUsaha : 'Skala',
                aktif: filter.adaFilterSkala,
                terbuka: _openPanel == 'skala',
                onTap: () => _togglePanel('skala', _keySkala),
              ),

              // ─── Tombol Reset (muncul hanya saat ada filter aktif) ───
              if (adaFilter) ...[
                const _Divider(),
                Tooltip(
                  message: 'Reset semua filter',
                  child: InkWell(
                    onTap: _resetSemua,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.filter_alt_off_rounded, size: 18, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ================================================================
//  KOMPONEN MINI (Private)
// ================================================================

/// Tombol filter individual
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool aktif;
  final bool terbuka;
  final VoidCallback onTap;

  const _FilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.aktif,
    required this.terbuka,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = aktif ? Colors.orange : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: aktif ? Colors.orange.shade50 : (terbuka ? Colors.grey.shade100 : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: aktif ? Border.all(color: Colors.orange.shade200) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 3),
            Icon(terbuka ? Icons.expand_less : Icons.expand_more, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

/// Wrapper container untuk panel dropdown
class _PanelWrapper extends StatelessWidget {
  final double width;
  final Widget child;

  const _PanelWrapper({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

/// Judul panel
class _PanelJudul extends StatelessWidget {
  final String label;
  const _PanelJudul({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

/// Chip pilihan filter
class _Chip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: aktif ? Colors.orange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: aktif ? Colors.orange : Colors.grey.shade300),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
            color: aktif ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// Divider vertikal antar tombol
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20, width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// Tombol Batal/Clear
class _TombolBatal extends StatelessWidget {
  final VoidCallback onTap;
  const _TombolBatal({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: const BorderSide(color: Colors.orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Reset', style: TextStyle(color: Colors.orange, fontSize: 12)),
    );
  }
}

/// Tombol Terapkan
class _TombolTerapkan extends StatelessWidget {
  final VoidCallback onTap;
  const _TombolTerapkan({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Terapkan', style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

// ================================================================
//  EXTENSION HELPERS
// ================================================================
extension on String {
  String get titleCase => split(' ')
    .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
    .join(' ');
}
