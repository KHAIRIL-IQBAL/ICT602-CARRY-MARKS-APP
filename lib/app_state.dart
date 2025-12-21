import 'package:flutter/material.dart';
import 'services/realtime_database_service.dart';

class AppState extends ChangeNotifier {
  final RealtimeDatabaseService _service = RealtimeDatabaseService();

  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? marks;

  // LOGIN
  Future<bool> login(String username, String password) async {
    final user = await _service.login(username, password);
    if (user == null) return false;

    currentUser = user;
    notifyListeners();
    return true;
  }

  // LOAD STUDENT MARKS
  Future<void> loadMarks() async {
    if (currentUser == null) return;
    final studentId = currentUser!['studentId'];
    if (studentId != null && studentId.toString().isNotEmpty) {
      marks = await _service.getMarks(studentId);
      notifyListeners();
    }
  }

  // UPDATE MARKS (Lecturer)
  Future<void> updateMarks(String studentId, double test, double assignment, double project) async {
    await _service.updateMarks(studentId, test, assignment, project);
    await loadMarks(); // refresh marks if currently viewing
  }

  // ADD STUDENT (Admin)
  Future<void> addStudent(String username, String password, String studentId) async {
    await _service.addStudent(username, password, studentId);
  }

  // LOGOUT
  void logout() {
    currentUser = null;
    marks = null;
    notifyListeners();
  }

  // HELPER
  Future<Map<String, dynamic>?> getMarksFor(String studentId) async {
    return await _service.getMarks(studentId);
  }
}
