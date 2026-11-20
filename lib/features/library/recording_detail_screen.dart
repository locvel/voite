import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../domain/models/recording_details.dart';
import '../../domain/models/transcript_segment.dart';
import '../recording/recorder_controller.dart';
import 'local_share.dart';

class RecordingDetailScreen extends ConsumerStatefulWidget {
  const RecordingDetailScreen({
    required this.recordingId,
    this.initialPositionMillis,
    super.key,
  });

  final String recordingId;
  final int? initialPositionMillis;

  @override
  ConsumerState<RecordingDetailScreen> createState() =>
      _RecordingDetailScreenState();
}

class _RecordingDetailScreenState extends ConsumerState<RecordingDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  late Future<RecordingDetails?> _details;
  String? _loadedPath;
  String? _audioError;
  bool _transcriptionBusy = false;

  @override
  void initState() {
    super.initState();
    _details = _loadDetails();
  }

  Future<RecordingDetails?> _loadDetails() async {
    final repository = await ref.read(recordingsRepositoryProvider.future);
    if (!mounted) return null;
    final details = await repository.getRecordingDetails(widget.recordingId);
    if (details != null && _loadedPath != details.recording.audioPath) {
      _loadedPath = details.recording.audioPath;
      try {
        await _player.setFilePath(details.recording.audioPath);
        final initialPosition = widget.initialPositionMillis;
        if (initialPosition != null && initialPosition > 0) {
          await _player.seek(Duration(milliseconds: initialPosition));
        }
      } catch (_) {
        _audioError = 'Audio could not be opened. The file may be missing or unavailable.';
      }
    }
    return details;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<RecordingDetails?>(
    future: _details,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final details = snapshot.data;
      if (snapshot.hasError || details == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text('This recording is no longer available.'),
          ),
        );
      }
      return _buildPage(context, details);
    },
  );

  Widget _buildPage(BuildContext context, RecordingDetails details) {
    final recording = details.recording;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recording.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Recording actions',
            onSelected: (value) => switch (value) {
              'rename' => _rename(recording),
              'edit_diary' => _editDiaryEntry(details),
              'delete_diary' => _deleteDiaryEntry(details),
              'share_text' => _shareTranscript(details),
              'share_audio' => _shareAudio(recording),
              'delete' => _delete(recording),
              _ => null,
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(
                value: 'edit_diary',
                child: Text('Edit diary entry'),
              ),
              if (details.transcript.isNotEmpty)
                const PopupMenuItem(
                  value: 'delete_diary',
                  child: Text('Delete diary entry'),
                ),
              PopupMenuItem(
                value: 'share_text',
                enabled: details.transcript.isNotEmpty,
                child: const Text('Share transcript'),
              ),
              PopupMenuItem(
                value: 'share_audio',
                enabled: File(recording.audioPath).existsSync(),
                child: const Text('Share audio file'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  recording.isTrashed
                      ? 'Delete permanently'
                      : 'Move to Recently Deleted',
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: SliverList.list(
                children: [
                  Text(
                    _dateLabel(recording.createdAt),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recording.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: const Icon(Icons.sell_outlined, size: 16),
                      label: Text(recording.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_duration(recording.durationMillis)}  ·  WAV · 16 kHz mono',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 22),
                  const _PlaybackCompanions(),
                  const SizedBox(height: 8),
                  _PlayerCard(
                    player: _player,
                    durationMillis: recording.durationMillis,
                    error: _audioError,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Transcript',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (details.transcript.isNotEmpty) ...[
                        IconButton.filledTonal(
                          tooltip: 'Edit diary entry',
                          onPressed: () => _editDiaryEntry(details),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Copy transcript',
                          onPressed: () => _copyTranscript(details),
                          icon: const Icon(Icons.content_copy_rounded),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (details.transcript.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NoTranscriptState(
                          status: recording.transcriptionStatus,
                          onCompanionTap: () => _message(
                            'Transcription runs on this phone after you download a speech model.',
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _transcriptionBusy || recording.isTrashed
                              ? null
                              : _transcribe,
                          icon: _transcriptionBusy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.subject_rounded),
                          label: Text(
                            _transcriptionBusy ? 'Transcribing…' : 'Transcribe',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: recording.isTrashed
                              ? null
                              : () => context.push('/settings'),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download a speech model'),
                        ),
                      ],
                    )
                  else ...[
                    Text(
                      'Tap a paragraph to hear that moment.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    for (final segment in details.transcript)
                      _TranscriptSegmentTile(
                        segment: segment,
                        onTap: () => _seekTo(segment.startMillis),
                      ),
                  ],
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: details.transcript.isEmpty
                        ? null
                        : () => _shareTranscript(details),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share transcript'),
                  ),
                  if (recording.isTrashed) ...[
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: _restore,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore recording'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seekTo(int milliseconds) async {
    await HapticFeedback.selectionClick();
    await _player.seek(Duration(milliseconds: milliseconds));
    await _player.play();
  }

  Future<void> _rename(RecordingSummary recording) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) =>
          _RenameRecordingDialog(initialTitle: recording.title),
    );
    if (value == null || value.trim().isEmpty) return;
    try {
      final repository = await ref.read(recordingsRepositoryProvider.future);
      await repository.renameRecording(recording.id, value);
      if (!mounted) return;
      setState(() => _details = _loadDetails());
    } catch (_) {
      if (mounted) {
        _message('Could not rename this recording. Please try again.');
      }
    }
  }

  Future<void> _editDiaryEntry(RecordingDetails details) async {
    final result = await showDialog<({String title, String transcript})>(
      context: context,
      builder: (context) => _EditDiaryDialog(
        initialTitle: details.recording.title,
        initialTranscript: details.transcript
            .map((segment) => segment.text)
            .join('\n\n'),
      ),
    );
    if (result == null) return;
    if (result.title.isEmpty) {
      _message('Add a title before saving.');
      return;
    }
    try {
      final repository = await ref.read(recordingsRepositoryProvider.future);
      await repository.saveDiaryEntry(
        id: details.recording.id,
        title: result.title,
        transcript: result.transcript,
      );
      if (!mounted) return;
      setState(() => _details = _loadDetails());
      _message('Diary entry saved on this device.');
    } catch (_) {
      if (mounted) {
        _message('The diary entry could not be saved. Please try again.');
      }
    }
  }

  Future<void> _deleteDiaryEntry(RecordingDetails details) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.notes_rounded),
        title: const Text('Delete diary entry?'),
        content: const Text(
          'The transcript will be removed from this device. The audio recording stays in your library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep entry'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete entry'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      final repository = await ref.read(recordingsRepositoryProvider.future);
      await repository.deleteDiaryEntry(details.recording.id);
      if (!mounted) return;
      setState(() => _details = _loadDetails());
      _message('Diary entry deleted. Your audio is still saved.');
    } catch (_) {
      if (mounted) {
        _message('The diary entry could not be deleted. Please try again.');
      }
    }
  }

  Future<void> _shareTranscript(RecordingDetails details) async {
    if (details.transcript.isEmpty) {
      _message('There is no transcript to share yet.');
      return;
    }
    final content = StringBuffer(
      '${details.recording.title}\n${_dateLabel(details.recording.createdAt)}\n\n',
    );
    for (final segment in details.transcript) {
      content.writeln('[${_timestamp(segment.startMillis)}] ${segment.text}');
    }
    try {
      await LocalShare.text(
        title: details.recording.title,
        text: content.toString().trim(),
      );
    } on PlatformException catch (error) {
      _message(error.message ?? 'Could not open the share menu.');
    }
  }

  Future<void> _shareAudio(RecordingSummary recording) async {
    try {
      await LocalShare.audio(title: recording.title, path: recording.audioPath);
    } on PlatformException catch (error) {
      _message(error.message ?? 'Could not share this audio file.');
    }
  }

  Future<void> _copyTranscript(RecordingDetails details) async {
    final text = details.transcript.map((segment) => segment.text).join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _message('Transcript copied');
  }

  Future<void> _transcribe() async {
    setState(() => _transcriptionBusy = true);
    try {
      await ref
          .read(recorderControllerProvider.notifier)
          .transcribeSavedRecording(recordingId: widget.recordingId);
      if (!mounted) return;
      setState(() => _details = _loadDetails());
      _message('Transcript saved on this device.');
    } catch (_) {
      if (mounted) {
        _message('Transcription could not finish. Your audio is still saved.');
      }
    } finally {
      if (mounted) setState(() => _transcriptionBusy = false);
    }
  }

  Future<void> _restore() async {
    final repository = await ref.read(recordingsRepositoryProvider.future);
    if (!mounted) return;
    await repository.restoreRecording(widget.recordingId);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(RecordingSummary recording) async {
    if (!recording.isTrashed) {
      final repository = await ref.read(recordingsRepositoryProvider.future);
      if (!mounted) return;
      await repository.moveToTrash(recording.id);
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text(
          'This removes the audio and transcript from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    final repository = await ref.read(recordingsRepositoryProvider.future);
    await repository.deleteRecording(recording.id);
    if (mounted) Navigator.of(context).pop();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.durationMillis,
    required this.error,
  });

  final AudioPlayer player;
  final int durationMillis;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'ON DEVICE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (error != null)
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.recordRed,
                )
              else
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton.filled(
                      tooltip: playing ? 'Pause' : 'Play',
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        playing ? await player.pause() : await player.play();
                      },
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    );
                  },
                ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!, style: Theme.of(context).textTheme.bodySmall),
          ] else ...[
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = Duration(milliseconds: durationMillis);
                final max = duration.inMilliseconds
                    .toDouble()
                    .clamp(1, double.infinity)
                    .toDouble();
                return Column(
                  children: [
                    Slider(
                      value: position.inMilliseconds
                          .toDouble()
                          .clamp(0, max)
                          .toDouble(),
                      max: max,
                      onChanged: (value) =>
                          player.seek(Duration(milliseconds: value.round())),
                    ),
                    Row(
                      children: [
                        Text(
                          _timestamp(position.inMilliseconds),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        Text(
                          _timestamp(durationMillis),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PopupMenuButton<double>(
              tooltip: 'Playback speed',
              initialValue: player.speed,
              onSelected: (speed) async {
                await HapticFeedback.selectionClick();
                await player.setSpeed(speed);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0.75, child: Text('0.75×')),
                PopupMenuItem(value: 1, child: Text('1×')),
                PopupMenuItem(value: 1.25, child: Text('1.25×')),
                PopupMenuItem(value: 1.5, child: Text('1.5×')),
                PopupMenuItem(value: 2, child: Text('2×')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Playback speed',
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: colors.primary),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${player.speed}×',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptSegmentTile extends StatelessWidget {
  const _TranscriptSegmentTile({required this.segment, required this.onTap});
  final TranscriptSegment segment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _timestamp(segment.startMillis),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    segment.text,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoTranscriptState extends StatelessWidget {
  const _NoTranscriptState({
    required this.status,
    required this.onCompanionTap,
  });
  final String status;
  final VoidCallback onCompanionTap;

  @override
  Widget build(BuildContext context) {
    final waitingForModel = status == 'queued';
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                waitingForModel
                    ? Icons.offline_bolt_rounded
                    : Icons.subject_rounded,
                color: colors.primary,
                size: 30,
              ),
              IconButton(
                tooltip: 'About transcription',
                onPressed: onCompanionTap,
                icon: const Icon(Icons.info_outline_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              waitingForModel
                  ? 'This recording is waiting for a transcript. Tap Transcribe to create one on this device.'
                  : 'There are no transcript segments for this recording.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackCompanions extends StatelessWidget {
  const _PlaybackCompanions();

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final imageWidth = isTablet ? 90.0 : 70.0;
    final imageHeight = isTablet ? 124.0 : 96.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/voite-fox-listening.png',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
          semanticLabel: 'The fox listens alongside audio playback',
        ),
        Image.asset(
          'assets/images/voite-bird-listening.png',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
          semanticLabel: 'The bird listens alongside audio playback',
        ),
        Image.asset(
          'assets/images/voite-frog-listening.png',
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.contain,
          semanticLabel: 'The frog listens alongside audio playback',
        ),
      ],
    );
  }
}

String _dateLabel(DateTime value) =>
    '${_month(value.month)} ${value.day}, ${value.year} · ${_clock(value)}';

String _month(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '$hour:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
}

String _duration(int milliseconds) {
  final total = milliseconds ~/ 1000;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  if (minutes > 0) return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  return '${seconds}s';
}

String _timestamp(int milliseconds) {
  final total = milliseconds ~/ 1000;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  return hours > 0
      ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
      : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

// Lifecycle-safe dialog that manages TextEditingController disposal
class _RenameRecordingDialog extends StatefulWidget {
  const _RenameRecordingDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameRecordingDialog> createState() => _RenameRecordingDialogState();
}

class _RenameRecordingDialogState extends State<_RenameRecordingDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename recording'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Lifecycle-safe dialog that manages multiple TextEditingController disposal
class _EditDiaryDialog extends StatefulWidget {
  const _EditDiaryDialog({
    required this.initialTitle,
    required this.initialTranscript,
  });

  final String initialTitle;
  final String initialTranscript;

  @override
  State<_EditDiaryDialog> createState() => _EditDiaryDialogState();
}

class _EditDiaryDialogState extends State<_EditDiaryDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _transcriptController = TextEditingController(
      text: widget.initialTranscript,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit diary entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _transcriptController,
              minLines: 4,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Diary entry',
                hintText: 'Write what you want to remember…',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((
            title: _titleController.text.trim(),
            transcript: _transcriptController.text.trim(),
          )),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
