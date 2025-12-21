import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard/student_dashboard.dart';
import '../dashboard/lecturer_dashboard.dart';
import '../dashboard/admin_dashboard.dart';
import '../home_menu.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const HomeMenu();

    return FutureBuilder<Map<String, dynamic>?>(
      future: _detectRoleAndData(user.uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snap.data!;
        final role = result["role"];

        if (role == "student") {
          return StudentDashboard(data: result["data"]);
        }
        if (role == "lecturer") {
          return const LecturerDashboard();
        }
        if (role == "admin") {
          return const AdminDashboard();
        }

        return const HomeMenu();
      },
    );
  }

  // Returns:  { "role": "student", "data": {...student data...} }
  Future<Map<String, dynamic>?> _detectRoleAndData(String uid) async {
    final fs = FirebaseFirestore.instance;

    final student = await fs.collection("students").doc(uid).get();
    if (student.exists) {
      return {
        "role": "student",
        "data": student.data(),
      };
    }

    final lecturer = await fs.collection("lecturers").doc(uid).get();
    if (lecturer.exists) {
      return {"role": "lecturer"};
    }

    final admin = await fs.collection("admins").doc(uid).get();
    if (admin.exists) {
      return {"role": "admin"};
    }

    return null;
  }
}
