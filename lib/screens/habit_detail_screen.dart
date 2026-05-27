import 'package:flutter/material.dart';
import '../models/habit.dart';

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
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF9F27),
        title: Text(
          '${habit.icon} ${habit.name}',
          style: const TextStyle(
            color: Color(0xFF412402),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF412402)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 절약액 메인 카드
            if (habit.savingAmount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAEEDA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      '총 절약액',
                      style: TextStyle(fontSize: 12, color: Color(0xFF633806)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatMoney(habit.totalSaving)}원',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF9F27),
                      ),
                    ),
                    Text(
                      '${habit.completedDates.length}일 달성 × ${habit.savingCycle}일마다 ${_formatMoney(habit.savingAmount)}원',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF633806),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // 스트릭 통계
            Row(
              children: [
                _StatCard(label: '현재 스트릭 🔥', value: '${habit.currentStreak}일'),
                const SizedBox(width: 8),
                _StatCard(label: '최장 스트릭', value: '${habit.longestStreak}일'),
                const SizedBox(width: 8),
                _StatCard(
                  label: '총 달성',
                  value: '${habit.completedDates.length}일',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 달력
            const Text('이번달 기록', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 요일 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map(
                          (d) => SizedBox(
                            width: 32,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF633806),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // 날짜 그리드
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

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? const Color(0xFFEF9F27)
                              : isToday
                              ? const Color(0xFFFAEEDA)
                              : Colors.transparent,
                          border: isToday && !isDone
                              ? Border.all(
                                  color: const Color(0xFFEF9F27),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDone
                                  ? const Color(0xFF412402)
                                  : const Color(0xFF2C2C2A),
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

            // 달력 범례
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEF9F27),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '완료',
                  style: TextStyle(fontSize: 12, color: Color(0xFF633806)),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF9F27),
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '오늘',
                  style: TextStyle(fontSize: 12, color: Color(0xFF633806)),
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

  const _StatCard({required this.label, required this.value});

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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF9F27),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF633806)),
            ),
          ],
        ),
      ),
    );
  }
}
