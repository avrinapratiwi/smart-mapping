import 'package:flutter/material.dart';

class LoginHalaman extends StatelessWidget {
  const LoginHalaman({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Halaman Autentikasi / Login',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
