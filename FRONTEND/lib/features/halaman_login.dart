import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Konstanta Warna Tema
const _kNavy = Color(0xFF1A1A2E);
const _kOrange = Color(0xFFFFA500);

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _selectedRole;

  void _login() {
    // Aksi login sementara, langsung pindah ke dashboard
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background abu-abu seperti permintaan
      backgroundColor: Colors.grey[200],
      body: Center(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ROW untuk 3 LOGO
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo 1: Aplikasi (Paling Kiri)
                          Image.asset(
                            'assets/logoAplikasi.png',
                            height: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                          ),
                          
                          const SizedBox(width: 16),
                          // Garis Pemisah Tipis
                          Container(width: 1.5, height: 45, color: Colors.grey[300]),
                          const SizedBox(width: 16),
                          
                          // Logo 2: BPS Prov Sulsel (Tengah)
                          Image.asset(
                            'assets/logo-bps-sulsel.png',
                            height: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                          ),
                          
                          const SizedBox(width: 16),
                          // Garis Pemisah Tipis
                          Container(width: 1.5, height: 45, color: Colors.grey[300]),
                          const SizedBox(width: 16),
                          
                          // Logo 3: SE2026 (Paling Kanan)
                          Image.asset(
                            'assets/logo-sensus-ekonomi.png',
                            height: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 70, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    
                    // LOGIN TITLE (Lebih besar dan menarik dengan gradient / bold)
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_kNavy, Color(0xFF3A4276)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Dibutuhkan agar ShaderMask bekerja
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Masuk ke akun Anda untuk melanjutkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),
                    
                    // Input Username
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan username',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _kOrange, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Input Password
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _kOrange, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Input Role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownMenu<String>(
                              width: constraints.maxWidth,
                              initialSelection: _selectedRole,
                              hintText: 'Pilih role Anda',
                              textStyle: const TextStyle(fontSize: 14, color: _kNavy),
                              inputDecorationTheme: InputDecorationTheme(
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _kOrange, width: 2),
                                ),
                              ),
                              menuStyle: MenuStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.white),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                elevation: WidgetStateProperty.all(8),
                              ),
                              onSelected: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                              dropdownMenuEntries: ['Petugas', 'Admin kab/kot', 'Super Admin']
                                  .map(
                                    (role) => DropdownMenuEntry<String>(
                                      value: role,
                                      label: role,
                                      style: MenuItemButton.styleFrom(
                                        foregroundColor: _kNavy,
                                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ).copyWith(
                                        overlayColor: WidgetStateProperty.resolveWith((states) {
                                          if (states.contains(WidgetState.hovered)) {
                                            return _kOrange.withValues(alpha: 0.15);
                                          }
                                          if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
                                            return _kOrange.withValues(alpha: 0.2);
                                          }
                                          return null;
                                        }),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Forget Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/forget-password'),
                        style: TextButton.styleFrom(
                          foregroundColor: _kOrange,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forget password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 36),
                    
                    // Login Button => "Sign in" dengan Arrow
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
