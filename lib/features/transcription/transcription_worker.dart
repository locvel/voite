import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import '../../core/constants.dart';
import '../../domain/models/transcript_segment.dart';
import 'model_download_manager.dart';

/// Owns sherpa_onnx in a worker isolate. Every isolate must initialize its own
/// FFI bindings; see the upstream sherpa-onnx Flutter examples.
class TranscriptionWorker {
  TranscriptionWorker._(this._messages);

  final ReceivePort _messages;
  final StreamController<TranscriptSegment> _segments =
      StreamController<TranscriptSegment>.broadcast();
  final Completer<void> _ready = Completer<void>();
  final Completer<void> _stopped = Completer<void>();
  Isolate? _isolate;
  SendPort? _commands;
  String? errorMessage;

  Stream<TranscriptSegment> get segments => _segments.stream;

  static Future<TranscriptionWorker> start(InstalledWhisperModel model) async {
    final messages = ReceivePort();
    final worker = TranscriptionWorker._(messages);
    messages.listen(worker._handleMessage);
    worker._isolate = await Isolate.spawn<Map<String, Object>>(
      _transcriptionIsolate,
      {
        'replyTo': messages.sendPort,
        'encoderPath': model.encoderPath,
        'decoderPath': model.decoderPath,
        'tokensPath': model.tokensPath,
        'vadPath': model.vadPath,
      },
      onError: messages.sendPort,
      onExit: messages.sendPort,
    );
    await worker._ready.future.timeout(const Duration(seconds: 60));
    return worker;
  }

  void addAudio(Float32List samples) {
    final port = _commands;
    if (port == null || samples.isEmpty) return;
    port.send({
      'type': 'audio',
      'pcm': TransferableTypedData.fromList([samples.buffer.asUint8List()]),
    });
  }

  Future<void> stop() async {
    _commands?.send({'type': 'stop'});
    await _stopped.future.timeout(const Duration(seconds: 30));
    _messages.close();
    await _segments.close();
    _isolate?.kill(priority: Isolate.immediate);
  }

  void dispose() {
    _commands?.send({'type': 'dispose'});
    _messages.close();
    _segments.close();
    _isolate?.kill(priority: Isolate.immediate);
  }

  void _handleMessage(Object? message) {
    if (message is List<Object?> && message.isNotEmpty) {
      errorMessage = message.join(' ');
      if (!_ready.isCompleted) _ready.completeError(StateError(errorMessage!));
      return;
    }
    if (message is! Map<Object?, Object?>) return;
    switch (message['type']) {
      case 'ready':
        _commands = message['commands'] as SendPort;
        if (!_ready.isCompleted) _ready.complete();
      case 'segment':
        _segments.add(
          TranscriptSegment(
            text: message['text'] as String,
            startMillis: message['startMillis'] as int,
            endMillis: message['endMillis'] as int,
          ),
        );
      case 'error':
        errorMessage = message['message'] as String?;
      case 'stopped':
        if (!_stopped.isCompleted) _stopped.complete();
    }
  }

  static Future<List<TranscriptSegment>> transcribeFile({
    required String audioPath,
    required InstalledWhisperModel model,
  }) {
    return Isolate.run(() async {
      await sherpa.initBindingsAsync();
      final recognizer = _createRecognizer(model);
      final vad = _createVad(model.vadPath);
      final buffer = sherpa.CircularBuffer(
        capacity: 30 * AppConstants.sampleRate,
      );
      final wave = sherpa.readWave(audioPath);
      if (wave.sampleRate != AppConstants.sampleRate) {
        recognizer.free();
        vad.free();
        buffer.free();
        throw StateError('Test audio must be 16 kHz mono PCM.');
      }
      final output = <TranscriptSegment>[];
      try {
        buffer.push(wave.samples);
        _consumeVadBuffer(buffer, vad, recognizer, output);
        if (buffer.size > 0) {
          vad.acceptWaveform(
            buffer.get(startIndex: buffer.head, n: buffer.size),
          );
          buffer.reset();
        }
        vad.flush();
        _drainVad(vad, recognizer, output);
      } finally {
        recognizer.free();
        vad.free();
        buffer.free();
      }
      return output;
    });
  }
}

