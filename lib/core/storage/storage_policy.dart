enum StorageWarning { none, lowSpace, blocked }

class StoragePolicy {
  static const int warningBytes = 500 * 1024 * 1024;
  static const int minimumBytes = 200 * 1024 * 1024;
  static const Duration trashRetention = Duration(days: 30);

  const StoragePolicy();

  StorageWarning warningFor(int freeBytes) {
    if (freeBytes <= minimumBytes) return StorageWarning.blocked;
    if (freeBytes <= warningBytes) return StorageWarning.lowSpace;
    return StorageWarning.none;
  }

  bool canStartRecording(int freeBytes) => freeBytes > minimumBytes;

  bool shouldPurge(DateTime trashedAt, DateTime now) =>
      !trashedAt.isAfter(now.subtract(trashRetention));
}
