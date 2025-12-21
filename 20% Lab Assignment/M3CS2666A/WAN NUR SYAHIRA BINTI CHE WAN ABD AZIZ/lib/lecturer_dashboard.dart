import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'dart:math';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _testController = TextEditingController();
  final TextEditingController _assignmentController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Animation controller for glitter stars
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose (){
    _emailController.dispose();
    _testController.dispose();
    _assignmentController.dispose();
    _projectController.dispose();
    _animationController.dispose();
    super.dispose();
    }

  Future<void> _submitMarks() async {
    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim();
      double test = double.parse(_testController.text.trim());
      double assignment = double.parse(_assignmentController.text.trim());
      double project = double.parse(_projectController.text.trim());

      await _firestore.collection('students').doc(email).set({
        'test': test,
        'assignment': assignment,
        'project': project,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marks submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9575CD),
        title: const Text("Lecturer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) =>  const LoginPage()));
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Pastel purple gradient background
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
          // Dashboard form
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.purple.shade200.withOpacity(0.4),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(_emailController, "Student ID"),
                    const SizedBox(height: 15),
                    _buildTextField(_testController, "Test (20%)", keyboard: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(_assignmentController, "Assignment (10%)", keyboard: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(_projectController, "Project (20%)", keyboard: TextInputType.number),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submitMarks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9575CD),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Submit Marks",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom reusable textfield
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.purple),
        filled: true,
        fillColor: Colors.purple.shade50.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.purple),
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
