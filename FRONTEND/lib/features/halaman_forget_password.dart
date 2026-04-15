import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Konstanta Warna Tema
const _kNavy = Color(0xFF1A1A2E);
const _kOrange = Color(0xFFFFA500);

class HalamanForgetPassword extends StatefulWidget {
  const HalamanForgetPassword({super.key});

  @override
  State<HalamanForgetPassword> createState() => _HalamanForgetPasswordState();
}

class _HalamanForgetPasswordState extends State<HalamanForgetPassword> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _resetPassword() {
    // Implementasi reset password nantinya
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui.')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      // Logo Row
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/logoAplikasi.png', height: 60),
                            const SizedBox(width: 16),
                            Container(
                              width: 1.5,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(width: 16),
                            Image.asset(
                              'assets/logo-bps-sulsel.png',
                              height: 60,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 1.5,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(width: 16),
                            Image.asset(
                              'assets/logo-sensus-ekonomi.png',
                              height: 60,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_kNavy, Color(0xFF3A4276)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Silakan lengkapi data di bawah ini untuk memperbarui kata sandi Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Input Password Lama
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        label: 'Password Lama',
                        hint: 'Masukkan password lama',
                        isVisible: _isOldPasswordVisible,
                        onToggle: () => setState(
                          () => _isOldPasswordVisible = !_isOldPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Password Baru
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Password Baru',
                        hint: 'Masukkan password baru',
                        isVisible: _isNewPasswordVisible,
                        onToggle: () => setState(
                          () => _isNewPasswordVisible = !_isNewPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Konfirmasi Password Baru
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Konfirmasi Password Baru',
                        hint: 'Ulangi password baru',
                        isVisible: _isConfirmPasswordVisible,
                        onToggle: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Back to Login
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Kembali ke Halaman Login',
                          style: TextStyle(
                            color: _kOrange,
                            fontWeight: FontWeight.bold,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: Colors.grey[600],
              ),
              onPressed: onToggle,
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
    );
  }
}
