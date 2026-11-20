import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/storage/device_storage.dart';

enum WhisperSize { tinyEn, baseEn, smallEn }

extension WhisperSizeDetails on WhisperSize {
  String get label => switch (this) {
    WhisperSize.tinyEn => 'tiny.en',
    WhisperSize.baseEn => 'base.en',
    WhisperSize.smallEn => 'small.en',
  };

  String get repository => 'csukuangfj/sherpa-onnx-whisper-$label';
}

// Model revisions and file hashes are reviewed release inputs. Do not resolve
// `main` at runtime: a mutable upstream branch must not silently change the
// model that a user downloads. Update these pins only with a reviewed model
// provenance/license update and a fresh transcription validation pass.
const Map<WhisperSize, String> _whisperRevisions = {
  WhisperSize.tinyEn: 'd026532c022fa99fd789d6b32446a1df7b6bfc43',
  WhisperSize.baseEn: '59eea950fc76df2453efb57e6c0fd334548e8ffe',
  WhisperSize.smallEn: 'd9533f69affd85061aee349af7fea5cb2996dbbe',
};

const _sharedWhisperTokensSha256 =
    '306cd27f03c1a714eca7108e03d66b7dc042abe8c258b44c199a7ed9838dd930';

const Map<WhisperSize, Map<String, String>> _whisperFileSha256 = {
  WhisperSize.tinyEn: {
    'tiny.en-encoder.int8.onnx':
        '0ce578b827c94a961aacb8fa14b02f096504b337e5c94be37c36238cbe3e8bc6',
    'tiny.en-decoder.int8.onnx':
        '06c0e6ff6348d427e51839219d1c886c18cfdf411e629e33f5e1679bff9c1527',
    'tiny.en-tokens.txt': _sharedWhisperTokensSha256,
  },
  WhisperSize.baseEn: {
    'base.en-encoder.int8.onnx':
        'ef6b936f4c9b1d90a3b68634b60c4ed8576b26172b33c2535ec0e933c9edb823',
    'base.en-decoder.int8.onnx':
        'f7162ad6db2dbef16cfaeaa7f945b9d7dd9c1b8d472f6aca82f2273d185e4d41',
    'base.en-tokens.txt': _sharedWhisperTokensSha256,
  },
  WhisperSize.smallEn: {
    'small.en-encoder.int8.onnx':
        '8bdac288f369aa94ee2194059238c465ed82ea9d47ee8fa4a8c0a891873e462f',
    'small.en-decoder.int8.onnx':
        '710ccf890e10f3faa15f51ec346081a2723c9f3adb6e4da81c6573a5a6f877fb',
    'small.en-tokens.txt': _sharedWhisperTokensSha256,
  },
};

const _vadRevision = '66b1409e6c67c060fd1abe9f01e580d1a9c2de9f';
const _vadFileSha256 =
    'a35ebf52fd3ce5f1469b2a36158dba761bc47b973ea3382b3186ca15b1f5af28';

// Bound remote sizes and streamed bytes so an invalid or compromised manifest
// cannot consume unbounded app storage before the final checksum is checked.
const Map<WhisperSize, Map<String, int>> _whisperFileSizeCeilings = {
  WhisperSize.tinyEn: {
    'tiny.en-encoder.int8.onnx': 16 * 1024 * 1024,
    'tiny.en-decoder.int8.onnx': 100 * 1024 * 1024,
    'tiny.en-tokens.txt': 2 * 1024 * 1024,
  },
  WhisperSize.baseEn: {
    'base.en-encoder.int8.onnx': 32 * 1024 * 1024,
    'base.en-decoder.int8.onnx': 140 * 1024 * 1024,
    'base.en-tokens.txt': 2 * 1024 * 1024,
  },
  WhisperSize.smallEn: {
    'small.en-encoder.int8.onnx': 120 * 1024 * 1024,
    'small.en-decoder.int8.onnx': 280 * 1024 * 1024,
    'small.en-tokens.txt': 2 * 1024 * 1024,
  },
};
const _vadFileSizeCeiling = 2 * 1024 * 1024;

class InstalledWhisperModel {
  const InstalledWhisperModel({
    required this.name,
    required this.encoderPath,
    required this.decoderPath,
    required this.tokensPath,
    required this.vadPath,
    required this.checksums,
  });

  final String name;
  final String encoderPath;
  final String decoderPath;
  final String tokensPath;
  final String vadPath;
  final Map<String, String> checksums;

