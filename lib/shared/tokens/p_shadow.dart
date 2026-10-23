import 'package:flutter/material.dart';

class PShadow {
  static List<BoxShadow> get dropdown => [
        BoxShadow(
          color: Colors.grey.withAlpha(50),
          spreadRadius: 2,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
