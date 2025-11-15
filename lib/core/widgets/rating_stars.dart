import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.reviewCount});

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = List.generate(5, (index) {
      final value = rating - index;
      return Icon(
        value >= 1
            ? Icons.star
            : value >= 0.5
                ? Icons.star_half
                : Icons.star_border,
        color: theme.colorScheme.secondary,
        size: 18,
      );
    });
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stars,
        if (reviewCount != null) ...[
          const SizedBox(width: 6),
          Text('(${reviewCount!})', style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
