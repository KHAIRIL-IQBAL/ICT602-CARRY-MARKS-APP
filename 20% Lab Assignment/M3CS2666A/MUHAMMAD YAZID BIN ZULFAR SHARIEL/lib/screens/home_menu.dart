import 'package:flutter/material.dart';
import '../components/moving_clouds.dart';
import '../components/wobble_text.dart';
import '../components/pixel_button.dart';
import 'login/login_student.dart';
import 'login/login_lecturer.dart';
import 'login/login_admin.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    bool isMobile = w < 600;
    double titleSize = isMobile ? 32 : 56;
    double spacing = isMobile ? 18 : 25;
    double buttonScale = isMobile ? 1.0 : 1.3;

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: Stack(
        children: [

          const MovingClouds(),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 60 : 90),
              child: WobbleText(
                text: "ICT602 ASSIGNMENT",
                fontSize: titleSize,
                color: Colors.white,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: buttonScale,
                  child: PixelButton(
                    text: "STUDENT",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentLogin()),
                    ),
                  ),
                ),

                SizedBox(height: spacing),

                Transform.scale(
                  scale: buttonScale,
                  child: PixelButton(
                    text: "LECTURER",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LecturerLogin()),
                    ),
                  ),
                ),

                SizedBox(height: spacing),

                Transform.scale(
                  scale: buttonScale,
                  child: PixelButton(
                    text: "ADMIN",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLogin()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: isMobile ? 80 : 130,
              child: Image.asset(
                "assets/images/grass.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
