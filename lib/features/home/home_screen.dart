import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/recording_details.dart';
import 'home_data.dart';

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int _calculateStreak(List<RecordingSummary> items, DateTime today) {
  final dates = items
      .where((r) => !r.isTrashed)
      .map(
        (r) => DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day),
      )
      .toSet();
  var date = DateTime(today.year, today.month, today.day);
  if (!dates.contains(date)) date = date.subtract(const Duration(days: 1));
  var count = 0;
  while (dates.contains(date)) {
    count++;
    date = date.subtract(const Duration(days: 1));
  }
  return count;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordings = ref.watch(homeRecordingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voite'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: Image.asset(
            'assets/logo/voite-logo-glassy-v.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: recordings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your library could not be opened.'),
              TextButton(
                onPressed: () => ref.invalidate(homeRecordingsProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (items) => _HomeContent(items: items),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.items});
  final List<RecordingSummary> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final goalMinutes = ref.watch(dailyGoalMinutesProvider).asData?.value ?? 10;
    final today = items
        .where((r) => !r.isTrashed && _isSameDay(r.createdAt, now))
        .toList();
    final recordedMinutes = today.fold<double>(
      0,
      (sum, r) => sum + r.durationMillis / 60000,
    );
    final minutes = recordedMinutes;
    final fill = (recordedMinutes / goalMinutes).clamp(0.0, 1.0).toDouble();
    // Count only completed diary entries from today (not recording/audio_only)
    final recordedEntries = today
        .where((r) => r.transcriptionStatus == 'complete')
        .length;
    // One diary entry a day completes the goal
    final done = recordedEntries > 0;
    final sorted = [...items.where((r) => !r.isTrashed)]
      ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
    final streak = _calculateStreak(items, now);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
      children: [
        Text(
          'TODAY',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkAccentText
                : AppTheme.lightAccentText,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your voice, kept close.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        _GoalCard(minutes: minutes, fill: fill, goalMinutes: goalMinutes),
        const SizedBox(height: 14),
        const _QuickActions(),
        const SizedBox(height: 16),
        if (streak >= 7 && !done) ...[
          const _StreakCard(),
          const SizedBox(height: 12),
        ],
        _CrewCard(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent recordings',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/library'),
              child: const Text('See all'),
            ),
          ],
        ),
        if (sorted.isEmpty)
          Card(
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
                      "Nothing yet today — tap Record when you're ready.",
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...sorted
              .take(3)
              .map((recording) => _RecentRow(recording: recording)),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({
    required this.minutes,
    required this.fill,
    required this.goalMinutes,
  });
  final double minutes;
  final double fill;
  final int goalMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? AppTheme.darkAccentText
        : AppTheme.lightAccentText;
    final minutesLabel = minutes <= 0
        ? '0'
        : minutes < 1
        ? '<1'
        : minutes < 10
        ? minutes.toStringAsFixed(1)
        : minutes.round().toString();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  minutesLabel,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontFamily: 'Sora',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(
                    'min today',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(fill * 100).round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'The cat fills as you record — full at $goalMinutes minutes.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _CatFill(fill: fill),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/diary'),
                child: const Text('Open diary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatFill extends StatefulWidget {
  const _CatFill({required this.fill});
  final double fill;

  @override
  State<_CatFill> createState() => _CatFillState();
}

class _CatFillState extends State<_CatFill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentFill = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.fill,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_CatFill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fill != widget.fill) {
      _animation = Tween<double>(
        begin: _currentFill,
        end: widget.fill,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        _currentFill = _animation.value.clamp(0.0, 1.0);
        return Semantics(
          label: 'Daily goal ${(_currentFill * 100).round()} percent complete',
          child: Container(
            width: 62,
            height: 88,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                return Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (_currentFill > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: height * _currentFill,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.bottomCenter,
                            minHeight: height,
                            maxHeight: height,
                            child: Transform.scale(
                              scale: 1.24,
                              child: Image.asset(
                                'assets/images/voite-cat-listening.png',
                                height: height,
                                fit: BoxFit.contain,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    children: [
      Expanded(
        child: _Action(
          label: 'Record',
          icon: Icons.mic_rounded,
          onTap: () => context.go('/record'),
        ),
      ),
      Expanded(
        child: _Action(
          label: 'Library',
          icon: Icons.library_books_rounded,
          onTap: () => context.go('/library'),
        ),
      ),
      Expanded(
        child: _Action(
          label: 'Prompt',
          icon: Icons.lightbulb_outline_rounded,
          onTap: () => context.go('/daily-prompt'),
        ),
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _CrewCard extends ConsumerWidget {
  const _CrewCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: InkWell(
      onTap: () => context.push('/crew'),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(
              Icons.group,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet the crew',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text('Friends who help you feel at home'),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.recording});
  final RecordingSummary recording;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Image.asset(
        'assets/images/voite-icon-voicenote.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
      title: Text(
        recording.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${recording.createdAt.day}/${recording.createdAt.month} · '
        '${_homeDurationLabel(recording.durationMillis)}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/recording/${recording.id}'),
    ),
  );
}

String _homeDurationLabel(int millis) {
  final seconds = (millis / 1000).round();
  if (seconds < 60) return '$seconds sec';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  if (minutes < 60) {
    return '$minutes min ${remainder.toString().padLeft(2, '0')} sec';
  }
  final hours = minutes ~/ 60;
  return '$hours hr ${(minutes % 60).toString().padLeft(2, '0')} min';
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A week of thoughts, kept close.',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'A small moment, saved each day.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
