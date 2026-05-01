import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// ============================================================
/// CUSTOM TEXT FIELD — Widget TextField yang sudah di-style
/// secara konsisten untuk digunakan di seluruh aplikasi.
/// Digunakan di Login, Register, dan Task Form page.
/// ============================================================

class CustomTextField extends StatelessWidget {
  /// Controller untuk mengambil/mengatur nilai text
  final TextEditingController controller;

  /// Label yang muncul di atas field
  final String label;

  /// Hint text di dalam field
  final String? hintText;

  /// Icon di sebelah kiri field
  final IconData? prefixIcon;

  /// Widget di sebelah kanan field (misal: toggle password visibility)
  final Widget? suffixIcon;

  /// Apakah text disembunyikan (untuk password)
  final bool obscureText;

  /// Tipe keyboard yang ditampilkan
  final TextInputType keyboardType;

  /// Fungsi validasi form
  final String? Function(String?)? validator;

  /// Maksimal baris (untuk field deskripsi)
  final int maxLines;

  /// Apakah field bisa diedit
  final bool readOnly;

  /// Callback saat field di-tap (untuk date picker)
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Label ---
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // --- Text Field ---
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 22)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
