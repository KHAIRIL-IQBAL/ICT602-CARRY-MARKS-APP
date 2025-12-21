import 'package:flutter/material.dart';

class PixelPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color color;        // Background color (customizable)
  final Color borderColor;  // Border color (customizable)

  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 20),
    this.color = const Color(0xFF3B82F6),   // Default bright blue
    this.borderColor = Colors.black,        // Default black border
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          width: 4,
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}
