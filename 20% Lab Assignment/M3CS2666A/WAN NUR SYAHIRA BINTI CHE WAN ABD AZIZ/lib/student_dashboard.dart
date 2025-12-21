import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';
import 'login_page.dart';
import 'dart:math';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  final studentId = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose(){
    studentId.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9575CD),
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Pastel gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glitter stars overlay
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  color: Colors.purple.shade100.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: studentId,
                      decoration: InputDecoration(
                        labelText: "Student ID",
                        labelStyle: const TextStyle(color: Colors.purple),
                        filled: true,
                        fillColor: Colors.purple.shade50.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFF9575CD),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MarkView(studentId: studentId.text),
                        ),
                      );
                    },
                    child: const Text("View Marks"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarkView extends StatefulWidget {
  final String studentId;
  const MarkView({super.key, required this.studentId});

  @override
  State<MarkView> createState() => _MarkViewState();
}

class _MarkViewState extends State<MarkView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9575CD),
        title: const Text("Carry Mark"),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarPainter(_animationController.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          StreamBuilder<Map<String, dynamic>>(
            stream: FirestoreService().getStudentMarks(widget.studentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No data found for this student.",
                    style: TextStyle(color: Colors.purple),
                  ),
                );
              }

              final data = snapshot.data!;
              final double test = (data["test"] ?? 0).toDouble();
              final double assignment = (data["assignment"] ?? 0).toDouble();
              final double project = (data["project"] ?? 0).toDouble();
              final double total = (data["total"] ?? test + assignment + project).toDouble();

              final grades = [
                {"grade": "A+", "score": 90},
                {"grade": "A", "score": 80},
                {"grade": "A-", "score": 75},
                {"grade": "B+", "score": 70},
                {"grade": "B", "score": 65},
                {"grade": "B-", "score": 60},
                {"grade": "C+", "score": 55},
                {"grade": "C", "score": 50},
              ];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  color: Colors.purple.shade100.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Test: $test %", style: const TextStyle(fontSize: 16, color: Colors.purple)),
                        Text("Assignment: $assignment %", style: const TextStyle(fontSize: 16, color: Colors.purple)),
                        Text("Project: $project %", style: const TextStyle(fontSize: 16, color: Colors.purple)),
                        const Divider(height: 30, color: Colors.purpleAccent),
                        Text(
                          "Carry Mark Total: $total / 50",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Required Final Exam Score to Achieve Grade:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        const SizedBox(height: 10),

                        // Centered DataTable
                        Center(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.purple.shade200.withOpacity(0.6)),
                            columns: const [
                              DataColumn(label: Center(child: Text("Grade", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)))),
                              DataColumn(label: Center(child: Text("Score Needed", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)))),
                            ],
                            rows: grades.map((g) {
                              final grade = g['grade'] as String;
                              final score = (g['score'] as num).toDouble();
                              final required = score - total;
                              final display = required < 0 ? 0 : required;
                              final rowColor = display == 0 ? Colors.green.shade100 : Colors.orange.shade100;
                              return DataRow(
                                color: MaterialStateProperty.all(rowColor),
                                cells: [
                                  DataCell(Center(child: Text(grade, style: const TextStyle(color: Colors.purple)))),
                                  DataCell(Center(child: Text(display.toStringAsFixed(1), style: const TextStyle(color: Colors.purple)))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom painter for glitter stars
class StarPainter extends CustomPainter {
  final double animationValue;
  final int starCount = 80;
  StarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = Random(42); // fixed seed for consistent star positions

    for (int i = 0; i < starCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = (random.nextDouble() + animationValue) % 1 * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
