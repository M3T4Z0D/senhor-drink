import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../features/library/presentation/add_to_list_sheet.dart';
import '../../profile/data/profile_repository.dart';
import '../data/cocktaildb_repository.dart';
import '../data/drink_model.dart';

class DrinkDetailScreen extends ConsumerWidget {
  const DrinkDetailScreen({super.key, required this.drinkId});

  final String drinkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinkAsync = ref.watch(drinkDetailProvider(drinkId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: drinkAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (drink) => drink == null
            ? const Center(child: Text('Drink não encontrado'))
            : _DrinkDetail(drink: drink),
      ),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _DrinkDetail extends ConsumerStatefulWidget {
  const _DrinkDetail({required this.drink});
  final Drink drink;

  @override
  ConsumerState<_DrinkDetail> createState() => _DrinkDetailState();
}

class _DrinkDetailState extends ConsumerState<_DrinkDetail> {
  final Set<int> _checked = {};

  List<String> get _steps {
    final raw = widget.drink.instructions ?? '';
    return raw
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 4)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final drink = widget.drink;
    final uid = supabase.auth.currentUser?.id;
    final profileAsync = uid != null ? ref.watch(myProfileProvider) : null;
    final isFavorite =
        profileAsync?.valueOrNull?.favoriteDrinkIds.contains(drink.id) == true;

    return Stack(
      children: [
        // ── Scrollable content ─────────────────────────────────
        CustomScrollView(
          slivers: [
            // ── Hero ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 480,
              pinned: true,
              backgroundColor: AppColors.surfaceContainerLowest,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _GlassIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              actions: [
                if (uid != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _GlassIconButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.vermouthRed : null,
                      onTap: () async {
                        final current =
                            profileAsync?.valueOrNull?.favoriteDrinkIds ?? [];
                        await ref
                            .read(profileRepositoryProvider)
                            .toggleFavoriteDrink(drink.id, current);
                        ref.invalidate(myProfileProvider);
                        ref.invalidate(userProfileProvider(uid));
                        ref.invalidate(userFavoriteDrinksProvider(uid));
                      },
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _HeroBackground(drink: drink),
              ),
            ),

            // ── Body ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients
                  _SectionHeader(
                    icon: Icons.liquor,
                    title: 'Ingredientes',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.2,
                          colors: [
                            AppColors.primary.withAlpha(20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: drink.ingredients.asMap().entries.map((e) {
                          return _IngredientRow(
                            ingredient: e.value,
                            isLast: e.key == drink.ingredients.length - 1,
                            checked: _checked.contains(e.key),
                            onToggle: () => setState(() {
                              if (_checked.contains(e.key)) {
                                _checked.remove(e.key);
                              } else {
                                _checked.add(e.key);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Preparation
                  if (_steps.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _SectionHeader(
                      icon: Icons.restaurant_menu,
                      title: 'Modo de Preparo',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        children: _steps.asMap().entries.map((e) {
                          return _StepRow(
                            step: e.key + 1,
                            text: e.value,
                            isLast: e.key == _steps.length - 1,
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 120), // space for FAB
                ],
              ),
            ),
          ],
        ),

        // ── Floating "Add to list" button ──────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withAlpha(0),
                  AppColors.background.withAlpha(230),
                  AppColors.background,
                ],
              ),
            ),
            child: FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => AddToListSheet(externalDrinkId: drink.id),
              ),
              icon: const Icon(Icons.playlist_add),
              label: const Text('Adicionar à Lista'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero background with glass panel ─────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.drink});
  final Drink drink;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        if (drink.imageUrl != null)
          CachedNetworkImage(
            imageUrl: drink.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (ctx, url) =>
                Container(color: AppColors.surfaceContainerHigh),
            errorWidget: (ctx, url, err) => Container(
              color: AppColors.surfaceContainerHigh,
              child: const Icon(Icons.local_bar, size: 80, color: AppColors.outline),
            ),
          )
        else
          Container(
            color: AppColors.surfaceContainerHigh,
            child: const Icon(Icons.local_bar, size: 80, color: AppColors.outline),
          ),

        // Gradient overlay
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
              stops: [0.35, 0.65, 1.0],
            ),
          ),
        ),

        // Glass panel at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drink.name,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (drink.alcoholic != null)
                        DrinkLabelChip(label: drink.alcoholic!),
                      if (drink.category != null)
                        DrinkLabelChip(label: drink.category!),
                      if (drink.glass != null)
                        DrinkLabelChip(
                          label: drink.glass!,
                          color: AppColors.tertiary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Ingredient row with circular checkbox ─────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.isLast,
    required this.checked,
    required this.onToggle,
  });

  final ({String name, String? measure}) ingredient;
  final bool isLast;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Circular checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? AppColors.primary.withAlpha(25) : Colors.transparent,
                border: Border.all(
                  color: checked ? AppColors.primary : AppColors.primary.withAlpha(77),
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 14),

            // Name
            Expanded(
              child: Text(
                ingredient.name,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: checked
                      ? AppColors.textSecondary.withAlpha(128)
                      : AppColors.onSurface,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            // Separator line
            if (ingredient.measure != null) ...[
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.primary.withAlpha(25),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              // Measure label
              Text(
                ingredient.measure!,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.05,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Preparation step with numbered circle ─────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.text,
    required this.isLast,
  });

  final int step;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number column
          Column(
            children: [
              // Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  border: Border.all(
                    color: AppColors.primary.withAlpha(51),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              // Vertical connector
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.primary.withAlpha(38),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 6,
                bottom: isLast ? 0 : 24,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass icon button (back / favorite) ───────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.stoneDark.withAlpha(179),
          border: Border.all(color: AppColors.primary.withAlpha(51)),
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.primary),
      ),
    );
  }
}
