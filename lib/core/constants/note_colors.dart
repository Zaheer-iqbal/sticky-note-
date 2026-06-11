import 'package:flutter/material.dart';

class NoteColors {
  static const Color yellow = Color(0xFFFFF3CD);
  static const Color green = Color(0xFFD4EDDA);
  static const Color blue = Color(0xFFD6EAF8);
  static const Color red = Color(0xFFF5B7B1);
  static const Color purple = Color(0xFFE8DAEF);
  static const Color orange = Color(0xFFFDEBD0);
  static const Color pink = Color(0xFFFADBD8);
  static const Color white = Color(0xFFFFFFFF);

  static const Map<String, Color> colors = {
    'Yellow': yellow,
    'Green': green,
    'Blue': blue,
    'Red': red,
    'Purple': purple,
    'Orange': orange,
    'Pink': pink,
    'White': white,
  };

  static Color fromName(String name) => colors[name] ?? white;

  static String nameFromColor(Color color) {
    return colors.entries
        .firstWhere(
          (e) => e.value.toARGB32() == color.toARGB32(),
          orElse: () => const MapEntry('White', white),
        )
        .key;
  }
}
