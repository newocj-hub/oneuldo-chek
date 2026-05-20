import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import 'add_habit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekday = today.weekday - 1;
    print('오늘 weekday: ${today.weekday}, 변환후: $weekday');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF9F27),
        title: const Text(
          '오늘도첵',
          style: TextStyle(
            color: Color(0xFF412402),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFF412402)),
            onPressed: () {},
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values
              .where((h) => h.repeatDays.contains(weekday))
              .toList();
          final completed = habits.where((h) => h.isCompletedToday).length;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFAEEDA),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      habits.isEmpty
                          ? '습관을 추가해보세요!'
                          : '$completed / ${habits.length} 완료',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF633806),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: habits.isEmpty
                    ? const Center(
                        child: Text(
                          '오늘의 습관이 없어요\n아래 + 버튼으로 추가해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          return _HabitCard(habit: habit, todayKey: todayKey);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF9F27),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen()),
          );
        },
        child: const Icon(Icons.add, color: Color(0xFF412402)),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final String todayKey;

  const _HabitCard({required this.habit, required this.todayKey});

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCompletedToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(habit.icon, style: const TextStyle(fontSize: 28)),
        title: Text(
          habit.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDone ? Colors.grey : const Color(0xFF2C2C2A),
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Text(
              '${habit.currentStreak}일',
              style: const TextStyle(fontSize: 12, color: Color(0xFF633806)),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            if (isDone) {
              habit.completedDates.remove(todayKey);
            } else {
              habit.completedDates.add(todayKey);
            }
            habit.save();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? const Color(0xFFEF9F27) : Colors.transparent,
              border: Border.all(color: const Color(0xFFEF9F27), width: 2),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
