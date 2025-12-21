import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // LOGIN
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final snapshot = await _db.child('users').orderByChild('username').equalTo(username).get();
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

  // GET STUDENT MARKS
  Future<Map<String, dynamic>?> getMarks(String studentId) async {
    final snapshot = await _db.child('marks/$studentId').get();
    if (!snapshot.exists) return null;
    final data = snapshot.value as Map<dynamic, dynamic>;
    return {
      'test': (data['test'] ?? 0.0).toDouble(),
      'assignment': (data['assignment'] ?? 0.0).toDouble(),
      'project': (data['project'] ?? 0.0).toDouble(),
    };
  }

  // UPDATE MARKS
  Future<void> updateMarks(String studentId, double test, double assignment, double project) async {
    await _db.child('marks/$studentId').set({
      'test': test,
      'assignment': assignment,
      'project': project,
    });
  }

  // ADD STUDENT + Initialize Marks
  Future<void> addStudent(String username, String password, String studentId) async {
    // Add user
    await _db.child('users/$username').set({
      'username': username,
      'password': password,
      'role': 'student',
      'studentId': studentId,
    });

    // Initialize marks to 0
    await _db.child('marks/$studentId').set({
      'test': 0.0,
      'assignment': 0.0,
      'project': 0.0,
    });
  }
}
