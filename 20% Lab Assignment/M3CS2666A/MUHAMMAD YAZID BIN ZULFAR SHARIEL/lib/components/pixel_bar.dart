import 'package:flutter/material.dart';

class PixelBar extends StatelessWidget {
  final dynamic value;         // accepts int, double, string, null
  final int maxValue;
  final Color color;
  final double height;

  const PixelBar({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
    this.height = 22,
  });

  int _safeInt(dynamic v) {
    if (v == null) return 0;

    if (v is int) return v;

    if (v is double) return v.toInt();

    if (v is String) {
      return int.tryParse(v) ?? 0;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int v = _safeInt(value);

    double percentage = (v / maxValue).clamp(0, 1);
    int blockCount = (percentage * 12).round();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 4, color: Colors.black),
      ),
      child: Row(
        children: [
          for (int i = 0; i < blockCount; i++)
            Container(
              width: 14,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              color: color,
            ),

          for (int i = blockCount; i < 12; i++)
            Container(
              width: 14,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              color: Colors.grey.shade300,
            ),

          const SizedBox(width: 10),
          Text(
            "$v / $maxValue",
            style: const TextStyle(
              fontFamily: "Minecraft",
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
