import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference students = FirebaseFirestore.instance.collection("students");

  Future<void> saveCarryMark(String studentId, double test, double assignment, double project) async {
    final double total = test + assignment + project;

    await students.doc(studentId).set({
      "test": test,
      "assignment": assignment,
      "project": project,
      "total": total, // tambah total di sini
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> getStudentMarks(String studentId) {
    return students.doc(studentId).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data;
    });
  }
}