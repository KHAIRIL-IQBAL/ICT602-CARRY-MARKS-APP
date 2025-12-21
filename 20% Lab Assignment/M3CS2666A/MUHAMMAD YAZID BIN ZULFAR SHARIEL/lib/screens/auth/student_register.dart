import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/pixel_panel.dart';
import '../../components/pixel_button.dart';
import '../dashboard/student_dashboard.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({super.key});

  @override
  State<StudentRegister> createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final name = TextEditingController();
  final email = TextEditingController();
  final studentID = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool obscure = true;

  Future<void> registerStudent() async {
    if (loading) return;
    setState(() => loading = true);

    try {
      // 1) Create Firebase Authentication User
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      String uid = cred.user!.uid;

      // 2) Save student profile to Firestore
      await FirebaseFirestore.instance.collection("students").doc(uid).set({
        "name": name.text.trim(),
        "email": email.text.trim(),
        "studentID": studentID.text.trim(),
        "carrymark": {
          "test": 0,
          "assignment": 0,
          "project": 0,
        }
      });

      // 3) Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(
            data: {
              "name": name.text.trim(),
              "email": email.text.trim(),
              "studentID": studentID.text.trim(),
              "carrymark": {
                "test": 0,
                "assignment": 0,
                "project": 0,
              },
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // Reusable pixel-themed text field style
  InputDecoration pixelInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: "Minecraft",
        color: Colors.white,
        fontSize: 16,
      ),
      filled: true,
      fillColor: const Color(0xFF60A5FA),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 3),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Student Registration",
          style: TextStyle(fontFamily: "Minecraft"),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // FIXED back button color
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PixelPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // FULL NAME
                TextField(
                  controller: name,
                  style: const TextStyle(
                      fontFamily: "Minecraft", color: Colors.white),
                  decoration: pixelInput("Full Name"),
                ),
                const SizedBox(height: 15),

                // STUDENT ID
                TextField(
                  controller: studentID,
                  style: const TextStyle(
                      fontFamily: "Minecraft", color: Colors.white),
                  decoration: pixelInput("Student ID"),
                ),
                const SizedBox(height: 15),

                // EMAIL
                TextField(
                  controller: email,
                  style: const TextStyle(
                      fontFamily: "Minecraft", color: Colors.white),
                  decoration: pixelInput("Email"),
                ),
                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: password,
                  obscureText: obscure,
                  style: const TextStyle(
                      fontFamily: "Minecraft", color: Colors.white),
                  decoration: pixelInput("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                PixelButton(
                  text: loading ? "CREATING..." : "REGISTER",
                  width: 200,
                  height: 55,
                  onTap: registerStudent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
