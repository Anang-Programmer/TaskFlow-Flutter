import 'package:flutter/material.dart';

/// ============================================================
/// APP CONSTANTS — Warna, ukuran, dan style yang digunakan
/// secara konsisten di seluruh aplikasi TaskFlow.
/// ============================================================

class AppColors {
  // --- Primary Colors ---
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo-400
  static const Color primaryDark = Color(0xFF3730A3);    // Indigo-800

  // --- Accent / Secondary ---
  static const Color accent = Color(0xFFF59E0B);        // Amber-500
  static const Color accentLight = Color(0xFFFBBF24);   // Amber-400

  // --- Background ---
  static const Color background = Color(0xFFF8FAFC);    // Slate-50
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // --- Text ---
  static const Color textPrimary = Color(0xFF1E293B);   // Slate-800
  static const Color textSecondary = Color(0xFF64748B);  // Slate-500
  static const Color textHint = Color(0xFF94A3B8);       // Slate-400

  // --- Status Colors ---
  static const Color success = Color(0xFF10B981);        // Emerald-500
  static const Color error = Color(0xFFEF4444);          // Red-500
  static const Color warning = Color(0xFFF59E0B);        // Amber-500

  // --- Category Colors ---
  static const Color categoryPersonal = Color(0xFF8B5CF6); // Violet-500
  static const Color categoryWork = Color(0xFF3B82F6);     // Blue-500
  static const Color categoryStudy = Color(0xFF10B981);    // Emerald-500
}

class AppSizes {
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

/// Kategori tugas yang tersedia
class TaskCategories {
  static const String personal = 'personal';
  static const String work = 'work';
  static const String study = 'study';

  /// Mendapatkan label display untuk kategori
  static String getLabel(String category) {
    switch (category) {
      case personal:
        return 'Personal';
      case work:
        return 'Work';
      case study:
        return 'Study';
      default:
        return 'Other';
    }
  }

  /// Mendapatkan warna untuk kategori
  static Color getColor(String category) {
    switch (category) {
      case personal:
        return AppColors.categoryPersonal;
      case work:
        return AppColors.categoryWork;
      case study:
        return AppColors.categoryStudy;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Mendapatkan icon untuk kategori
  static IconData getIcon(String category) {
    switch (category) {
      case personal:
        return Icons.person_outline;
      case work:
        return Icons.work_outline;
      case study:
        return Icons.school_outlined;
      default:
        return Icons.label_outline;
    }
  }

  /// Daftar semua kategori
  static const List<String> all = [personal, work, study];
}
