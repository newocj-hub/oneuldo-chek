import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // 알림 채널 수동 생성
    const channel = AndroidNotificationChannel(
      'habit_channel',
      '습관 알림',
      description: '절약 습관 알림',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleHabitNotification({
    required int id,
    required String habitName,
    required String icon,
    required int hour,
    required int minute,
    required List<int> repeatDays,
  }) async {
    await cancelNotification(id);

    for (int i = 0; i < repeatDays.length; i++) {
      final day = repeatDays[i];
      final androidDay = day + 2 > 7 ? 1 : day + 2;

      await _plugin.zonedSchedule(
        id * 10 + i,
        '$icon $habitName',
        '오늘도 실천하고 절약해요! 💰',
        _nextInstanceOfDayTime(androidDay, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel',
            '습관 알림',
            channelDescription: '절약 습관 알림',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfDayTime(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != day || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelNotification(int id) async {
    for (int i = 0; i < 7; i++) {
      await _plugin.cancel(id * 10 + i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
