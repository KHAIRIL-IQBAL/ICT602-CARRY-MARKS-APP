import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/pixel_button.dart';
import '../../components/pixel_panel.dart';
import '../home_menu.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> data;

  const StudentDashboard({super.key, required this.data});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String? selectedGrade;
  int? requiredMarks;

  // Grade boundaries
  final List<Map<String, dynamic>> gradeBands = [
    {"grade": "A+", "min": 90},
    {"grade": "A", "min": 80},
    {"grade": "A-", "min": 75},
    {"grade": "B+", "min": 70},
    {"grade": "B", "min": 65},
    {"grade": "B-", "min": 60},
    {"grade": "C+", "min": 55},
    {"grade": "C", "min": 50},
  ];

  // For table calculation
  int needed(int target, int total) {
    final x = target - total;
    return x < 0 ? 0 : x;
  }

  @override
  Widget build(BuildContext context) {
    final cm = widget.data["carrymark"] ?? {};
    final int total = (cm["test"] ?? 0) +
        (cm["assignment"] ?? 0) +
        (cm["project"] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFF8EC5FF),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 8,
        centerTitle: true,
        title: const Text(
          "Student Dashboard",
          style: TextStyle(fontFamily: "Minecraft", fontSize: 24),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // --------------------------
          // STUDENT HEADER PANEL
          // --------------------------
          PixelPanel(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data["name"] ?? "Unknown Student",
                  style: const TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.data["email"] ?? "",
                  style: const TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------
          // CARRY MARKS
          // --------------------------
          PixelPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Carry Mark Breakdown",
                  style: TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid layout for carry marks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoTile("Test", cm["test"] ?? 0),
                    _infoTile("Assignment", cm["assignment"] ?? 0),
                    _infoTile("Project", cm["project"] ?? 0),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  "Total Carrymark: $total / 50",
                  style: const TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 20,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------
          // EXAM SCORE NEEDED TABLE
          // --------------------------
          PixelPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Exam Score Required",
                  style: TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),

                ...gradeBands.map((g) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${g["grade"]} (${g["min"]} target):  ${needed(g["min"], total)} needed",
                      style: const TextStyle(
                        fontFamily: "Minecraft",
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------
          // TARGET GRADE CALCULATOR
          // --------------------------
          PixelPanel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Target Grade Calculator",
                  style: TextStyle(
                    fontFamily: "Minecraft",
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGrade,
                      isExpanded: true,
                      dropdownColor: Colors.white,

                      hint: const Text(
                        "Choose Target Grade",
                        style: TextStyle(
                            fontFamily: "Minecraft", fontSize: 16),
                      ),

                      items: gradeBands.map((g) {
                        int minScore = g["min"];
                        int scoreNeeded = minScore - total;
                        bool impossible = scoreNeeded > 50;

                        return DropdownMenuItem<String>(
                          value: g["grade"],
                          enabled: !impossible,
                          child: Text(
                            impossible
                                ? "${g["grade"]}  (Not possible)"
                                : "${g["grade"]}  (Need $scoreNeeded)",
                            style: TextStyle(
                              fontFamily: "Minecraft",
                              fontSize: 16,
                              color: impossible ? Colors.grey : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          selectedGrade = value;
                          final chosen = gradeBands
                              .firstWhere((g) => g["grade"] == value);
                          requiredMarks = chosen["min"] - total;
                          if (requiredMarks! < 0) requiredMarks = 0;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                if (selectedGrade != null)
                  Text(
                    "To achieve $selectedGrade, you need at least $requiredMarks / 50 in the final exam.",
                    style: const TextStyle(
                      fontFamily: "Minecraft",
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // --------------------------
          // LOGOUT BUTTON FIXED + CENTERED
          // --------------------------
          Center(
            child: PixelButton(
              text: "LOGOUT",
              width: 200,
              height: 55,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeMenu()),
                  (route) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Small tiles for carry mark breakdown
  Widget _infoTile(String title, int value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "Minecraft",
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Text(
            "$value",
            style: const TextStyle(
              fontFamily: "Minecraft",
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
