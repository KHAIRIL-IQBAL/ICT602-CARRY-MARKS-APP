import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Adminhomepage extends StatelessWidget {
  const Adminhomepage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "Admin";

    return Scaffold(
      body: Row(
        children: [
          // =============================
          //       SIDE NAVIGATION
          // =============================
          Container(
            width: 250,
            color: Colors.blue.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DrawerHeader(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SidebarItem(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () {},
                ),
                SidebarItem(
                  icon: Icons.person,
                  title: "Users",
                  onTap: () {},
                ),
                SidebarItem(
                  icon: Icons.list_alt,
                  title: "Reports",
                  onTap: () {},
                ),
                SidebarItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {},
                ),
              ],
            ),
          ),

          // =============================
          //         MAIN CONTENT
          // =============================
          Expanded(
            child: Column(
              children: [
                // -------- TOP BAR -------- //
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dashboard Overview",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            userEmail,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 20),

                          // Logout Button
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // -------------- BODY CONTENT -------------- //
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        DashboardCard(
                          title: "Total Users",
                          value: "120",
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        DashboardCard(
                          title: "Packages",
                          value: "34",
                          icon: Icons.card_travel,
                          color: Colors.green,
                        ),
                        DashboardCard(
                          title: "Bookings",
                          value: "89",
                          icon: Icons.book_online,
                          color: Colors.orange,
                        ),
                        DashboardCard(
                          title: "Reports",
                          value: "12",
                          icon: Icons.bar_chart,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
//     Sidebar Item Widget
// =========================
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}

// =========================
//     Dashboard Card Widget
// =========================
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
