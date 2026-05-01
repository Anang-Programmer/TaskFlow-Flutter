// ============================================================
// FORM VALIDATORS — Validasi input form untuk Authentication
// dan Task Form. Mengembalikan pesan error jika tidak valid,
// atau null jika valid.
// ============================================================

class Validators {
  /// Validasi field email
  /// - Tidak boleh kosong
  /// - Harus format email yang benar
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    // Regex sederhana untuk validasi format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Validasi field password
  /// - Tidak boleh kosong
  /// - Minimal 6 karakter (requirement Firebase Auth)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  /// Validasi konfirmasi password
  /// - Harus sama dengan password utama
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != password) {
      return 'Password tidak cocok';
    }

    return null;
  }

  /// Validasi field nama
  /// - Tidak boleh kosong
  /// - Minimal 2 karakter
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }

    return null;
  }

  /// Validasi judul tugas
  /// - Tidak boleh kosong
  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul tugas tidak boleh kosong';
    }

    return null;
  }

  /// Validasi deskripsi tugas
  /// - Tidak boleh kosong
  static String? validateTaskDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tugas tidak boleh kosong';
    }

    return null;
  }
}
