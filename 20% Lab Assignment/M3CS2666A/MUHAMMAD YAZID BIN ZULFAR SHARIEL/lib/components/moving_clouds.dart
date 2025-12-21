import 'package:flutter/material.dart';

class MovingClouds extends StatefulWidget {
  const MovingClouds({super.key});

  @override
  State<MovingClouds> createState() => _MovingCloudsState();
}

class _MovingCloudsState extends State<MovingClouds>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    double cloudWidth = w < 600 ? 90 : 150;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double pos = controller.value * w;

        return Stack(
          children: [
            Positioned(
              left: -pos,
              top: cloudWidth * 0.1,
              child: Image.asset("assets/images/clouds/cloud1.png",
                  width: cloudWidth),
            ),
            Positioned(
              left: w - pos,
              top: cloudWidth * 0.35,
              child: Image.asset("assets/images/clouds/cloud2.png",
                  width: cloudWidth),
            ),
            Positioned(
              left: (w * 0.5) - pos,
              top: cloudWidth * 0.6,
              child: Image.asset("assets/images/clouds/cloud3.png",
                  width: cloudWidth),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
