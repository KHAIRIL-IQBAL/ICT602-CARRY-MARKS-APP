import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'login_screen.dart';

const gradeBounds = {
  'A+': 90,
  'A': 80,
  'A-': 75,
  'B+': 70,
  'B': 65,
  'B-': 60,
  'C+': 55,
  'C': 50,
};

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});
  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  double test = 0, assignment = 0, project = 0;
  bool loading = true;
  String studentId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final app = Provider.of<AppState>(context, listen: false);
    await app.loadMarks();
    final u = app.currentUser!;
    studentId = (u['studentId'] ?? '').toString();
    if (app.marks != null) {
      test = (app.marks!['test'] ?? 0.0).toDouble();
      assignment = (app.marks!['assignment'] ?? 0.0).toDouble();
      project = (app.marks!['project'] ?? 0.0).toDouble();
    }
    setState(() {
      loading = false;
    });
  }

  double requiredFinalExamForTarget(double targetTotal) {
    final currentContribution = test * 0.20 + assignment * 0.10 + project * 0.20;
    final req = (targetTotal - currentContribution) / 0.50;
    return req;
  }

  Widget gradeRow(String grade, int bound) {
    final req = requiredFinalExamForTarget(bound.toDouble());
    final reqClamped = req.isFinite ? req.clamp(0.0, 100.0) : double.nan;
    String msg;
    if (req.isNaN) msg = 'N/A';
    else if (req <= 0) msg = 'Already guaranteed (no extra final needed)';
    else if (req > 100) msg = 'Impossible (need >100%)';
    else msg = '${reqClamped.toStringAsFixed(1)}% (min final exam required)';
    return ListTile(
      title: Text('$grade (>= $bound%)'),
      subtitle: Text(msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final carryContribution = test * 0.20 + assignment * 0.10 + project * 0.20;
    return Scaffold(
      appBar: AppBar(title: const Text('Student — Carry Mark & Targets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Student ID: $studentId'),
            const SizedBox(height: 8),
            Text(
              'Test: ${test.toStringAsFixed(1)}  Assignment: ${assignment.toStringAsFixed(1)}  Project: ${project.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Carry contribution to final grade: ${carryContribution.toStringAsFixed(2)}% (out of 100)',
            ),
            const Divider(),
            const Text('Target grades — required final exam mark to achieve lower bound of each grade:'),
            Expanded(
              child: ListView(
                children: gradeBounds.entries.map((e) => gradeRow(e.key, e.value)).toList(),
              ),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                final app = Provider.of<AppState>(context, listen: false);
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
