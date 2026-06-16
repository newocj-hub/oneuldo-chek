import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../utils/theme_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _getFunMessage(int amount) {
    if (amount <= 0) return '절약 습관을 시작해보세요! 💪';
    if (amount < 10000) return '편의점 간식 ${(amount ~/ 2000)}개를 살 수 있어요! 🍫';
    if (amount < 30000) return '치킨 ${(amount ~/ 20000)}마리를 살 수 있어요! 🍗';
    if (amount < 100000) return '맛있는 식사 ${(amount ~/ 30000)}번을 할 수 있어요! 🍽️';
    if (amount < 500000) return '여행 적금 ${_formatMoney(amount)}원 모았어요! ✈️';
    return '대단해요! ${_formatMoney(amount)}원이나 절약했어요! 🏆';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: const Text(
          '전체 통계',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: theme.textDark,
        iconTheme: IconThemeData(color: theme.textDark),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.toList();
          final totalSaving = habits.fold<int>(
            0,
            (sum, h) => sum + h.totalSaving,
          );
          final totalDays = habits.fold<int>(
            0,
            (sum, h) => sum + h.completedDates.length,
          );
          final longestStreak = habits.isEmpty
              ? 0
              : habits
                    .map((h) => h.longestStreak)
                    .reduce((a, b) => a > b ? a : b);

          final sortedHabits = [...habits]
            ..sort((a, b) => b.totalSaving.compareTo(a.totalSaving));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.light,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '총 절약액',
                        style: TextStyle(fontSize: 14, color: theme.textLight),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatMoney(totalSaving)}원',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getFunMessage(totalSaving),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(
                      label: '절약 습관',
                      value: '${habits.length}개',
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: '총 달성일',
                      value: '${totalDays}일',
                      theme: theme,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: '최장 스트릭',
                      value: '${longestStreak}일',
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '습관별 절약액 순위',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (habits.isEmpty)
                  Center(
                    child: Text(
                      '아직 습관이 없어요!',
                      style: TextStyle(color: theme.textLight),
                    ),
                  )
                else
                  ...sortedHabits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final habit = entry.value;
                    final maxSaving = sortedHabits.first.totalSaving;
                    final ratio = maxSaving == 0
                        ? 0.0
                        : habit.totalSaving / maxSaving;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: index == 0
                                  ? theme.primary
                                  : const Color(0xFF888780),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            habit.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: theme.light,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.primary,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatMoney(habit.totalSaving)}원',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final dynamic theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: theme.textLight)),
          ],
        ),
      ),
    );
  }
}
