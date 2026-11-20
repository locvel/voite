import 'package:flutter/services.dart';

class LocalShare {
  static const _channel = MethodChannel('com.locvel.voite/share');

  static Future<void> text({required String title, required String text}) =>
      _channel.invokeMethod<void>('shareText', {'title': title, 'text': text});

  static Future<void> audio({required String title, required String path}) =>
      _channel.invokeMethod<void>('shareAudio', {'title': title, 'path': path});
}
