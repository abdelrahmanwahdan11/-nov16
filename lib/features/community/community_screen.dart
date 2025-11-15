import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_loader.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, required this.state});

  static const route = '/community';

  final AppState state;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final ScrollController _controller;

  CommunityNotifier get _notifier => widget.state.communityNotifier;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          _notifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('community')),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _notifier.isLoading,
            builder: (context, loading, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: loc.translate('community_refresh_cta'),
                onPressed: loading ? null : () => _notifier.refresh(),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<CommunityEvent>>(
          valueListenable: _notifier.events,
          builder: (context, events, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _notifier.isLoading,
              builder: (context, loading, __) {
                return CustomScrollView(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: context.pagePadding,
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: context.screenWidth >= 1200 ? 1080 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: loading && events.isNotEmpty ? 1 : 0,
                                  child: const LinearProgressIndicator(),
                                ),
                                if (events.isNotEmpty || loading)
                                  const SizedBox(height: 16),
                                Text(
                                  loc.translate('community_intro'),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 24),
                                _EventsSection(
                                  events: events,
                                  loading: loading,
                                ),
                                const SizedBox(height: 32),
                                SectionHeader(
                                  title: loc.translate('story_highlights'),
                                  actionLabel: loc.translate('view_all'),
                                  onActionPressed: () => _showStoriesSheet(context),
                                ),
                                const SizedBox(height: 16),
                                ValueListenableBuilder<List<ChefStory>>(
                                  valueListenable: _notifier.stories,
                                  builder: (context, stories, __) {
                                    if (loading && stories.isEmpty) {
                                      return const _StoriesSkeleton();
                                    }
                                    if (stories.isEmpty) {
                                      return Text(
                                        loc.translate('community_empty'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context).hintColor,
                                            ),
                                      );
                                    }
                                    return _StoriesList(stories: stories);
                                  },
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _notifier.loadingMore,
                        builder: (context, loadingMore, __) {
                          if (!loadingMore) {
                            return const SizedBox.shrink();
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _notifier,
                        builder: (context, _) {
                          if (!_notifier.hasMore && events.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  loc.translate('no_more_results'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showStoriesSheet(BuildContext context) {
    final stories = _notifier.stories.value;
    final loc = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        if (stories.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: EmptyState(
              title: loc.translate('community_empty'),
              subtitle: loc.translate('community_refresh_cta'),
            ),
          );
        }
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Text(
                    loc.translate('story_highlights'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return _StoryTile(story: story);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: stories.length,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection({
    required this.events,
    required this.loading,
  });

  final List<CommunityEvent> events;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loading && events.isEmpty) {
      return const _EventsSkeleton();
    }
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: EmptyState(
          title: loc.translate('community_empty'),
          subtitle: loc.translate('community_refresh_cta'),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth > 760;
        final spacing = 20.0;
        final itemWidth = isTwoColumn
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: 20,
          children: [
            for (final event in events)
              SizedBox(
                width: itemWidth,
                child: _CommunityEventCard(event: event),
              ),
          ],
        );
      },
    );
  }
}

class _CommunityEventCard extends StatelessWidget {
  const _CommunityEventCard({required this.event});

  final CommunityEvent event;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(event.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (event.isLive)
                      Chip(
                        label: Text(loc.translate('live_now')),
                        avatar: const Icon(Icons.podcasts, size: 16),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                      ),
                    Chip(
                      label: Text(event.isVirtual
                          ? loc.translate('virtual_event')
                          : loc.translate('in_person_event')),
                    ),
                    for (final key in event.highlightKeys)
                      Chip(label: Text(loc.translate(key))),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  loc.translate(event.titleKey),
                  style: theme.textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate(event.descriptionKey),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _EventMetaRow(
                  icon: IconlyLight.calendar,
                  label: loc.translate(event.scheduleKey),
                ),
                const SizedBox(height: 8),
                _EventMetaRow(
                  icon: IconlyLight.location,
                  label: loc.translate(event.locationKey),
                ),
                const SizedBox(height: 8),
                _EventMetaRow(
                  icon: IconlyLight.profile,
                  label: '${loc.translate('hosted_by')} ${loc.translate(event.hostKey)}',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(IconlyBold.ticket),
                        label: Text(loc.translate('reserve_spot')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc
                          .translate('spots_remaining')
                          .replaceFirst('%d', event.spotsRemaining.toString()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _EventMetaRow extends StatelessWidget {
  const _EventMetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StoriesList extends StatelessWidget {
  const _StoriesList({required this.stories});

  final List<ChefStory> stories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final story = stories[index];
          return _StoryCard(story: story);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: stories.length,
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final ChefStory story;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(story.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(loc.translate(story.tagKey)),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate(story.titleKey),
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${story.durationMinutes} ${loc.translate('community_minutes_short')} • ${loc.translate('community_watch_now')}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story});

  final ChefStory story;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            story.imageUrl,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(loc.translate(story.tagKey)),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${story.durationMinutes} ${loc.translate('community_minutes_short')}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate(story.titleKey),
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate(story.descriptionKey),
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth > 760;
        final spacing = 20.0;
        final itemWidth = isTwoColumn
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: spacing,
          runSpacing: 20,
          children: List.generate(
            isTwoColumn ? 2 : 1,
            (index) => SkeletonLoader(
              width: itemWidth,
              height: 340,
              borderRadius: 28,
            ),
          ),
        );
      },
    );
  }
}

class _StoriesSkeleton extends StatelessWidget {
  const _StoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => const SkeletonLoader(width: 220, height: 190, borderRadius: 24),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: 3,
      ),
    );
  }
}
