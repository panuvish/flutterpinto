import 'package:flutter/material.dart';

const Color kBrandBlue = Color(0xFF2962FF);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: kBrandBlue),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kBrandBlue,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
);

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // พื้นหลังหน้า
  Color get bg => Theme.of(this).scaffoldBackgroundColor;

  // พื้นการ์ด กลุ่ม appbar
  Color get cardColor2 => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  // ข้อความหลัก
  Color get textMain =>
      isDark ? const Color(0xFFECEFF1) : const Color(0xFF263238);

  // ข้อความรอง
  Color get textSub =>
      isDark ? const Color(0xFF90A4AE) : const Color(0xFF78909C);

  // พื้นกล่องไอคอนสีฟ้าอ่อน
  Color get iconChipBg =>
      isDark ? const Color(0xFF1F2E4D) : const Color(0xFFE7F0FF);

  // เงาของการ์ด
  Color get shadowColor2 =>
      isDark ? Colors.transparent : Colors.blueGrey.withValues(alpha: 0.07);

  // สีฟ้าสำหรับข้อความ
  Color get blue => isDark ? const Color(0xFF82B1FF) : kBrandBlue;
}