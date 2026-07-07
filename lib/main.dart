import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/habit.dart';
import 'screens/home_screen.dart';
import 'utils/notification_service.dart';
import 'utils/theme_provider.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      Hive.registerAdapter(HabitAdapter());
      await Hive.openBox<Habit>('habits');
      await Hive.openBox('settings');
      await NotificationService().init();
      await _requestPermissions();
      runApp(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
    },
    // 오프라인 등으로 google_fonts가 폰트 다운로드에 실패해도
    // 이 예외가 앱 전체를 죽이지 않고 시스템 기본 폰트로 넘어가게 한다.
    (error, stack) => debugPrint('Uncaught error: $error'),
  );
}

Future<void> _requestPermissions() async {
  await Permission.notification.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    return MaterialApp(
      title: '오늘도첵',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.primary),
        scaffoldBackgroundColor: theme.background,
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
