import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

/// ============================================================
/// TASK CARD — Widget card untuk menampilkan satu item task
/// di Home Page. Menampilkan judul, kategori, tanggal, dan
/// checkbox untuk toggle status selesai/belum.
/// ============================================================

class TaskCard extends StatelessWidget {
  /// Data task yang ditampilkan
  final TaskModel task;

  /// Callback saat checkbox di-tap (toggle completed)
  final Function(bool?) onToggleCompleted;

  /// Callback saat card di-tap (navigasi ke edit)
  final VoidCallback onTap;

  /// Callback saat card di-swipe / delete button di-tap
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompleted,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id ?? ''),
      direction: DismissDirection.endToStart,
      // --- Background saat di-swipe ke kiri (Hapus) ---
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingLg),
        margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 28,
        ),
      ),
      // --- Konfirmasi sebelum hapus ---
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            title: const Text('Hapus Tugas'),
            content: Text(
              'Apakah kamu yakin ingin menghapus "${task.title}"?',
            ),
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
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      // --- Card utama ---
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? Colors.grey.shade50
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: task.isCompleted
                  ? Colors.grey.shade200
                  : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: task.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // --- Checkbox ---
              _buildCheckbox(),
              const SizedBox(width: 12),

              // --- Content (Title, Category Badge, Date) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul task
                    Text(
                      task.title,
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 16,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Deskripsi singkat
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          task.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: task.isCompleted
                                ? AppColors.textHint
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Category badge + Due date
                    Row(
                      children: [
                        _buildCategoryBadge(),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 8),
                          _buildDueDate(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // --- Menu (Edit & Hapus) ---
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textHint,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onTap();
                  } else if (value == 'delete') {
                    // Tampilkan dialog konfirmasi hapus
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget checkbox dengan animasi
  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: () => onToggleCompleted(!task.isCompleted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: task.isCompleted ? AppColors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted ? AppColors.success : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  /// Widget badge kategori (Personal / Work / Study)
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TaskCategories.getColor(task.category).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TaskCategories.getIcon(task.category),
            size: 12,
            color: TaskCategories.getColor(task.category),
          ),
          const SizedBox(width: 4),
          Text(
            TaskCategories.getLabel(task.category),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: TaskCategories.getColor(task.category),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget tanggal deadline
  Widget _buildDueDate() {
    final now = DateTime.now();
    final isOverdue = task.dueDate!.isBefore(now) && !task.isCompleted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 12,
          color: isOverdue ? AppColors.error : AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat('dd MMM').format(task.dueDate!),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isOverdue ? AppColors.error : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  /// Dialog konfirmasi hapus tugas (digunakan oleh popup menu)
  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        title: const Text('Hapus Tugas'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
