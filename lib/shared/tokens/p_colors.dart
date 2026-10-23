import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';

class PColor {
  static Color primaryColor = TWColors.blue.shade600; // ตัวอย่างสีหลัก
  static const Color secondaryColor = Colors.deepPurple; // ตัวอย่างสีรอง
  static Color backgroundColor = TWColors.gray.shade100; // สีพื้นหลัง
  static Color neutralColor = TWColors.gray.shade50;
  static const Color textNeutralColor = Color.fromRGBO(117, 117, 117, 1);
  static Color contentColor = TWColors.gray.shade900;
  static Color errorColor = TWColors.red.shade400;
  static void updatePrimaryColor(Color color) {
    primaryColor = color;
  }
}
