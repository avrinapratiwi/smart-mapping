import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_bloc.dart';

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

      Widget innerContent = MediaQuery.removePadding(
        context: context,
        removeTop: true, // Hapus padding default agar header mencapai area atas status bar
        child: CustomScrollView(
          scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          slivers: [
            SliverToBoxAdapter(
              child: _buildSidebarHeader(isCollapsed, isDrawer),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 4 : 12, // Kurangi margin jika diringkas agar pas di 78px
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 16), // Pemisah antara menu utama dan action bawah
                    _buildLogoutItem(isCollapsed: isCollapsed, isDrawer: isDrawer, context: context),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isDrawer) _buildUserProfile(isCollapsed),
                  _buildSidebarFooter(isCollapsed),
                ],
              ),
            ),
          ],
        ),
      );

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: isDrawer ? null : (isCollapsed ? 78 : 260),
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
        child: isDrawer
            ? innerContent
            : ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: isCollapsed ? 78 : 260,
                  maxWidth: isCollapsed ? 78 : 260,
                  child: innerContent,
                ),
              ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Jika statusnya kembali ke awal (Initial/Belum login) maka tendang ke halaman login
        if (state is AuthInitial) {
          context.go('/login');
        }
      },
      child: Scaffold(
      // Tampilkan AppBar pada layar mobile
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: _kNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              // Ikon burger otomatis ditambahkan oleh Scaffold jika ada drawer
              title: const Text(
                'Smart Mapping',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: _kOrange.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, color: _kOrange, size: 18),
                  ),
                ),
              ],
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SIDEBAR HEADER — Logo + App name + Toggle
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSidebarHeader(bool isCollapsed, bool isDrawer) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 14 : 20,
        topPadding + 24, // Tambahkan padding top layar agar background warna penuh
        isCollapsed ? 14 : 16,
        16,
      ),
      decoration: BoxDecoration(
        color: _kNavyLight,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hover Toggle Logo for collapsed desktop
          if (isCollapsed && !isDrawer)
            Expanded(child: Center(child: _SidebarLogoHoverToggle(onTap: _toggleSidebar)))
          else
            Image.asset(
              'assets/logoAplikasi.png',
              width: 42,
              height: 42,
              fit: BoxFit.contain,
            ),
            
          // Close icon for Drawer (Mobile) or App title + Close icon for Desktop Header
          if (isDrawer) ...[
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
                splashRadius: 20,
                hoverColor: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ] else if (!isCollapsed) ...[
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Smart Mapping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: _toggleSidebar,
                icon: const Icon(Icons.close_rounded, color: Colors.white54),
                splashRadius: 20,
                hoverColor: Colors.white.withValues(alpha: 0.1),
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

  Widget _buildLogoutItem({
    required bool isCollapsed,
    required bool isDrawer,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (isDrawer) {
              Navigator.of(context).pop();
            }
            // Trigger logut
            context.read<AuthBloc>().add(LogoutRequested());
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.red.withValues(alpha: 0.1),
          splashColor: Colors.red.withValues(alpha: 0.2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 14 : 16,
              vertical: 13,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: Colors.redAccent,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
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
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
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
  //  USER PROFILE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUserProfile(bool isCollapsed) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : 20,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _kOrange.withValues(alpha: 0.15),
            child: const Icon(Icons.person_rounded, color: _kOrange, size: 20),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Petugas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '73060002-Budi Santoso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SIDEBAR FOOTER — BPS Branding
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSidebarFooter(bool isCollapsed) {
    if (isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo-bps-sulsel.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Image.asset(
              'assets/logo-sensus-ekonomi.png',
              height: 32,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.asset(
              'assets/logo-bps-sulsel.png',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Image.asset(
              'assets/logo-sensus-ekonomi.png',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  KOMPONEN: Hover Toggle Logo
// ═══════════════════════════════════════════════════════════════

class _SidebarLogoHoverToggle extends StatefulWidget {
  final VoidCallback onTap;
  const _SidebarLogoHoverToggle({required this.onTap});

  @override
  State<_SidebarLogoHoverToggle> createState() => _SidebarLogoHoverToggleState();
}

class _SidebarLogoHoverToggleState extends State<_SidebarLogoHoverToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isHovered
              ? const SizedBox(
                  key: ValueKey('burger'),
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                )
              : Image.asset(
                  'assets/logoAplikasi.png',
                  key: const ValueKey('logo'),
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
