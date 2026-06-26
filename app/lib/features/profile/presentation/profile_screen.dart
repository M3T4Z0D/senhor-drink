import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../home/presentation/widgets/drink_card.dart';
import '../../library/presentation/widgets/drink_list_card.dart';
import '../data/profile_model.dart';
import '../data/profile_repository.dart';
import 'widgets/avatar_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.userId});

  final String userId;

  bool get _isOwnProfile => supabase.auth.currentUser?.id == userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (profile) => _ProfileContent(
          profile: profile,
          isOwnProfile: _isOwnProfile,
          onEditSaved: () {
            ref.invalidate(userProfileProvider(userId));
            ref.invalidate(myProfileProvider);
            ref.invalidate(userFavoriteDrinksProvider(userId));
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({
    required this.profile,
    required this.isOwnProfile,
    required this.onEditSaved,
  });

  final UserProfile profile;
  final bool isOwnProfile;
  final VoidCallback onEditSaved;

  Future<void> _openEdit(BuildContext context) async {
    final result = await context.push<bool>('/profile/edit', extra: profile);
    if (result == true) onEditSaved();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userPublicListsProvider(profile.id));
    final favoritesAsync = ref.watch(userFavoriteDrinksProvider(profile.id));

    return CustomScrollView(
      slivers: [
        // ── AppBar com avatar e informações ─────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
          actions: [
            if (isOwnProfile) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEdit(context),
                tooltip: 'Editar perfil',
              ),
              PopupMenuButton<_ProfileAction>(
                onSelected: (action) async {
                  if (action == _ProfileAction.logout) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sair da conta?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(ctx).colorScheme.error,
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await supabase.auth.signOut();
                      if (context.mounted) context.go('/login');
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: _ProfileAction.logout,
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Sair da conta'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarWidget(profile: profile, radius: 48),
                    const SizedBox(height: 10),
                    // Nome de exibição
                    Text(
                      profile.presentationName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    // @username (se tiver display_name diferente)
                    if (profile.displayName != null &&
                        profile.displayName!.isNotEmpty)
                      Text(
                        '@${profile.username}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(160),
                            ),
                      ),
                    // Apelido e pronomes
                    if (profile.nickname != null ||
                        profile.pronouns != null) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          if (profile.nickname != null)
                            Chip(
                              label: Text('"${profile.nickname}"'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          if (profile.pronouns != null)
                            Chip(
                              label: Text(profile.pronouns!),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ],
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          profile.bio!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Drinks favoritos ────────────────────────────────
        if (profile.favoriteDrinkIds.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Drinks favoritos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

        if (profile.favoriteDrinkIds.isNotEmpty)
          SliverToBoxAdapter(
            child: favoritesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, st) => const SizedBox.shrink(),
              data: (drinks) {
                final valid =
                    drinks.whereType<Object>().toList();
                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: valid.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      final drink = drinks[i];
                      if (drink == null) return const SizedBox.shrink();
                      return SizedBox(
                        width: 150,
                        child: DrinkCard(
                          drink: drink,
                          onTap: () => context.push('/drink/${drink.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

        // ── Listas públicas ─────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Listas públicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: listsAsync.when(
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                SliverToBoxAdapter(child: Center(child: Text('Erro: $e'))),
            data: (lists) {
              if (lists.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.menu_book_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            isOwnProfile
                                ? 'Você não tem listas públicas ainda.'
                                : 'Nenhuma lista pública.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DrinkListCard(
                      drinkList: lists[i],
                      onTap: () => context.push('/list/${lists[i].id}'),
                    ),
                  ),
                  childCount: lists.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _ProfileAction { logout }
