import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/recording_details.dart';
import '../recording/recorder_controller.dart';
import '../settings/daily_reminder_service.dart';

const goalCelebrationDaySettingKey = 'daily_goal_celebration_day_v3';
const dailyReminderSettingKey = 'daily_prompt_reminder_enabled_v1';
const dailyReminderTimeSettingKey = 'daily_prompt_reminder_time_v1';
const dailyGoalMinutesSettingKey = 'daily_goal_minutes_v1';

final homeRecordingsProvider = StreamProvider<List<RecordingSummary>>((
  ref,
) async* {
  final repository = await ref.watch(recordingsRepositoryProvider.future);
  yield* repository.watchLibrary();
});

final dailyGoalMinutesProvider = FutureProvider<int>((ref) async {
  final settings = await ref.watch(settingsRepositoryProvider.future);
  return await settings.getInt(dailyGoalMinutesSettingKey) ?? 10;
});

final dailyReminderEnabledProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.watch(settingsRepositoryProvider.future);
  return settings.getBool(dailyReminderSettingKey);
});
final dailyReminderTimeProvider = FutureProvider<String>((ref) async {
  final settings = await ref.watch(settingsRepositoryProvider.future);
  return await settings.getString(dailyReminderTimeSettingKey) ?? '09:00';
});

Future<void> saveDailyReminderEnabled(WidgetRef ref, bool enabled) async {
  final settings = await ref.read(settingsRepositoryProvider.future);
  if (enabled) {
    if (!await DailyReminderService.instance.requestPermission()) {
      throw StateError(
        'Notification permission is needed for a daily reminder.',
      );
    }
    final value =
        await settings.getString(dailyReminderTimeSettingKey) ?? '09:00';
    final parts = value.split(':');
    await DailyReminderService.instance.scheduleDaily(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.last) ?? 0,
    );
  } else {
    await DailyReminderService.instance.cancel();
  }
  await settings.setBool(dailyReminderSettingKey, enabled);
  ref.invalidate(dailyReminderEnabledProvider);
}

Future<void> saveDailyReminderTime(WidgetRef ref, TimeOfDay time) async {
  final settings = await ref.read(settingsRepositoryProvider.future);
  final value =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  await settings.setString(dailyReminderTimeSettingKey, value);
  if (await settings.getBool(dailyReminderSettingKey)) {
    await DailyReminderService.instance.scheduleDaily(
      hour: time.hour,
      minute: time.minute,
    );
  }
  ref.invalidate(dailyReminderTimeProvider);
}

Future<void> saveDailyGoalMinutes(WidgetRef ref, int minutes) async {
  if (minutes < 1 || minutes > 120) {
    throw ArgumentError('Goal must be between 1 and 120 minutes');
  }
  final settings = await ref.read(settingsRepositoryProvider.future);
  await settings.setInt(dailyGoalMinutesSettingKey, minutes);
  ref.invalidate(dailyGoalMinutesProvider);
  ref.invalidate(homeRecordingsProvider); // Refresh home to update cat
}
