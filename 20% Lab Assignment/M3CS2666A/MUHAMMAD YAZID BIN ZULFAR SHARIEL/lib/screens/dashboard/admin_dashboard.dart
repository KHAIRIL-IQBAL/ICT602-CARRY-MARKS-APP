import 'package:flutter/material.dart';
import '../../components/pixel_panel.dart';
import '../../components/pixel_button.dart';
import '../home_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void openWebLink() async {
    final Uri url = Uri.parse("https://example.com/ict602-carrymark-system"); // CHANGE URL

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontFamily: "Minecraft"),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PixelPanel(
              child: const Text(
                "Direct Access Link (Web-based Management)\n\nClick the button below:",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Minecraft", fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            PixelButton(
              text: "OPEN WEB MANAGEMENT",
              width: 230,
              onTap: openWebLink,
            ),

            const SizedBox(height: 30),

            PixelPanel(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PixelButton(
                    text: "BACK",
                    width: 120,
                    onTap: () => Navigator.pop(context),
                  ),
                  PixelButton(
                    text: "LOGOUT",
                    width: 120,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeMenu()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
