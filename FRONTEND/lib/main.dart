import 'package:flutter/material.dart';
import 'core/rute/rute_aplikasi.dart';

Future<void> main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Jalankan aplikasi setelah inisialisasi selesai
  runApp(const AplikasiSmartMapping());
}

class AplikasiSmartMapping extends StatelessWidget {
  const AplikasiSmartMapping({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Mapping SE2026',
      debugShowCheckedModeBanner: false,
      // Tetap menggunakan konfigurasi router kamu
      routerConfig: RuteAplikasi.router,
      // Memberikan tema dasar agar nyaman dilihat
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
    );
  }
}
