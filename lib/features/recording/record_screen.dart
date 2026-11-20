import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/platform/app_settings_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/storage_policy.dart';
import '../../core/widgets/entrance_animation.dart';
import '../../core/widgets/recorder_companion.dart';
import '../../core/widgets/voite_mark.dart';
import '../../domain/models/transcript_segment.dart';
import '../transcription/model_download_manager.dart';
import 'recorder_controller.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recorderControllerProvider);
    final controller = ref.read(recorderControllerProvider.notifier);
    final manager = ref.watch(modelDownloadManagerProvider);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5),
          child: const VoiteMark(size: 42),
        ),
        title: Text(
          AppConstants.displayName,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EntranceAnimation(
                        child: _StudioHero(
                          isRecording: state.isRecording,
                          isPaused: state.isPaused,
                          isTranscribing: state.isTranscribing,
                          audioLevel: controller.audioLevel,
                          onCompanionTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            _showMessage(
                              context,
                              state.isTranscribing
                                  ? 'Your recording is saved while it is transcribed on this phone.'
                                  : state.isPaused
                                  ? 'Voite is holding your place. Resume when you’re ready.'
                                  : state.isRecording
                                  ? 'The Voite cat is listening with you. Your audio stays on this device.'
                                  : 'Tap Start recording when you’re ready. Your audio stays on this device.',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 45),
                        child: _RecordingCard(
                          state: state,
                          audioLevel: controller.audioLevel,
                          onBuddyTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            _showMessage(
                              context,
                              state.isRecording && !state.isPaused
                                  ? 'Oren is moving with the sound reaching your microphone.'
                                  : 'Start recording and Oren will respond to the room’s sound.',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 80),
                        child: _CapturePresetPicker(
                          selected: state.recordingLabel,
                          customLabels: state.customLabels,
                          isRecording: state.isRecording,
                          onSelected: (label) {
                            if (label != state.recordingLabel) {
                              controller.chooseRecordingLabel(label);
                              unawaited(HapticFeedback.selectionClick());
                            }
                          },
                          onAddLabel: () => _addCustomLabel(
                            context,
                            controller,
                            state.customLabels,
                          ),
                        ),
                      ),
                      if (!state.isRecording && !state.isTranscribing) ...[
                        const SizedBox(height: 10),
                        _ConsentReminder(label: state.recordingLabel),
                      ],
                      const SizedBox(height: 16),
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 80),
                        child: _ModelCard(
                          state: state,
                          manager: manager,
                          onChoose: controller.chooseModel,
                          onDownload: () =>
                              _downloadModel(context, manager, state.modelSize),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.storageWarning == StorageWarning.lowSpace)
                        const _NoticeCard(
                          icon: Icons.storage_rounded,
                          text: 'Storage is getting low. Free space before a long recording.',
                        ),
                      if (state.storageWarning == StorageWarning.blocked)
                        const _NoticeCard(
                          icon: Icons.block_rounded,
                          text: 'At least 200 MB of free space is required to record.',
                        ),
                      if (state.notificationPermissionDenied)
                        const _NoticeCard(
                          icon: Icons.notifications_off_outlined,
                          text: 'Notifications are off. You can still record; use the in-app Stop button when you are finished.',
                        ),
                      if (state.errorMessage != null)
                        _NoticeCard(
                          icon: Icons.info_outline_rounded,
                          text: state.errorMessage!,
                          isError: true,
                        ),
                      if (state.storageWarning == StorageWarning.lowSpace ||
                          state.storageWarning == StorageWarning.blocked ||
                          state.errorMessage != null)
                        const SizedBox(height: 16),
                      EntranceAnimation(
                        delay: const Duration(milliseconds: 220),
                        child: _TranscriptCard(
                          transcript: state.transcript,
                          isRecording: state.isRecording,
                          isTranscribing: state.isTranscribing,
                          queued: state.transcriptionQueued,
                          retrying: state.retryingTranscription,
                          onRetry: () =>
                              _retryTranscription(context, controller),
                          onCompanionTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            _showMessage(
                              context,
                              state.transcriptionQueued
                                  ? 'Install a Whisper model to let Wren help create a transcript on this device.'
                                  : 'Wren keeps recognized phrases in order as you record.',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor
                          .withValues(alpha: 0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
              child: Row(
                children: [
                  Expanded(
                    child: _ScaleButton(
                      isPressed: state.isRecording,
                      child: FilledButton(
                        onPressed: state.isTranscribing
                            ? null
                            : state.isRecording
                            ? () => _stop(context, controller)
                            : () => _begin(context, controller),
                        style: FilledButton.styleFrom(
                          backgroundColor: state.isRecording
                              ? AppTheme.recordRed
                              : AppTheme.orange,
                          foregroundColor: state.isRecording
                              ? Colors.white
                              : AppTheme.ink,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                              child: Icon(
                                state.isTranscribing
                                    ? Icons.hourglass_top_rounded
                                    : state.isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                key: ValueKey((
                                  state.isRecording,
                                  state.isTranscribing,
                                )),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.12),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                child: Text(
                                  state.isTranscribing
                                      ? 'Writing it down…'
                                      : state.isRecording
                                      ? 'Stop recording'
                                      : 'Start recording',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  key: ValueKey(
                                    'record-label-${state.isRecording}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (state.isRecording) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _togglePause(context, controller, state.isPaused),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                              child: Icon(
                                state.isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                key: ValueKey('pause-icon-${state.isPaused}'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: Text(
                                  state.isPaused ? 'Resume' : 'Pause',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  key: ValueKey(
                                    'pause-label-${state.isPaused}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Future<void> _begin(
    BuildContext context,
    RecorderController controller,
  ) async {
    try {
      if (!await controller.requestMicrophonePermission()) {
        if (!context.mounted) return;
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.mic_off_outlined),
            title: const Text('Microphone access is off'),
            content: const Text(
              'Allow microphone access in Settings to record audio.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        if (openSettings == true && context.mounted) {
          await AppSettingsLauncher.open();
        }
        return;
      }
      await controller.start();
      await HapticFeedback.lightImpact();
    } catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          'Recording could not start. Check microphone access and available storage, then try again.',
        );
      }
    }
  }

  Future<void> _stop(
    BuildContext context,
    RecorderController controller,
  ) async {
    try {
      final recordingId = await controller.stop();
      if (!context.mounted || recordingId == null) return;
      await HapticFeedback.mediumImpact();
      if (context.mounted) context.go('/diary', extra: recordingId);
    } catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          'The stop failed. Check your library for the saved audio.',
        );
      }
    }
  }

  Future<void> _addCustomLabel(
    BuildContext context,
    RecorderController controller,
    List<String> customLabels,
  ) async {
    final editor = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final label = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.sell_outlined),
          title: const Text('Create a label'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: editor,
              autofocus: true,
              maxLength: 36,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Class, course, project…',
                hintText: 'e.g. Biology 101',
              ),
              validator: (value) {
                final clean = value?.trim() ?? '';
                if (clean.isEmpty) return 'Enter a label name.';
                final allLabels = {
                  'Voice note',
                  'Lecture',
                  'Meeting',
                  'Idea',
                  ...customLabels,
                };
                if (allLabels.any(
                  (item) => item.toLowerCase() == clean.toLowerCase(),
                )) {
                  return 'That label already exists.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(editor.text.trim());
                }
              },
              child: const Text('Create label'),
            ),
          ],
        ),
      );
      if (label == null) return;
      await controller.addCustomLabel(label);
      await HapticFeedback.selectionClick();
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          'The label could not be saved. Please try again.',
        );
      }
    } finally {
      editor.dispose();
    }
  }

  Future<void> _togglePause(
    BuildContext context,
    RecorderController controller,
    bool isPaused,
  ) async {
    try {
      if (isPaused) {
        await controller.resume();
      } else {
        await controller.pause();
      }
      await HapticFeedback.selectionClick();
    } catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          'The recording could not be updated. Please try again.',
        );
      }
    }
  }

  Future<void> _retryTranscription(
    BuildContext context,
    RecorderController controller,
  ) async {
    try {
      await controller.retryPendingTranscription();
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          'Transcription could not be retried. Your audio is still saved.',
        );
      }
    }
  }

  Future<void> _downloadModel(
    BuildContext context,
    ModelDownloadManager manager,
    WhisperSize size,
  ) async {
    try {
      final preview = await manager.preview(size);
      if (!context.mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.download_for_offline_rounded),
          title: Text('Download ${size.label}?'),
          content: Text(
            'This model needs ${preview.sizeLabel} of free space. '
            'The files are downloaded directly to this device and verified before use.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Download'),
            ),
          ],
        ),
      );
      if (accepted == true) await manager.start(size);
    } catch (error) {
      if (context.mounted) {
        _showMessage(
          context,
          'Could not download the model. Check your connection and try again.',
        );
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StudioHero extends StatelessWidget {
  const _StudioHero({
    required this.isRecording,
    required this.isPaused,
    required this.isTranscribing,
    required this.audioLevel,
    required this.onCompanionTap,
  });

  final bool isRecording;
  final bool isPaused;
  final bool isTranscribing;
  final ValueListenable<double> audioLevel;
  final VoidCallback onCompanionTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        height: 210,
        decoration: BoxDecoration(color: colors.surface),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -56,
              right: 84,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -55,
              left: 96,
              child: Container(
                width: 164,
                height: 164,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 19,
              bottom: 17,
              child: SizedBox(
                width: 174,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTranscribing
                              ? Icons.hourglass_top_rounded
                              : isPaused
                              ? Icons.pause_rounded
                              : isRecording
                              ? Icons.graphic_eq_rounded
                              : Icons.lock_outline_rounded,
                          color: colors.primary,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTranscribing
                              ? 'ON YOUR PHONE'
                              : isPaused
                              ? 'ON PAUSE'
                              : isRecording
                              ? 'IN YOUR MOMENT'
                              : 'PRIVATE BY DESIGN',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: const Interval(
                        0.45,
                        1,
                        curve: Curves.easeOutCubic,
                      ),
                      switchOutCurve: const Interval(
                        0.45,
                        1,
                        curve: Curves.easeInCubic,
                      ),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        isTranscribing
                            ? 'Writing it\ndown…'
                            : isPaused
                            ? 'Take a breath.\nVoite will wait.'
                            : isRecording
                            ? 'Stay here.\nYou’re doing fine.'
                            : 'Make room\nto listen.',
                        key: ValueKey((isRecording, isPaused, isTranscribing)),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: colors.onSurface,
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w700,
                              height: 1.08,
                              letterSpacing: -0.7,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Audio stays on this device.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 3,
              bottom: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: audioLevel,
                builder: (context, level, _) {
                  final reduceMotion = MediaQuery.disableAnimationsOf(context);
                  final input = isRecording && !isPaused && !reduceMotion
                      ? level.clamp(0.0, 1.0).toDouble()
                      : 0.0;
                  final duration = reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 150);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        width: 116 + input * 30,
                        height: 116 + input * 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.orange.withValues(
                            alpha: isRecording && !isPaused
                                ? 0.045 + input * 0.11
                                : 0.035,
                          ),
                          border: Border.all(
                            color: AppTheme.orange.withValues(
                              alpha: isRecording && !isPaused
                                  ? 0.18 + input * 0.46
                                  : 0.13,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.orange.withValues(
                                alpha: isRecording && !isPaused
                                    ? 0.06 + input * 0.18
                                    : 0.025,
                              ),
                              blurRadius: 10 + input * 18,
                              spreadRadius: input * 3,
                            ),
                          ],
                        ),
                      ),
                      AnimatedScale(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 190),
                        scale: isPaused
                            ? 0.96
                            : isRecording
                            ? 1 + input * 0.055
                            : 1,
                        curve: Curves.easeOutCubic,
                        child: RecorderCompanion(
                          mood: isTranscribing
                              ? CompanionMood.thinking
                              : isPaused
                              ? CompanionMood.thinking
                              : isRecording
                              ? CompanionMood.listening
                              : CompanionMood.curious,
                          width: 160,
                          height: 184,
                          semanticLabel: isPaused
                              ? 'Voite is waiting while recording is paused.'
                              : isRecording
                              ? 'The Voite cat listens while recording is active.'
                              : 'Voite the cat. Tap for a privacy note.',
                          onTap: onCompanionTap,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (isRecording && !isPaused)
              Positioned(
                right: 18,
                top: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/voite-fox-flying.png',
                      width: 32,
                      height: 48,
                      fit: BoxFit.contain,
                      semanticLabel: 'Fox floating beside the recorder',
                    ),
                    Image.asset(
                      'assets/images/voite-frog-floating.png',
                      width: 32,
                      height: 48,
                      fit: BoxFit.contain,
                      semanticLabel: 'Frog floating beside the recorder',
                    ),
                  ],
                ),
              ),
            Positioned(
              right: 18,
              top: 17,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  isPaused
                      ? Icons.pause_rounded
                      : isRecording
                      ? Icons.graphic_eq_rounded
                      : Icons.auto_awesome_rounded,
                  size: 17,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentReminder extends StatelessWidget {
  const _ConsentReminder({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final copy = label == 'Meeting' || label == 'Lecture'
        ? "Everyone here knows you're recording, right?"
        : "Recording other people? Make sure everyone you're recording knows.";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.groups_2_outlined,
            size: 19,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              copy,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturePresetPicker extends StatelessWidget {
  const _CapturePresetPicker({
    required this.selected,
    required this.customLabels,
    required this.isRecording,
    required this.onSelected,
    required this.onAddLabel,
  });

  final String selected;
  final List<String> customLabels;
  final bool isRecording;
  final ValueChanged<String> onSelected;
  final VoidCallback onAddLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sell_outlined, size: 18, color: colors.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Recording label',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isRecording ? 'IN THIS RECORDING' : 'MAKE IT YOURS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: isRecording
                  ? Row(
                      key: const ValueKey('active-recording-label'),
                      children: [
                        Icon(Icons.graphic_eq_rounded, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Saving as $selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final label in [
                          'Voice note',
                          'Lecture',
                          'Meeting',
                          'Idea',
                          ...customLabels,
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: selected == label,
                            onSelected: (_) => onSelected(label),
                            avatar: selected == label
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: colors.primary,
                                  )
                                : null,
                          ),
                        ActionChip(
                          avatar: Icon(
                            Icons.add_rounded,
                            size: 17,
                            color: colors.primary,
                          ),
                          label: const Text('Create label'),
                          onPressed: onAddLabel,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({
    required this.state,
    required this.audioLevel,
    required this.onBuddyTap,
  });

  final RecorderUiState state;
  final ValueListenable<double> audioLevel;
  final VoidCallback onBuddyTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = state.isRecording && !state.isPaused;
    final paused = state.isRecording && state.isPaused;
    final readyAccent = colors.primary;
    const recordingAccent = AppTheme.recordRed;
    final pausedAccent = colors.tertiary;
    final statusColor = active
        ? recordingAccent
        : paused
        ? pausedAccent
        : readyAccent;
    final label = !state.isRecording
        ? 'Ready to record'
        : state.isPaused
        ? 'Recording paused'
        : 'Recording';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: active
            ? colors.primaryContainer.withValues(alpha: 0.68)
            : paused
            ? colors.tertiaryContainer.withValues(alpha: 0.62)
            : colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active
              ? colors.primary.withValues(alpha: 0.36)
              : paused
              ? pausedAccent.withValues(alpha: 0.38)
              : colors.outlineVariant.withValues(alpha: 0.72),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 9),
                ),
              ]
            : const [],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(19, 17, 19, 16),
        child: Column(
          children: [
            Semantics(
              liveRegion: true,
              label: label,
              child: Row(
                children: [
                  _PulseIndicator(active: active, color: statusColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        active ? 'Voite is listening' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        key: ValueKey(label),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'About this recording',
                    visualDensity: VisualDensity.compact,
                    onPressed: onBuddyTap,
                    icon: const Icon(Icons.info_outline_rounded, size: 19),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 170),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _formatDuration(state.elapsedMillis),
                key: ValueKey(state.elapsedMillis ~/ 1000),
                semanticsLabel:
                    'Elapsed time ${_formatDuration(state.elapsedMillis)}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontFamily: 'Sora',
                  fontFeatures: const [],
                  fontSize: 54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(17),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _Soundwave(
                active: active,
                paused: paused,
                color: statusColor,
                audioLevel: audioLevel,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smartphone_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Text(
                  'Stored here  ·  WAV  ·  16 kHz mono',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Soundwave extends StatefulWidget {
  const _Soundwave({
    required this.active,
    required this.paused,
    required this.color,
    required this.audioLevel,
  });

  final bool active;
  final bool paused;
  final Color color;
  final ValueListenable<double> audioLevel;

  @override
  State<_Soundwave> createState() => _SoundwaveState();
}

class _SoundwaveState extends State<_Soundwave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    value: 0.5,
  );
  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant _Soundwave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.paused != widget.paused) {
      _syncMotion();
    }
  }

  void _syncMotion() {
    if (widget.active && !widget.paused && !_reducedMotion) {
      if (!_motion.isAnimating) _motion.repeat();
    } else {
      _motion.stop();
      _motion.value = 0.5;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.active
        ? 'Live microphone level'
        : widget.paused
        ? 'Recording paused'
        : 'Microphone ready',
    child: SizedBox(
      height: 40,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _WaveformPainter(
            motion: _motion,
            audioLevel: widget.audioLevel,
            active: widget.active,
            paused: widget.paused,
            color: widget.color,
          ),
        ),
      ),
    ),
  );
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.motion,
    required this.audioLevel,
    required this.active,
    required this.paused,
    required this.color,
  }) : super(repaint: Listenable.merge([motion, audioLevel]));

  final Animation<double> motion;
  final ValueListenable<double> audioLevel;
  final bool active;
  final bool paused;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 43;
    const barWidth = 3.2;
    final step = size.width / barCount;
    final centerY = size.height / 2;
    final input = audioLevel.value.clamp(0.0, 1.0);
    final opacity = active
        ? 0.92
        : paused
        ? 0.55
        : 0.34;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < barCount; index++) {
      final position = index / (barCount - 1);
      final envelope = 0.22 + 0.78 * math.sin(math.pi * position);
      final texture = 0.38 + 0.62 * math.sin(index * 1.71 + 0.8).abs();
      final phase = motion.value * math.pi * 2 + index * 0.19;
      final breath = active ? 0.78 + 0.22 * math.sin(phase) : 1.0;
      final signal = active
          ? 0.16 + input * 0.84
          : paused
          ? 0.18
          : 0.32;
      final height = (3 + (7 + signal * 22) * envelope * texture * breath)
          .clamp(3.0, size.height - 2)
          .toDouble();
      final x = index * step + (step - barWidth) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, centerY),
            width: barWidth,
            height: height,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.motion != motion ||
      oldDelegate.audioLevel != audioLevel ||
      oldDelegate.active != active ||
      oldDelegate.paused != paused ||
      oldDelegate.color != color;
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator({required this.active, required this.color});
  final bool active;
  final Color color;

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _PulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.active && !_reducedMotion) {
      if (!_animation.isAnimating) _animation.repeat(reverse: true);
    } else {
      _animation.stop();
      _animation.value = 0;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
          width: 16 + (_animation.value * 5),
          height: 16 + (_animation.value * 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.active ? widget.color : Colors.transparent,
            border: Border.all(
              color: widget.active ? widget.color : widget.color,
              width: 2,
            ),
          ),
          child: widget.active
              ? const Icon(
                  Icons.mic_rounded,
                  color: Color(0xFF292326),
                  size: 12,
                )
              : Icon(Icons.mic_none_rounded, color: widget.color, size: 12),
        ),
      ),
    );
  }
}

class _ModelCard extends StatefulWidget {
  const _ModelCard({
    required this.state,
    required this.manager,
    required this.onChoose,
    required this.onDownload,
  });

  final RecorderUiState state;
  final ModelDownloadManager manager;
  final ValueChanged<WhisperSize> onChoose;
  final VoidCallback onDownload;

  @override
  State<_ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<_ModelCard> {
  late Future<InstalledWhisperModel?> _installedModel;
  late bool _lastDownloadComplete;

  @override
  void initState() {
    super.initState();
    _lastDownloadComplete = widget.manager.isComplete;
    _refreshInstalledModel();
    widget.manager.addListener(_onManagerChanged);
  }

  @override
  void didUpdateWidget(covariant _ModelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.manager != widget.manager) {
      oldWidget.manager.removeListener(_onManagerChanged);
      widget.manager.addListener(_onManagerChanged);
      _lastDownloadComplete = widget.manager.isComplete;
      _refreshInstalledModel();
    } else if (oldWidget.state.modelSize != widget.state.modelSize) {
      _refreshInstalledModel();
    }
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChanged);
    super.dispose();
  }

  void _refreshInstalledModel() {
    _installedModel = widget.manager.findInstalled(widget.state.modelSize);
  }

  void _onManagerChanged() {
    final isComplete = widget.manager.isComplete;
    if (isComplete != _lastDownloadComplete) {
      _lastDownloadComplete = isComplete;
      if (isComplete) _refreshInstalledModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final manager = widget.manager;
    final onChoose = widget.onChoose;
    final onDownload = widget.onDownload;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: manager,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.offline_bolt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline transcription',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DropdownButton<WhisperSize>(
                    value: state.modelSize,
                    underline: const SizedBox.shrink(),
                    items: WhisperSize.values
                        .map(
                          (size) => DropdownMenuItem(
                            value: size,
                            child: Text(size.label),
                          ),
                        )
                        .toList(),
                    onChanged: state.isRecording
                        ? null
                        : (size) {
                            if (size != null) onChoose(size);
                          },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FutureBuilder<InstalledWhisperModel?>(
                future: _installedModel,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Text(
                      '${state.modelSize.label} is installed. English transcription runs on this device.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const RecorderCompanion(
                            mood: CompanionMood.thinking,
                            width: 54,
                            height: 60,
                            semanticLabel: 'Voite is thinking while an offline model is not installed',
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No model installed. Recording still works; download an English model to transcribe offline.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (manager.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Image.asset(
                            'assets/images/voite-error-offline.png',
                            width: 180,
                            fit: BoxFit.contain,
                            semanticLabel: 'Voite offline model download error',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Couldn’t download the model. Check your connection and try again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ] else if (manager.isDownloading) ...[
                        const SizedBox(height: 14),
                        LinearProgressIndicator(value: manager.progress),
                        const SizedBox(height: 6),
                        Text(
                          '${(manager.downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB of ${(manager.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB · ${_formatSpeed(manager.bytesPerSecond)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: manager.pause,
                              icon: const Icon(Icons.pause_rounded),
                              label: const Text('Pause'),
                            ),
                            OutlinedButton.icon(
                              onPressed: manager.cancelDownload,
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ] else if (manager.isPaused) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: manager.resume,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Resume download'),
                            ),
                            OutlinedButton.icon(
                              onPressed: manager.cancelDownload,
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: onDownload,
                          icon: const Icon(Icons.download_rounded),
                          label: Text('Download ${state.modelSize.label}'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard({
    required this.transcript,
    required this.isRecording,
    required this.isTranscribing,
    required this.queued,
    required this.retrying,
    required this.onRetry,
    required this.onCompanionTap,
  });

  final List<TranscriptSegment> transcript;
  final bool isRecording;
  final bool isTranscribing;
  final bool queued;
  final bool retrying;
  final VoidCallback onRetry;
  final VoidCallback onCompanionTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isTranscribing ? 'Writing it down…' : 'Transcript',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RecorderCompanion(
                      mood: CompanionMood.thinking,
                      width: 44,
                      height: 56,
                      semanticLabel: transcript.isNotEmpty
                          ? 'Voite is thinking about recognized phrases. Tap for a transcript hint.'
                          : 'Voite is ready to help with the transcript. Tap for a hint.',
                      onTap: onCompanionTap,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isTranscribing)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'On your phone — nothing leaves it.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              )
            else if (transcript.isEmpty)
              Text(
                isRecording
                    ? queued
                          ? 'Your audio is recording. Transcription will be queued until a model is installed.'
                          : 'Speak naturally. Text appears one phrase at a time after speech is detected.'
                    : 'Transcript segments will appear here while you record.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              )
            else
              ...transcript.map(
                (segment) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDuration(segment.startMillis),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(segment.text)),
                    ],
                  ),
                ),
              ),
            if (transcript.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Times mark speech segments, not individual words.',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            if (queued && !isRecording) ...[
              const SizedBox(height: 12),
              Text(
                'Saved audio is waiting for a model before transcription can start.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: retrying ? null : onRetry,
                icon: retrying
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(retrying ? 'Transcribing…' : 'Retry transcription'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.text,
    this.isError = false,
  });
  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isError ? colors.error : colors.tertiary;
    return Card(
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(int millis) {
  final totalSeconds = millis ~/ 1000;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _formatSpeed(double bytesPerSecond) {
  if (bytesPerSecond <= 0) return 'Preparing';
  return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
}

class _ScaleButton extends StatefulWidget {
  const _ScaleButton({required this.child, required this.isPressed});

  final Widget child;
  final bool isPressed;

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
