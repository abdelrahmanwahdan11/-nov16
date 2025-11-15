import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton_loader.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.state});

  static const route = '/notifications';

  final AppState state;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ScrollController _controller;

  NotificationsNotifier get _notifier => widget.state.notificationsNotifier;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notifier.initialized) {
        _notifier.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _notifier.loadMore();
    }
  }

  Future<void> _handleRefresh() => _notifier.refresh();

  void _openDetails(AppNotification notification) {
    _notifier.markAsRead(notification.id);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate(notification.typeKey),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _accentForType(notification.typeKey, theme),
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.translate(notification.titleKey),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (notification.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(notification.imageUrl!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                loc.translate(notification.bodyKey),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                loc.translate(notification.timeKey),
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.translate('close')),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('notifications')),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _notifier.unreadCount,
            builder: (context, unread, _) {
              if (unread == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: _notifier.markAllAsRead,
                child: Text(loc.translate('mark_all_read')),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AnimatedBuilder(
        animation: _notifier,
        builder: (context, _) {
          final items = _notifier.notifications.value;
          final isLoading = _notifier.isLoading.value;
          final loadingMore = _notifier.loadingMore.value;
          final hasMore = _notifier.hasMore;

          if (isLoading && items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: const [
                SkeletonLoader(height: 120, borderRadius: 28),
                SizedBox(height: 18),
                SkeletonLoader(height: 120, borderRadius: 28),
                SizedBox(height: 18),
                SkeletonLoader(height: 120, borderRadius: 28),
              ],
            );
          }

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
                children: [
                  EmptyState(
                    title: loc.translate('notifications_empty_title'),
                    subtitle: loc.translate('notifications_empty_subtitle'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  if (loadingMore) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(color: theme.colorScheme.primary),
                      ),
                    );
                  }
                  if (!hasMore) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        loc.translate('no_more_results'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }
                  return const SizedBox(height: 24);
                }

                final notification = items[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 16),
                  child: _NotificationTile(
                    notification: notification,
                    loc: loc,
                    onOpen: () => _openDetails(notification),
                    onMarkRead: () {
                      final wasUnread = !notification.isRead;
                      _notifier.markAsRead(notification.id);
                      if (wasUnread) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.translate('notification_marked_read')),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.loc,
    required this.onOpen,
    required this.onMarkRead,
  });

  final AppNotification notification;
  final AppLocalizations loc;
  final VoidCallback onOpen;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    final accent = _accentForType(notification.typeKey, theme);
    final background = theme.brightness == Brightness.dark
        ? (isUnread ? theme.colorScheme.primary.withOpacity(0.18) : theme.colorScheme.surfaceVariant.withOpacity(0.24))
        : (isUnread ? theme.colorScheme.primary.withOpacity(0.08) : theme.colorScheme.surfaceVariant.withOpacity(0.16));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: background,
        border: Border.all(color: accent.withOpacity(0.18)),
        boxShadow: [
          if (isUnread)
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NotificationMedia(notification: notification, accent: accent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate(notification.typeKey).toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate(notification.titleKey),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.translate(notification.bodyKey),
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(IconlyLight.time_circle, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      loc.translate(notification.timeKey),
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isUnread ? 1 : 0.6,
                      child: TextButton(
                        onPressed: onMarkRead,
                        child: Text(loc.translate('notification_mark_read')),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(IconlyLight.arrow_right_2),
                      color: theme.colorScheme.primary,
                      onPressed: onOpen,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationMedia extends StatelessWidget {
  const _NotificationMedia({required this.notification, required this.accent});

  final AppNotification notification;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    if (notification.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          notification.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: accent.withOpacity(0.18),
      ),
      child: Icon(IconlyBold.bag, color: accent),
    );
  }
}

Color _accentForType(String typeKey, ThemeData theme) {
  switch (typeKey) {
    case 'notification_type_event':
      return Colors.tealAccent.shade400;
    case 'notification_type_tip':
      return Colors.amber.shade600;
    case 'notification_type_offer':
      return Colors.pinkAccent;
    case 'notification_type_order':
    default:
      return theme.colorScheme.primary;
  }
}
