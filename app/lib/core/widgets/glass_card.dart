import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Glassmorphism container: semi-transparent stone-dark bg, amber border, backdrop blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.blurSigma = 12,
    this.borderOpacityAlpha = 38, // ~0.15
    this.backgroundAlpha = 166,   // ~0.65
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final int borderOpacityAlpha;
  final int backgroundAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.stoneDark.withAlpha(backgroundAlpha),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.primary.withAlpha(borderOpacityAlpha),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small pill-shaped category/label chip matching the Stitch label-caps style.
class DrinkLabelChip extends StatelessWidget {
  const DrinkLabelChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.withAlpha(77)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}
