import 'package:firebase_auth/firebase_auth.dart';

/// ============================================================
/// AUTH SERVICE — Mengelola semua operasi autentikasi pengguna
/// menggunakan Firebase Authentication.
///
/// Fitur:
/// - Register (Sign Up) dengan email & password
/// - Login (Sign In) dengan email & password
/// - Logout (Sign Out)
/// - Mendapatkan user yang sedang login
/// - Stream perubahan status autentikasi
/// ============================================================

class AuthService {
  /// Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mendapatkan user yang sedang login saat ini.
  /// Mengembalikan null jika tidak ada user yang login.
  User? get currentUser => _auth.currentUser;

  /// Stream yang memancarkan perubahan status autentikasi.
  /// Digunakan untuk auto-redirect antara Login dan Home page.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// REGISTER — Membuat akun baru dengan email dan password.
  ///
  /// [email] - Email pengguna baru
  /// [password] - Password pengguna baru (minimal 6 karakter)
  ///
  /// Mengembalikan [UserCredential] jika berhasil.
  /// Melempar [FirebaseAuthException] jika gagal.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Menerjemahkan error code Firebase ke pesan yang mudah dipahami
      throw _handleAuthError(e.code);
    }
  }

  /// LOGIN — Masuk ke akun dengan email dan password.
  ///
  /// [email] - Email pengguna
  /// [password] - Password pengguna
  ///
  /// Mengembalikan [UserCredential] jika berhasil.
  /// Melempar [String] error message jika gagal.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  /// LOGOUT — Mengeluarkan user dari sesi saat ini.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Menerjemahkan Firebase Auth error codes ke pesan bahasa Indonesia
  /// yang ramah pengguna.
  String _handleAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
      case 'invalid-credential':
        return 'Email atau password salah. Silakan coba lagi.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi. ($code)';
    }
  }
}
