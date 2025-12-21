import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'login_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  // Grade targets
  final Map<String, int> gradeTargets = {
    'A+': 90,
    'A': 80,
    'A-': 75,
    'B+': 70,
    'B': 65,
    'B-': 60,
    'C+': 55,
    'C': 50,
  };

  @override
  void initState() {
    super.initState();
    // Load student's marks on init
    Future.microtask(
      () => Provider.of<AppState>(context, listen: false).loadMarks(),
    );
  }

  // Calculate required final exam mark based on carry
  double calculateRequiredExam(double carry, int target) {
    final needed = (target - carry) * 2; // Since carry is 50%
    if (needed <= 0) return 0; // Already sufficient
    if (needed > 100) return -1; // Impossible
    return needed;
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final marks = app.marks;

    if (marks == null) {
      return const Scaffold(
        body: Center(child: Text('No marks available')),
      );
    }

    // Compute carry mark (20% Test, 10% Assignment, 20% Project)
    final test = (marks['test'] ?? 0).toDouble();
    final assignment = (marks['assignment'] ?? 0).toDouble();
    final project = (marks['project'] ?? 0).toDouble();

    final carry = test * 0.2 + assignment * 0.1 + project * 0.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student — Carry Mark & Target'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              app.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Carry mark card
            Card(
              child: ListTile(
                title: const Text('Carry Mark (50%)'),
                subtitle: Text(
                  carry.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Final Exam Target for Each Grade',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            // List of grade targets
            Expanded(
              child: ListView(
                children: gradeTargets.entries.map((e) {
                  final requiredExam = calculateRequiredExam(carry, e.value);

                  return Card(
                    child: ListTile(
                      title: Text('Grade ${e.key} (${e.value}%)'),
                      trailing: Text(
                        requiredExam == -1
                            ? 'Impossible'
                            : '${requiredExam.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Required Final Exam Mark'),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
