import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class AppTextStyle {
  static const String? _fontFamily = null;

  static TextStyle regularBlack({double? fontSize, TextOverflow? overflow}) {
    return _baseStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      overflow: overflow,
    );
  }

  static TextStyle mediumBlack({double? fontSize, TextOverflow? overflow}) {
    return _baseStyle(
      color: Colors.black,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      overflow: overflow,
    );
  }

  static TextStyle semiBoldBlack({double? fontSize, TextOverflow? overflow}) {
    return _baseStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      overflow: overflow,
    );
  }

  static TextStyle boldBlack({double? fontSize, TextOverflow? overflow}) {
    return _baseStyle(
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      overflow: overflow,
    );
  }

  static TextStyle gameTitle({double? fontSize}) {
    return _baseStyle(
      color: AppColors.titleColor,
      fontWeight: FontWeight.w800,
      fontSize: fontSize ?? 42,
      letterSpacing: 1.2,
    );
  }

  static TextStyle gameSubtitle({double? fontSize}) {
    return _baseStyle(
      color: AppColors.subtitleColor,
      fontWeight: FontWeight.w500,
      fontSize: fontSize ?? 16,
      letterSpacing: 0.5,
    );
  }

  static TextStyle buttonLabel({double? fontSize}) {
    return _baseStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: fontSize ?? 22,
      letterSpacing: 1.5,
    );
  }

  static TextStyle _baseStyle({
    double? fontSize,
    Color? color,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: _fontFamily,
      fontWeight: fontWeight,
      overflow: overflow,
      letterSpacing: letterSpacing,
    );
  }
}
