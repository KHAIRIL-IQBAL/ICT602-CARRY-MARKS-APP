import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'login_screen.dart';

class LecturerScreen extends StatefulWidget {
  const LecturerScreen({super.key});
  @override
  State<LecturerScreen> createState() => _LecturerScreenState();
}

class _LecturerScreenState extends State<LecturerScreen> {
  // Controllers for marks
  final _sid = TextEditingController(text: 'S001');
  final _test = TextEditingController();
  final _assignment = TextEditingController();
  final _project = TextEditingController();

  // Controllers for adding student
  final _newUsername = TextEditingController();
  final _newPassword = TextEditingController();
  final _newStudentId = TextEditingController();

  String message = '';

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer — Carry Mark & Add Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== Load / Update Marks Section =====
            const Text('Load / Update Student Marks', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _sid,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final marks = await app.getMarksFor(_sid.text.trim());
                if (marks != null) {
                  _test.text = marks['test'].toString();
                  _assignment.text = marks['assignment'].toString();
                  _project.text = marks['project'].toString();
                  setState(() {
                    message = 'Loaded existing marks for ${_sid.text.trim()}';
                  });
                } else {
                  _test.clear();
                  _assignment.clear();
                  _project.clear();
                  setState(() {
                    message = 'No existing marks; enter new values (0-100)';
                  });
                }
              },
              child: const Text('Load Student Marks'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _test,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Test (0-100)'),
            ),
            TextField(
              controller: _assignment,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Assignment (0-100)'),
            ),
            TextField(
              controller: _project,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Project (0-100)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final sid = _sid.text.trim();
                final t = double.tryParse(_test.text) ?? 0.0;
                final a = double.tryParse(_assignment.text) ?? 0.0;
                final p = double.tryParse(_project.text) ?? 0.0;
                await app.updateMarks(sid, t, a, p);
                setState(() {
                  message = 'Saved marks for $sid';
                });
              },
              child: const Text('Save / Update Carry Mark'),
            ),
            const Divider(height: 32),

            // ===== Add Student Section =====
            const Text('Add New Student', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _newUsername,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _newPassword,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newStudentId,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final username = _newUsername.text.trim();
                final password = _newPassword.text.trim();
                final studentId = _newStudentId.text.trim();

                if (username.isEmpty || password.isEmpty || studentId.isEmpty) {
                  setState(() {
                    message = 'Please fill all fields to add a student';
                  });
                  return;
                }

                await app.addStudent(username, password, studentId);

                // Clear fields
                _newUsername.clear();
                _newPassword.clear();
                _newStudentId.clear();

                setState(() {
                  message = 'Student $username ($studentId) added successfully';
                });
              },
              child: const Text('Add Student'),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.green)),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                app.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
