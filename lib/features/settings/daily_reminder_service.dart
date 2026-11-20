import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class DailyReminderService {
  DailyReminderService._();
  static final instance = DailyReminderService._();
  static const _notificationId = 4081;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: false, sound: false) ??
          true;
    }
    return true;
  }

  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await initialize();
    var next = tz.TZDateTime.now(tz.local);
    next = tz.TZDateTime(
      tz.local,
      next.year,
      next.month,
      next.day,
      hour,
      minute,
    );
    if (!next.isAfter(tz.TZDateTime.now(tz.local))) {
      next = next.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'A moment for your diary',
      body: 'What would you like to remember today?',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'voite_daily_reminder',
          'Daily diary reminder',
          channelDescription: 'A daily reminder to capture a thought in Voite.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: false,
          presentBadge: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(id: _notificationId);
  }
}
