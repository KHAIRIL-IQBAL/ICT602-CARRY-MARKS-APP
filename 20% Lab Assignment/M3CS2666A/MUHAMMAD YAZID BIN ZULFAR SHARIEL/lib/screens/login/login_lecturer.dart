import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/lecturer_dashboard.dart';
import '../../components/pixel_button.dart';

class LecturerLogin extends StatefulWidget {
  const LecturerLogin({super.key});

  @override
  State<LecturerLogin> createState() => _LecturerLoginState();
}

class _LecturerLoginState extends State<LecturerLogin> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future login() async {
    try {
      setState(() => loading = true);

      final auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final doc = await FirebaseFirestore.instance
          .collection("lecturers")
          .doc(auth.user!.uid)
          .get();

      if (!doc.exists) {
        _error("Lecturer account not found.");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerDashboard()),
      );
    } catch (e) {
      _error("Invalid lecturer credentials.");
    } finally {
      setState(() => loading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

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
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white, width: 3),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            border: Border.all(width: 4, color: Colors.black),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Lecturer Login",
                style: TextStyle(
                  fontFamily: "Minecraft",
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: email,
                style: const TextStyle(
                  fontFamily: "Minecraft",
                  color: Colors.white,
                ),
                decoration: pixelInput("Email"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: password,
                obscureText: true,
                style: const TextStyle(
                  fontFamily: "Minecraft",
                  color: Colors.white,
                ),
                decoration: pixelInput("Password"),
              ),

              const SizedBox(height: 25),

              loading
                  ? const CircularProgressIndicator()
                  : PixelButton(
                      text: "LOGIN",
                      width: 180,
                      height: 55,
                      onTap: login,
                    ),

              const SizedBox(height: 20),

              PixelButton(
                text: "BACK",
                width: 220,
                height: 55,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
