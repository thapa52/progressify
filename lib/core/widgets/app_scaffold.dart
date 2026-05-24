import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/system_ui_helper.dart';
import 'app_drawer.dart';
import 'app_text.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final List<Widget>? actions;
  final Color appBarColor;
  final Color foregroundColor;
  final Color? drawerHeaderColor;
  final bool showDrawer;
  final bool centerTitle;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.systemUiOverlayStyle,
    this.actions,
    this.appBarColor = Colors.indigo,
    this.foregroundColor = Colors.white,
    this.drawerHeaderColor,
    this.showDrawer = true,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUIHelper.custom(
              statusBarColor: drawerHeaderColor ?? appBarColor,
              iconBrightness: Brightness.light,
            ),
          );
        } else {
          SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }
      },
      drawer:
          showDrawer
              ? AppDrawer(headerColor: drawerHeaderColor ?? appBarColor)
              : null,
      appBar: AppBar(
        title: AppText(title, style: AppTextStyle.title, color: Colors.white),
        centerTitle: centerTitle,
        backgroundColor: appBarColor,
        foregroundColor: foregroundColor,
        systemOverlayStyle: systemUiOverlayStyle,
        actions: actions,
      ),
      body: body,
    );
  }
}
