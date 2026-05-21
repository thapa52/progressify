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
  final Color drawerHeaderColor;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.systemUiOverlayStyle,
    this.actions,
    this.appBarColor = Colors.indigo,
    this.drawerHeaderColor = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUIHelper.custom(
              statusBarColor: drawerHeaderColor,
              iconBrightness: Brightness.light,
            ),
          );
        } else {
          SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }
      },
      drawer: AppDrawer(headerColor: drawerHeaderColor),
      appBar: AppBar(
        title: AppText(title, style: AppTextStyle.title, color: Colors.white),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: systemUiOverlayStyle,
        actions: actions,
      ),
      body: body,
    );
  }
}
