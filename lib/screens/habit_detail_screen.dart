import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../utils/theme_provider.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    int perfectDays = 0;
    int monthlyTarget = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final weekday = DateTime(now.year, now.month, d).weekday - 1;
      if (habit.repeatDays.contains(weekday)) {
        monthlyTarget++;
        final dateKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
        if (habit.completedDates.contains(dateKey)) {
          perfectDays++;
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          '${habit.icon} ${habit.name}',
          style: TextStyle(color: theme.textDark, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: theme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.savingAmount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.light,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '총 절약액',
                      style: TextStyle(fontSize: 12, color: theme.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatMoney(habit.totalSaving)}원',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    Text(
                      '${habit.completedDates.length}일 달성 × ${habit.savingCycle}일마다 ${_formatMoney(habit.savingAmount)}원',
                      style: TextStyle(fontSize: 12, color: theme.textLight),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(
                  label: '현재 스트릭 🔥',
                  value: '${habit.currentStreak}일',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: '최장 스트릭',
                  value: '${habit.longestStreak}일',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: '총 달성',
                  value: '${habit.completedDates.length}일',
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번달 기록',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✅ $perfectDays / $monthlyTarget',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map(
                          (d) => SizedBox(
                            width: 32,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday) return const SizedBox();
                      final day = index - firstWeekday + 1;
                      final dateKey =
                          '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                      final isDone = habit.completedDates.contains(dateKey);
                      final isToday = day == now.day;
                      final weekday =
                          DateTime(now.year, now.month, day).weekday - 1;
                      final isTarget = habit.repeatDays.contains(weekday);

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? theme.primary
                              : isToday
                              ? theme.light
                              : Colors.transparent,
                          border: isToday && !isDone
                              ? Border.all(color: theme.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? theme.textDark
                                  : isTarget
                                  ? const Color(0xFF2C2C2A)
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '완료',
                  style: TextStyle(fontSize: 12, color: theme.textLight),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '오늘',
                  style: TextStyle(fontSize: 12, color: theme.textLight),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '목표 아님',
                  style: TextStyle(fontSize: 12, color: theme.textLight),
                ),
              ],
            ),
          ],
        ),
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
