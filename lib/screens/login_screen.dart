import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'admin_screen.dart';
import 'lecturer_screen.dart';
import 'student_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userC = TextEditingController();
  final _passC = TextEditingController();
  bool loading = false;
  String message = '';

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('ICT602 — Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _userC,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _passC,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading
                ? null
                : () async {
                    setState(() {
                      loading = true;
                      message = '';
                    });

                    final ok = await app.login(
                      _userC.text.trim(),
                      _passC.text.trim(),
                    );

                    setState(() {
                      loading = false;
                    });

                    if (!ok) {
                      setState(() {
                        message = 'Login failed — check username/password';
                      });
                      return;
                    }

                    final role = app.currentUser!['role'] as String;
                    if (role == 'administrator') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminScreen()));
                    } else if (role == 'lecturer') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LecturerScreen()));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentScreen()));
                    }
                  },
            child:
                loading ? const CircularProgressIndicator() : const Text('Login'),
          ),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.red)),
        ]),
      ),
    );
  }
}
