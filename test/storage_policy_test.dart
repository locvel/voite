import 'package:flutter_test/flutter_test.dart';
import 'package:voicerecorder/core/storage/storage_policy.dart';

void main() {
  const policy = StoragePolicy();

  test('warns at 500 MB and blocks at 200 MB', () {
    expect(
      policy.warningFor(StoragePolicy.warningBytes),
      StorageWarning.lowSpace,
    );
    expect(policy.canStartRecording(StoragePolicy.warningBytes), isTrue);
    expect(
      policy.warningFor(StoragePolicy.minimumBytes),
      StorageWarning.blocked,
    );
    expect(policy.canStartRecording(StoragePolicy.minimumBytes), isFalse);
  });

  test('purges trash once it reaches the 30 day retention limit', () {
    final now = DateTime.utc(2026, 11, 10);
    expect(
      policy.shouldPurge(now.subtract(const Duration(days: 30)), now),
      isTrue,
    );
    expect(
      policy.shouldPurge(now.subtract(const Duration(days: 29)), now),
      isFalse,
    );
  });
}
