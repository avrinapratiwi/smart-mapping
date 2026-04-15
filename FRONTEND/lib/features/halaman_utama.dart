import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Konstanta Warna BPS
const _kNavy = Color(0xFF1A1A2E);
const _kNavyLight = Color(0xFF232946);
const _kOrange = Color(0xFFFFA500);
const _kOrangeLight = Color(0xFFFFF3E0);

class HalamanUtama extends StatefulWidget {
  final Widget child; // Widget dari route saat ini (ShellRoute)

  const HalamanUtama({super.key, required this.child});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // Status toggle Sidebar (buka/tutup)
  bool _isSidebarDipersingkat = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarDipersingkat = !_isSidebarDipersingkat;
    });
  }

  // Fungsi navigasi menu
  void _onMenuTapped(String rute, bool isDrawer) {
    if (isDrawer) {
      Navigator.of(context).pop(); // Tutup drawer jika diakses via mobile
    }
    context.go(rute);
  }

  @override
  Widget build(BuildContext context) {
    final ruteAktif = GoRouterState.of(context).uri.path;
    // Deteksi jika layar lebar (desktop/tablet landscape >= 800px)
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Fungsi helper untuk membangun konten sidebar
    Widget buildSidebarContent({required bool isDrawer}) {
      final isCollapsed = isDrawer ? false : _isSidebarDipersingkat;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: isCollapsed ? 78 : 260,
        decoration: const BoxDecoration(
          color: _kNavy,
          // Bayangan halus di sisi kanan sidebar
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(3, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HEADER SIDEBAR ──────────────────────────
              _buildSidebarHeader(isCollapsed, isDrawer),

              const SizedBox(height: 8),

              // ── NAVIGATION MENU ─────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      if (!isCollapsed)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            bottom: 10,
                            top: 4,
                          ),
                          child: Text(
                            'MENU UTAMA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.35),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                      _buildMenuItem(
                        ikon: Icons.dashboard_rounded,
                        judul: 'Dashboard',
                        rute: '/dashboard',
                        ruteAktif: ruteAktif,
                        isCollapsed: isCollapsed,
                        isDrawer: isDrawer,
                      ),
                      _buildMenuItem(
                        ikon: Icons.storefront_rounded,
                        judul: 'Direktori Usaha',
                        rute: '/direktori',
                        ruteAktif: ruteAktif,
                        isCollapsed: isCollapsed,
                        isDrawer: isDrawer,
                      ),
                      _buildMenuItem(
                        ikon: Icons.people_alt_rounded,
                        judul: 'Data Petugas',
                        rute: '/petugas',
                        ruteAktif: ruteAktif,
                        isCollapsed: isCollapsed,
                        isDrawer: isDrawer,
                      ),
                      _buildMenuItem(
                        ikon: Icons.analytics_rounded,
                        judul: 'Monitoring',
                        rute: '/monitoring',
                        ruteAktif: ruteAktif,
                        isCollapsed: isCollapsed,
                        isDrawer: isDrawer,
                      ),
                    ],
                  ),
                ),
              ),

              // ── FOOTER SIDEBAR ──────────────────────────
              _buildSidebarFooter(isCollapsed),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // Tampilkan AppBar pada layar mobile
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Smart Mapping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
      // Tampilkan Drawer pada layar mobile
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: Colors.transparent, // ikut ke warna AnimatedContainer
              child: buildSidebarContent(isDrawer: true),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Jika desktop, tampilkan sidebar sebagai bagian dari Row
          if (isDesktop) buildSidebarContent(isDrawer: false),
          
          // Konten Utama (Berubah sesuai navigasi ShellRoute)
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SIDEBAR HEADER — Logo + App name + Toggle
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSidebarHeader(bool isCollapsed, bool isDrawer) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 14 : 20,
        24,
        isCollapsed ? 14 : 16,
        16,
      ),
      decoration: BoxDecoration(
        color: _kNavyLight,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo Aplikasi
              Container(
                width: isCollapsed ? 42 : 48,
                height: isCollapsed ? 42 : 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/logoAplikasi.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // App title — Tersembunyi saat sidebar mengecil
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Mapping',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sensus Ekonomi 2026',
                        style: TextStyle(
                          color: _kOrange.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Jangan tampilkan tombol perkecil menu jika sedang dalam bentuk Drawer (Mobile)
          if (!isDrawer) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _SidebarToggleButton(
                isCollapsed: isCollapsed,
                onTap: _toggleSidebar,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MENU ITEM
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMenuItem({
    required IconData ikon,
    required String judul,
    required String rute,
    required String ruteAktif,
    required bool isCollapsed,
    required bool isDrawer,
  }) {
    final isSelected = ruteAktif == rute;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _onMenuTapped(rute, isDrawer),
          borderRadius: BorderRadius.circular(12),
          splashColor: _kOrange.withValues(alpha: 0.15),
          hoverColor: Colors.white.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 14 : 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? _kOrange.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: _kOrange.withValues(alpha: 0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Ikon dengan container melingkar saat aktif
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kOrange
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    ikon,
                    size: 19,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      judul,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  // Indikator aktif — panah kecil
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SIDEBAR FOOTER — BPS Branding
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSidebarFooter(bool isCollapsed) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: isCollapsed
          // Versi minimal — hanya ikon BPS
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: _kOrange,
                  size: 16,
                ),
              ),
            )
          // Versi penuh — copyright text
          : Column(
              children: [
                // Divider dekoratif
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _kOrange.withValues(alpha: 0.0),
                        _kOrange.withValues(alpha: 0.4),
                        _kOrange.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: _kOrange,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '© 2026 BPS Sulsel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  KOMPONEN: Tombol Toggle Sidebar
// ═══════════════════════════════════════════════════════════════

class _SidebarToggleButton extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarToggleButton({required this.isCollapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCollapsed
                    ? Icons.keyboard_double_arrow_right_rounded
                    : Icons.keyboard_double_arrow_left_rounded,
                color: Colors.white54,
                size: 18,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 6),
                const Text(
                  'Perkecil Menu',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
