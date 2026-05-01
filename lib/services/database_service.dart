import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// ============================================================
/// DATABASE SERVICE — Mengelola semua operasi CRUD (Create,
/// Read, Update, Delete) ke Cloud Firestore.
///
/// Collection: 'tasks'
/// Setiap document berisi data task milik user tertentu,
/// difilter berdasarkan userId.
/// ============================================================

class DatabaseService {
  /// Referensi ke collection 'tasks' di Firestore
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // ==========================================================
  // CREATE — Menambahkan task baru ke Firestore
  // ==========================================================

  /// Menambahkan task baru ke database.
  ///
  /// [task] - TaskModel yang akan disimpan.
  /// Firestore akan otomatis membuat document ID unik.
  Future<DocumentReference> addTask(TaskModel task) async {
    try {
      return await _tasksCollection.add(task.toMap());
    } catch (e) {
      throw 'Gagal menambahkan tugas: $e';
    }
  }

  // ==========================================================
  // READ — Mengambil data task dari Firestore (real-time)
  // ==========================================================

  /// Mendapatkan stream daftar task milik user tertentu.
  /// Stream akan otomatis update ketika ada perubahan di Firestore.
  ///
  /// [userId] - UID user yang sedang login.
  /// Task diurutkan berdasarkan tanggal pembuatan (terbaru di atas).
  Stream<List<TaskModel>> getTasks(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Mendapatkan satu task berdasarkan document ID.
  ///
  /// [taskId] - Document ID task yang dicari.
  /// Mengembalikan null jika task tidak ditemukan.
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil data tugas: $e';
    }
  }

  // ==========================================================
  // UPDATE — Memperbarui data task di Firestore
  // ==========================================================

  /// Memperbarui seluruh data task yang sudah ada.
  ///
  /// [task] - TaskModel yang sudah dimodifikasi (harus punya id).
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw 'Gagal memperbarui tugas: $e';
    }
  }

  /// Toggle status completed/uncompleted pada task.
  ///
  /// [taskId] - Document ID task.
  /// [isCompleted] - Status baru (true = selesai, false = belum).
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      throw 'Gagal mengubah status tugas: $e';
    }
  }

  // ==========================================================
  // DELETE — Menghapus task dari Firestore
  // ==========================================================

  /// Menghapus task berdasarkan document ID.
  ///
  /// [taskId] - Document ID task yang akan dihapus.
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw 'Gagal menghapus tugas: $e';
    }
  }
}
