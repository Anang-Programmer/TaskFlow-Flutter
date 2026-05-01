import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_page.dart';
import 'screens/home/home_page.dart';
import 'utils/constants.dart';

/// ============================================================
/// APP — Konfigurasi MaterialApp, tema, dan routing utama.
/// Menggunakan StreamBuilder untuk auto-redirect berdasarkan
/// status autentikasi (login/logout).
/// ============================================================

class TaskFlowApp extends StatelessWidget {
  TaskFlowApp({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // --- App Config ---
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,

      // --- Theme ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      ),

      // --- Auth-based Routing ---
      // StreamBuilder mendengarkan perubahan status login.
      // Jika user sudah login → tampilkan HomePage
      // Jika user belum login → tampilkan LoginPage
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          // Menunggu koneksi ke Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          // Cek apakah user sudah login
          if (snapshot.hasData) {
            return const HomePage();
          }

          // User belum login, tampilkan Login Page
          return const LoginPage();
        },
      ),
    );
  }
}
