import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/pixel_button.dart';
import '../../components/pixel_panel.dart';
import '../dashboard/lecturer_dashboard.dart';

class EditMarksPage extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> student;

  const EditMarksPage({
    super.key,
    required this.uid,
    required this.student,
  });

  @override
  State<EditMarksPage> createState() => _EditMarksPageState();
}

class _EditMarksPageState extends State<EditMarksPage> {
  late TextEditingController test;
  late TextEditingController assignment;
  late TextEditingController project;

  @override
  void initState() {
    super.initState();
    final cm = widget.student["carrymark"];
    test = TextEditingController(text: cm["test"].toString());
    assignment = TextEditingController(text: cm["assignment"].toString());
    project = TextEditingController(text: cm["project"].toString());
  }

  Future<void> save() async {
    try {
      await FirebaseFirestore.instance
          .collection("students")
          .doc(widget.uid)
          .update({
        "carrymark": {
          "test": int.tryParse(test.text) ?? 0,
          "assignment": int.tryParse(assignment.text) ?? 0,
          "project": int.tryParse(project.text) ?? 0,
        }
      });

      // SUCCESS → Return to Lecturer Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LecturerDashboard()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving marks: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD),

      // ⭐ IMPROVED APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB), // bright royal blue
        elevation: 8,
        shadowColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Marks",
          style: TextStyle(
            fontFamily: "Minecraft",
            fontSize: 26,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(2, 2), blurRadius: 2, color: Colors.black)
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PixelPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _markField("Test (20%)", test),
                const SizedBox(height: 18),

                _markField("Assignment (10%)", assignment),
                const SizedBox(height: 18),

                _markField("Project (20%)", project),
              ],
            ),
          ),

          const SizedBox(height: 30),

          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelButton(
                  text: "SAVE",
                  width: 150,
                  onTap: save,
                ),
                const SizedBox(width: 20),
                PixelButton(
                  text: "CANCEL",
                  width: 150,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _markField(String label, TextEditingController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        border: Border.all(width: 4, color: Colors.black),
      ),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontFamily: "Minecraft",
          fontSize: 18,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: "Minecraft",
            color: Colors.white,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
