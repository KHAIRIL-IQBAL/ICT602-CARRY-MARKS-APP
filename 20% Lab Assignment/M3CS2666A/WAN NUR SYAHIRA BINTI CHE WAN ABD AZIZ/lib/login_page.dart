import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

// Replace these imports with your actual dashboard pages' imports / routes
import 'admin_dashboard.dart';
import 'lecturer_dashboard.dart';
import 'student_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'Admin';
  bool _loading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Animation controller for stars
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      setState(() => _loading = false);
      return;
    }

    try {
      final User user = await _authService.signIn(email, password);
      final userData = await _authService.getUserDataByEmail(user.email ?? '');

      if (userData == null) {
        await FirebaseAuth.instance.signOut();
        _showMessage('User record not found in Firestore.');
        setState(() => _loading = false);
        return;
      }

      final firestoreRole = (userData['role'] ?? '').toString().toLowerCase();
      final selected = selectedRole.toLowerCase();

      if (firestoreRole != selected) {
        await FirebaseAuth.instance.signOut();
        _showMessage('User is not registered as $selectedRole.');
        setState(() => _loading = false);
        return;
      }

      if (selected == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminDashboard()));
      } else if (selected == 'lecturer') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LecturerDashboard()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => StudentDashboard()));
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'user-not-found') msg = 'No user found with that email.';
      else if (e.code == 'wrong-password') msg = 'Wrong password.';
      else msg = e.message ?? 'Authentication failed.';
      _showMessage(msg);
    } catch (e) {
      _showMessage('Login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.purple.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Login card
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.travel_explore, size: 80, color: Color(0xFF9575CD)),
                    const SizedBox(height: 15),
                    const Text(
                      "SUBJECT PORTAL ICT602",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF673AB7),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.purple),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9575CD)),
                        filled: true,
                        fillColor: Colors.purple.shade50.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.purple),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.purple),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9575CD)),
                        filled: true,
                        fillColor: Colors.purple.shade50.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.purple),
                    ),
                    const SizedBox(height: 20),

                    // Pretty dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.purple.shade50.withOpacity(0.7),
                        border: Border.all(color: const Color(0xFF9575CD)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          dropdownColor: Colors.purple.shade100,
                          style: const TextStyle(color: Colors.purple),
                          items: const [
                            DropdownMenuItem(value: "Admin", child: Text("Admin")),
                            DropdownMenuItem(value: "Lecturer", child: Text("Lecturer")),
                            DropdownMenuItem(value: "Student", child: Text("Student")),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
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
                                "LOGIN",
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
}

// Custom painter for glitter stars
class StarPainter extends CustomPainter {
  final double animationValue;
  final int starCount = 80;
  StarPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    final random = Random(42); // Fixed seed for consistent star positions

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


