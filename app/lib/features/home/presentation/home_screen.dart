import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/cocktaildb_repository.dart';
import '../data/drink_model.dart';
import 'widgets/drink_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting, Mixologista',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qual será a alquimia de hoje?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _PillSearchBar(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      onChanged: (v) =>
                          ref.read(_searchQueryProvider.notifier).state = v,
                      onClear: () {
                        _searchCtrl.clear();
                        ref.read(_searchQueryProvider.notifier).state = '';
                      },
                      hasQuery: query.isNotEmpty,
                    ),
                  ],
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────
            if (query.isEmpty)
              ...[
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                const SliverToBoxAdapter(child: _ShakerSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const _HighlightsSection(),
              ]
            else
              _SearchResultsSliver(query: query),

            // bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Pill Search Bar ───────────────────────────────────────────────────────────

class _PillSearchBar extends StatelessWidget {
  const _PillSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.stoneMid.withAlpha(204),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.primary.withAlpha(25)),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Outfit',
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar coquetéis ou ingredientes...',
              hintStyle: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.textSecondary.withAlpha(128),
                fontSize: 15,
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.primary.withAlpha(153)),
              suffixIcon: hasQuery
                  ? IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary.withAlpha(153), size: 20),
                      onPressed: onClear,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              filled: false,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shaker / Random drink section ────────────────────────────────────────────

class _ShakerSection extends ConsumerWidget {
  const _ShakerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomAsync = ref.watch(randomDrinkProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.local_bar, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Drink Aleatório',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Não sabe o que beber?\nDeixe o destino decidir por você.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            randomAsync.when(
              loading: () => const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => FilledButton.icon(
                onPressed: () => ref.invalidate(randomDrinkProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
              data: (drink) => Column(
                children: [
                  if (drink != null)
                    _ShakerDrinkPreview(
                      drink: drink,
                      onTap: () => context.push('/drink/${drink.id}'),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(randomDrinkProvider),
                    icon: const Icon(Icons.shuffle, size: 18),
                    label: const Text('Outro drink'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withAlpha(100)),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShakerDrinkPreview extends StatelessWidget {
  const _ShakerDrinkPreview({required this.drink, required this.onTap});
  final Drink drink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: DrinkCard(drink: drink, onTap: onTap),
      ),
    );
  }
}

// ── Highlights horizontal scroll ─────────────────────────────────────────────

class _HighlightsSection extends ConsumerWidget {
  const _HighlightsSection();

  // Drinks clássicos sempre populares — carregados individualmente
  static const _classicIds = ['11007', '11001', '11000', '12628', '178341'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Destaques da Semana',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'VER TODOS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.08,
                        ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _classicIds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => SizedBox(
                width: 200,
                child: _HighlightCard(drinkId: _classicIds[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends ConsumerWidget {
  const _HighlightCard({required this.drinkId});
  final String drinkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drinkAsync = ref.watch(drinkDetailProvider(drinkId));

    return drinkAsync.when(
      loading: () => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: AppColors.surfaceContainerHigh,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (drink) => drink == null
          ? const SizedBox.shrink()
          : DrinkCard(
              drink: drink,
              onTap: () => context.push('/drink/${drink.id}'),
            ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResultsSliver extends ConsumerWidget {
  const _SearchResultsSliver({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(drinkSearchProvider(query));

    return resultsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Erro: $e', style: const TextStyle(color: AppColors.vermouthRed)),
        )),
      ),
      data: (drinks) {
        if (drinks.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum coquetel encontrado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 3 / 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => DrinkCard(
                drink: drinks[i],
                onTap: () => context.push('/drink/${drinks[i].id}'),
              ),
              childCount: drinks.length,
            ),
          ),
        );
      },
    );
  }
}
