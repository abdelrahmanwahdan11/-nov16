import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notifiers.dart';
import '../../core/services/mock_data_service.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key, required this.state, required this.item});

  static const route = '/food-details';
  final AppState state;
  final FoodItem item;

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> with TickerProviderStateMixin {
  late AnimationController _flipController;
  bool _overlayVisible = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_flipController.isDismissed) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _showAiInfo() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconlyBold.info_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(loc.translate('ai_info'), style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            Text(loc.translate('ai_placeholder'), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(IconlyLight.heart),
                    onPressed: () => widget.state.favoritesNotifier.toggle(widget.item),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: widget.item.id,
                    child: Image.network(widget.item.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.name, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: theme.colorScheme.secondary, size: 18),
                          const SizedBox(width: 4),
                          Text(widget.item.rating.toStringAsFixed(1)),
                          const SizedBox(width: 16),
                          const Icon(Icons.timer, size: 18),
                          const SizedBox(width: 4),
                          Text('${widget.item.deliveryTime} min'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(widget.item.description, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: widget.item.ingredients
                            .map((e) => Chip(label: Text(e)))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
                                icon: const Icon(IconlyLight.minus),
                              ),
                              Text(_quantity.toString(), style: theme.textTheme.headlineSmall),
                              IconButton(
                                onPressed: () => setState(() => _quantity += 1),
                                icon: const Icon(IconlyLight.plus),
                              )
                            ],
                          ),
                          Text('${(widget.item.price * _quantity).toStringAsFixed(2)} USD', style: theme.textTheme.headlineMedium),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.state.cartNotifier.add(widget.item);
                              },
                              icon: const Icon(IconlyBold.bag_2),
                              label: Text(loc.translate('add_to_cart')),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => widget.state.comparisonNotifier.toggle(widget.item),
                              icon: const Icon(IconlyLight.swap),
                              label: Text(loc.translate('add_to_comparison')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _showAiInfo,
                          icon: const Icon(IconlyBold.info_circle),
                          label: Text(loc.translate('ai_info')),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          if (_overlayVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _toggleCard,
                onTapCancel: () => setState(() => _overlayVisible = false),
                child: AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, child) {
                    final angle = _flipController.value * pi;
                    final isBack = angle > pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black.withOpacity(0.7),
                        ),
                        child: isBack
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Nutrition', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: () => setState(() => _overlayVisible = false),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Calories: ${widget.item.calories}', style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  const Text('Protein: 22g', style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  const Text('Carbs: 34g', style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  const Text('Fats: 12g', style: TextStyle(color: Colors.white70)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: () => setState(() => _overlayVisible = false),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(widget.item.description, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 12),
                                  Text('Tap to flip for nutrition info', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
