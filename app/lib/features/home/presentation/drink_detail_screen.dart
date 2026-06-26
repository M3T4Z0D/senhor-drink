import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
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

class _DrinkDetail extends ConsumerWidget {
  const _DrinkDetail({required this.drink});

  final Drink drink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final uid = supabase.auth.currentUser?.id;
    final profileAsync = uid != null ? ref.watch(myProfileProvider) : null;

    final isFavorite = profileAsync?.valueOrNull?.favoriteDrinkIds
            .contains(drink.id) ==
        true;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          actions: [
            if (uid != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : null,
                ),
                tooltip: isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed: () async {
                  final current = profileAsync?.valueOrNull?.favoriteDrinkIds ?? [];
                  await ref
                      .read(profileRepositoryProvider)
                      .toggleFavoriteDrink(drink.id, current);
                  ref.invalidate(myProfileProvider);
                  ref.invalidate(userProfileProvider(uid));
                  ref.invalidate(userFavoriteDrinksProvider(uid));
                },
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              drink.name,
              style: const TextStyle(shadows: [Shadow(blurRadius: 4)]),
            ),
            background: drink.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: drink.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) =>
                        Container(color: colorScheme.surfaceContainerHighest),
                    errorWidget: (ctx, url, err) =>
                        const Icon(Icons.local_bar, size: 80),
                  )
                : null,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Chips de metadata
              Wrap(
                spacing: 8,
                children: [
                  if (drink.alcoholic != null)
                    Chip(label: Text(drink.alcoholic!)),
                  if (drink.category != null)
                    Chip(label: Text(drink.category!)),
                  if (drink.glass != null)
                    Chip(
                      avatar: const Icon(Icons.local_bar, size: 16),
                      label: Text(drink.glass!),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredientes
              Text('Ingredientes',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...drink.ingredients.map(
                (ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 8),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ing.name)),
                      if (ing.measure != null)
                        Text(
                          ing.measure!,
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Modo de preparo
              if (drink.instructions != null) ...[
                Text('Modo de preparo',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(drink.instructions!,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
              ],

              FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) =>
                      AddToListSheet(externalDrinkId: drink.id),
                ),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Adicionar a uma lista'),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}
