import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/cocktaildb_repository.dart';
import 'widgets/drink_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(_searchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(_searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mr. Drink'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Buscar drink...',
              leading: const Icon(Icons.search),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
              ],
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: query.isEmpty ? const _RandomSection() : _SearchResults(query: query),
          ),
        ],
      ),
    );
  }
}

class _RandomSection extends ConsumerWidget {
  const _RandomSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomAsync = ref.watch(randomDrinkProvider);

    return Center(
      child: randomAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Erro: $e'),
        data: (drink) => drink == null
            ? const Text('Nenhum drink encontrado')
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Drink aleatório',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    DrinkCard(
                      drink: drink,
                      onTap: () => context.push('/drink/${drink.id}'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(randomDrinkProvider),
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Outro drink aleatório'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(drinkSearchProvider(query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (drinks) {
        if (drinks.isEmpty) {
          return const Center(child: Text('Nenhum drink encontrado.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: drinks.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 8),
          itemBuilder: (context, i) => DrinkCard(
            drink: drinks[i],
            onTap: () => context.push('/drink/${drinks[i].id}'),
          ),
        );
      },
    );
  }
}
