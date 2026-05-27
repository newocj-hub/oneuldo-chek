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
  late List<int> repeatDays;

  @HiveField(4)
  late String? alarmTime;

  @HiveField(5)
  late List<String> completedDates;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late int savingAmount; // 절약 금액 (원)

  @HiveField(8)
  late int savingCycle; // 며칠마다 (기본 1일)

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.repeatDays,
    this.alarmTime,
    List<String>? completedDates,
    DateTime? createdAt,
    this.savingAmount = 0,
    this.savingCycle = 1,
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

  // 총 절약액 계산 (N일마다 M원)
  int get totalSaving {
    if (savingAmount == 0 || savingCycle == 0) return 0;
    return (completedDates.length ~/ savingCycle) * savingAmount;
  }

  // 오늘 절약액 (오늘 체크했을 때 N일 사이클 완성되면 표시)
  int get todaySaving {
    if (savingAmount == 0 || savingCycle == 0) return 0;
    if (!isCompletedToday) return 0;
    return completedDates.length % savingCycle == 0 ? savingAmount : 0;
  }
}
