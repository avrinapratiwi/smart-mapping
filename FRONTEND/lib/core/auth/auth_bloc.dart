import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================
// 1. EVENT (Aksi yang dilakukan oleh User)
// ============================================
abstract class AuthEvent {}

// Trigger saat aplikasi pertama dibuka / web di-refresh
class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String role;
  
  LoginRequested({
    required this.username,
    required this.password,
    required this.role,
  });
}

class LogoutRequested extends AuthEvent {}

// ============================================
// 2. STATE (Kondisi layarnya saat ini)
// ============================================
abstract class AuthState {}

class AuthInitial extends AuthState {} // Belum ngapa-ngapain
class AuthLoading extends AuthState {} // Sedang muter (loading API dummy)
class AuthAuthenticated extends AuthState {
  final String username;
  final String role;
  AuthAuthenticated(this.username, this.role);
} // Kunci sukses diturunkan

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
} // Password salah

// ============================================
// 3. BLOC (Otak penghubung Event -> State)
// ============================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    
    // Saat aplikasi memuat ulang (Refresh Web)
    on<CheckAuthStatus>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final savedUser = prefs.getString('saved_user') ?? '';
      final savedRole = prefs.getString('saved_role') ?? '';
      
      if (isLoggedIn) {
        emit(AuthAuthenticated(savedUser, savedRole));
      } else {
        emit(AuthInitial());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Suruh UI muter (loading)
      
      // Simulasi jeda waktu tembak API ke Server selama 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // LOGIKA ROLE: Tolak semua selain Super Admin
      if (event.role != 'Super Admin') {
        emit(AuthError('Akses Ditolak! Sementara ini hanya Role "Super Admin" yang diizinkan masuk.'));
        return;
      }
      
      // LOGIKA PALSU (DUMMY): 
      if (event.username == 'admin' && event.password == 'admin123') {
        // SIMPAN DATA LOGIN DALAM BROWSER MEMORY (COOKIE/LOCALSTORAGE)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('saved_user', event.username);
        await prefs.setString('saved_role', event.role);

        emit(AuthAuthenticated(event.username, event.role));
      } else {
        emit(AuthError('Username atau Password salah! (Hint: admin / admin123)'));
      }
    });

    on<LogoutRequested>((event, emit) async {
       emit(AuthLoading());
       
       // HAPUS INGATAN DARI BROWSER SAAT LOGOUT
       final prefs = await SharedPreferences.getInstance();
       await prefs.remove('is_logged_in');
       await prefs.remove('saved_user');
       await prefs.remove('saved_role');

       await Future.delayed(const Duration(milliseconds: 500));
       emit(AuthInitial()); // Balik ke status belum login
    });
  }
}
