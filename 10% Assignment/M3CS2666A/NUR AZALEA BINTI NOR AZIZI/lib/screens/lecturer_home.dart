import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enter_marks.dart';

class LecturerHomePage extends StatefulWidget {
  final String lecturerId;

  const LecturerHomePage({super.key, required this.lecturerId});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Student',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          // Student list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!.docs.where((doc) {
                  final name = (doc['username'] ?? '').toString().toLowerCase();
                  final email = (doc['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                if (students.isEmpty) {
                  return const Center(child: Text("No students found."));
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, i) {
                    final student = students[i];
                    final carry = student['carryMark'] ?? {};

                    final test = (carry['test'] ?? 0).toDouble();
                    final assignment = (carry['assignment'] ?? 0).toDouble();
                    final project = (carry['project'] ?? 0).toDouble();

                    // Calculate percentages
                    final testPercent = test / 100 * 20;
                    final assignmentPercent = assignment / 100 * 10;
                    final projectPercent = project / 100 * 20;
                    final totalPercent =
                        testPercent + assignmentPercent + projectPercent;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(student['username'] ?? 'Unnamed'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['email'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              "Test: $test → ${testPercent.toStringAsFixed(2)}%",
                            ),
                            Text(
                              "Assignment: $assignment → ${assignmentPercent.toStringAsFixed(2)}%",
                            ),
                            Text(
                              "Project: $project → ${projectPercent.toStringAsFixed(2)}%",
                            ),
                            Text(
                              "Total Carry Mark (50%): ${totalPercent.toStringAsFixed(2)}%",
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () {
                          // Navigate to enter marks page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnterMarksPage(
                                studentId: student.id,
                                lecturerId: widget.lecturerId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
