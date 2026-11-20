import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void recordingTaskEntrypoint() {
  FlutterForegroundTask.setTaskHandler(_RecordingTaskHandler());
}

class _RecordingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') FlutterForegroundTask.sendDataToMain('stop_recording');
  }
}
