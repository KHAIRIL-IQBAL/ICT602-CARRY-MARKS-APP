import 'package:flutter/material.dart';
import 'services/realtime_database_service.dart';

class AppState extends ChangeNotifier {
  final RealtimeDatabaseService _service = RealtimeDatabaseService();

  // Logged-in user info
  String username = '';
  String role = '';
  String studentId = '';

  // Student data
  Map<String, dynamic>? marks;
  List<Map<String, dynamic>> students = [];

  // ================= LOGIN =================
  Future<bool> login(String u, String p) async {
    final data = await _service.login(u, p);
    if (data == null) return false;

    username = data['username'];
    role = data['role'];
    studentId = data['studentId'];
    notifyListeners();
    return true;
  }

  void logout() {
    username = '';
    role = '';
    studentId = '';
    marks = null;
    students.clear();
    notifyListeners();
  }

  // ================= STUDENT =================
  Future<void> loadMarks() async {
    if (studentId.isEmpty) return;
    marks = await _service.getMarks(studentId);
    notifyListeners();
  }

  // ================= LECTURER =================
  Future<void> loadStudents() async {
    students = await _service.getAllStudents();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getMarksFor(String sid) async {
    return await _service.getMarks(sid);
  }

  Future<void> updateMarks(
      String sid, double test, double assignment, double project) async {
    await _service.updateMarks(sid, test, assignment, project);
  }

  // ================= ADMIN =================
  Future<void> addStudent(
      String username, String password, String studentId) {
    return _service.addStudent(username, password, studentId);
  }
}
