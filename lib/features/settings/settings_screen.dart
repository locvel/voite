import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../core/widgets/entrance_animation.dart';
import '../home/home_data.dart';
import '../recording/recorder_controller.dart';
import '../transcription/model_download_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(dailyReminderEnabledProvider);
    final time = ref.watch(dailyReminderTimeProvider);
    final goalMinutes = ref.watch(dailyGoalMinutesProvider);
    final theme =
        ref.watch(themeModeProvider).asData?.value ?? ThemeMode.system;
    final manager = ref.watch(modelDownloadManagerProvider);
    final selectedModel = ref.watch(recorderControllerProvider).modelSize;
    final recordingInProgress = ref.watch(
      recorderControllerProvider.select((state) => state.isRecording),
    );
    final recorderController = ref.read(recorderControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          EntranceAnimation(
            delay: Duration.zero,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A private space for your voice.',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Free · offline · yours'),
                        ],
                      ),
                    ),
                    for (final companion in [
                      ('voite-fox-hero.png', 'Finn the fox'),
                      ('voite-bird-hero.png', 'Wren the bird'),
                      ('voite-frog-hero.png', 'Moss the frog'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Image.asset(
                          'assets/images/${companion.$1}',
                          width: 42,
                          height: 70,
                          fit: BoxFit.contain,
                          semanticLabel: companion.$2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _heading(context, 'YOUR DAY'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 100),
            child: Card(
              child: Column(
                children: [
                  goalMinutes.when(
                    data: (minutes) => ListTile(
                      leading: const Icon(Icons.today_outlined),
                      title: const Text('Daily diary goal'),
                      subtitle: Text(
                        '$minutes ${minutes == 1 ? 'minute' : 'minutes'} a day — the cat fills as you record',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _adjustDailyGoal(context, ref, minutes),
                    ),
                    error: (_, _) => const ListTile(
                      leading: Icon(Icons.today_outlined),
                      title: Text('Daily diary goal'),
                      subtitle: Text(
                        '10 minutes a day — the cat fills as you record',
                      ),
                    ),
                    loading: () => const ListTile(
                      leading: Icon(Icons.today_outlined),
                      title: Text('Daily diary goal'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  reminder.when(
                    data: (on) => SwitchListTile(
                      secondary: ClipOval(
                        child: Image.asset(
                          'assets/images/voite-avatar-notif.png',
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          semanticLabel: 'Voite reminder avatar',
                        ),
                      ),
                      title: const Text('Daily reminder'),
                      subtitle: Text(on ? 'A gentle nudge each day' : 'Off'),
                      value: on,
                      onChanged: (v) async {
                        try {
                          await saveDailyReminderEnabled(ref, v);
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The reminder could not be updated. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    error: (_, _) => const ListTile(
                      title: Text('Daily reminder unavailable'),
                    ),
                    loading: () => const ListTile(
                      title: Text('Daily reminder'),
                      trailing: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.schedule_rounded),
                    title: const Text('Reminder time'),
                    subtitle: Text(
                      _parseTime(time.asData?.value).format(context),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final current = _parseTime(time.asData?.value);
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: current,
                      );
                      if (picked != null) {
                        try {
                          await saveDailyReminderTime(ref, picked);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The reminder time could not be saved. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _heading(context, 'APPEARANCE'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 200),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: {theme},
                      onSelectionChanged: (v) =>
                          ref.read(themeModeProvider.notifier).setMode(v.first),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _heading(context, 'ON-DEVICE TRANSCRIPTION'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 300),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Choose an on-device speech model'),
                        ),
                        for (final companion in [
                          ('voite-fox-thinking.png', 'Fox thinking'),
                          ('voite-bird-thinking.png', 'Bird thinking'),
                          ('voite-frog-thinking.png', 'Frog thinking'),
                        ])
                          Image.asset(
                            'assets/images/${companion.$1}',
                            width: 28,
                            height: 42,
                            fit: BoxFit.contain,
                            semanticLabel: companion.$2,
                          ),
                      ],
                    ),
                    Text(
                      'English-only models. Download to this phone, then transcribe offline.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final model in WhisperSize.values)
            EntranceAnimation(
              delay: Duration(milliseconds: 350 + (model.index * 50)),
              child: _ModelPackCard(
                size: model,
                manager: manager,
                selected: selectedModel == model,
                onSelect: () => recorderController.chooseModel(model),
              ),
            ),
          if (manager.errorMessage != null)
            EntranceAnimation(
              delay: const Duration(milliseconds: 500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/voite-error-offline.png',
                        width: 120,
                        height: 150,
                        fit: BoxFit.contain,
                        semanticLabel: 'Offline model download error',
                      ),
                      const Text(
                        'Couldn’t download the model. Check your connection and try again.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: () => _retryDownload(context, manager),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          _heading(context, 'DIARY'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 550),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/voite-icon-diary.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                    title: const Text('Your diary'),
                    subtitle: const Text('Read, edit, and play your entries'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/diary'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/voite-icon-pdf.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                    title: const Text('Export diary as PDF'),
                    subtitle: const Text('Share your diary entries as a PDF'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/diary?export=1'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('Export recordings'),
                    subtitle: const Text('Share original audio files'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _exportRecordings(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _heading(context, 'ABOUT'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 600),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About Voite'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/about'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Licences'),
                    subtitle: const Text(
                      'Open-source notices for the libraries Voite uses',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Voite',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _heading(context, 'DANGER ZONE'),
          EntranceAnimation(
            delay: const Duration(milliseconds: 650),
            child: Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.recordRed,
                ),
                title: const Text(
                  'Delete all recordings',
                  style: TextStyle(
                    color: AppTheme.recordRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  recordingInProgress
                      ? 'Stop the active recording before deleting saved recordings'
                      : 'Remove saved audio, transcripts, and diary entries from this phone',
                ),
                onTap: recordingInProgress
                    ? null
                    : () => _deleteAll(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${AppConstants.displayName} · Version ${AppConstants.version}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _heading(BuildContext c, String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      s,
      style: Theme.of(c).textTheme.labelLarge?.copyWith(
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
        color: Theme.of(c).colorScheme.primary,
      ),
    ),
  );
  static TimeOfDay _parseTime(String? value) {
    if (value == null) return const TimeOfDay(hour: 9, minute: 0);
    final p = value.split(':');
    if (p.length != 2) return const TimeOfDay(hour: 9, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(p[0]) ?? 9,
      minute: int.tryParse(p[1]) ?? 0,
    );
  }

  Future<void> _exportRecordings(BuildContext context, WidgetRef ref) async {
    final repository = await ref.read(recordingsRepositoryProvider.future);
    if (!context.mounted) return;
    final recordings = await repository.watchLibrary().first;
    final files = <XFile>[];
    for (final recording in recordings.where((item) => !item.isTrashed)) {
      final file = File(recording.audioPath);
      if (await file.exists()) files.add(XFile(file.path));
    }
    if (!context.mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no recordings to export yet.')),
      );
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: files, subject: 'Voite recordings'),
    );
  }

  Future<void> _retryDownload(
    BuildContext context,
    ModelDownloadManager manager,
  ) async {
    try {
      await manager.start(manager.activeSize ?? WhisperSize.baseEn);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The model download could not be completed.'),
          ),
        );
      }
    }
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all recordings?'),
        content: const Text(
          "This permanently removes saved audio, transcripts, and diary entries from this phone. Downloaded models and app settings will remain. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep everything'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.recordRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    if (ref.read(recorderControllerProvider).isRecording) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stop the active recording before deleting saved recordings.',
            ),
          ),
        );
      }
      return;
    }
    final repo = await ref.read(recordingsRepositoryProvider.future);
    if (!context.mounted) return;
    try {
      await repo.deleteAllData();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saved recordings could not be deleted. Please try again.',
            ),
          ),
        );
      }
      return;
    }
    ref.invalidate(homeRecordingsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All saved recordings and diary entries were deleted.'),
        ),
      );
    }
  }

  Future<void> _adjustDailyGoal(
    BuildContext context,
    WidgetRef ref,
    int currentMinutes,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _DailyGoalDialog(initialMinutes: currentMinutes),
    );
    if (result == null) return;
    try {
      await saveDailyGoalMinutes(ref, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily goal set to $result ${result == 1 ? 'minute' : 'minutes'}',
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The daily goal could not be saved. Please try again.',
            ),
          ),
        );
      }
    }
  }
}

class _DailyGoalDialog extends StatefulWidget {
  const _DailyGoalDialog({required this.initialMinutes});
  final int initialMinutes;

  @override
  State<_DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends State<_DailyGoalDialog> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _currentValue.round();
    return AlertDialog(
      title: const Text('Daily diary goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$minutes ${minutes == 1 ? 'minute' : 'minutes'} per day',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: AppTheme.orange),
          ),
          const SizedBox(height: 16),
          const Text(
            'Set your daily recording goal. The cat fills as you record each day.',
          ),
          const SizedBox(height: 24),
          Slider(
            value: _currentValue,
            min: 1,
            max: 120,
            divisions: 119,
            label: '$minutes min',
            onChanged: (value) => setState(() => _currentValue = value),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 min', style: Theme.of(context).textTheme.bodySmall),
              Text('120 min', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, minutes),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ModelPackCard extends StatelessWidget {
  const _ModelPackCard({
    required this.size,
    required this.manager,
    required this.selected,
    required this.onSelect,
  });
  final WhisperSize size;
  final ModelDownloadManager manager;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: manager,
        builder: (context, _) => FutureBuilder<InstalledWhisperModel?>(
          future: manager.findInstalled(size),
          builder: (context, snapshot) {
            final installed = snapshot.data != null;
            final title = switch (size) {
              WhisperSize.tinyEn => 'Light · smallest',
              WhisperSize.baseEn => 'Balanced · default',
              WhisperSize.smallEn => 'Maximum · highest accuracy',
            };
            final downloading =
                manager.isDownloading && size == manager.activeSize;
            return ListTile(
              leading: Icon(
                installed
                    ? Icons.check_circle_rounded
                    : Icons.download_for_offline_outlined,
                color: installed ? AppTheme.orange : null,
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${size.label} · ${installed ? 'Ready on this phone' : 'Download to transcribe offline'}',
                  ),
                  if (downloading) ...[
                    const SizedBox(height: 6),
                    Text('Downloading ${(manager.progress * 100).round()}%'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: manager.progress),
                  ],
                ],
              ),
              trailing: downloading
                  ? const _DownloadingIcon()
                  : TextButton(
                      onPressed: installed
                          ? selected
                                ? null
                                : onSelect
                          : () => _download(context),
                      child: Text(
                        installed
                            ? selected
                                  ? 'In use'
                                  : 'Use'
                            : 'Download',
                      ),
                    ),
              onTap: downloading
                  ? null
                  : installed
                  ? onSelect
                  : () => _download(context),
            );
          },
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    try {
      final preview = await manager.preview(size);
      if (!context.mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Download ${size.label}?'),
          content: Text(
            'About ${preview.sizeLabel} will be stored on this phone. An internet connection is needed for the download.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Download'),
            ),
          ],
        ),
      );
      if (accepted == true) await manager.start(size);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Couldn’t download the model. Check your connection and try again.',
            ),
          ),
        );
      }
    }
  }
}

class _DownloadingIcon extends StatefulWidget {
  const _DownloadingIcon();

  @override
  State<_DownloadingIcon> createState() => _DownloadingIconState();
}

class _DownloadingIconState extends State<_DownloadingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.downloading_rounded),
    );
  }
}
