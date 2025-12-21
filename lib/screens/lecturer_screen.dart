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
  // MARKS
  final _test = TextEditingController();
  final _assignment = TextEditingController();
  final _project = TextEditingController();

  // ADD STUDENT
  final _newUsername = TextEditingController();
  final _newPassword = TextEditingController();
  final _newStudentId = TextEditingController();

  String selectedStudentId = '';
  String message = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AppState>(context, listen: false).loadStudents());
  }

  void _showAddStudentDialog(AppState app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newUsername,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _newPassword,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _newStudentId,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              await app.addStudent(
                _newUsername.text,
                _newPassword.text,
                _newStudentId.text,
              );

              _newUsername.clear();
              _newPassword.clear();
              _newStudentId.clear();

              await app.loadStudents();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer — ICT602 Carry Marks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddStudentDialog(app),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              app.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // ================= STUDENT LIST =================
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: app.students.length,
              itemBuilder: (_, i) {
                final s = app.students[i];
                return Card(
                  child: ListTile(
                    title: Text(s['studentId']),
                    subtitle: Text(s['username']),
                    onTap: () async {
                      selectedStudentId = s['studentId'];
                      final marks = await app.getMarksFor(selectedStudentId);

                      _test.text = (marks?['test'] ?? 0).toString();
                      _assignment.text =
                          (marks?['assignment'] ?? 0).toString();
                      _project.text = (marks?['project'] ?? 0).toString();

                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),

          // ================= MARK ENTRY =================
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: selectedStudentId.isEmpty
                  ? const Center(child: Text('Select student'))
                  : Column(
                      children: [
                        Text('Student: $selectedStudentId',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _test,
                          decoration:
                              const InputDecoration(labelText: 'Test (20%)'),
                        ),
                        TextField(
                          controller: _assignment,
                          decoration: const InputDecoration(
                              labelText: 'Assignment (10%)'),
                        ),
                        TextField(
                          controller: _project,
                          decoration:
                              const InputDecoration(labelText: 'Project (20%)'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            await app.updateMarks(
                              selectedStudentId,
                              double.parse(_test.text),
                              double.parse(_assignment.text),
                              double.parse(_project.text),
                            );
                            setState(() => message = 'Saved');
                          },
                        ),
                        Text(message),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
