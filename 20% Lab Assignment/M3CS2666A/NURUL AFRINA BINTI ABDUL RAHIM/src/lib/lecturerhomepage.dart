import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firestore_service.dart';
import 'login_page.dart';

class LecturerDashboard extends StatelessWidget {
  final TextEditingController test = TextEditingController();
  final TextEditingController assignment = TextEditingController();
  final TextEditingController project = TextEditingController();
  final TextEditingController studentId = TextEditingController();

  LecturerDashboard({super.key});

  bool _isNumberField(TextEditingController controller) {
    return controller == test ||
        controller == assignment ||
        controller == project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Carry Marks"),
        backgroundColor: Colors.green,
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildFieldCard(studentId, "Student ID"),
            buildFieldCard(test, "Test (20%)"),
            buildFieldCard(assignment, "Assignment (10%)"),
            buildFieldCard(project, "Project (20%)"),

            const SizedBox(height: 25),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                 double testScore = double.tryParse(test.text)?? 0;
                 double assignmentScore = double.tryParse(assignment.text)?? 0;
                 double projectScore = double.tryParse(project.text) ?? 0;

                 double total = testScore + assignmentScore + projectScore;

                 await FirestoreService().saveCarryMark(
                  studentId.text.trim(),
                   testScore, 
                   assignmentScore, 
                   projectScore,
                   );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Carry Mark Saved Successfully. Total Score = $total",
                      ),
                    ),
                  );
                },
                child: const Text("Save Carry Mark"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------
  //      FIELD CARD UI
  // -----------------------
  Widget buildFieldCard(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType:
                _isNumberField(controller) ? TextInputType.number : TextInputType.text,
          ),
        ),
      ),
    );
  }
}
