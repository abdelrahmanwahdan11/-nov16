import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/primary_button.dart';

Future<void> showReservationSheet({
  required BuildContext context,
  required AppState state,
  Restaurant? preselected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return _ReservationSheet(state: state, preselected: preselected);
    },
  );
}

class _ReservationSheet extends StatefulWidget {
  const _ReservationSheet({required this.state, this.preselected});

  final AppState state;
  final Restaurant? preselected;

  @override
  State<_ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<_ReservationSheet> {
  late final TextEditingController _noteController;
  late final List<Restaurant> _restaurants;
  late String _restaurantId;
  ReservationSlot? _selectedSlot;
  int _guests = 2;
  String _occasionKey = 'reservation_occasion_casual';

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _restaurants = widget.state.mockDataService.restaurants;
    _restaurantId = widget.preselected?.id ?? (_restaurants.isNotEmpty ? _restaurants.first.id : '');
    if (_restaurantId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.state.reservationsNotifier.loadSlotsForRestaurant(_restaurantId);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    widget.state.reservationsNotifier.clearSlots();
    super.dispose();
  }

  void _onRestaurantChanged(String? value) {
    if (value == null || value == _restaurantId) return;
    setState(() {
      _restaurantId = value;
      _selectedSlot = null;
    });
    widget.state.reservationsNotifier.loadSlotsForRestaurant(_restaurantId);
  }

  void _onSelectSlot(ReservationSlot slot) {
    setState(() => _selectedSlot = slot);
  }

  Future<void> _onConfirm() async {
    final slot = _selectedSlot;
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('reservation_select_slot'))),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final notifier = widget.state.reservationsNotifier;
    final loc = AppLocalizations.of(context);
    final reservation = await notifier.bookReservation(
      restaurantId: _restaurantId,
      dateTime: slot.dateTime,
      guests: _guests,
      occasionKey: _occasionKey,
      note: _noteController.text.trim(),
    );
    if (!mounted) return;
    if (reservation != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('reservation_saved'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = widget.state.reservationsNotifier;
    final material = MaterialLocalizations.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              loc.translate('reservation_sheet_title'),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('reservation_sheet_subtitle'),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _restaurantId.isEmpty ? null : _restaurantId,
              items: _restaurants
                  .map(
                    (restaurant) => DropdownMenuItem<String>(
                      value: restaurant.id,
                      child: Text(restaurant.name),
                    ),
                  )
                  .toList(),
              onChanged: _restaurants.isEmpty ? null : _onRestaurantChanged,
              decoration: InputDecoration(
                labelText: loc.translate('reservation_select_restaurant'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.translate('reservation_select_slot'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: notifier.isLoadingSlots,
              builder: (context, loading, _) {
                return ValueListenableBuilder<List<ReservationSlot>>(
                  valueListenable: notifier.availableSlots,
                  builder: (context, slots, __) {
                    if (loading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator.adaptive(),
                      ));
                    }
                    if (slots.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          loc.translate('reservation_no_slots'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: slots.map((slot) {
                        final selected = _selectedSlot?.id == slot.id;
                        final label = '${material.formatShortDate(slot.dateTime)} • '
                            '${material.formatTimeOfDay(TimeOfDay.fromDateTime(slot.dateTime))}';
                        final capacity = '${loc.translate('reservation_guests')}: ${slot.capacity}';
                        return ChoiceChip(
                          label: SizedBox(
                            width: 160,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label, style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 2),
                                Text(
                                  capacity,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          selected: selected,
                          selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                          onSelected: (_) => _onSelectSlot(slot),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _guests,
                    decoration: InputDecoration(
                      labelText: loc.translate('reservation_guests'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    items: List.generate(8, (index) => index + 1)
                        .map((count) => DropdownMenuItem(value: count, child: Text('$count')))
                        .toList(),
                    onChanged: (value) => setState(() => _guests = value ?? 2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _occasionKey,
                    decoration: InputDecoration(
                      labelText: loc.translate('reservation_select_occasion'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    items: const [
                      'reservation_occasion_casual',
                      'reservation_occasion_celebration',
                      'reservation_occasion_business',
                      'reservation_occasion_date',
                    ]
                        .map(
                          (key) => DropdownMenuItem(
                            value: key,
                            child: Text(loc.translate(key)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _occasionKey = value ?? _occasionKey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: loc.translate('reservation_notes_label'),
                hintText: loc.translate('reservation_notes_placeholder'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.translate('reservation_sheet_hint'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: notifier.isBooking,
              builder: (context, booking, _) {
                return SizedBox(
                  width: double.infinity,
                  child: AbsorbPointer(
                    absorbing: booking,
                    child: Opacity(
                      opacity: booking ? 0.6 : 1,
                      child: PrimaryButton(
                        label: loc.translate('reservation_confirm_cta'),
                        icon: booking ? null : IconlyLight.calendar,
                        onPressed: booking ? null : _onConfirm,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
