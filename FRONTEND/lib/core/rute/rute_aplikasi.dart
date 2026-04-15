import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/direktori_usaha/direktori_usaha.dart';
import '../../features/data_petugas/data_petugas_halaman.dart';
import '../../features/monitoring_progres/monitoring_progres_halaman.dart';
import '../../features/halaman_utama.dart';
import '../../features/halaman_login.dart';
import '../../features/halaman_forget_password.dart';

class RuteAplikasi {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    // Rute awal yang dibuka
    initialLocation: '/login',
    routes: [
      // Rute Login (diluar ShellRoute agar tidak ada sidebar)
      GoRoute(
        path: '/login',
        builder: (context, state) => const HalamanLogin(),
      ),
      GoRoute(
        path: '/forget-password',
        builder: (context, state) => const HalamanForgetPassword(),
      ),
      
      // ShellRoute digunakan agar Sidebar tetap diam, 
      // dan konten sebelah kanan saja yang berubah (Nested Navigation)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HalamanUtama(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) {
              final usaha = state.extra as UsahaModel?;
              return DashboardPage(usahaTerpilih: usaha);
            },
          ),
          GoRoute(
            path: '/direktori',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const DirektoriHalaman(),
          ),
          GoRoute(
            path: '/petugas',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const DataPetugasHalaman(),
          ),
          GoRoute(
            path: '/monitoring',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const MonitoringProgresHalaman(),
          ),
        ],
      ),
    ],
  );
}
