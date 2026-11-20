import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Keeps the random SQLCipher key in Android Keystore / iOS Keychain.
class EncryptionKeyStore {
  EncryptionKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'database_key_v1';
  static const _installMarkerName = '.install_marker';
  final FlutterSecureStorage _storage;

  Future<String> readOrCreate() async {
    await _clearStaleKeychainEntryAfterReinstall();
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final key = base64UrlEncode(bytes);
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<void> _clearStaleKeychainEntryAfterReinstall() async {
    if (!Platform.isIOS) return;
    final support = await getApplicationSupportDirectory();
    final marker = File(p.join(support.path, _installMarkerName));
    if (!await marker.exists()) {
      // Keychain items can survive deleting an iOS app. The app container does
      // not, so an absent marker identifies a fresh install and invalidates
      // the old database key before it can be reused.
      await _storage.delete(key: _keyName);
      await marker.parent.create(recursive: true);
      await marker.writeAsString('installed');
      await const MethodChannel('com.locvel.voite/storage').invokeMethod<void>(
        'protectAppData',
        <String, Object>{'path': support.path},
      );
    }
  }
}