  Map<String, Object> toJson() => {
    'name': name,
    'encoderPath': encoderPath,
    'decoderPath': decoderPath,
    'tokensPath': tokensPath,
    'vadPath': vadPath,
    'checksums': checksums,
  };

  factory InstalledWhisperModel.fromJson(Map<String, dynamic> json) =>
      InstalledWhisperModel(
        name: json['name'] as String,
        encoderPath: json['encoderPath'] as String,
        decoderPath: json['decoderPath'] as String,
        tokensPath: json['tokensPath'] as String,
        vadPath: json['vadPath'] as String,
        checksums: Map<String, String>.from(
          json['checksums'] as Map<String, dynamic>? ?? const {},
        ),
      );
}

class DownloadPreview {
  const DownloadPreview({required this.bytes, required this.files});

  final int bytes;
  final int files;

  String get sizeLabel => '${(bytes / (1024 * 1024)).ceil()} MB';
}

class ModelDownloadManager extends ChangeNotifier {
  ModelDownloadManager({Dio? dio, Connectivity? connectivity})
    : _dio = dio ?? Dio(),
      _connectivity = connectivity ?? Connectivity();

  final Dio _dio;
  final Connectivity _connectivity;
  CancelToken? _cancelToken;
  Future<void>? _activeRun;
  WhisperSize? _activeSize;
  WhisperSize? get activeSize => _activeSize;
  bool isDownloading = false;
  bool isPaused = false;
  bool isComplete = false;
  String? errorMessage;
  double progress = 0;
  int downloadedBytes = 0;
  int totalBytes = 0;
  double bytesPerSecond = 0;
  int _networkBytes = 0;

  Future<DownloadPreview> preview(WhisperSize size) async {
    await _requireNetwork();
    final modelFiles = await _whisperFiles(size);
    final vadFiles = await _vadFiles();
    final local = await _modelDirectory(size);
    var bytes = 0;
    var count = 0;
    for (final remote in [...modelFiles, ...vadFiles]) {
      final target = File(p.join(local, remote.name));
      if (!await _isVerified(target, remote.sha256)) {
        bytes += remote.size;
        count++;
      }
    }
    return DownloadPreview(bytes: bytes, files: count);
  }

  Future<InstalledWhisperModel?> findInstalled(WhisperSize size) async {
    final directory = await _modelDirectory(size);
    final metadata = File(p.join(directory, 'installed.json'));
    if (!await metadata.exists()) return null;
    try {
      final model = InstalledWhisperModel.fromJson(
        jsonDecode(await metadata.readAsString()) as Map<String, dynamic>,
      );
      final paths = [
        model.encoderPath,
        model.decoderPath,
        model.tokensPath,
        model.vadPath,
      ];
      for (final path in paths) {
        final expected = model.checksums[path];
        if (expected == null || !await _isVerified(File(path), expected)) {
          return null;
        }
      }
      return model;
    } on Object {
      return null;
    }
  }

  Future<void> start(WhisperSize size) {
    if (_activeRun != null) return _activeRun!;
    _activeSize = size;
    _cancelToken = CancelToken();
    isDownloading = true;
    isPaused = false;
    isComplete = false;
    errorMessage = null;
    progress = 0;
    downloadedBytes = 0;
    _networkBytes = 0;
    totalBytes = 0;
    notifyListeners();
    _activeRun = _download(size).whenComplete(() {
      _activeRun = null;
      isDownloading = false;
      notifyListeners();
    });
    return _activeRun!;
  }

  Future<void> pause() async {
    if (!isDownloading) return;
    isPaused = true;
    _cancelToken?.cancel('paused');
    notifyListeners();
    await _activeRun;
  }

  Future<void> resume() async {
    final size = _activeSize;
    if (size == null || !isPaused) return;
    await start(size);
  }

  Future<void> cancelDownload() async {
    final size = _activeSize;
    _cancelToken?.cancel('cancelled');
    await _activeRun;
    isPaused = false;
    isComplete = false;
    progress = 0;
    if (size != null) {
      final directory = Directory(await _modelDirectory(size));
      if (await directory.exists()) {
        await for (final entry in directory.list(recursive: true)) {
          if (entry.path.endsWith('.tmp')) await entry.delete();
        }
      }
    }
    notifyListeners();
  }

  Future<InstalledWhisperModel?> currentInstalled() async {
    final size = _activeSize ?? WhisperSize.baseEn;
    return findInstalled(size);
  }

