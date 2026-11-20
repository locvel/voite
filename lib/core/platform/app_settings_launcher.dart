import 'package:flutter/services.dart';

abstract final class AppSettingsLauncher {
  static const _channel = MethodChannel('com.locvel.voite/app_settings');

  static Future<void> open() => _channel.invokeMethod<void>('openAppSettings');
}
