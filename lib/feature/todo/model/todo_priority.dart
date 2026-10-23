import 'package:flutter/material.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';

enum TodoPriority {
  low(0, Color(0xFF42A5F5)),
  medium(1, Color(0xFFFFA000)),
  high(2, Color(0xFFE53935));

  const TodoPriority(this.value, this.color);

  final int value;
  final Color color;

  static TodoPriority fromInt(int v) => v >= 2
      ? high
      : v == 1
          ? medium
          : low;

  String label(S s) => switch (this) {
        low => s.priorityLow,
        medium => s.priorityMedium,
        high => s.priorityHigh,
      };
}