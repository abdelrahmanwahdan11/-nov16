import 'package:flutter/material.dart';

import '../../core/services/mock_data_service.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key, required this.order});

  static const route = '/track-order';
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1523961131990-5ea7c61b2107?auto=format&fit=crop&w=1200&q=80',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoutePainter(theme.colorScheme.primary),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Heading your way', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('ETA 15 min', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Chip(label: Text(order.id)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _TimelineStep(label: 'Accepted', active: true),
                _TimelineStep(label: 'Cooking', active: true),
                _TimelineStep(label: 'Pickup', active: false),
                _TimelineStep(label: 'Delivered', active: false),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80'),
              ),
              title: const Text('Aria Bloom'),
              subtitle: const Text('Courier'),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('Order Received'),
            )
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.9, size.height * 0.3);
    canvas.drawPath(path, paint);
    final pickup = Offset(size.width * 0.1, size.height * 0.8);
    final drop = Offset(size.width * 0.9, size.height * 0.3);
    canvas.drawCircle(pickup, 8, Paint()..color = color);
    canvas.drawCircle(drop, 8, Paint()..color = color.withOpacity(0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
