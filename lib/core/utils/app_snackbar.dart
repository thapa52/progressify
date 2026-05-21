import 'package:flutter/material.dart';

import '../widgets/app_text.dart';
import 'app_messenger.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show({
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getIcon(type), color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  message,
                  style: AppTextStyle.body,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: _getColor(type),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  static void success(String message) {
    show(message: message, type: SnackBarType.success);
  }

  static void error(String message) {
    show(message: message, type: SnackBarType.error);
  }

  static void warning(String message) {
    show(message: message, type: SnackBarType.warning);
  }

  static void info(String message) {
    show(message: message, type: SnackBarType.info);
  }

  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }
}
