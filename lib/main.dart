import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants.dart';
import 'features/recording/recorder_controller.dart';
import 'features/settings/daily_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await DailyReminderService.instance.initialize();
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'recording',
      channelName: AppConstants.displayName,
      channelDescription: 'Shown while a recording is in progress.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.nothing(),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: false,
      allowWifiLock: false,
      allowAutoRestart: false,
      stopWithTask: false,
    ),
  );

  final container = ProviderContainer();
  FlutterForegroundTask.addTaskDataCallback((data) {
    if (data == 'stop_recording') {
      container.read(recorderControllerProvider.notifier).stop();
    }
  });
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VoiceRecorderApp(),
    ),
  );
}
