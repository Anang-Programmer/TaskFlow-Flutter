import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

/// ============================================================
/// TASK FORM PAGE — Halaman form untuk menambah (Create) atau
/// mengedit (Update) tugas. Mode ditentukan oleh parameter
/// [task]: null = mode Create, ada data = mode Edit.
/// ============================================================

class TaskFormPage extends StatefulWidget {
  /// Task yang akan diedit. Null jika mode Create.
  final TaskModel? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  // --- Controllers & State ---
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _authService = AuthService();
  final _dbService = DatabaseService();

  String _selectedCategory = TaskCategories.personal;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  /// Apakah sedang dalam mode edit
  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    // Jika mode Edit, populate form dengan data task yang ada
    if (_isEditMode) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedCategory = widget.task!.category;
      _selectedDueDate = widget.task!.dueDate;

      if (_selectedDueDate != null) {
        _dueDateController.text =
            DateFormat('dd MMMM yyyy').format(_selectedDueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  /// Menampilkan Date Picker untuk memilih due date
  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
        _dueDateController.text =
            DateFormat('dd MMMM yyyy').format(pickedDate);
      });
    }
  }

  /// Proses simpan task (Create atau Update)
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.uid ?? '';

      if (_isEditMode) {
        // --- UPDATE: Perbarui task yang ada ---
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          dueDate: _selectedDueDate,
        );
        await _dbService.updateTask(updatedTask);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tugas berhasil diperbarui!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
          );
        }
      } else {
        // --- CREATE: Tambah task baru ---
        final newTask = TaskModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          createdAt: DateTime.now(),
          dueDate: _selectedDueDate,
          userId: userId,
        );
        await _dbService.addTask(newTask);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tugas berhasil ditambahkan!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
          );
        }
      }

      // Kembali ke Home Page
      if (mounted) Navigator.pop(context);
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
      backgroundColor: AppColors.background,
      // --- App Bar ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
        ),
        title: Text(
          _isEditMode ? 'Edit Tugas' : 'Tambah Tugas',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title Field ---
              CustomTextField(
                controller: _titleController,
                label: 'Judul Tugas',
                hintText: 'Contoh: Belajar Flutter',
                prefixIcon: Icons.title,
                validator: Validators.validateTaskTitle,
              ),
              const SizedBox(height: 20),

              // --- Description Field ---
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hintText: 'Deskripsikan tugas ini...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: Validators.validateTaskDescription,
              ),
              const SizedBox(height: 20),

              // --- Category Selector ---
              _buildCategorySelector(),
              const SizedBox(height: 20),

              // --- Due Date Picker ---
              CustomTextField(
                controller: _dueDateController,
                label: 'Tanggal Deadline (Opsional)',
                hintText: 'Pilih tanggal',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickDueDate,
                suffixIcon: _selectedDueDate != null
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                            _dueDateController.clear();
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
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
                      : Text(
                          _isEditMode ? 'Simpan Perubahan' : 'Tambah Tugas',
                          style: AppTextStyles.button,
                        ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingLg),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget selector kategori dengan chip-style buttons
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: TaskCategories.all.map((category) {
            final isSelected = _selectedCategory == category;
            final color = TaskCategories.getColor(category);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: category != TaskCategories.all.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          TaskCategories.getIcon(category),
                          color: isSelected ? color : AppColors.textHint,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          TaskCategories.getLabel(category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
