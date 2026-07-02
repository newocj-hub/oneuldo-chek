import 'package:flutter/services.dart';
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

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);

    // Android 12+에서는 정확한 알람 예약을 위해 별도 권한이 필요함
    // (미허용 시 zonedSchedule의 exactAllowWhileIdle 모드가 알림을 예약하지 못함)
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
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
      // repeatDays: 0=월요일...6=일요일, DateTime.weekday: 1=월요일...7=일요일
      final androidDay = day + 1;
      final notificationId = id * 10 + i;
      final scheduledDate = _nextInstanceOfDayTime(androidDay, hour, minute);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel',
          '습관 알림',
          channelDescription: '절약 습관 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

      try {
        await _plugin.zonedSchedule(
          notificationId,
          '$icon $habitName',
          '오늘도 실천하고 절약해요! 💰',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } on PlatformException {
        // 사용자가 '정확한 알람' 권한을 거부한 경우 등에는 정확한 예약이 불가능하므로
        // 알림이 아예 등록되지 않는 것을 막기 위해 비정확 모드로 대체 예약한다.
        await _plugin.zonedSchedule(
          notificationId,
          '$icon $habitName',
          '오늘도 실천하고 절약해요! 💰',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
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
