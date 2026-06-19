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
      name: '민트 그린',
      primary: Color(0xFF1D9E75),
      light: Color(0xFFE1F5EE),
      background: Color(0xFFFDFAF4),
      textDark: Color(0xFF04342C),
      textLight: Color(0xFF0F6E56),
    ),
    AppThemeData(
      name: '피치 오렌지',
      primary: Color(0xFFD4783A),
      light: Color(0xFFFFE8D6),
      background: Color(0xFFFFF8F3),
      textDark: Color(0xFF4A2010),
      textLight: Color(0xFF7A3D1A),
    ),
    AppThemeData(
      name: '라벤더',
      primary: Color(0xFF6058B8),
      light: Color(0xFFEAE8FF),
      background: Color(0xFFF8F7FF),
      textDark: Color(0xFF26215C),
      textLight: Color(0xFF3A3480),
    ),
    AppThemeData(
      name: '로즈 핑크',
      primary: Color(0xFFA8345E),
      light: Color(0xFFFFE0EB),
      background: Color(0xFFFFF5F8),
      textDark: Color(0xFF4B1528),
      textLight: Color(0xFF6B1835),
    ),
    AppThemeData(
      name: '크림 아이보리',
      primary: Color(0xFF7A6040),
      light: Color(0xFFF2ECD8),
      background: Color(0xFFFDFAF5),
      textDark: Color(0xFF2C2010),
      textLight: Color(0xFF4A3B1F),
    ),
  ];
}

class BankApp {
  final String name;
  final String emoji;
  final String scheme;

  const BankApp({
    required this.name,
    required this.emoji,
    required this.scheme,
  });
}

class BankApps {
  static const List<BankApp> apps = [
    BankApp(name: '토스', emoji: '💙', scheme: 'supertoss://'),
    BankApp(name: '카카오뱅크', emoji: '💛', scheme: 'kakaobank://'),
    BankApp(name: '국민은행', emoji: '🟡', scheme: 'kbbank://'),
    BankApp(name: '신한은행', emoji: '🔵', scheme: 'shinhan://'),
    BankApp(name: '우리은행', emoji: '🔵', scheme: 'wooribank://'),
    BankApp(name: '하나은행', emoji: '🟢', scheme: 'hanabank://'),
    BankApp(name: '농협은행', emoji: '🟢', scheme: 'nonghyup://'),
    BankApp(name: '케이뱅크', emoji: '⚫', scheme: 'kbank://'),
  ];
}
