import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../reservations/reservation_sheet.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key, required this.state});

  static const route = '/reservations';
  final AppState state;

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  Future<void> _refresh() async {
    await widget.state.reservationsNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notifier = widget.state.reservationsNotifier;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('reservations')),
          bottom: TabBar(
            tabs: [
              Tab(text: loc.translate('reservation_upcoming')),
              Tab(text: loc.translate('reservation_history')),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showReservationSheet(context: context, state: widget.state),
          icon: const Icon(IconlyLight.calendar),
          label: Text(loc.translate('book_table')),
        ),
        body: TabBarView(
          children: [
            _ReservationList(
              state: widget.state,
              notifier: notifier,
              listenable: notifier.upcoming,
              emptyTitle: loc.translate('reservation_empty_title'),
              emptySubtitle: loc.translate('reservation_empty_subtitle'),
              onRefresh: _refresh,
              showActions: true,
            ),
            _ReservationList(
              state: widget.state,
              notifier: notifier,
              listenable: notifier.history,
              emptyTitle: loc.translate('reservation_history_empty_title'),
              emptySubtitle: loc.translate('reservation_history_empty_subtitle'),
              onRefresh: _refresh,
              showActions: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList({
    required this.state,
    required this.notifier,
    required this.listenable,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.showActions,
  });

  final AppState state;
  final ReservationsNotifier notifier;
  final ValueNotifier<List<Reservation>> listenable;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ValueListenableBuilder<List<Reservation>>(
        valueListenable: listenable,
        builder: (context, reservations, _) {
          if (reservations.isEmpty) {
            if (notifier.isLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 4,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SkeletonLoader(height: 140, borderRadius: 28),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                EmptyState(title: emptyTitle, subtitle: emptySubtitle),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => showReservationSheet(context: context, state: state),
                    icon: const Icon(IconlyLight.calendar),
                    label: Text(loc.translate('reservation_home_cta')),
                  ),
                ]
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final restaurant = state.mockDataService.getRestaurantById(reservation.restaurantId);
              return _ReservationCard(
                reservation: reservation,
                restaurant: restaurant,
                material: material,
                showActions: showActions,
                onMarkCompleted: showActions
                    ? () async {
                        final success = await notifier.updateStatus(
                          reservation.id,
                          'reservation_status_completed',
                        );
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('reservation_status_updated'))),
                          );
                        }
                      }
                    : null,
                onCancel: showActions
                    ? () async {
                        final success = await notifier.updateStatus(
                          reservation.id,
                          'reservation_status_cancelled',
                        );
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('reservation_status_updated'))),
                          );
                        }
                      }
                    : null,
                onRebook: () => showReservationSheet(
                  context: context,
                  state: state,
                  preselected: restaurant,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.restaurant,
    required this.material,
    required this.showActions,
    required this.onMarkCompleted,
    required this.onCancel,
    required this.onRebook,
  });

  final Reservation reservation;
  final Restaurant restaurant;
  final MaterialLocalizations material;
  final bool showActions;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onCancel;
  final VoidCallback onRebook;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateLabel = material.formatMediumDate(reservation.dateTime);
    final timeLabel = material.formatTimeOfDay(TimeOfDay.fromDateTime(reservation.dateTime));
    final note = reservation.note;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(restaurant.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('$dateLabel • $timeLabel', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.guests} ${loc.translate('reservation_guests')}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Chip(label: Text(loc.translate(reservation.statusKey))),
            ],
          ),
          const SizedBox(height: 12),
          Text(loc.translate(reservation.occasionKey), style: theme.textTheme.labelMedium),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${loc.translate('reservation_notes_label')}: $note',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          if (showActions) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onMarkCompleted,
                    child: Text(loc.translate('reservation_mark_completed')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: Text(loc.translate('reservation_cancel')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onRebook,
              icon: const Icon(IconlyLight.calendar),
              label: Text(loc.translate('reservation_rebook')),
            ),
          ),
        ],
      ),
    );
  }
}
