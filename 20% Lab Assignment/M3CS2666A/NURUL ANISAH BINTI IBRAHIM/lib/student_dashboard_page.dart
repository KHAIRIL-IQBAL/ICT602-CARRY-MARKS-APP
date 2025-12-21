import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logout_page.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  double? _test, _assignment, _project;
  double? _finalCarryMark;
  String? _currentGrade;

  @override
  void initState() {
    super.initState();
    _loadStudentMarks();
  }

  Future<void> _loadStudentMarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()!.containsKey('carry_mark')) {
      final carry = doc['carry_mark'] as Map<String, dynamic>;
      setState(() {
        _test = (carry['test'] ?? 0).toDouble();
        _assignment = (carry['assignment'] ?? 0).toDouble();
        _project = (carry['project'] ?? 0).toDouble();
        _finalCarryMark = _calculateFinal(_test!, _assignment!, _project!);
        _currentGrade = _getGrade(_finalCarryMark!);
      });
    }
  }

  double _calculateFinal(double test, double assignment, double project) {
    return test + assignment + project;
  }

  String _getGrade(double finalMark) {
    if (finalMark >= 45) return "A+";
    if (finalMark >= 40) return "A";
    if (finalMark >= 37.5) return "A-";
    if (finalMark >= 35) return "B+";
    if (finalMark >= 32.5) return "B";
    if (finalMark >= 30) return "B-";
    if (finalMark >= 27.5) return "C+";
    if (finalMark >= 25) return "C";
    return "F";
  }

  Map<String, double> _calculateExamTargets(double carryMark) {
    // ICT602 grading: final mark = carry mark + final exam (max 50)
    Map<String, double> targets = {};
    targets['A+ (90-100)'] = (90 - carryMark).clamp(0, 50);
    targets['A (80-89)'] = (80 - carryMark).clamp(0, 50);
    targets['A- (75-79)'] = (75 - carryMark).clamp(0, 50);
    targets['B+ (70-74)'] = (70 - carryMark).clamp(0, 50);
    targets['B (65-69)'] = (65 - carryMark).clamp(0, 50);
    targets['B- (60-64)'] = (60 - carryMark).clamp(0, 50);
    targets['C+ (55-59)'] = (55 - carryMark).clamp(0, 50);
    targets['C (50-54)'] = (50 - carryMark).clamp(0, 50);
    return targets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogoutPage()),
              );
            },
          ),
        ],
      ),
      body: _finalCarryMark == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Carry Marks",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Carry marks cards
                  _buildMarkCard(
                    "Test (20%)",
                    _test!,
                    Colors.deepPurple.shade300,
                  ),
                  _buildMarkCard(
                    "Assignment (10%)",
                    _assignment!,
                    Colors.deepPurple.shade400,
                  ),
                  _buildMarkCard(
                    "Project (20%)",
                    _project!,
                    Colors.deepPurple.shade500,
                  ),
                  const SizedBox(height: 20),

                  // Final carry mark with grade
                  Card(
                    color: Colors.deepPurple.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            "Final Carry Mark",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${_finalCarryMark!.toStringAsFixed(2)} / 50",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Current Grade: $_currentGrade",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Exam targets
                  const Text(
                    "Target Final Exam Marks for Grades",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._calculateExamTargets(_finalCarryMark!).entries.map((
                    entry,
                  ) {
                    return Card(
                      color: Colors.deepPurple.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(
                          Icons.grade,
                          color: Colors.deepPurple,
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                          "${entry.value.toStringAsFixed(1)} / 50",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildMarkCard(String title, double mark, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              mark.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
