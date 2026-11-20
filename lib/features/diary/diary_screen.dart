import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/recording_details.dart';
import '../home/home_data.dart';
import '../library/local_share.dart';
import '../recording/recorder_controller.dart';
import 'diary_pdf.dart';

enum _DiaryScope { all, today, week, month }

enum _DiaryExport { pdf, text }

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({
    this.initialRecordingId,
    this.exportOnOpen = false,
    super.key,
  });
  final String? initialRecordingId;
  final bool exportOnOpen;

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  _DiaryScope _scope = _DiaryScope.all;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.exportOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _exportPdf());
    }
  }

  bool _inScope(RecordingSummary recording) {
    if (_scope == _DiaryScope.all) return true;
    final now = DateTime.now();
    final day = DateTime(
      recording.createdAt.year,
      recording.createdAt.month,
      recording.createdAt.day,
    );
    switch (_scope) {
      case _DiaryScope.today:
        return day == DateTime(now.year, now.month, now.day);
      case _DiaryScope.week:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        return !day.isBefore(start);
      case _DiaryScope.month:
        return day.year == now.year && day.month == now.month;
      case _DiaryScope.all:
        return true;
    }
  }

  Future<List<RecordingDetails>> _visibleEntries() async {
    final all = await ref.read(homeRecordingsProvider.future);
    final summaries = all.where((r) => !r.isTrashed && _inScope(r)).toList()
      ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
    final repository = await ref.read(recordingsRepositoryProvider.future);
    final details = await Future.wait(
      summaries.map((summary) => repository.getRecordingDetails(summary.id)),
    );
    return details.whereType<RecordingDetails>().toList(growable: false);
  }

  Future<void> _exportPdf() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    _showBusy('Preparing your PDF…');
    try {
      final entries = await _visibleEntries();
      if (entries.isEmpty) {
        _hideBusy();
        _message('Nothing to export yet.');
        return;
      }
      final Uint8List bytes;
      try {
        bytes = await buildDiaryPdf(entries);
      } catch (_) {
        _hideBusy();
        _message('The PDF could not be created on this device.');
        return;
      }
      final directory = await getTemporaryDirectory();
      final stamp = DateTime.now();
      final file = File(
        p.join(directory.path, 'voite-diary-${_fileStamp(stamp)}.pdf'),
      );
      await file.writeAsBytes(bytes, flush: true);
      _hideBusy();
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/pdf')],
            subject: 'Voite diary',
            text: 'Voite diary',
          ),
        );
      } catch (_) {
        _message('The PDF is ready, but the share menu could not be opened.');
      }
    } catch (_) {
      _hideBusy();
      _message('The PDF could not be created on this device.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportText() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    _showBusy('Preparing your diary…');
    try {
      final entries = await _visibleEntries();
      if (entries.isEmpty) {
        _hideBusy();
        _message('Nothing to export yet.');
        return;
      }
      final buffer = StringBuffer('Voite diary\n\n');
      for (final details in entries) {
        final entry = details.recording;
        final date = entry.createdAt;
        buffer.writeln(
          '${date.year}-${_two(date.month)}-${_two(date.day)} · '
          '${entry.title} (${_durationLabel(entry.durationMillis)})',
        );
        if (entry.label.isNotEmpty) buffer.writeln('Label: ${entry.label}');
        if (entry.prompt?.trim().isNotEmpty ?? false) {
          buffer.writeln('Prompt: ${entry.prompt!.trim()}');
        }
        final transcript = details.transcript
            .map((segment) => segment.text.trim())
            .where((text) => text.isNotEmpty)
            .join(' ');
        if (transcript.isNotEmpty) buffer.writeln(transcript);
        buffer.writeln();
      }
      _hideBusy();
      await LocalShare.text(title: 'Voite diary', text: buffer.toString());
    } catch (_) {
      _hideBusy();
      _message('The diary could not be shared on this device.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showBusy(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(minutes: 1)),
      );
  }

  void _hideBusy() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static String _fileStamp(DateTime date) =>
      '${date.year}${_two(date.month)}${_two(date.day)}-'
      '${_two(date.hour)}${_two(date.minute)}';

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _durationLabel(int millis) {
    final seconds = (millis / 1000).round();
    if (seconds < 60) return '$seconds s';
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    if (minutes < 60) {
      return '$minutes min ${rest.toString().padLeft(2, '0')} s';
    }
    final hours = minutes ~/ 60;
    return '$hours h ${(minutes % 60).toString().padLeft(2, '0')} min';
  }

  @override
  Widget build(BuildContext context) {
    final recordings = ref.watch(homeRecordingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your diary'),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                tooltip: 'Home',
                icon: const Icon(Icons.home_outlined),
                onPressed: () => context.go('/'),
              ),
        actions: [
          if (_exporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            PopupMenuButton<_DiaryExport>(
              tooltip: 'Export diary',
              icon: const Icon(Icons.ios_share_rounded),
              onSelected: (format) {
                switch (format) {
                  case _DiaryExport.pdf:
                    _exportPdf();
                  case _DiaryExport.text:
                    _exportText();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _DiaryExport.pdf,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.picture_as_pdf_outlined),
                    title: Text('Share as PDF'),
                  ),
                ),
                PopupMenuItem(
                  value: _DiaryExport.text,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notes_rounded),
                    title: Text('Share as text'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: recordings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your diary could not be opened.'),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(homeRecordingsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (items) {
          final entries =
              items.where((r) => !r.isTrashed && _inScope(r)).toList()..sort(
                (a, b) => b.createdAtMillis.compareTo(a.createdAtMillis),
              );
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _scopeBar(),
              const SizedBox(height: 12),
              if (entries.isEmpty) _emptyState() else ..._daySections(entries),
            ],
          );
        },
      ),
    );
  }

  Widget _scopeBar() => Wrap(
    spacing: 8,
    children: [
      for (final scope in _DiaryScope.values)
        ChoiceChip(
          label: Text(_scopeLabel(scope)),
          selected: _scope == scope,
          showCheckmark: false,
          onSelected: (_) => setState(() => _scope = scope),
        ),
    ],
  );

  String _scopeLabel(_DiaryScope scope) => switch (scope) {
    _DiaryScope.all => 'All',
    _DiaryScope.today => 'Today',
    _DiaryScope.week => 'This week',
    _DiaryScope.month => 'This month',
  };

  Widget _emptyState() => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Image.asset(
            'assets/images/voite-cat-waving.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nothing here yet — record a thought and it will appear in your diary.',
            ),
          ),
        ],
      ),
    ),
  );

  List<Widget> _daySections(List<RecordingSummary> entries) {
    final sections = <Widget>[];
    DateTime? currentDay;
    for (final entry in entries) {
      final created = entry.createdAt;
      final day = DateTime(created.year, created.month, created.day);
      if (currentDay == null || day != currentDay) {
        currentDay = day;
        sections.add(_dayHeader(day));
      }
      sections.add(
        _DiaryEntryCard(
          recording: entry,
          highlighted: entry.id == widget.initialRecordingId,
          timeLabel: '${_two(created.hour)}:${_two(created.minute)}',
          durationLabel: _durationLabel(entry.durationMillis),
          onTap: () => context.push('/recording/${entry.id}'),
        ),
      );
      sections.add(const SizedBox(height: 10));
    }
    return sections;
  }

  Widget _dayHeader(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final label = day == today
        ? 'Today'
        : day == yesterday
        ? 'Yesterday'
        : MaterialLocalizations.of(context).formatMediumDate(day);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DiaryEntryCard extends StatelessWidget {
  const _DiaryEntryCard({
    required this.recording,
    required this.highlighted,
    required this.timeLabel,
    required this.durationLabel,
    required this.onTap,
  });

  final RecordingSummary recording;
  final bool highlighted;
  final String timeLabel;
  final String durationLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = recording.transcriptPreview.trim();
    final status = switch (recording.transcriptionStatus) {
      'complete' => null,
      'queued' => 'Transcript queued',
      'failed' => 'Transcript failed',
      'recording' => 'Recording interrupted — open to review',
      _ => 'No transcript yet',
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: highlighted
            ? const BorderSide(color: AppTheme.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recording.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (highlighted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.orange.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '$timeLabel · $durationLabel · ${recording.label}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                preview.isNotEmpty
                    ? preview
                    : (status ?? 'Tap to open this entry.'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: preview.isNotEmpty
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (recording.prompt != null &&
                  recording.prompt!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Prompt: ${recording.prompt!.trim()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
