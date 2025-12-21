import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnterMarksPage extends StatefulWidget {
  final String studentId;
  final String lecturerId;

  const EnterMarksPage({
    super.key,
    required this.studentId,
    required this.lecturerId,
  });

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  final testCtrl = TextEditingController();
  final assignmentCtrl = TextEditingController();
  final projectCtrl = TextEditingController();
  bool loading = false;

  Future<void> saveMarks() async {
    if (testCtrl.text.isEmpty ||
        assignmentCtrl.text.isEmpty ||
        projectCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      // Parse marks
      double test = double.parse(testCtrl.text);
      double assignment = double.parse(assignmentCtrl.text);
      double project = double.parse(projectCtrl.text);

      // Calculate weighted carry
      double testWeighted = test / 100 * 20;
      double assignmentWeighted = assignment / 100 * 10;
      double projectWeighted = project / 100 * 20;
      double totalCarry = testWeighted + assignmentWeighted + projectWeighted;

      // Save to student document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .update({
            'carryMark': {
              'test': test,
              'assignment': assignment,
              'project': project,
              'weightedScore': totalCarry,
            },
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Marks saved successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Student Marks")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: testCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Test (Out of 100, 20%)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: assignmentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Assignment (Out of 100, 10%)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: projectCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Project (Out of 100, 20%)",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveMarks,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Save Marks"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
