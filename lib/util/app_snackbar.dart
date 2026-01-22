import 'package:flutter/material.dart';

class AppSnackBar {
  AppSnackBar._(); // private constructor

  /// ❌ Error SnackBar
  static void showError(
      BuildContext context, {
        String message = 'Something went wrong. Please try again.',
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF2D2D2D),
      icon: Icons.error_outline,
      iconColor: Colors.redAccent,
    );
  }

  /// ✅ Success SnackBar
  static void showSuccess(
      BuildContext context, {
        String message = 'Operation completed successfully.',
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E3A2F),
      icon: Icons.check_circle_outline,
      iconColor: Colors.greenAccent,
    );
  }


  static void showInfo(
      BuildContext context, {
        String message = 'Please check the information.',
      }) {
    _show(
      context,
      message: message,
      backgroundColor: const Color(0xFF1F2A44),
      icon: Icons.info_outline,
      iconColor: Colors.lightBlueAccent,
    );
  }

  /// 🔁 Common method (private)
  static void _show(
      BuildContext context, {
        required String message,
        required Color backgroundColor,
        required IconData icon,
        required Color iconColor,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
