import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘도첵'),
        backgroundColor: const Color(0xFFEF9F27),
      ),
      body: const Center(child: Text('오늘도첵 시작!')),
    );
  }
}
