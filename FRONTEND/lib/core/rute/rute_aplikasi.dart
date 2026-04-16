import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_bloc.dart';

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
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      
      final bool isGoingToLogin = state.uri.toString() == '/login' || state.uri.toString() == '/forget-password';
      final bool isLoggedIn = authState is AuthAuthenticated;

      // Jika belum login dan mencoba masuk halaman selain login -> tendang ke login
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // Jika sudah login tapi mencoba masuk ke halaman login/register -> tendang ke dashboard
      if (isLoggedIn && isGoingToLogin) {
        return '/dashboard';
      }

      // Biarkan rute berjalan normal
      return null;
    },
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
