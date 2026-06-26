import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/drink_model.dart';

/// Portrait image card — 3:4 aspect ratio, image fills the card,
/// gradient overlay at bottom with category chip + drink name.
class DrinkCard extends StatelessWidget {
  const DrinkCard({super.key, required this.drink, required this.onTap});

  final Drink drink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image ────────────────────────────────────────
              if (drink.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: drink.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.local_bar, size: 40, color: AppColors.outline),
                    ),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.local_bar, size: 40, color: AppColors.outline),
                    ),
                  ),
                )
              else
                Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Icon(Icons.local_bar, size: 48, color: AppColors.outline),
                  ),
                ),

              // ── Gradient overlay ─────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x66000000),
                      Color(0xFF141312),
                    ],
                    stops: [0.4, 0.65, 1.0],
                  ),
                ),
              ),

              // ── Gold border ─────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(38),
                    width: 1,
                  ),
                ),
              ),

              // ── Content at bottom ────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (drink.category != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: _LabelChip(drink.category!),
                        ),
                      Text(
                        drink.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withAlpha(77)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}
