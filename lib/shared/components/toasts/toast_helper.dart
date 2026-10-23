import 'package:flutter/material.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';
import 'package:mobile_app_standard/shared/tokens/p_radius.dart';
import 'package:mobile_app_standard/shared/tokens/p_spacing.dart';
import 'package:toastification/toastification.dart';

void showErrorToast({
  required BuildContext context,
  String? title,
  String description = '',
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  toastification.show(
      context: context,
      alignment: Alignment.topCenter,
      title: Text(title ?? "", style: TextStyle(fontSize: 18)),
      description: Text(description),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: autoCloseDuration,
      icon: Icon(Icons.error_outline, color: PColor.errorColor),
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: EdgeInsets.all(PSpacing.lg),
      margin: EdgeInsets.all(PSpacing.xl),
      borderRadius: BorderRadius.circular(PRadius.md),
      progressBarTheme: ProgressIndicatorThemeData(
        color: PColor.errorColor,
        linearTrackColor: Colors.redAccent.withValues(alpha: 0.3),
      ));
}

void showSuccessToast({
  required BuildContext context,
  String? title,
  String description = '',
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  toastification.show(
      context: context,
      alignment: Alignment.topCenter,
      title: Text(title!, style: TextStyle(fontSize: 18)),
      description: Text(description),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: autoCloseDuration,
      icon: Icon(Icons.check_circle_outline, color: PColor.primaryColor),
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: EdgeInsets.all(PSpacing.lg),
      margin: EdgeInsets.all(PSpacing.xl),
      borderRadius: BorderRadius.circular(PRadius.md),
      progressBarTheme: ProgressIndicatorThemeData(
        color: PColor.primaryColor,
      ));
}
