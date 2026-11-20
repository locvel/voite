import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/asset_video.dart';
import '../recording/recorder_controller.dart';

const _prompts = [
  'What did you notice today?',
  'What made you smile today?',
  'What is one thing you want to remember?',
  'What has been on your mind lately?',
  'What sounds made today feel like today?',
  'What would you tell a friend who asked how you are?',
  'What is something small you are grateful for?',
];

class DailyPromptScreen extends ConsumerStatefulWidget {
  const DailyPromptScreen({super.key});
  @override
  ConsumerState<DailyPromptScreen> createState() => _DailyPromptScreenState();
}

class _DailyPromptScreenState extends ConsumerState<DailyPromptScreen> {
  int _activeAnimationIndex = 0;

  String get _todayPrompt {
    final now = DateTime.now();
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(now.year)).inDays;
    return _prompts[day % _prompts.length];
  }

  void _animationFinished(int index) {
    if (!mounted || index != _activeAnimationIndex) return;
    setState(() => _activeAnimationIndex++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daily prompt')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
      children: [
        Center(
          child: Image.asset(
            'assets/images/voite-cat-floating.png',
            width: 240,
            height: 210,
            fit: BoxFit.contain,
            semanticLabel: 'Voite the cat floating above sound waves',
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/voite-icon-idea.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TODAY’S PROMPT',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _todayPrompt,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A small detail, a passing idea, or something you want to remember.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(recorderControllerProvider.notifier)
                        ..setPrompt(_todayPrompt)
                        ..chooseRecordingLabel('Idea');
                      context.go('/record');
                    },
                    icon: const Icon(Icons.mic_none_rounded),
                    label: const Text('Record an answer'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _companionBadge(
                  _companionAnimation(
                    index: 0,
                    video: 'assets/videos/voite-video-bird-flying.mp4',
                    fallback: 'assets/images/voite-bird-flying.png',
                    still: 'assets/images/voite-bird-waving.png',
                    label: 'Bird flies beside today’s prompt',
                    stillLabel: 'Bird waves hello',
                  ),
                ),
                _companionBadge(
                  _companionAnimation(
                    index: 1,
                    video: 'assets/videos/voite-video-frog-waving.mp4',
                    fallback: 'assets/images/voite-frog-waving.png',
                    still: 'assets/images/voite-frog-waving.png',
                    label: 'Frog waves beside today’s prompt',
                    stillLabel: 'Frog waves hello',
                  ),
                ),
                _companionBadge(
                  _companionAnimation(
                    index: 2,
                    video: 'assets/videos/voite-video-fox-celebrating.mp4',
                    fallback: 'assets/images/voite-fox-waving.png',
                    still: 'assets/images/voite-fox-waving.png',
                    label: 'Fox celebrates beside today’s prompt',
                    stillLabel: 'Fox waves hello',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _activeAnimationIndex = 0);
            },
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Replay the crew'),
          ),
        ),
      ],
    ),
  );

  Widget _companionBadge(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF17120D),
        border: Border.all(
          color: AppTheme.orange.withValues(alpha: isDark ? 0.28 : 0.38),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }

  Widget _still(String asset, String semanticLabel) => Image.asset(
    asset,
    width: 56,
    height: 56,
    fit: BoxFit.contain,
    semanticLabel: semanticLabel,
  );

  Widget _companionAnimation({
    required int index,
    required String video,
    required String fallback,
    required String still,
    required String label,
    required String stillLabel,
  }) {
    if (_activeAnimationIndex != index) return _still(still, stillLabel);
    return AssetVideo(
      key: ValueKey(video),
      asset: video,
      fallbackAsset: fallback,
      semanticLabel: label,
      width: 56,
      height: 56,
      onCompleted: () => _animationFinished(index),
    );
  }
}
