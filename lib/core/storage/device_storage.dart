import 'package:flutter/services.dart';

class DeviceStorage {
  static const MethodChannel _channel = MethodChannel(
    'com.locvel.voite/storage',
  );

  Future<int> availableBytes() async {
    final value = await _channel.invokeMethod<int>('freeBytes');
    if (value == null) throw StateError('Device storage value is unavailable.');
    return value;
  }

  Future<void> protectAppData(String filePath) async {
    await _channel.invokeMethod<void>('protectAppData', <String, Object>{
      'path': filePath,
    });
  }
}
