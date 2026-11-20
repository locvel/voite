import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/entrance_animation.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../domain/models/recording_details.dart';
import '../../domain/repositories/recordings_repository.dart';
import '../recording/recorder_controller.dart';

enum _LibraryFilter { all, favorites, needsTranscript, transcriptReady }

enum _LibrarySort { newest, oldest, longest }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _showTrash = false;
  String? _labelFilter;
  _LibraryFilter _filter = _LibraryFilter.all;
  _LibrarySort _sort = _LibrarySort.newest;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(recordingsRepositoryProvider);
    final customLabels = ref.watch(
      recorderControllerProvider.select((state) => state.customLabels),
    );
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Your library'),
        actions: [
          IconButton(
            tooltip: _showTrash ? 'Show recordings' : 'Recently deleted',
            onPressed: () => setState(() {
              _showTrash = !_showTrash;
              _filter = _LibraryFilter.all;
              _labelFilter = null;
            }),
            icon: Icon(
              _showTrash
                  ? Icons.library_music_rounded
                  : Icons.delete_outline_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await HapticFeedback.mediumImpact();
            ref.invalidate(recordingsRepositoryProvider);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
            children: [
              if (_showTrash)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently deleted',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.55,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Items are removed after 30 days. Restore them or delete them sooner.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your recordings',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Search and find a thought when you need it.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              TextField(
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search recordings or transcripts',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (!_showTrash) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == _LibraryFilter.all,
                      onSelected: (_) =>
                          setState(() => _filter = _LibraryFilter.all),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.star_rounded, size: 17),
                      label: const Text('Favorites'),
                      selected: _filter == _LibraryFilter.favorites,
                      onSelected: (_) =>
                          setState(() => _filter = _LibraryFilter.favorites),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.subject_rounded, size: 17),
                      label: const Text('Needs transcript'),
                      selected: _filter == _LibraryFilter.needsTranscript,
                      onSelected: (_) => setState(
                        () => _filter = _LibraryFilter.needsTranscript,
                      ),
                    ),
                    ChoiceChip(
                      avatar: const Icon(Icons.task_alt_rounded, size: 17),
                      label: const Text('Transcript ready'),
                      selected: _filter == _LibraryFilter.transcriptReady,
                      onSelected: (_) => setState(
                        () => _filter = _LibraryFilter.transcriptReady,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final label in [
                        'All labels',
                        'Voice note',
                        'Lecture',
                        'Meeting',
                        'Idea',
                        ...customLabels,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 7),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: label == 'All labels'
                                ? _labelFilter == null
                                : _labelFilter == label,
                            onSelected: (_) => setState(
                              () => _labelFilter = label == 'All labels'
                                  ? null
                                  : label,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              repository.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _MessageState(
                  icon: Icons.storage_outlined,
                  title: 'Library unavailable',
                  description:
                      'Your recordings could not be loaded. Please try again.',
                  action: TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(recordingsRepositoryProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ),
                data: (repo) => StreamBuilder<List<RecordingSummary>>(
                  stream: repo.watchLibrary(
                    query: _query,
                    showTrash: _showTrash,
                    favoritesOnly: _filter == _LibraryFilter.favorites,
                    label: _labelFilter,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _MessageState(
                        icon: Icons.error_outline_rounded,
                        title: 'Could not load recordings',
                        description:
                            'Your local library is safe. Please try again.',
                        action: TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try again'),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final items = [...snapshot.data!]
                      ..removeWhere((item) {
                        if (_filter == _LibraryFilter.needsTranscript) {
                          return item.transcriptionStatus == 'complete';
                        }
                        if (_filter == _LibraryFilter.transcriptReady) {
                          return item.transcriptionStatus != 'complete';
                        }
                        return false;
                      })
                      ..sort((a, b) {
                        switch (_sort) {
                          case _LibrarySort.newest:
                            return b.createdAtMillis.compareTo(
                              a.createdAtMillis,
                            );
                          case _LibrarySort.oldest:
                            return a.createdAtMillis.compareTo(
                              b.createdAtMillis,
                            );
                          case _LibrarySort.longest:
                            return b.durationMillis.compareTo(a.durationMillis);
                        }
                      });
                    if (items.isEmpty &&
                        snapshot.data!.isEmpty &&
                        !_showTrash &&
                        _query.trim().isEmpty &&
                        _filter == _LibraryFilter.all &&
                        _labelFilter == null) {
                      return _EmptyLibraryState(
                        onRecord: () => context.go('/record'),
                      );
                    }
                    if (items.isEmpty) {
                      return _MessageState(
                        icon: _query.isNotEmpty
                            ? Icons.search_off_rounded
                            : _showTrash
                            ? Icons.delete_outline_rounded
                            : _filter == _LibraryFilter.needsTranscript
                            ? Icons.subject_rounded
                            : _filter == _LibraryFilter.transcriptReady
                            ? Icons.task_alt_rounded
                            : Icons.graphic_eq_rounded,
                        title: _query.isNotEmpty
                            ? 'No matches yet'
                            : _showTrash
                            ? 'Nothing in Recently Deleted'
                            : _filter == _LibraryFilter.favorites
                            ? 'No favorites yet'
                            : _filter == _LibraryFilter.needsTranscript
                            ? 'Nothing waiting for a transcript'
                            : _filter == _LibraryFilter.transcriptReady
                            ? 'No transcripts ready yet'
                            : _labelFilter != null
                            ? 'No “$_labelFilter” recordings yet'
                            : 'No recordings yet',
                        description: _query.isNotEmpty
                            ? 'Try another title or phrase from a transcript.'
                            : _showTrash
                            ? 'Deleted recordings stay here for up to 30 days.'
                            : _filter == _LibraryFilter.favorites
                            ? 'Mark important recordings as favorites to keep them close.'
                            : _filter == _LibraryFilter.needsTranscript
                            ? 'Recordings without a completed transcript will appear here.'
                            : _filter == _LibraryFilter.transcriptReady
                            ? 'Completed on-device transcripts will appear here.'
                            : _labelFilter != null
                            ? 'Recordings with this label will appear here.'
                            : 'Your saved recordings will appear here.',
                        action:
                            !_showTrash &&
                                (_query.isNotEmpty ||
                                    _filter != _LibraryFilter.all ||
                                    _labelFilter != null)
                            ? OutlinedButton.icon(
                                onPressed: () {
                                  _search.clear();
                                  setState(() {
                                    _query = '';
                                    _filter = _LibraryFilter.all;
                                    _labelFilter = null;
                                  });
                                },
                                icon: const Icon(Icons.filter_alt_off_rounded),
                                label: const Text('Clear filters'),
                              )
                            : !_showTrash && _query.isEmpty
                            ? FilledButton.icon(
                                onPressed: () => context.go('/record'),
                                icon: const Icon(Icons.mic_rounded),
                                label: const Text('Start a recording'),
                              )
                            : null,
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${items.length} ${items.length == 1 ? 'recording' : 'recordings'}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            if (_showTrash)
                              TextButton.icon(
                                onPressed: () => _emptyTrash(context, repo),
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                  size: 18,
                                ),
                                label: const Text('Empty'),
                              )
                            else
                              PopupMenuButton<_LibrarySort>(
                                tooltip: 'Sort recordings',
                                initialValue: _sort,
                                onSelected: (sort) =>
                                    setState(() => _sort = sort),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: _LibrarySort.newest,
                                    child: Text('Newest first'),
                                  ),
                                  PopupMenuItem(
                                    value: _LibrarySort.oldest,
                                    child: Text('Oldest first'),
                                  ),
                                  PopupMenuItem(
                                    value: _LibrarySort.longest,
                                    child: Text('Longest first'),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.sort_rounded, size: 18),
                                      const SizedBox(width: 4),
                                      Text(switch (_sort) {
                                        _LibrarySort.newest => 'Newest',
                                        _LibrarySort.oldest => 'Oldest',
                                        _LibrarySort.longest => 'Longest',
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columnCount = context.gridColumnCount;
                            if (columnCount == 1) {
                              // Compact: standard list
                              return Column(
                                children: items.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return EntranceAnimation(
                                    key: ValueKey(item.id),
                                    delay: Duration(
                                      milliseconds: index < 5
                                          ? index * 55
                                          : 220,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: _buildRecordingTile(
                                        context,
                                        repo,
                                        item,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              // Medium/Expanded: responsive grid
                              final spacing = context.responsivePadding / 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columnCount,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: 3.2,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return EntranceAnimation(
                                    key: ValueKey(item.id),
                                    delay: Duration(
                                      milliseconds: index < 5
                                          ? index * 55
                                          : 220,
                                    ),
                                    child: _buildRecordingTile(
                                      context,
                                      repo,
                                      item,
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingTile(
    BuildContext context,
    RecordingsRepository repo,
    RecordingSummary item,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        _showTrash
            ? _RecordingTile(
                item: item,
                showTrash: _showTrash,
                onOpen: () {
                  unawaited(HapticFeedback.selectionClick());
                  context.push(
                    '/recording/${item.id}',
                    extra: item.searchMatchStartMillis,
                  );
                },
                onRename: () => _rename(context, repo, item),
                onChangeLabel: () => _changeLabel(context, repo, item),
                onTrash: () => _moveToTrash(context, repo, item),
                onRestore: () => _restore(context, repo, item),
                onDelete: () => _deletePermanently(context, repo, item),
                onFavorite: () {
                  unawaited(HapticFeedback.lightImpact());
                  unawaited(repo.setFavorite(item.id, !item.isFavorite));
                },
              )
            : Dismissible(
                key: ValueKey('dismiss-${item.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  await HapticFeedback.mediumImpact();
                  if (!context.mounted) return false;
                  return await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Move to Recently Deleted?'),
                      content: Text(
                        '"${item.title}" will be moved to Recently Deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Move to trash'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  unawaited(_moveToTrash(context, repo, item));
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.error,
                    size: 28,
                  ),
                ),
                child: _RecordingTile(
                  item: item,
                  showTrash: _showTrash,
                  onOpen: () {
                    unawaited(HapticFeedback.selectionClick());
                    context.push(
                      '/recording/${item.id}',
                      extra: item.searchMatchStartMillis,
                    );
                  },
                  onRename: () => _rename(context, repo, item),
                  onChangeLabel: () => _changeLabel(context, repo, item),
                  onTrash: () => _moveToTrash(context, repo, item),
                  onRestore: () => _restore(context, repo, item),
                  onDelete: () => _deletePermanently(context, repo, item),
                  onFavorite: () {
                    unawaited(HapticFeedback.lightImpact());
                    unawaited(repo.setFavorite(item.id, !item.isFavorite));
                  },
                ),
              ),
        if (!_showTrash &&
            (item.transcriptSegmentCount > 0 ||
                item.transcriptionStatus == 'queued'))
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: ListTile(
              dense: true,
              leading: Image.asset(
                'assets/images/voite-icon-diary.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              title: const Text(
                'Diary',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/diary', extra: item.id),
            ),
          ),
      ],
    );
  }

  Future<void> _rename(
    BuildContext context,
    RecordingsRepository repository,
    RecordingSummary item,
  ) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _RenameRecordingDialog(initialTitle: item.title),
    );
    if (value == null || value.trim().isEmpty) return;
    try {
      await repository.renameRecording(item.id, value);
    } catch (_) {
      if (context.mounted) {
        _message(context, 'Could not rename this recording. Please try again.');
      }
    }
  }

  Future<void> _moveToTrash(
    BuildContext context,
    RecordingsRepository repository,
    RecordingSummary item,
  ) async {
    await repository.moveToTrash(item.id);
    if (context.mounted) _message(context, 'Moved to Recently Deleted');
  }

  Future<void> _changeLabel(
    BuildContext context,
    RecordingsRepository repository,
    RecordingSummary item,
  ) async {
    final labels = <String>[
      'Voice note',
      'Lecture',
      'Meeting',
      'Idea',
      ...ref.read(recorderControllerProvider).customLabels,
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Text(
                'Choose a label',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            for (final label in labels)
              ListTile(
                leading: Icon(
                  item.label == label
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                ),
                title: Text(label),
                onTap: () => Navigator.of(sheetContext).pop(label),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == item.label) return;
    try {
      await repository.setRecordingLabel(item.id, selected);
      if (context.mounted) _message(context, 'Label updated to $selected');
    } catch (_) {
      if (context.mounted) {
        _message(context, 'Could not update the label. Please try again.');
      }
    }
  }

  Future<void> _restore(
    BuildContext context,
    RecordingsRepository repository,
    RecordingSummary item,
  ) async {
    await repository.restoreRecording(item.id);
    if (context.mounted) _message(context, 'Recording restored');
  }

  Future<void> _deletePermanently(
    BuildContext context,
    RecordingsRepository repository,
    RecordingSummary item,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: const Text('Delete permanently?'),
        content: const Text(
          'The audio and transcript will be removed from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    await repository.deleteRecording(item.id);
  }

  Future<void> _emptyTrash(
    BuildContext context,
    RecordingsRepository repository,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Recently Deleted?'),
        content: const Text(
          'All audio and transcripts here will be permanently removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Empty trash'),
          ),
        ],
      ),
    );
    if (accepted == true) await repository.emptyTrash();
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({
    required this.item,
    required this.showTrash,
    required this.onOpen,
    required this.onRename,
    required this.onChangeLabel,
    required this.onTrash,
    required this.onRestore,
    required this.onDelete,
    required this.onFavorite,
  });

  final RecordingSummary item;
  final bool showTrash;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onChangeLabel;
  final VoidCallback onTrash;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = item.createdAt;
    final dateLabel = '${_month(date.month)} ${date.day} · ${_clock(date)}';
    final status = switch (item.transcriptionStatus) {
      'complete' => (
        'Transcript ready',
        Icons.check_circle_outline_rounded,
        colors.primary,
      ),
      'queued' => (
        'Waiting for model',
        Icons.hourglass_bottom_rounded,
        colors.tertiary,
      ),
      'failed' => ('Transcription failed', Icons.error_rounded, colors.error),
      'audio_only' => ('Audio only', Icons.mic_none_rounded, colors.secondary),
      'recording' => (
        'Recording interrupted',
        Icons.warning_amber_rounded,
        colors.error,
      ),
      _ => ('Unknown status', Icons.question_mark_rounded, colors.outline),
    };

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 8, 15),
          child: Row(
            children: [
              Image.asset(
                _categoryIcon(item.label),
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                semanticLabel: '${item.label} recording category',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateLabel  ·  ${_duration(item.durationMillis)}',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    if (item.transcriptPreview.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.transcriptPreview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(status.$2, size: 15, color: status.$3),
                        const SizedBox(width: 5),
                        Text(
                          status.$1,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: status.$3,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Recording actions',
                onSelected: (value) => switch (value) {
                  'rename' => onRename(),
                  'label' => onChangeLabel(),
                  'trash' => onTrash(),
                  'restore' => onRestore(),
                  'delete' => onDelete(),
                  'favorite' => onFavorite(),
                  'unfavorite' => onFavorite(),
                  _ => null,
                },
                itemBuilder: (context) => showTrash
                    ? const [
                        PopupMenuItem(value: 'restore', child: Text('Restore')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete permanently'),
                        ),
                      ]
                    : [
                        PopupMenuItem(
                          value: item.isFavorite ? 'unfavorite' : 'favorite',
                          child: Text(
                            item.isFavorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                        const PopupMenuItem(
                          value: 'label',
                          child: Text('Change label'),
                        ),
                        const PopupMenuItem(
                          value: 'trash',
                          child: Text('Move to Recently Deleted'),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 30),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: colors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 22), action!],
        ],
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
    child: Column(
      children: [
        Image.asset(
          'assets/images/voite-cat-sleeping.png',
          width: 240,
          fit: BoxFit.contain,
          semanticLabel:
              'Voite the cat is sleeping while your library is empty',
        ),
        const SizedBox(height: 10),
        Text(
          'No recordings yet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        Text(
          'Your saved voice notes will live here.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onRecord,
          icon: const Icon(Icons.mic_none_rounded),
          label: const Text('Record your first one'),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final companion in [
              ('voite-fox-sleeping.png', 'Fox resting'),
              ('voite-bird-sleeping.png', 'Bird resting'),
              ('voite-frog-sleeping.png', 'Frog resting'),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Image.asset(
                  'assets/images/${companion.$1}',
                  width: 34,
                  height: 52,
                  fit: BoxFit.contain,
                  semanticLabel: companion.$2,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

String _categoryIcon(String label) {
  final normalized = label.toLowerCase();
  if (normalized.contains('meeting')) {
    return 'assets/images/voite-icon-meeting.png';
  }
  if (normalized.contains('idea')) {
    return 'assets/images/voite-icon-idea.png';
  }
  if (normalized.contains('journal')) {
    return 'assets/images/voite-icon-journal.png';
  }
  return 'assets/images/voite-icon-voicenote.png';
}

String _month(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
}

String _duration(int milliseconds) {
  final total = milliseconds ~/ 1000;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;

  // For durations >= 1 hour, show "Xh Ym" format
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }

  // For durations < 1 hour, show "M:SS" format
  if (minutes > 0) {
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // For durations < 1 minute, show "Xs" format
  return '${seconds}s';
}

// Lifecycle-safe rename dialog with proper controller disposal
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
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Title'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
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
