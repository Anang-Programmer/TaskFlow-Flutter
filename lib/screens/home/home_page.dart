import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import '../task/task_form_page.dart';

/// ============================================================
/// HOME PAGE — Halaman utama setelah login. Menampilkan
/// daftar tugas milik user dari Firestore secara real-time.
///
/// Fitur:
/// - List tugas dengan StreamBuilder (real-time)
/// - Filter: All / Active / Completed
/// - Search bar untuk mencari tugas
/// - Floating Action Button untuk tambah tugas
/// - Swipe-to-delete dan popup menu delete pada card
/// - Logout dari AppBar
/// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  // Filter state: 0 = All, 1 = Active, 2 = Completed
  int _selectedFilter = 0;

  // Search state
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // Listener untuk search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Mendapatkan nama user untuk greeting
  String get _userName {
    final user = _authService.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user?.email?.split('@').first ?? 'User';
  }

  /// Filter dan search list task
  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    // Filter berdasarkan tab (All / Active / Completed)
    List<TaskModel> filtered;
    switch (_selectedFilter) {
      case 1: // Active
        filtered = tasks.where((t) => !t.isCompleted).toList();
        break;
      case 2: // Completed
        filtered = tasks.where((t) => t.isCompleted).toList();
        break;
      default: // All
        filtered = tasks;
    }

    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final titleMatch = t.title.toLowerCase().contains(_searchQuery);
        final descMatch = t.description.toLowerCase().contains(_searchQuery);
        return titleMatch || descMatch;
      }).toList();
    }

    return filtered;
  }

  /// Proses logout
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
    }
  }

  /// Toggle status completed task
  Future<void> _toggleTask(TaskModel task, bool? value) async {
    try {
      await _dbService.toggleTaskStatus(task.id!, value ?? false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Hapus task
  Future<void> _deleteTask(TaskModel task) async {
    try {
      await _dbService.deleteTask(task.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" berhasil dihapus'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Navigasi ke form tambah/edit task
  void _navigateToForm({TaskModel? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // --- Header Section ---
              _buildHeader(),

              // --- Search Bar ---
              _buildSearchBar(),

              // --- Filter Tabs ---
              _buildFilterTabs(),

              // --- Task List ---
              Expanded(
                child: _buildTaskList(userId),
              ),
            ],
          ),
        ),
      ),
      // --- FAB: Tambah Tugas ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Tugas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Header dengan greeting dan logout button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingLg,
        AppSizes.paddingMd,
        AppSizes.paddingMd,
        AppSizes.paddingSm,
      ),
      child: Row(
        children: [
          // User avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _userName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $_userName!',
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Apa yang mau kamu kerjakan hari ini?',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Logout button
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  /// Search bar untuk mencari tugas berdasarkan judul atau deskripsi
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingSm,
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Cari tugas...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMd,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  /// Filter tabs: All / Active / Completed
  Widget _buildFilterTabs() {
    final filters = ['Semua', 'Aktif', 'Selesai'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// List task dengan StreamBuilder (real-time dari Firestore)
  Widget _buildTaskList(String userId) {
    return StreamBuilder<List<TaskModel>>(
      stream: _dbService.getTasks(userId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Terjadi kesalahan',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allTasks = snapshot.data ?? [];
        final filteredTasks = _filterTasks(allTasks);

        // Empty state
        if (allTasks.isEmpty) {
          return _buildEmptyState();
        }

        // Empty filter/search state
        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.filter_list_off,
                  size: 56,
                  color: AppColors.textHint.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Tidak ditemukan tugas untuk "$_searchQuery"'
                      : _selectedFilter == 1
                          ? 'Semua tugas sudah selesai!'
                          : 'Belum ada tugas yang selesai',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Task list
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLg,
            vertical: AppSizes.paddingSm,
          ),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TaskCard(
              task: task,
              onToggleCompleted: (value) => _toggleTask(task, value),
              onTap: () => _navigateToForm(task: task),
              onDelete: () => _deleteTask(task),
            );
          },
        );
      },
    );
  }

  /// Empty state saat belum ada task
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada tugas',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai buat tugas pertamamu\ndengan menekan tombol di bawah!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
