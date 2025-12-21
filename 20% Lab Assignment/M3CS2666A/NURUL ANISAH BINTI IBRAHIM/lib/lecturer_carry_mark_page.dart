import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerCarryMarkPage extends StatefulWidget {
  final String studentUid;
  final String studentName;

  const LecturerCarryMarkPage({
    super.key,
    required this.studentUid,
    required this.studentName,
  });

  @override
  _LecturerCarryMarkPageState createState() => _LecturerCarryMarkPageState();
}

class _LecturerCarryMarkPageState extends State<LecturerCarryMarkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();

  double? _finalCarryMark; // to store calculated final carry mark

  @override
  void initState() {
    super.initState();
    _loadCarryMarks();
  }

  void _loadCarryMarks() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.studentUid)
        .get();

    if (doc.exists && doc.data()!.containsKey('carry_mark')) {
      var carry = doc['carry_mark'] as Map<String, dynamic>;
      setState(() {
        _testController.text = carry['test']?.toString() ?? "";
        _assignmentController.text = carry['assignment']?.toString() ?? "";
        _projectController.text = carry['project']?.toString() ?? "";
        _finalCarryMark = _calculateFinal(
          carry['test']?.toDouble() ?? 0,
          carry['assignment']?.toDouble() ?? 0,
          carry['project']?.toDouble() ?? 0,
        );
      });
    }
  }

  double _calculateFinal(double test, double assignment, double project) {
    // Test 20%, Assignment 10%, Project 20%
    return test + assignment + project;
  }

  void _saveCarryMarks() async {
    if (_formKey.currentState!.validate()) {
      double test = double.parse(_testController.text);
      double assignment = double.parse(_assignmentController.text);
      double project = double.parse(_projectController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentUid)
          .set({
            'carry_mark': {
              'test': test,
              'assignment': assignment,
              'project': project,
            },
          }, SetOptions(merge: true));

      // Calculate final carry mark
      setState(() {
        _finalCarryMark = _calculateFinal(test, assignment, project);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carry marks saved successfully")),
      );
    }
  }

  Color _getCardColor(double mark) {
    if (mark >= 50) return Colors.green.shade400;
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Marks - ${widget.studentName}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _testController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Test (20%)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter Test mark";
                      double? val = double.tryParse(value);
                      if (val == null || val < 0 || val > 20)
                        return "Test must be 0-20";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _assignmentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Assignment (10%)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter Assignment mark";
                      double? val = double.tryParse(value);
                      if (val == null || val < 0 || val > 10)
                        return "Assignment must be 0-10";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _projectController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Project (20%)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Enter Project mark";
                      double? val = double.tryParse(value);
                      if (val == null || val < 0 || val > 20)
                        return "Project must be 0-20";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveCarryMarks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Save Marks",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Display final carry mark if available
            if (_finalCarryMark != null)
              Card(
                color: _getCardColor(_finalCarryMark!),
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
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
