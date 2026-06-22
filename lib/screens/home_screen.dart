import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/habit.dart';
import '../utils/app_theme.dart';
import '../utils/theme_provider.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
  }

  String _getCheerMessage(int completed, int total) {
    if (total == 0) return '오늘의 습관을 추가해보세요! 🌱';
    if (completed == 0) return '오늘도 할 수 있어요! 💪';
    if (completed == total) return '오늘 목표 완료! 정말 잘했어요! 🎉';
    if (completed >= total / 2) return '절반 넘었어요! 조금만 더! 🔥';
    return '시작이 반이에요! 계속해봐요! 😊';
  }

  String _getSavingMessage(int amount) {
    if (amount <= 0) return '오늘 절약을 시작해보세요!';
    if (amount < 5000) return '편의점 간식 ${(amount ~/ 1500)}개 값이에요! 🍫';
    if (amount < 15000) return '아메리카노 ${(amount ~/ 4500)}잔 값이에요! ☕';
    if (amount < 25000) return '편의점 도시락 ${(amount ~/ 5000)}개 값이에요! 🍱';
    if (amount < 50000) return '치킨 ${(amount ~/ 20000)}마리 값이에요! 🍗';
    if (amount < 100000) return '맛있는 식사 ${(amount ~/ 30000)}번 값이에요! 🍽️';
    return '오늘 정말 많이 절약했어요! ✈️';
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

  Future<void> _showBankPopup(BuildContext context) async {
    final theme = context.read<ThemeProvider>().currentTheme;

    List<BankApp> installedBanks = [];
    for (final bank in BankApps.apps) {
      final uri = Uri.parse(bank.scheme);
      if (await canLaunchUrl(uri)) {
        installedBanks.add(bank);
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '어디에 저축할까요? 🐷',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '설치된 금융앱을 선택해주세요',
              style: TextStyle(fontSize: 12, color: theme.textLight),
            ),
            const SizedBox(height: 16),
            installedBanks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '설치된 금융앱이 없어요 😢\n카카오뱅크, 토스 등을 설치해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: theme.textLight),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: installedBanks.length,
                    itemBuilder: (context, index) {
                      final bank = installedBanks[index];
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await _launchBankApp(context, bank);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: bank.bgColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  bank.initial,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: bank.textColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              bank.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: theme.textDark,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchBankApp(BuildContext context, BankApp bank) async {
    final uri = Uri.parse(bank.scheme);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=${bank.packageName}',
      );
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${bank.name} 앱을 열 수 없어요!')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final box = Hive.box<Habit>('habits');
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final weekday = today.weekday - 1;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<Habit> box, _) {
            final habits = box.values
                .where((h) => h.repeatDays.contains(weekday))
                .toList();
            final completed = habits.where((h) => h.isCompletedToday).length;
            final totalSaving = box.values.fold<int>(
              0,
              (sum, h) => sum + h.totalSaving,
            );
            final todaySaving = habits
                .where((h) => h.isCompletedToday && h.savingAmount > 0)
                .fold<int>(0, (sum, h) => sum + h.todaySaving);
            final allHabits = box.values.toList();
            final longestStreak = allHabits.isEmpty
                ? 0
                : allHabits
                      .map((h) => h.longestStreak)
                      .reduce((a, b) => a > b ? a : b);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '오늘도첵',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StatsScreen(),
                                ),
                              ),
                              child: Icon(
                                Icons.bar_chart_rounded,
                                color: theme.textLight,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
                                color: theme.textLight,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Text(
                      _formatDate(today),
                      style: TextStyle(fontSize: 13, color: theme.textLight),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCheerMessage(completed, habits.length),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '오늘 절약',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textLight,
                                      ),
                                    ),
                                    Text(
                                      '${_formatMoney(todaySaving)}원',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primary,
                                      ),
                                    ),
                                    Text(
                                      _getSavingMessage(todaySaving),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/images/piggy_bank.png',
                                width: 90,
                                height: 90,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => _showBankPopup(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/piggy_bank.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '지금 저축하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        _StatBadge(
                          value: '$completed / ${habits.length}',
                          label: '오늘 완료 ✅',
                          color: theme.primary,
                          bg: theme.light,
                        ),
                        const SizedBox(width: 8),
                        _StatBadge(
                          value: '${longestStreak}일',
                          label: '최장 스트릭 ⭐',
                          color: const Color(0xFFE5C040),
                          bg: const Color(0xFFFFF8D6),
                        ),
                        const SizedBox(width: 8),
                        _StatBadge(
                          value: '${_formatMoney(totalSaving)}원',
                          label: '누적 절약 💰',
                          color: const Color(0xFFF5A97A),
                          bg: const Color(0xFFFFE8D6),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '오늘의 습관',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddHabitScreen(),
                            ),
                          ),
                          child: Text(
                            '+ 추가하기',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (habits.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          '오늘의 습관이 없어요\n+ 추가하기를 눌러 시작해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final habit = habits[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _HabitCard(
                          habit: habit,
                          todayKey: todayKey,
                          theme: theme,
                          iconBg: _getIconBg(index),
                        ),
                      );
                    }, childCount: habits.length),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  completed == habits.length &&
                                          habits.isNotEmpty
                                      ? '오늘도 정말 잘했어요! 👏'
                                      : '작은 습관이 큰 변화를 만들어요 💚',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A3B1F),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  completed == habits.length &&
                                          habits.isNotEmpty
                                      ? '오늘 절약한 금액: ${_formatMoney(todaySaving)}원 🎉'
                                      : '매일 조금씩, 꾸준히 함께해요!',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8C7A60),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF8C7A60)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final String todayKey;
  final dynamic theme;
  final Color iconBg;

  const _HabitCard({
    required this.habit,
    required this.todayKey,
    required this.theme,
    required this.iconBg,
  });

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${habit.icon} ${habit.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: theme.primary),
              title: const Text('수정하기'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditHabitScreen(habit: habit),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('삭제하기', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('습관 삭제'),
                    content: Text('${habit.name} 습관을 삭제할까요?\n기록도 모두 사라져요.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          habit.delete();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCompletedToday;
    final totalSaving = habit.totalSaving;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
      ),
      onLongPress: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDone ? theme.light : iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDone
                          ? const Color(0xFFC0B8B0)
                          : const Color(0xFF2C2010),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🔥 ${habit.currentStreak}일 연속',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8C7A60),
                    ),
                  ),
                  if (habit.savingAmount > 0)
                    Text(
                      '오늘 절약 ${_formatMoney(habit.todaySaving)}원',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.primary,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
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
                  color: isDone ? theme.primary : Colors.transparent,
                  border: Border.all(
                    color: isDone ? theme.primary : const Color(0xFFD0C8C0),
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
