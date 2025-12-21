import 'package:flutter/material.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  // NEW: custom widget instead of text
  final Widget? childOverride;

  const PixelButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.childOverride,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    double fontSize = isMobile ? 20 : 26;
    double scaleAmount = pressed ? 0.92 : (hovered ? 1.05 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) {
          setState(() => pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => pressed = false),

        child: AnimatedScale(
          scale: scaleAmount,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,

          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            margin: const EdgeInsets.symmetric(vertical: 8),

            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/pixel_button.png"),
                fit: BoxFit.fill,
              ),
              border: Border.all(width: 4, color: Colors.black),
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),

            // If custom child provided → use it
            // Else → use normal text
            child: Center(
              child: widget.childOverride ??
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: "Minecraft",
                      fontSize: fontSize,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.6),
                        )
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
