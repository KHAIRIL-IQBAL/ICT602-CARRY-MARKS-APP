import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  final gradeMap = const {
    "A+": 90,
    "A": 80,
    "A-": 75,
    "B+": 70,
    "B": 65,
    "B-": 60,
    "C+": 55,
    "C": 50,
  };

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Carry Marks"),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null || data['carryMark'] == null) {
            return const Center(child: Text("No marks entered yet."));
          }

          final carry = data['carryMark'];
          final testRaw = (carry['test'] ?? 0).toDouble();
          final assignmentRaw = (carry['assignment'] ?? 0).toDouble();
          final projectRaw = (carry['project'] ?? 0).toDouble();

          // Calculate percentage of course
          final testPercent = testRaw / 100 * 20;
          final assignmentPercent = assignmentRaw / 100 * 10;
          final projectPercent = projectRaw / 100 * 20;
          final totalPercent = testPercent + assignmentPercent + projectPercent;

          // Target final exam calculation (full mark 100, weight 50%)
          Map<String, double> targetExam = {};
          gradeMap.forEach((grade, target) {
            double needed = (target - totalPercent) / 0.5;
            if (needed > 100) needed = 100;
            if (needed < 0) needed = 0;
            targetExam[grade] = needed;
          });

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Carry Marks:",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "Test (20%): $testRaw → ${testPercent.toStringAsFixed(2)}%",
                ),
                Text(
                  "Assignment (10%): $assignmentRaw → ${assignmentPercent.toStringAsFixed(2)}%",
                ),
                Text(
                  "Project (20%): $projectRaw → ${projectPercent.toStringAsFixed(2)}%",
                ),
                Text(
                  "Total Carry Mark (50%): ${totalPercent.toStringAsFixed(2)}%",
                ),
                const Divider(height: 30),
                Text(
                  "Target Final Exam Marks for Each Grade (Full mark= 100):",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: targetExam.entries.map((e) {
                      return ListTile(
                        title: Text(e.key),
                        trailing: Text("${e.value.toStringAsFixed(2)} / 100"),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
