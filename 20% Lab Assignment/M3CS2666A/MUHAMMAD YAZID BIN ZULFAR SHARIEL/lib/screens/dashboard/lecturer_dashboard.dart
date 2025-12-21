import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/pixel_bar.dart';
import '../../components/pixel_button.dart';
import '../../components/pixel_panel.dart';
import '../edit/edit_marks.dart';
import '../home_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  String? selectedStudentId;
  String sort = "name";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD),

      // ---------------------------- APP BAR ----------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 6,
        shadowColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Lecturer Dashboard",
          style: TextStyle(
            fontFamily: "Minecraft",
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(2, 2), color: Colors.black),
            ],
          ),
        ),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) => setState(() => sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: "name", child: Text("Sort by Name")),
              PopupMenuItem(value: "high", child: Text("Highest Marks")),
              PopupMenuItem(value: "low", child: Text("Lowest Marks")),
            ],
          ),
        ],
      ),

      // ---------------------------- BODY ----------------------------
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("students").snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No students found.\nAdd students in Firestore.",
                style: TextStyle(fontFamily: "Minecraft", fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Sorting
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aName = aData["name"] ?? "";
            final bName = bData["name"] ?? "";

            final aTotal = getTotal(aData["carrymark"] ?? {});
            final bTotal = getTotal(bData["carrymark"] ?? {});

            if (sort == "name") return aName.compareTo(bName);
            if (sort == "high") return bTotal.compareTo(aTotal);
            return aTotal.compareTo(bTotal);
          });

          return Column(
            children: [
              const SizedBox(height: 20),

              // ---------------------------- DROPDOWN ----------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: PixelPanel(
                  padding: const EdgeInsets.all(14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStudentId,
                      hint: const Text(
                        "Select a Student",
                        style: TextStyle(
                          fontFamily: "Minecraft",
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      isExpanded: true,

                      items: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            "${data["name"]} (${data["email"]})",
                            style: const TextStyle(
                              fontFamily: "Minecraft",
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() => selectedStudentId = value);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------- STUDENT PANEL ----------------------------
              Expanded(
                child: selectedStudentId == null
                    ? const Center(
                        child: Text(
                          "Please select a student.",
                          style: TextStyle(
                            fontFamily: "Minecraft",
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          studentTile(
                            selectedStudentId!,
                            docs.firstWhere((d) => d.id == selectedStudentId).data()
                                as Map<String, dynamic>,
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),

      // ---------------------------- LOGOUT BAR ----------------------------
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: PixelPanel(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: PixelButton(
              text: "LOGOUT",
              width: 170,
              height: 50,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeMenu()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------- TOTAL MARKS ----------------------------
  int getTotal(Map cm) {
    return (cm["test"] ?? 0) +
        (cm["assignment"] ?? 0) +
        (cm["project"] ?? 0);
  }

  // ---------------------------- STUDENT TILE ----------------------------
  Widget studentTile(String uid, Map student) {
    final cm = student["carrymark"] ?? {"test": 0, "assignment": 0, "project": 0};
    final total = getTotal(cm);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditMarksPage(
            uid: uid,
            student: Map<String, dynamic>.from(student),
          ),
        ),
      ),

      child: PixelPanel(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student["name"] ?? "Unnamed",
              style: const TextStyle(
                fontFamily: "Minecraft",
                fontSize: 20,
                color: Colors.white,
              ),
            ),

            Text(
              student["email"] ?? "-",
              style: const TextStyle(
                fontFamily: "Minecraft",
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            PixelBar(value: cm["test"], maxValue: 20, color: Colors.blue.shade900),
            const SizedBox(height: 6),

            PixelBar(value: cm["assignment"], maxValue: 10, color: Colors.blue.shade700),
            const SizedBox(height: 6),

            PixelBar(value: cm["project"], maxValue: 20, color: Colors.blue.shade500),

            const SizedBox(height: 14),

            Text(
              "Total: $total / 50",
              style: const TextStyle(
                fontFamily: "Minecraft",
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