void _transcriptionIsolate(Map<String, Object> initialization) async {
  final replyTo = initialization['replyTo']! as SendPort;
  final commands = ReceivePort();
  late sherpa.OfflineRecognizer recognizer;
  late sherpa.VoiceActivityDetector vad;
  late sherpa.CircularBuffer buffer;
  try {
    await sherpa.initBindingsAsync();
    final model = InstalledWhisperModel(
      name: 'worker',
      encoderPath: initialization['encoderPath']! as String,
      decoderPath: initialization['decoderPath']! as String,
      tokensPath: initialization['tokensPath']! as String,
      vadPath: initialization['vadPath']! as String,
      checksums: const {},
    );
    recognizer = _createRecognizer(model);
    vad = _createVad(model.vadPath);
    buffer = sherpa.CircularBuffer(capacity: 30 * AppConstants.sampleRate);
  } catch (error, stackTrace) {
    replyTo.send({'type': 'error', 'message': '$error\n$stackTrace'});
    commands.close();
    return;
  }

  replyTo.send({'type': 'ready', 'commands': commands.sendPort});
  await for (final message in commands) {
    if (message is! Map<Object?, Object?>) continue;
    if (message['type'] == 'dispose') break;
    if (message['type'] == 'audio') {
      try {
        final bytes = (message['pcm'] as TransferableTypedData)
            .materialize()
            .asUint8List();
        final samples = Float32List.view(
          bytes.buffer,
          bytes.offsetInBytes,
          bytes.lengthInBytes ~/ Float32List.bytesPerElement,
        );
        buffer.push(samples);
        _consumeVadBuffer(buffer, vad, recognizer, [], replyTo: replyTo);
      } catch (error) {
        replyTo.send({'type': 'error', 'message': error.toString()});
      }
    } else if (message['type'] == 'stop') {
      try {
        if (buffer.size > 0) {
          vad.acceptWaveform(
            buffer.get(startIndex: buffer.head, n: buffer.size),
          );
          buffer.reset();
        }
        vad.flush();
        _drainVad(vad, recognizer, [], replyTo: replyTo);
        replyTo.send({'type': 'stopped'});
      } finally {
        recognizer.free();
        vad.free();
        buffer.free();
        commands.close();
      }
      break;
    }
  }
}

sherpa.OfflineRecognizer _createRecognizer(InstalledWhisperModel model) {
  final config = sherpa.OfflineRecognizerConfig(
    model: sherpa.OfflineModelConfig(
      whisper: sherpa.OfflineWhisperModelConfig(
        encoder: model.encoderPath,
        decoder: model.decoderPath,
        language: 'en',
        task: 'transcribe',
      ),
      tokens: model.tokensPath,
      modelType: 'whisper',
      numThreads: 2,
      debug: false,
    ),
  );
  return sherpa.OfflineRecognizer(config);
}

sherpa.VoiceActivityDetector _createVad(String vadPath) {
  final config = sherpa.VadModelConfig(
    sileroVad: sherpa.SileroVadModelConfig(
      model: vadPath,
      minSilenceDuration: 0.25,
      minSpeechDuration: 0.5,
      maxSpeechDuration: 5.0,
    ),
    numThreads: 1,
    debug: false,
  );
  return sherpa.VoiceActivityDetector(config: config, bufferSizeInSeconds: 30);
}

void _consumeVadBuffer(
  sherpa.CircularBuffer buffer,
  sherpa.VoiceActivityDetector vad,
  sherpa.OfflineRecognizer recognizer,
  List<TranscriptSegment> output, {
  SendPort? replyTo,
}) {
  final windowSize = vad.config.sileroVad.windowSize;
  while (buffer.size >= windowSize) {
    final samples = buffer.get(startIndex: buffer.head, n: windowSize);
    buffer.pop(windowSize);
    vad.acceptWaveform(samples);
    _drainVad(vad, recognizer, output, replyTo: replyTo);
  }
}

void _drainVad(
  sherpa.VoiceActivityDetector vad,
  sherpa.OfflineRecognizer recognizer,
  List<TranscriptSegment> output, {
  SendPort? replyTo,
}) {
  while (!vad.isEmpty()) {
    final segment = vad.front();
    vad.pop();
    final stream = recognizer.createStream();
    try {
      stream.acceptWaveform(
        samples: segment.samples,
        sampleRate: AppConstants.sampleRate,
      );
      recognizer.decode(stream);
      final text = recognizer.getResult(stream).text.trim();
      if (text.isEmpty) continue;
      final start = (segment.start * 1000 / AppConstants.sampleRate).round();
      final end =
          ((segment.start + segment.samples.length) *
                  1000 /
                  AppConstants.sampleRate)
              .round();
      final result = TranscriptSegment(
        text: text,
        startMillis: start,
        endMillis: end,
      );
      output.add(result);
      replyTo?.send({
        'type': 'segment',
        'text': result.text,
        'startMillis': result.startMillis,
        'endMillis': result.endMillis,
      });
    } finally {
      stream.free();
    }
  }
}
