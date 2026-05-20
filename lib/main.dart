import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habits');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘도첵',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEF9F27)),
        scaffoldBackgroundColor: const Color(0xFFFFFBF2),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
