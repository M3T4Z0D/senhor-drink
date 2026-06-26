import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../explore/data/explore_repository.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(publicListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(publicListsProvider),
          ),
        ],
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Nenhuma lista pública ainda.'),
                  Text('Torne uma das suas listas pública!'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(publicListsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: lists.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = lists[i];
                return _PublicListCard(
                  item: item,
                  onTap: () => context.push('/list/${item.list.id}'),
                  onAuthorTap: () =>
                      context.push('/profile/${item.author.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PublicListCard extends StatelessWidget {
  const _PublicListCard({
    required this.item,
    required this.onTap,
    required this.onAuthorTap,
  });

  final PublicDrinkList item;
  final VoidCallback onTap;
  final VoidCallback onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.list.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (item.list.description != null &&
                  item.list.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.list.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onAuthorTap,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text(
                        item.author.username.isNotEmpty
                            ? item.author.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '@${item.author.username}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
