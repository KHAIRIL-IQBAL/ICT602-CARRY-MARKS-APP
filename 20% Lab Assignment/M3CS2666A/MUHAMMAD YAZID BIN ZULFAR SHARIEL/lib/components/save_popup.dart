import 'package:flutter/material.dart';

class SavePopup {
  static void show(BuildContext context) {
    OverlayEntry entry = OverlayEntry(
      builder: (_) => Center(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              border: Border.all(width: 4, color: Colors.black),
            ),
            child: const Text(
              "SAVED!",
              style: TextStyle(
                fontFamily: "Minecraft",
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 1), () {
      entry.remove();
    });
  }
}
