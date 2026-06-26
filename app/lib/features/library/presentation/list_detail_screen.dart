import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../home/data/cocktaildb_repository.dart';
import '../../home/presentation/widgets/drink_card.dart';
import '../data/lists_repository.dart';

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(listItemsProvider(listId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lista')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_bar_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Lista vazia.'),
                  Text('Adicione drinks pela tela de detalhes.'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = items[i];
              if (item.externalDrinkId == null) return const SizedBox.shrink();
              return _DrinkItemTile(
                drinkId: item.externalDrinkId!,
                itemId: item.id,
                listId: listId,
                onRemoved: () => ref.invalidate(listItemsProvider(listId)),
              );
            },
          );
        },
      ),
    );
  }
}

class _DrinkItemTile extends ConsumerWidget {
  const _DrinkItemTile({
    required this.drinkId,
    required this.itemId,
    required this.listId,
    required this.onRemoved,
  });

  final String drinkId;
  final String itemId;
  final String listId;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinkAsync = ref.watch(drinkDetailProvider(drinkId));

    return drinkAsync.when(
      loading: () => const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => ListTile(title: Text('Erro: $e')),
      data: (drink) {
        if (drink == null) return const SizedBox.shrink();
        return Dismissible(
          key: Key(itemId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await ref.read(listsRepositoryProvider).removeItem(itemId);
            onRemoved();
          },
          child: DrinkCard(
            drink: drink,
            onTap: () => context.push('/drink/${drink.id}'),
          ),
        );
      },
    );
  }
}
