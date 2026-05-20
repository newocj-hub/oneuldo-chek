import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late List<int> repeatDays; // 0=월 1=화 2=수 3=목 4=금 5=토 6=일

  @HiveField(4)
  late String? alarmTime; // "08:00" 형식

  @HiveField(5)
  late List<String> completedDates; // "2025-05-20" 형식

  @HiveField(6)
  late DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.repeatDays,
    this.alarmTime,
    List<String>? completedDates,
    DateTime? createdAt,
  }) : completedDates = completedDates ?? [],
       createdAt = createdAt ?? DateTime.now();

  // 오늘 완료 여부
  bool get isCompletedToday {
    final today = DateTime.now();
    final key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(key);
  }

  // 현재 스트릭 계산
  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = [...completedDates]..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime check = DateTime.now();
    for (final date in sorted) {
      final d = DateTime.parse(date);
      final diff = check.difference(d).inDays;
      if (diff <= 1) {
        streak++;
        check = d;
      } else {
        break;
      }
    }
    return streak;
  }

  // 최장 스트릭 계산
  int get longestStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = [...completedDates]..sort();
    int longest = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}
