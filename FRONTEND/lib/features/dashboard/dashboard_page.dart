import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/peta_dashboard.dart';
import '../direktori_usaha/direktori_usaha.dart';

// ─── Konstanta Warna BPS ───────────────────────────────────────
const _kOrange      = Color(0xFFFFA500);
const _kOrangeDark  = Color(0xFFE69500);
const _kOrangeLight = Color(0xFFFFF3E0);
const _kNavy        = Color(0xFF1A1A2E);

class DashboardPage extends StatefulWidget {
  final UsahaModel? usahaTerpilih;
  const DashboardPage({super.key, this.usahaTerpilih});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isMapMaximized = false;
  bool _hasAutoSelected = false;
  late DirektoriBloc _direktoriBloc;

  @override
  void initState() {
    super.initState();
    _direktoriBloc = DirektoriBloc(DirektoriService())
      ..add(AmbilSemuaUntukPetaEvent());
  }

  @override
  void dispose() {
    _direktoriBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _direktoriBloc,
      child: BlocListener<DirektoriBloc, DirektoriState>(
        listener: (context, state) {
          if (state is DirektoriLoaded &&
              !_hasAutoSelected &&
              widget.usahaTerpilih != null) {
            _hasAutoSelected = true;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _direktoriBloc.add(PilihUsahaEvent(widget.usahaTerpilih!));
              }
            });
          }
        },
        child: Container(
          color: const Color(0xFFF5F6FA),
          padding: _isMapMaximized
              ? EdgeInsets.zero
              : const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = MediaQuery.of(context).size.width < 600;
              final bool isTablet = MediaQuery.of(context).size.width < 1100 && !isMobile;

              if (_isMapMaximized) {
                return _buildMapCard();
              }

              if (isMobile || isTablet) {
                // Layar kecil: buat scrollable sepenuhnya, beri tinggi peta statis agar tidak crash
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildStatCards(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 500, // Tinggi peta statis untuk mobile
                        width: double.infinity,
                        child: _buildMapCard(),
                      ),
                    ],
                  ),
                );
              }

              // Layar besar (Desktop): Gunakan Column & Expanded (tidak perlu scroll)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(),
                   const SizedBox(height: 20),
                   _buildStatCards(),
                   const SizedBox(height: 20),
                   Expanded(child: _buildMapCard()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    Widget badgeBPS = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _kOrangeLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kOrange.withOpacity(0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, color: _kOrange, size: 17),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'BPS Kab. Kepulauan Selayar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kOrangeDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Aksen garis oranye vertikal kiri
            Container(
              width: 5,
              height: 46,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monitoring Pemetaan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _kNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Sebaran usaha berdasarkan lokasi geografis Kabupaten Kepulauan Selayar',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Jika BUKAN mobile, tampilkan Badge BPS di kanan baris ini
            if (!isMobile) ...[
              const SizedBox(width: 16),
              badgeBPS,
            ],
          ],
        ),
        // Jika mobile, tampilkan Badge BPS di bawah judul
        if (isMobile) ...[
          const SizedBox(height: 12),
          badgeBPS,
        ],
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  STAT CARDS
  // ════════════════════════════════════════════════════════════

  Widget _buildStatCards() {
    final bool isTablet = MediaQuery.of(context).size.width < 1100;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    Widget card1 = _StatCard(
      icon: Icons.badge_rounded,
      label: 'Total Petugas',
      value: '120',
      warna: const Color(0xFF1976D2),
      warnaBackground: const Color(0xFFE3F2FD),
      trailing: _trendWidget('+5%', naik: true),
    );

    Widget card2 = BlocBuilder<DirektoriBloc, DirektoriState>(
      builder: (context, state) {
        String total = '—';
        Widget? sub;
        if (state is DirektoriLoading) {
          total = '...';
        } else if (state is DirektoriLoaded) {
          total = state.totalData.toString();
          final n = state.daftarUsaha.where((u) => u.punyaKoordinat).length;
          sub = Text('$n ber-koordinat',
              style: const TextStyle(
                  fontSize: 11, color: _kOrangeDark, fontWeight: FontWeight.w600));
        } else if (state is DirektoriError) {
          total = '!';
        }
        return _StatCard(
          icon: Icons.storefront_rounded,
          label: 'Total Usaha',
          value: total,
          warna: _kOrange,
          warnaBackground: _kOrangeLight,
          trailing: sub,
        );
      },
    );

    Widget card3 = BlocBuilder<DirektoriBloc, DirektoriState>(
      builder: (context, state) {
        String aktif = '—';
        Widget? badge;
        if (state is DirektoriLoaded) {
          aktif = state.daftarUsaha.where((u) => u.punyaKoordinat).length.toString();
          if (!state.filterSaatIni.isEmpty) {
            badge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Filter ON',
                  style: TextStyle(
                      fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }
        }
        return _StatCard(
          icon: Icons.location_on_rounded,
          label: 'Marker di Peta',
          value: aktif,
          warna: const Color(0xFF2E7D32),
          warnaBackground: const Color(0xFFE8F5E9),
          trailing: badge,
        );
      },
    );

    Widget card4 = _StatCard(
      icon: Icons.map_rounded,
      label: 'Kecamatan',
      value: '11',
      warna: const Color(0xFF6A1B9A),
      warnaBackground: const Color(0xFFF3E5F5),
      trailing: const Text(
        'Kab. Kepulauan Selayar',
        style: TextStyle(
            fontSize: 10,
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (isMobile) {
      // Pada layar mobile, gunakan grid 2x2 agar lebih ringkas
      return Column(
        children: [
          Row(
            children: [Expanded(child: card1), const SizedBox(width: 12), Expanded(child: card2)],
          ),
          const SizedBox(height: 12),
          Row(
            children: [Expanded(child: card3), const SizedBox(width: 12), Expanded(child: card4)],
          ),
        ],
      );
    } else if (isTablet) {
      // Pada tablet, gunakan grid 2x2
      return Column(
        children: [
          Row(
            children: [Expanded(child: card1), const SizedBox(width: 16), Expanded(child: card2)],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: card3), const SizedBox(width: 16), Expanded(child: card4)],
          ),
        ],
      );
    }

    // Default desktop: sebaris 1x4
    return Row(
      children: [
        Expanded(child: card1),
        const SizedBox(width: 16),
        Expanded(child: card2),
        const SizedBox(width: 16),
        Expanded(child: card3),
        const SizedBox(width: 16),
        Expanded(child: card4),
      ],
    );
  }

  Widget _trendWidget(String label, {required bool naik}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(naik ? Icons.trending_up : Icons.trending_down,
            size: 13, color: naik ? Colors.green : Colors.red),
        const SizedBox(width: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: naik ? Colors.green : Colors.red)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  MAP CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildMapCard() {
    return Container(
      decoration: _isMapMaximized
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius:
            _isMapMaximized ? BorderRadius.zero : BorderRadius.circular(16),
        child: Stack(
          children: [
            const PetaDashboard(),

            // Tombol fullscreen
            Positioned(
              top: 12,
              right: 12,
              child: _MapControlButton(
                heroTag: 'btnToggleMaximize',
                icon: _isMapMaximized
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                tooltip: _isMapMaximized ? 'Kecilkan Peta' : 'Perbesar Peta',
                onTap: () => setState(() => _isMapMaximized = !_isMapMaximized),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  KOMPONEN REUSABLE
// ════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color warna;
  final Color warnaBackground;
  final Widget? trailing;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.warna,
    required this.warnaBackground,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: warna.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: warnaBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: warna, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _kNavy,
              height: 1,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 5),
            trailing!,
          ],
          const SizedBox(height: 10),
          // Progress bar dekoratif
          Stack(
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: warna.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.heroTag,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

