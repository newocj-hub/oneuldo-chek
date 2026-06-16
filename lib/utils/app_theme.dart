import 'package:flutter/material.dart';

class AppThemeData {
  final String name;
  final Color primary;
  final Color light;
  final Color background;
  final Color textDark;
  final Color textLight;

  const AppThemeData({
    required this.name,
    required this.primary,
    required this.light,
    required this.background,
    required this.textDark,
    required this.textLight,
  });
}

class AppThemes {
  static const List<AppThemeData> themes = [
    AppThemeData(
      name: '선셋 오렌지',
      primary: Color(0xFFEF9F27),
      light: Color(0xFFFAEEDA),
      background: Color(0xFFFFFBF2),
      textDark: Color(0xFF412402),
      textLight: Color(0xFF633806),
    ),
    AppThemeData(
      name: '라벤더 퍼플',
      primary: Color(0xFF7F77DD),
      light: Color(0xFFEEEDFE),
      background: Color(0xFFF5F4FE),
      textDark: Color(0xFF26215C),
      textLight: Color(0xFF3C3489),
    ),
    AppThemeData(
      name: '민트 그린',
      primary: Color(0xFF1D9E75),
      light: Color(0xFFE1F5EE),
      background: Color(0xFFF4FBF8),
      textDark: Color(0xFF04342C),
      textLight: Color(0xFF0F6E56),
    ),
    AppThemeData(
      name: '스카이 블루',
      primary: Color(0xFF378ADD),
      light: Color(0xFFE6F1FB),
      background: Color(0xFFF2F8FE),
      textDark: Color(0xFF042C53),
      textLight: Color(0xFF185FA5),
    ),
    AppThemeData(
      name: '로즈 핑크',
      primary: Color(0xFFD4537E),
      light: Color(0xFFFBEAF0),
      background: Color(0xFFFEF5F8),
      textDark: Color(0xFF4B1528),
      textLight: Color(0xFF993556),
    ),
  ];
}
