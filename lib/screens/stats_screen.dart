import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../utils/theme_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriod = 0; // 0=1개월 1=3개월 2=전체

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _getFunMessage(int amount) {
    if (amount <= 0) return '절약 습관을 시작해보세요! 💪';
    if (amount < 5000) return '편의점 간식 ${(amount ~/ 1500)}개를 살 수 있어요! 🍫';
    if (amount < 15000) return '아메리카노 ${(amount ~/ 4500)}잔을 살 수 있어요! ☕';
    if (amount < 50000) return '치킨 ${(amount ~/ 20000)}마리를 살 수 있어요! 🍗';
    if (amount < 100000) return '맛있는 식사 ${(amount ~/ 30000)}번을 할 수 있어요! 🍽️';
    return '여행 적금 ${_formatMoney(amount)}원 모았어요! ✈️';
  }

  Color _getIconBg(int index) {
    final colors = [
      const Color(0xFFE1F5EE),
      const Color(0xFFFFE8D6),
      const Color(0xFFEAE8FF),
      const Color(0xFFFFE0EB),
      const Color(0xFFE6F1FB),
      const Color(0xFFFFF8E8),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: ValueListenableBuilder(
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

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: theme.textDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '전체 통계',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 총 절약액 카드
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.light,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '총 절약액',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textLight,
                            ),
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
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getFunMessage(totalSaving),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 통계 배지
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        _StatCard(
                          label: '절약 습관',
                          value: '${habits.length}개',
                          color: theme.primary,
                          bg: theme.light,
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: '총 달성일',
                          value: '${totalDays}일',
                          color: const Color(0xFFF5A97A),
                          bg: const Color(0xFFFFE8D6),
                        ),
                        const SizedBox(width: 8),
                        _StatCard(
                          label: '최장 스트릭',
                          value: '${longestStreak}일',
                          color: const Color(0xFFE5C040),
                          bg: const Color(0xFFFFF8D6),
                        ),
                      ],
                    ),
                  ),
                ),

                // 기간 탭
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: ['1개월', '3개월', '전체']
                            .asMap()
                            .entries
                            .map(
                              (e) => Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPeriod = e.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedPeriod == e.key
                                          ? theme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      e.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedPeriod == e.key
                                            ? Colors.white
                                            : theme.textLight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),

                // 습관별 절약액
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      '습관별 절약 금액',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.textDark,
                      ),
                    ),
                  ),
                ),

                if (habits.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          '아직 습관이 없어요!',
                          style: TextStyle(color: theme.textLight),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final habit = sortedHabits[index];
                      final maxSaving = sortedHabits.first.totalSaving;
                      final ratio = maxSaving == 0
                          ? 0.0
                          : habit.totalSaving / maxSaving;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _getIconBg(index),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    habit.icon,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          habit.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_formatMoney(habit.totalSaving)}원',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        backgroundColor: theme.light,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.primary,
                                            ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: sortedHabits.length),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8C7A60)),
            ),
          ],
        ),
      ),
    );
  }
}
