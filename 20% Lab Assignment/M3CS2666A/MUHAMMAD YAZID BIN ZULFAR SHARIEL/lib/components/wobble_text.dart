import 'package:flutter/material.dart';
import 'dart:math';

class WobbleText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;

  const WobbleText({
    super.key,
    required this.text,
    this.fontSize = 40,
    this.color = Colors.white,
  });

  @override
  State<WobbleText> createState() => _WobbleTextState();
}

class _WobbleTextState extends State<WobbleText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        double wobble = sin(controller.value * 2 * pi) * 4;

        return Transform.translate(
          offset: Offset(0, wobble),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: "Minecraft",
              fontSize: widget.fontSize,
              color: widget.color,
              shadows: const [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black,
                  offset: Offset(2, 2),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