  Future<void> _download(WhisperSize size) async {
    try {
      await _requireNetwork();
      final modelManifest = await _whisperFiles(size);
      final vadManifest = await _vadFiles();
      final directory = await _modelDirectory(size);
      final vadDirectory = await _vadDirectory();
      await Directory(directory).create(recursive: true);
      await Directory(vadDirectory).create(recursive: true);

      final files = <_RemoteFile>[];
      for (final remote in [...modelManifest, ...vadManifest]) {
        final baseDirectory = remote.repo == 'csukuangfj/vad'
            ? vadDirectory
            : directory;
        files.add(remote.withTarget(p.join(baseDirectory, remote.name)));
      }
      totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);
      downloadedBytes = 0;
      _networkBytes = 0;
      final timer = Stopwatch()..start();
      for (final file in files) {
        await _downloadFile(file, timer);
      }

      final encoder = files.firstWhere((file) => file.name.contains('encoder'));
      final decoder = files.firstWhere((file) => file.name.contains('decoder'));
      final tokens = files.firstWhere((file) => file.name.contains('tokens'));
      final vad = files.firstWhere((file) => file.repo == 'csukuangfj/vad');
      final model = InstalledWhisperModel(
        name: size.label,
        encoderPath: encoder.targetPath!,
        decoderPath: decoder.targetPath!,
        tokensPath: tokens.targetPath!,
        vadPath: vad.targetPath!,
        checksums: {for (final file in files) file.targetPath!: file.sha256},
      );
      final metadata = File(p.join(directory, 'installed.json'));
      final temporaryMetadata = File('${metadata.path}.tmp');
      await temporaryMetadata.writeAsString(jsonEncode(model.toJson()));
      if (await metadata.exists()) await metadata.delete();
      await temporaryMetadata.rename(metadata.path);
      for (final file in files) {
        await DeviceStorage().protectAppData(file.targetPath!);
      }
      isComplete = true;
      isPaused = false;
      progress = 1;
      notifyListeners();
    } on DioException catch (error) {
      if (_cancelToken?.isCancelled == true && isPaused) return;
      if (_cancelToken?.isCancelled == true) return;
      errorMessage = error.message ?? 'The model download failed.';
      rethrow;
    } catch (_) {
      errorMessage = 'The model download could not be completed. Check your connection and try again.';
      rethrow;
    }
  }

  Future<void> _downloadFile(_RemoteFile remote, Stopwatch timer) async {
    final target = File(remote.targetPath!);
    final temporary = File('${remote.targetPath}.tmp');
    if (await target.exists()) {
      final actualHash = await _sha256(target);
      if (actualHash == remote.sha256) {
        downloadedBytes += remote.size;
        _updateProgress(timer);
        return;
      }
      await target.delete();
    }

    var offset = await temporary.exists() ? await temporary.length() : 0;
    if (offset > remote.size || offset > remote.maxBytes) {
      await temporary.delete();
      offset = 0;
    }
    if (offset == remote.size && await _sha256(temporary) == remote.sha256) {
      await temporary.rename(target.path);
      downloadedBytes += remote.size;
      _updateProgress(timer);
      return;
    }
    if (offset == remote.size) {
      await temporary.delete();
      offset = 0;
    }
    downloadedBytes += offset;

    final headers = <String, Object>{};
    if (offset > 0) headers[HttpHeaders.rangeHeader] = 'bytes=$offset-';
    final response = await _dio.get<ResponseBody>(
      remote.downloadUrl,
      cancelToken: _cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 30),
      ),
    );
    if (offset > 0 && response.statusCode != HttpStatus.partialContent) {
      await temporary.delete();
      throw StateError('The model server did not resume the interrupted file.');
    }
    final output = await temporary.open(
      mode: offset > 0 ? FileMode.append : FileMode.write,
    );
    var receivedBytes = offset;
    var exceededSizeBound = false;
    try {
      await for (final chunk in response.data!.stream) {
        if (receivedBytes + chunk.length > remote.size ||
            receivedBytes + chunk.length > remote.maxBytes) {
          exceededSizeBound = true;
          break;
        }
        await output.writeFrom(chunk);
        receivedBytes += chunk.length;
        downloadedBytes += chunk.length;
        _networkBytes += chunk.length;
        _updateProgress(timer);
      }
      await output.flush();
    } finally {
      await output.close();
    }
    if (exceededSizeBound) {
      await temporary.delete();
      throw StateError('The download for ${remote.name} exceeded its size.');
    }

    if (await temporary.length() != remote.size) {
      await temporary.delete();
      throw StateError('Downloaded ${remote.name} has an unexpected size.');
    }
    final actualHash = await _sha256(temporary);
    if (actualHash != remote.sha256) {
      await temporary.delete();
      throw StateError('SHA-256 verification failed for ${remote.name}.');
    }
    await temporary.rename(target.path);
  }

  void _updateProgress(Stopwatch timer) {
    bytesPerSecond = timer.elapsedMilliseconds == 0
        ? 0
        : _networkBytes * 1000 / timer.elapsedMilliseconds;
    progress = totalBytes == 0 ? 1 : (downloadedBytes / totalBytes).clamp(0, 1);
    notifyListeners();
  }

  Future<List<_RemoteFile>> _whisperFiles(WhisperSize size) async {
    return _manifestFiles(
      size.repository,
      _whisperRevisions[size]!,
      _whisperFileSha256[size]!,
      _whisperFileSizeCeilings[size]!,
    );
  }

  Future<List<_RemoteFile>> _vadFiles() async {
    return _manifestFiles(
      'csukuangfj/vad',
      _vadRevision,
      {'silero_vad.onnx': _vadFileSha256},
      {'silero_vad.onnx': _vadFileSizeCeiling},
    );
  }

  Future<List<_RemoteFile>> _manifestFiles(
    String repository,
    String revision,
    Map<String, String> pinnedChecksums,
    Map<String, int> sizeCeilings,
  ) async {
    if (pinnedChecksums.length != sizeCeilings.length ||
        !pinnedChecksums.keys.toSet().containsAll(sizeCeilings.keys)) {
      throw StateError('The local manifest for $repository is inconsistent.');
    }
    final treeUri = Uri.https(
      'huggingface.co',
      '/api/models/$repository/tree/$revision',
      {'recursive': 'true', 'expand': 'true'},
    );
    final tree = await _dio.getUri<List<dynamic>>(treeUri);
    final files = tree.data!
        .whereType<Map<String, dynamic>>()
        .where((entry) => entry['type'] == 'file')
        .where((entry) => pinnedChecksums.containsKey(entry['path']))
        .map((entry) {
          final relativePath = entry['path'] as String;
          final size = (entry['size'] as num).toInt();
          final sizeCeiling = sizeCeilings[relativePath]!;
          if (size <= 0 || size > sizeCeiling) {
            throw StateError(
              'The pinned file $relativePath has an unexpected size.',
            );
          }
          return _RemoteFile(
            repo: repository,
            revision: revision,
            name: p.basename(relativePath),
            relativePath: relativePath,
            size: size,
            maxBytes: sizeCeiling,
            sha256: pinnedChecksums[relativePath]!,
          );
        })
        .toList();
    final foundPaths = files.map((file) => file.relativePath).toSet();
    if (files.length != pinnedChecksums.length ||
        foundPaths.length != pinnedChecksums.length ||
        !foundPaths.containsAll(pinnedChecksums.keys)) {
      throw StateError(
        'The pinned file list for $repository@$revision is incomplete.',
      );
    }
    return files;
  }

  Future<void> _requireNetwork() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw StateError('Connect to the internet before downloading a model.');
    }
  }

  Future<String> _modelDirectory(WhisperSize size) async {
    final documents = await getApplicationDocumentsDirectory();
    return p.join(documents.path, 'models', size.label);
  }

  Future<String> _vadDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    return p.join(documents.path, 'models', 'vad');
  }

  Future<String> _sha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  Future<bool> _isVerified(File file, String expectedHash) async =>
      expectedHash.isNotEmpty &&
      await file.exists() &&
      await file.length() > 0 &&
      await _sha256(file) == expectedHash;
}

class _RemoteFile {
  const _RemoteFile({
    required this.repo,
    required this.revision,
    required this.name,
    required this.relativePath,
    required this.size,
    required this.maxBytes,
    required this.sha256,
    this.targetPath,
  });

  final String repo;
  final String revision;
  final String name;
  final String relativePath;
  final int size;
  final int maxBytes;
  final String sha256;
  final String? targetPath;

  String get downloadUrl => Uri.https(
    'huggingface.co',
    '/$repo/resolve/$revision/$relativePath',
    {'download': 'true'},
  ).toString();

  _RemoteFile withTarget(String path) => _RemoteFile(
    repo: repo,
    revision: revision,
    name: name,
    relativePath: relativePath,
    size: size,
    maxBytes: maxBytes,
    sha256: sha256,
    targetPath: path,
  );
}
