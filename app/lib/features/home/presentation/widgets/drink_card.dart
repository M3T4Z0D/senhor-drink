import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/drink_model.dart';

class DrinkCard extends StatelessWidget {
  const DrinkCard({super.key, required this.drink, required this.onTap});

  final Drink drink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: '${drink.imageUrl}/preview',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                width: 90,
                height: 90,
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (ctx, url, err) => const Icon(Icons.local_bar),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (drink.category != null)
                    Text(
                      drink.category!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (drink.alcoholic != null)
                    Chip(
                      label: Text(drink.alcoholic!),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
