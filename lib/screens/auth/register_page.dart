import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

/// ============================================================
/// REGISTER PAGE — Halaman pendaftaran pengguna baru
/// menggunakan Firebase Authentication.
/// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // --- Controllers & State ---
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Proses registrasi dengan Firebase Auth
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Membuat akun baru di Firebase Auth
      final credential = await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Update display name user
      await credential.user?.updateDisplayName(_nameController.text.trim());

      // Kembali ke login page setelah berhasil register
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Akun berhasil dibuat! Silakan masuk.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),
        );
        Navigator.pop(context); // Kembali ke Login Page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // --- Background Gradient ---
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF4F46E5),
              Color(0xFF2563EB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- Header ---
                      _buildHeader(),
                      const SizedBox(height: 32),

                      // --- Register Form Card ---
                      _buildRegisterForm(),
                      const SizedBox(height: 24),

                      // --- Login Link ---
                      _buildLoginLink(),
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

  /// Header dengan icon
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Buat Akun Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Daftar untuk mulai mengelola tugasmu',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// Form card registrasi
  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            const Text(
              'Isi data di bawah untuk membuat akun',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            // --- Nama ---
            CustomTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama kamu',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),

            // --- Email ---
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'contoh@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),

            // --- Password ---
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Minimal 6 karakter',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),

            // --- Konfirmasi Password ---
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              hintText: 'Ulangi password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 24),

            // --- Register Button ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Daftar', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Link navigasi kembali ke login
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Masuk',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
