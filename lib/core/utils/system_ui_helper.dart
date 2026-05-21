import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUIHelper {
  SystemUIHelper._();

  static const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle transparentDark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle transparentLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static SystemUiOverlayStyle custom({
    required Color statusBarColor,
    Brightness iconBrightness = Brightness.light,
  }) {
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness:
          iconBrightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
    );
  }
}
