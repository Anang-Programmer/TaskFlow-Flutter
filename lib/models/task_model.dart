import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// TASK MODEL — Representasi data tugas yang disimpan di
/// Cloud Firestore. Menyediakan konversi dari/ke Map untuk
/// serialisasi data Firestore.
/// ============================================================

class TaskModel {
  /// Document ID dari Firestore (null saat membuat task baru)
  String? id;

  /// Judul tugas
  final String title;

  /// Deskripsi detail tugas
  final String description;

  /// Kategori: 'personal', 'work', atau 'study'
  final String category;

  /// Status tugas: selesai (true) atau belum (false)
  bool isCompleted;

  /// Waktu pembuatan tugas
  final DateTime createdAt;

  /// Tanggal deadline (opsional)
  final DateTime? dueDate;

  /// UID pemilik tugas (dari Firebase Auth)
  final String userId;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    required this.userId,
  });

  /// Konversi TaskModel ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'userId': userId,
    };
  }

  /// Membuat TaskModel dari document snapshot Firestore
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'personal',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      userId: map['userId'] ?? '',
    );
  }

  /// Membuat salinan TaskModel dengan perubahan tertentu
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }
}
