import 'package:flutter/material.dart';
import 'student_list_page.dart';
import 'logout_page.dart';

class LecturerHomePage extends StatelessWidget {
  const LecturerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer Dashboard"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              // Navigate to logout page or sign out directly
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogoutPage()),
              );
            },
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Color(0xFF673AB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo.png', // Make sure you have this in assets folder
                  height: 80,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Lecturer",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Manage your class efficiently",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    // Manage Students (same page as Enter Carry Marks)
                    _DashboardCard(
                      title: "Enter Carry Marks",
                      icon: Icons.grade,
                      color: Colors.deepPurple.shade700,
                      onTap: () {
                        // Navigate to Student List Page first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentListPage(),
                          ),
                        );
                      },
                    ),

                    // Attendance Placeholder
                    _DashboardCard(
                      title: "Attendance",
                      icon: Icons.assessment,
                      color: Colors.deepPurple.shade400,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Coming soon!")),
                        );
                      },
                    ),

                    // Reports Placeholder
                    _DashboardCard(
                      title: "Reports",
                      icon: Icons.bar_chart,
                      color: Colors.deepPurple.shade200,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Coming soon!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable dashboard card
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
