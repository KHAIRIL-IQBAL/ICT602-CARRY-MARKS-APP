import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/student_home.dart';
import 'screens/lecturer_home.dart';
import 'screens/admin_home.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marks App',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/studentHome': (context) => const StudentHomePage(),
        '/adminHome': (context) => const AdminHomePage(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        // Lecturer page requires lecturerId argument
        if (settings.name == '/lecturerHome') {
          final lecturerId = settings.arguments as String?;
          if (lecturerId != null) {
            return MaterialPageRoute(
              builder: (context) => LecturerHomePage(lecturerId: lecturerId),
            );
          } else {
            return MaterialPageRoute(builder: (context) => const LoginPage());
          }
        }
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
    );
  }
}
