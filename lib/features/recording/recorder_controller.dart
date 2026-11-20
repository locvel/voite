import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/storage/device_storage.dart';
import '../../core/storage/storage_policy.dart';
import '../../data/database/voice_database.dart';
import '../../data/repositories/local_repositories.dart';
import '../../domain/models/transcript_segment.dart';
import '../../domain/repositories/recordings_repository.dart';
import '../transcription/model_download_manager.dart';
import '../transcription/transcription_worker.dart';
import 'microphone_mute_monitor.dart';
import 'recording_task.dart';
import 'wav_file_writer.dart';

final voiceDatabaseProvider = FutureProvider<VoiceDatabase>((ref) async {
  final database = await VoiceDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final recordingsRepositoryProvider = FutureProvider<RecordingsRepository>((
  ref,
) async {
  final repository = LocalRecordingsRepository(
    await ref.watch(voiceDatabaseProvider.future),
  );
  try {
    await repository.purgeExpiredTrash();
  } on Object {
    // A cleanup failure must not keep the user's current library from opening.
  }
  return repository;
});

final settingsRepositoryProvider = FutureProvider<SettingsRepository>(
  (ref) async =>
      LocalSettingsRepository(await ref.watch(voiceDatabaseProvider.future)),
);

final modelDownloadManagerProvider = Provider<ModelDownloadManager>((ref) {
  final manager = ModelDownloadManager();
  ref.onDispose(manager.dispose);
  return manager;
});

const _selectedModelSettingKey = 'whisper_model_size_v1';

final recorderControllerProvider =
    NotifierProvider<RecorderController, RecorderUiState>(
      RecorderController.new,
    );

class RecorderUiState {
  const RecorderUiState({
    this.isRecording = false,
    this.isPaused = false,
    this.isTranscribing = false,
    this.elapsedMillis = 0,
    this.transcript = const [],
    this.modelSize = WhisperSize.baseEn,
    this.recordingLabel = 'Voice note',
    this.prompt,
    this.customLabels = const [],
    this.errorMessage,
    this.storageWarning = StorageWarning.none,
    this.transcriptionQueued = false,
    this.retryingTranscription = false,
    this.notificationPermissionDenied = false,
  });

  final bool isRecording;
  final bool isPaused;
  final bool isTranscribing;
  final int elapsedMillis;
  final List<TranscriptSegment> transcript;
  final WhisperSize modelSize;
  final String recordingLabel;
  final String? prompt;
  final List<String> customLabels;
  final String? errorMessage;
  final StorageWarning storageWarning;
  final bool transcriptionQueued;
  final bool retryingTranscription;
  final bool notificationPermissionDenied;

  RecorderUiState copyWith({
    bool? isRecording,
    bool? isPaused,
    bool? isTranscribing,
    int? elapsedMillis,
    List<TranscriptSegment>? transcript,
    WhisperSize? modelSize,
    String? recordingLabel,
    String? prompt,
    List<String>? customLabels,
    String? errorMessage,
    bool clearError = false,
    StorageWarning? storageWarning,
    bool? transcriptionQueued,
    bool? retryingTranscription,
    bool? notificationPermissionDenied,
  }) => RecorderUiState(
    isRecording: isRecording ?? this.isRecording,
    isPaused: isPaused ?? this.isPaused,
    isTranscribing: isTranscribing ?? this.isTranscribing,
    elapsedMillis: elapsedMillis ?? this.elapsedMillis,
    transcript: transcript ?? this.transcript,
    modelSize: modelSize ?? this.modelSize,
    recordingLabel: recordingLabel ?? this.recordingLabel,
    prompt: prompt ?? this.prompt,
    customLabels: customLabels ?? this.customLabels,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    storageWarning: storageWarning ?? this.storageWarning,
    transcriptionQueued: transcriptionQueued ?? this.transcriptionQueued,
    retryingTranscription: retryingTranscription ?? this.retryingTranscription,
    notificationPermissionDenied:
        notificationPermissionDenied ?? this.notificationPermissionDenied,
  );
}

class RecorderController extends Notifier<RecorderUiState> {
  final AudioRecorder _recorder = AudioRecorder();
  final StoragePolicy _storagePolicy = const StoragePolicy();
  final DeviceStorage _deviceStorage = DeviceStorage();
  final List<TranscriptSegment> _transcript = [];
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _audioLevelTimer;
  final ValueNotifier<double> _audioLevel = ValueNotifier(0);
  double _pendingAudioLevel = 0;
  StreamSubscription<Uint8List>? _audioSubscription;
  StreamSubscription<TranscriptSegment>? _transcriptSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<bool>? _micMuteSubscription;
  WavFileWriter? _wavWriter;
  TranscriptionWorker? _worker;
  Future<void> _pendingWrites = Future<void>.value();
  String? _activeId;
  String? _temporaryPath;
  String? _finalPath;
  Object? _streamError;
  bool _rowCreated = false;
  bool _userPaused = false;
  bool _incomingCall = false;
  bool _audioFocusLost = false;
  bool _micMuted = false;
  bool _pauseTransitionRunning = false;
  bool _starting = false;
  bool _stopping = false;

  @override
  RecorderUiState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _audioLevelTimer?.cancel();
      _audioLevel.dispose();
    });
    unawaited(_refreshPendingQueue());
    unawaited(_loadCustomLabels());
    unawaited(_loadModelPreference());
    return const RecorderUiState();
  }

  ValueListenable<double> get audioLevel => _audioLevel;

  Future<void> _refreshPendingQueue() async {
    try {
      final repository = await ref.read(recordingsRepositoryProvider.future);
      final pending = await repository.nextQueuedRecording();
      state = state.copyWith(transcriptionQueued: pending != null);
    } on Object {
      // The first screen stays usable if local database initialization fails.
    }
  }

  Future<bool> hasDisclosureConsent() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    return settings.getBool('mic_disclosure_accepted');
  }

  Future<void> acceptDisclosure() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    await settings.setBool('mic_disclosure_accepted', true);
  }

  Future<bool> needsRecordingReminder() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    return !(await settings.getBool('recording_reminder_seen'));
  }

  Future<void> acknowledgeRecordingReminder() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    await settings.setBool('recording_reminder_seen', true);
  }

  Future<bool> requestMicrophonePermission() =>
      _recorder.hasPermission(request: true);

  void chooseModel(WhisperSize size) {
    if (!state.isRecording) {
      state = state.copyWith(modelSize: size, clearError: true);
      unawaited(_saveModelPreference(size));
    }
  }

  Future<void> _loadModelPreference() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider.future);
      final saved = await settings.getString(_selectedModelSettingKey);
      for (final size in WhisperSize.values) {
        if (size.name == saved && !state.isRecording) {
          state = state.copyWith(modelSize: size);
          return;
        }
      }
    } on Object {
      // The default model remains available if saved preferences cannot load.
    }
  }

  Future<void> _saveModelPreference(WhisperSize size) async {
    try {
      final settings = await ref.read(settingsRepositoryProvider.future);
      await settings.setString(_selectedModelSettingKey, size.name);
    } on Object {
      // Model selection still applies to the current session if saving fails.
    }
  }

  void chooseRecordingLabel(String label) {
    if (!state.isRecording) {
      state = state.copyWith(recordingLabel: label, clearError: true);
    }
  }

  void setPrompt(String? prompt) {
    if (!state.isRecording) state = state.copyWith(prompt: prompt);
  }

  Future<void> _loadCustomLabels() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider.future);
      final encoded = await settings.getString('recording_custom_labels');
      if (encoded == null || encoded.isEmpty) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return;
      final labels = decoded
          .whereType<String>()
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toSet()
          .toList(growable: false);
      state = state.copyWith(customLabels: labels);
    } on Object {
      // Labels are an enhancement; the recorder remains usable if settings fail.
    }
  }

  Future<String> addCustomLabel(String input) async {
    final label = input.trim();
    if (label.isEmpty) throw ArgumentError('Enter a label name.');
    if (label.length > 36) throw ArgumentError('Use 36 characters or fewer.');
    final existing = <String>{
      'Voice note',
      'Lecture',
      'Meeting',
      'Idea',
      ...state.customLabels,
    };
    if (existing.any((item) => item.toLowerCase() == label.toLowerCase())) {
      throw ArgumentError('That label already exists.');
    }
    final labels = [...state.customLabels, label];
    final settings = await ref.read(settingsRepositoryProvider.future);
    await settings.setString('recording_custom_labels', jsonEncode(labels));
    state = state.copyWith(customLabels: labels, recordingLabel: label);
    return label;
  }

  Future<({String id, String title})?> activeRecordingInfo() async {
    final id = _activeId;
    if (id == null) return null;
    final repository = await ref.read(recordingsRepositoryProvider.future);
    final title = await repository.recordingTitle(id);
    return title == null ? null : (id: id, title: title);
  }

  Future<void> renameSavedRecording(String id, String title) async {
    final repository = await ref.read(recordingsRepositoryProvider.future);
    await repository.renameRecording(id, title);
  }

  Future<void> start() async {
    if (state.isRecording || _starting || _stopping) return;
    _starting = true;
    try {
      _resetAudioLevel();
      final availableBytes = await _deviceStorage.availableBytes();
      final warning = _storagePolicy.warningFor(availableBytes);
      state = state.copyWith(storageWarning: warning, clearError: true);
      if (!_storagePolicy.canStartRecording(availableBytes)) {
        throw StateError('Free at least 200 MB before starting a recording.');
      }
      if (!await _recorder.hasPermission(request: false)) {
        throw StateError('Microphone permission is required to record.');
      }
      await _configureAudioSession();
      if (Platform.isAndroid) {
        // Android permits microphone foreground services without POST_NOTIFICATIONS.
        // Keep recording available if the user declines; the in-app Stop control
        // remains available even when Android hides the foreground notification.
        final notificationsAllowed = await _requestNotificationPermission();
        state = state.copyWith(
          notificationPermissionDenied: !notificationsAllowed,
        );
      }

      final id = const Uuid().v4();
      final documents = await getApplicationDocumentsDirectory();
      final recordingsDirectory = Directory(
        p.join(documents.path, 'recordings'),
      );
      await recordingsDirectory.create(recursive: true);
      final finalPath = p.join(recordingsDirectory.path, '$id.wav');
      final temporaryPath = '$finalPath.recording';
      final writer = await WavFileWriter.create(temporaryPath);
      await _deviceStorage.protectAppData(temporaryPath);
      await _deviceStorage.protectAppData(recordingsDirectory.path);
      final repository = await ref.read(recordingsRepositoryProvider.future);
      try {
        await repository.beginRecording(
          id: id,
          audioPath: finalPath,
          label: state.recordingLabel,
          prompt: state.prompt,
        );
        _rowCreated = true;
        _activeId = id;
        _finalPath = finalPath;
        _temporaryPath = temporaryPath;
        _wavWriter = writer;
        await _startForegroundService();

        final model = await ref
            .read(modelDownloadManagerProvider)
            .findInstalled(state.modelSize);
        if (model != null) {
          _worker = await TranscriptionWorker.start(model);
          _transcriptSubscription = _worker!.segments.listen(_appendTranscript);
        }

        final stream = await _recorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: AppConstants.sampleRate,
            numChannels: AppConstants.channelCount,
            audioInterruption: AudioInterruptionMode.none,
            androidConfig: AndroidRecordConfig(
              audioSource: AndroidAudioSource.voiceRecognition,
            ),
          ),
        );
        _audioSubscription = stream.listen(
          _onAudioChunk,
          onError: (Object error) => _streamError = error,
        );
        await _watchInterruptions();
        _stopwatch
          ..reset()
          ..start();
        _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          state = state.copyWith(elapsedMillis: _stopwatch.elapsedMilliseconds);
        });
        state = state.copyWith(
          isRecording: true,
          isPaused: false,
          elapsedMillis: 0,
          transcript: const [],
          transcriptionQueued: model == null,
          clearError: true,
        );
        await _applyInterruptionPause();
      } catch (_) {
        _timer?.cancel();
        await _audioSubscription?.cancel();
        await _cancelInterruptionWatchers();
        try {
          await _recorder.stop();
        } on Object {
          // The recorder might not have started yet.
        }
        _worker?.dispose();
        _worker = null;
        await writer.close();
        if (await File(temporaryPath).exists()) {
          await File(temporaryPath).delete();
        }
        if (_rowCreated) await repository.deleteRecording(id);
        _rowCreated = false;
        _activeId = null;
        _temporaryPath = null;
        _finalPath = null;
        await _stopForegroundService();
        rethrow;
      }
    } catch (error) {
      _resetAudioLevel();
      state = state.copyWith(errorMessage: _friendlyError(error));
      rethrow;
    } finally {
      _starting = false;
    }
  }

  Future<void> pause() async {
    if (!state.isRecording || state.isPaused) return;
    _userPaused = true;
    await _recorder.pause();
    _stopwatch.stop();
    _resetAudioLevel();
    state = state.copyWith(
      isPaused: true,
      elapsedMillis: _stopwatch.elapsedMilliseconds,
    );
  }

  Future<void> resume() async {
    if (!state.isRecording || !state.isPaused) return;
    _userPaused = false;
    if (_hasSystemInterruption) return;
    await _recorder.resume();
    _resetAudioLevel();
    _stopwatch.start();
    state = state.copyWith(isPaused: false);
  }

  Future<String?> stop() async {
    if (_stopping) return null;
    if (!state.isRecording && _activeId == null) return null;
    _stopping = true;
    final savedId = _activeId;
    var queueTranscription = _worker == null;
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    try {
      await _recorder.stop();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      await _pendingWrites;
      if (_streamError != null) throw StateError(_streamError.toString());
      await _wavWriter?.close();
      _wavWriter = null;
      final temporary = _temporaryPath;
      final finalPath = _finalPath;
      if (temporary != null &&
          finalPath != null &&
          await File(temporary).exists()) {
        await File(temporary).rename(finalPath);
        await _deviceStorage.protectAppData(finalPath);
      }

      state = state.copyWith(
        isRecording: false,
        isPaused: false,
        isTranscribing: _worker != null,
      );
      await _worker?.stop();
      queueTranscription = queueTranscription || _worker?.errorMessage != null;
      await _transcriptSubscription?.cancel();
      _transcriptSubscription = null;
      if (_activeId != null && finalPath != null) {
        final repository = await ref.read(recordingsRepositoryProvider.future);
        await repository.saveRecording(
          id: _activeId!,
          audioPath: finalPath,
          durationMillis: _stopwatch.elapsedMilliseconds,
          transcript: List.unmodifiable(_transcript),
          transcriptionQueued: queueTranscription,
          transcriptionFailed: _worker?.errorMessage != null,
          label: state.recordingLabel,
          prompt: state.prompt,
        );
      }
      await _stopForegroundService();
      await _cancelInterruptionWatchers();
      state = state.copyWith(
        isRecording: false,
        isPaused: false,
        isTranscribing: false,
        elapsedMillis: 0,
        transcript: List.unmodifiable(_transcript),
        transcriptionQueued: queueTranscription,
      );
      unawaited(_refreshPendingQueue());
      return savedId;
    } catch (error) {
      // Stopping failed, but the captured audio is still valuable. Close the
      // WAV writer, keep the temporary file, and promote it to the final path
      // so the entry can be played or retried instead of being lost.
      _timer?.cancel();
      _timer = null;
      _stopwatch.stop();
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      try {
        await _pendingWrites;
      } catch (_) {
        // The file is still usable even if a buffered write failed.
      }
      try {
        await _wavWriter?.close();
      } catch (_) {
        // Keep whatever reached disk.
      }
      _wavWriter = null;
      final temporary = _temporaryPath;
      final finalPath = _finalPath;
      String? recoveredPath = finalPath;
      if (temporary != null) {
        final tempFile = File(temporary);
        if (await tempFile.exists()) {
          if (finalPath != null) {
            try {
              await tempFile.rename(finalPath);
              await _deviceStorage.protectAppData(finalPath);
              recoveredPath = finalPath;
            } catch (_) {
              recoveredPath = temporary;
            }
          } else {
            recoveredPath = temporary;
          }
        }
      }
      await _worker?.stop();
      await _transcriptSubscription?.cancel();
      _transcriptSubscription = null;
      await _stopForegroundService();
      await _cancelInterruptionWatchers();
      final repository = await ref.read(recordingsRepositoryProvider.future);
      if (_activeId != null && recoveredPath != null) {
        try {
          await repository.saveRecording(
            id: _activeId!,
            audioPath: recoveredPath,
            durationMillis: _stopwatch.elapsedMilliseconds,
            transcript: List.unmodifiable(_transcript),
            transcriptionQueued: false,
            transcriptionFailed: true,
            label: state.recordingLabel,
            prompt: state.prompt,
          );
        } catch (_) {
          // Ignore repair errors; the retry queue can still find the file.
        }
      } else if (_activeId != null) {
        try {
          await repository.deleteRecording(_activeId!);
        } catch (_) {
          // Ignore repair errors.
        }
      }
      state = state.copyWith(errorMessage: _friendlyError(error));
      rethrow;
    } finally {
      _resetAudioLevel();
      _worker?.dispose();
      _worker = null;
      _activeId = null;
      _temporaryPath = null;
      _finalPath = null;
      _rowCreated = false;
      _userPaused = false;
      _incomingCall = false;
      _audioFocusLost = false;
      _micMuted = false;
      _streamError = null;
      _starting = false;
      _stopping = false;
    }
  }

  Future<void> retryPendingTranscription({String? recordingId}) async {
    if (state.isRecording || state.retryingTranscription) return;
    final model = await ref
        .read(modelDownloadManagerProvider)
        .findInstalled(state.modelSize);
    if (model == null) {
      throw StateError(
        'Download ${state.modelSize.label} before retrying transcription.',
      );
    }
    final repository = await ref.read(recordingsRepositoryProvider.future);
    final pending = await repository.nextQueuedRecording(
      recordingId: recordingId,
    );
    if (pending == null) {
      state = state.copyWith(transcriptionQueued: false);
      return;
    }
    state = state.copyWith(retryingTranscription: true, clearError: true);
    try {
      final segments = await TranscriptionWorker.transcribeFile(
        audioPath: pending.audioPath,
        model: model,
      );
      await repository.saveTranscription(id: pending.id, transcript: segments);
      state = state.copyWith(transcript: List.unmodifiable(segments));
      await _refreshPendingQueue();
    } catch (error) {
      // Clean up orphaned recording on failure
      _timer?.cancel();
      _timer = null;
      _stopwatch.stop();
      final temporary = _temporaryPath;
      final finalPath = _finalPath;
      if (temporary != null && finalPath != null) {
        await File(temporary).delete();
      }
      // Mark the DB row as failed if an active ID exists
      if (_activeId != null) {
        try {
          final repository = await ref.read(
            recordingsRepositoryProvider.future,
          );
          await repository.saveRecording(
            id: _activeId!,
            audioPath: finalPath ?? '',
            durationMillis: _stopwatch.elapsedMilliseconds,
            transcript: List.unmodifiable(_transcript),
            transcriptionQueued: false,
            transcriptionFailed: true,
            label: state.recordingLabel,
            prompt: state.prompt,
          );
        } catch (_) {
          // Ignore repair errors
        }
      }
      state = state.copyWith(errorMessage: _friendlyError(error));
      rethrow;
    } finally {
      state = state.copyWith(retryingTranscription: false);
    }
  }

  /// Transcribes an already-saved recording from its detail screen.
  Future<void> transcribeSavedRecording({required String recordingId}) async {
    if (state.isRecording || state.retryingTranscription) return;
    final model = await ref
        .read(modelDownloadManagerProvider)
        .findInstalled(state.modelSize);
    if (model == null) {
      throw StateError(
        'Download the ${state.modelSize.label} speech model in Settings first.',
      );
    }

    final repository = await ref.read(recordingsRepositoryProvider.future);
    final details = await repository.getRecordingDetails(recordingId);
    if (details == null || details.recording.isTrashed) {
      throw StateError('This recording is no longer available.');
    }
    if (!await File(details.recording.audioPath).exists()) {
      throw StateError('The audio file for this recording is missing.');
    }

    state = state.copyWith(retryingTranscription: true, clearError: true);
    try {
      final segments = await TranscriptionWorker.transcribeFile(
        audioPath: details.recording.audioPath,
        model: model,
      );
      await repository.saveTranscription(id: recordingId, transcript: segments);
      state = state.copyWith(transcript: List.unmodifiable(segments));
      await _refreshPendingQueue();
    } catch (error) {
      // Clean up orphaned recording on failure
      _timer?.cancel();
      _timer = null;
      _stopwatch.stop();
      final temporary = _temporaryPath;
      final finalPath = _finalPath;
      if (temporary != null && finalPath != null) {
        await File(temporary).delete();
      }
      // Mark the DB row as failed if an active ID exists
      if (_activeId != null) {
        try {
          final repository = await ref.read(
            recordingsRepositoryProvider.future,
          );
          await repository.saveRecording(
            id: _activeId!,
            audioPath: finalPath ?? '',
            durationMillis: _stopwatch.elapsedMilliseconds,
            transcript: List.unmodifiable(_transcript),
            transcriptionQueued: false,
            transcriptionFailed: true,
            label: state.recordingLabel,
            prompt: state.prompt,
          );
        } catch (_) {
          // Ignore repair errors
        }
      }
      state = state.copyWith(errorMessage: _friendlyError(error));
      rethrow;
    } finally {
      state = state.copyWith(retryingTranscription: false);
    }
  }

  void _onAudioChunk(Uint8List bytes) {
    _updateAudioLevel(bytes);
    _pendingWrites = _pendingWrites
        .then((_) async {
          await _wavWriter?.append(bytes);
        })
        .catchError((Object error) {
          _streamError = error;
        });
    _worker?.addAudio(_pcm16ToFloat32(bytes));
  }

  void _updateAudioLevel(Uint8List bytes) {
    final sampleCount = bytes.lengthInBytes ~/ 2;
    if (sampleCount == 0 || state.isPaused) return;

    final data = ByteData.sublistView(bytes);
    var squaredTotal = 0.0;
    for (var index = 0; index < sampleCount; index++) {
      final sample = data.getInt16(index * 2, Endian.little) / 32768.0;
      squaredTotal += sample * sample;
    }
    final rms = math.sqrt(squaredTotal / sampleCount);
    _pendingAudioLevel = (rms * 3.5).clamp(0.0, 1.0).toDouble();

    if (_audioLevelTimer?.isActive ?? false) return;
    _audioLevelTimer = Timer(const Duration(milliseconds: 75), () {
      if (_audioLevel.value != _pendingAudioLevel) {
        _audioLevel.value = _pendingAudioLevel;
      }
    });
  }

  void _resetAudioLevel() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = null;
    _pendingAudioLevel = 0;
    if (_audioLevel.value != 0) _audioLevel.value = 0;
  }

  void _appendTranscript(TranscriptSegment segment) {
    _transcript.add(segment);
    state = state.copyWith(transcript: List.unmodifiable(_transcript));
  }

  Float32List _pcm16ToFloat32(Uint8List bytes) {
    final sampleCount = bytes.lengthInBytes ~/ 2;
    final samples = Float32List(sampleCount);
    final data = ByteData.sublistView(bytes);
    for (var index = 0; index < sampleCount; index++) {
      samples[index] = data.getInt16(index * 2, Endian.little) / 32768;
    }
    return samples;
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );
  }

  Future<void> _watchInterruptions() async {
    final session = await AudioSession.instance;
    _interruptionSubscription = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        _incomingCall = event.type == AudioInterruptionType.unknown;
        _audioFocusLost = event.type != AudioInterruptionType.unknown;
      } else {
        _incomingCall = false;
        _audioFocusLost = false;
      }
      unawaited(_applyInterruptionPause());
    });
    if (Platform.isAndroid) {
      _micMuteSubscription = MicrophoneMuteMonitor().changes.listen((muted) {
        _micMuted = muted;
        unawaited(_applyInterruptionPause());
      });
    }
  }

  bool get _hasSystemInterruption =>
      _incomingCall || _audioFocusLost || _micMuted;

  Future<void> _applyInterruptionPause() async {
    if (_pauseTransitionRunning || !state.isRecording) return;
    _pauseTransitionRunning = true;
    try {
      if (_hasSystemInterruption && !state.isPaused) {
        await _recorder.pause();
        _stopwatch.stop();
        state = state.copyWith(
          isPaused: true,
          elapsedMillis: _stopwatch.elapsedMilliseconds,
        );
      } else if (!_hasSystemInterruption && !_userPaused && state.isPaused) {
        await _recorder.resume();
        _stopwatch.start();
        state = state.copyWith(isPaused: false);
      }
    } finally {
      _pauseTransitionRunning = false;
    }
  }

  Future<void> _cancelInterruptionWatchers() async {
    await _interruptionSubscription?.cancel();
    await _micMuteSubscription?.cancel();
    _interruptionSubscription = null;
    _micMuteSubscription = null;
  }

  Future<bool> _requestNotificationPermission() async {
    final current = await FlutterForegroundTask.checkNotificationPermission();
    if (current != NotificationPermission.granted) {
      return await FlutterForegroundTask.requestNotificationPermission() ==
          NotificationPermission.granted;
    }
    return true;
  }

  Future<void> _startForegroundService() async {
    if (!Platform.isAndroid || await FlutterForegroundTask.isRunningService) {
      return;
    }
    final result = await FlutterForegroundTask.startService(
      serviceTypes: const [ForegroundServiceTypes.microphone],
      notificationTitle: AppConstants.displayName,
      notificationText: 'Recording audio on this device',
      notificationButtons: const [NotificationButton(id: 'stop', text: 'Stop')],
      callback: recordingTaskEntrypoint,
    );
    if (result is ServiceRequestFailure) {
      throw StateError(
        'Could not start the recording service: ${result.error}',
      );
    }
  }

  Future<void> _stopForegroundService() async {
    if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  String _friendlyError(Object error) {
    final message = error is StateError
        ? error.message.toString().toLowerCase()
        : '';
    if (message.startsWith('free at least')) {
      return 'Free at least 200 MB before starting a recording.';
    }
    if (message.contains('microphone permission')) {
      return 'Microphone permission is needed to record.';
    }
    if (message.contains('speech model') || message.contains('download')) {
      return 'A speech model is needed for transcription. Check Settings and try again.';
    }
    if (message.contains('audio file') ||
        message.contains('recording is no longer available')) {
      return 'This recording audio is unavailable. Check your library.';
    }
    return 'That recording action could not be completed. Check your library and try again.';
  }
}
