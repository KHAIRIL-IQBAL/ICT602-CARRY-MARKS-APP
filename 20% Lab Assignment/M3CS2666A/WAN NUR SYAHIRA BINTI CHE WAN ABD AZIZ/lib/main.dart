import 'package:assignment_2023131125/admin_dashboard.dart';
import 'package:assignment_2023131125/lecturer_dashboard.dart';
import 'package:assignment_2023131125/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';
import 'lecturer_dashboard.dart';
import 'student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Subject Portal',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/adminHome': (context) => const AdminDashboard(),
        '/lecturerHome': (context) => const LecturerDashboard(),
        '/studentHome': (context) => StudentDashboard()
      },
    );
  }
}
