import 'package:flutter/services.dart';

class MicrophoneMuteMonitor {
  static const EventChannel _events = EventChannel('com.locvel.voite/mic_mute');

  Stream<bool> get changes => _events.receiveBroadcastStream().map((event) {
    // Android emits a boolean; tolerate the structured payload used by older
    // native builds as well so a platform event cannot crash recording.
    if (event is bool) return event;
    if (event is Map) return event['muted'] == true;
    return false;
  });
}
