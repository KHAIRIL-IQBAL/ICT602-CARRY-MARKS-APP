import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ================= LOGIN =================
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final snapshot =
        await _db.child('users').orderByChild('username').equalTo(username).get();

    if (!snapshot.exists) return null;

    for (var child in snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>;
      if (data['password'] == password) {
        return {
          'username': data['username'],
          'role': data['role'],
          'studentId': data['studentId'] ?? ''
        };
      }
    }
    return null;
  }

  // ================= GET MARKS =================
  Future<Map<String, dynamic>?> getMarks(String studentId) async {
    final snapshot = await _db.child('marks/$studentId').get();
    if (!snapshot.exists) return null;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // ================= UPDATE MARKS =================
  Future<void> updateMarks(
      String studentId, double test, double assignment, double project) async {
    final carry = test + assignment + project;

    await _db.child('marks/$studentId').set({
      'test': test,
      'assignment': assignment,
      'project': project,
      'carry': carry,
    });
  }

  // ================= STUDENTS =================
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final snapshot = await _db.child('users').get();
    if (!snapshot.exists) return [];

    final List<Map<String, dynamic>> list = [];
    for (var child in snapshot.children) {
      final data = child.value as Map<dynamic, dynamic>;
      if (data['role'] == 'student') {
        list.add({
          'username': data['username'],
          'studentId': data['studentId'],
        });
      }
    }
    return list;
  }

  // ================= ADD STUDENT =================
  Future<void> addStudent(
      String username, String password, String studentId) async {
    await _db.child('users/$username').set({
      'username': username,
      'password': password,
      'role': 'student',
      'studentId': studentId,
    });
  }
}
