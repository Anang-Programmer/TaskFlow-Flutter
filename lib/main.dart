import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

/// ============================================================
/// MAIN — Entry point aplikasi TaskFlow.
///
/// Menginisialisasi Firebase sebelum menjalankan aplikasi.
/// File firebase_options.dart akan otomatis di-generate oleh
/// FlutterFire CLI saat setup Firebase.
/// ============================================================

void main() async {
  // Pastikan Flutter binding sudah siap sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan konfigurasi dari firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Jalankan aplikasi
  runApp(TaskFlowApp());
}
