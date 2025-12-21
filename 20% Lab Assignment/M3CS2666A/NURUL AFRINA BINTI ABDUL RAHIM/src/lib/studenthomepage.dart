import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';
import 'login_page.dart';

class StudentDashboard extends StatelessWidget {
  final studentId = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: studentId,
                  decoration: InputDecoration(
                    labelText: "Student ID",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
                  backgroundColor: Colors.deepPurple,
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
    );
  }
}

class MarkView extends StatelessWidget {
  final String studentId;
  MarkView({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carry Mark")),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: FirestoreService().getStudentMarks(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found for this student."));
          }

          final data = snapshot.data!;
          final double test = (data["test"] ?? 0).toDouble();
          final double assignment = (data["assignment"] ?? 0).toDouble();
          final double project = (data["project"] ?? 0).toDouble();
          final double total = (data["total"] ?? test + assignment + project).toDouble();
return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Test: $test", style: const TextStyle(fontSize: 16)),
                    Text("Assignment: $assignment", style: const TextStyle(fontSize: 16)),
                    Text("Project: $project", style: const TextStyle(fontSize: 16)),
                    const Divider(height: 30),
                    Text("Carry Mark Total: $total / 50", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Required Final Exam score to get:", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...[
                      {"grade": "A+", "score": 90},
                      {"grade": "A", "score": 80},
                      {"grade": "A-", "score": 75},
                      {"grade": "B+", "score": 70},
                      {"grade": "B", "score": 65},
                      {"grade": "B-", "score": 60},
                      {"grade": "C+", "score": 55},
                      {"grade": "C", "score": 50},
                    ].map((g) {
                      final double required = (g['score'] as num).toDouble() - total;
                      final display = required < 0 ? 0 : required;
                      return Text("${g['grade']} (${g['score']}): $display");
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}