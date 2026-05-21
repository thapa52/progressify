import 'package:flutter/material.dart';

enum AppTextStyle {
  heading,
  subHeading,
  title,
  body,
  bodyBold,
  caption,
  button,
  label,
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? textAlgn;
  final int? maxlines;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppText(
    this.text, {
    super.key,
    this.style = AppTextStyle.body,
    this.color,
    this.textAlgn,
    this.maxlines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlgn,
      maxLines: maxlines,
      overflow: overflow,
      style: _buildStyle(context),
    );
  }

  TextStyle _buildStyle(BuildContext context) {
    TextStyle baseStyle;

    switch (style) {
      case AppTextStyle.heading:
        baseStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      case AppTextStyle.subHeading:
        baseStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      case AppTextStyle.title:
        baseStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
      case AppTextStyle.body:
        baseStyle = const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        );
      case AppTextStyle.bodyBold:
        baseStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case AppTextStyle.caption:
        baseStyle = const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        );
      case AppTextStyle.button:
        baseStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case AppTextStyle.label:
        baseStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
    }

    return baseStyle.copyWith(
      color: color,
      fontSize: fontSize ?? baseStyle.fontSize,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
    );
  }
}
