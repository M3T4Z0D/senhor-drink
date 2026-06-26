import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mr_drink_app_bar.dart';
import '../data/drink_list_model.dart';
import '../data/lists_repository.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const MrDrinkAppBar(),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (lists) => _LibraryBody(
          lists: lists,
          onCreateList: () => _showListDialog(context, ref),
          onEdit: (l) => _showListDialog(context, ref, existing: l),
          onDelete: (l) => _confirmDelete(context, ref, l),
          onTap: (l) => context.push('/list/${l.id}'),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<void> _showListDialog(
    BuildContext context,
    WidgetRef ref, {
    DrinkList? existing,
  }) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    var isPublic = existing?.isPublic ?? false;
    var loading = false;
    String? error;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? 'Editar lista' : 'Nova lista',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.local_library_outlined),
                ),
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                title: Text(
                  'Lista pública',
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'Visível para outros no Explorar',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                value: isPublic,
                activeThumbColor: AppColors.primary,
                onChanged: loading ? null : (v) => setState(() => isPublic = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 12)),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading ? null : () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (nameCtrl.text.trim().isEmpty) {
                                setState(() => error = 'O nome é obrigatório.');
                                return;
                              }
                              setState(() { loading = true; error = null; });
                              try {
                                final repo = ref.read(listsRepositoryProvider);
                                if (isEdit) {
                                  await repo.updateList(
                                    existing.id,
                                    name: nameCtrl.text.trim(),
                                    description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                                    isPublic: isPublic,
                                  );
                                } else {
                                  await repo.createList(
                                    name: nameCtrl.text.trim(),
                                    description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                                    isPublic: isPublic,
                                  );
                                }
                                ref.invalidate(userListsProvider);
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setState(() { loading = false; error = e.toString(); });
                              }
                            },
                      child: loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEdit ? 'Salvar' : 'Criar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, DrinkList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lista?'),
        content: Text('A lista "${list.name}" será removida permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(listsRepositoryProvider).deleteList(list.id);
      ref.invalidate(userListsProvider);
    }
  }
}

// ── Library body ──────────────────────────────────────────────────────────────

class _LibraryBody extends StatelessWidget {
  const _LibraryBody({
    required this.lists,
    required this.onCreateList,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final List<DrinkList> lists;
  final VoidCallback onCreateList;
  final void Function(DrinkList) onEdit;
  final void Function(DrinkList) onDelete;
  final void Function(DrinkList) onTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Sua Biblioteca',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore e gerencie suas coleções curadas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),

                // Create button
                FilledButton.icon(
                  onPressed: onCreateList,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Criar Nova Lista'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Grid or empty state ─────────────────────────────────
        if (lists.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.local_library_outlined, size: 56, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text('Nenhuma lista ainda.',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Crie sua primeira coleção de drinks.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 3 / 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ListGridCard(
                  list: lists[i],
                  colorIndex: i % _ListGridCard.gradients.length,
                  onTap: () => onTap(lists[i]),
                  onEdit: () => onEdit(lists[i]),
                  onDelete: () => onDelete(lists[i]),
                ),
                childCount: lists.length,
              ),
            ),
          ),

        // ── Sugestões Guru IA section ────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sugestões Guru IA',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    Text(
                      'VER TUDO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary.withAlpha(153),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.08,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _GuruSuggestionCard(),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

// ── Grid card ─────────────────────────────────────────────────────────────────

class _ListGridCard extends StatelessWidget {
  const _ListGridCard({
    required this.list,
    required this.colorIndex,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final DrinkList list;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const gradients = [
    [Color(0xFF6B4226), Color(0xFF1A0B05)], // Whiskey bourbon
    [Color(0xFF3A2848), Color(0xFF0D0812)], // Dark plum
    [Color(0xFF1F3E28), Color(0xFF081008)], // Forest dark
    [Color(0xFF1E2D4A), Color(0xFF070C14)], // Navy gin
  ];

  @override
  Widget build(BuildContext context) {
    final g = gradients[colorIndex];

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [g[0], g[1]],
                ),
              ),
            ),

            // Subtle pattern overlay (amber glow center)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    AppColors.primary.withAlpha(30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Center icon (dim)
            Center(
              child: Icon(
                list.isPublic ? Icons.local_bar : Icons.lock_outline,
                size: 56,
                color: Colors.white.withAlpha(20),
              ),
            ),

            // Top: count badge + overflow menu
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (list.drinkCount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary.withAlpha(77)),
                        ),
                        child: Text(
                          '${list.drinkCount} DRINKS',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ),
                    const Spacer(),
                    _CardMenu(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
              ),
            ),

            // Bottom gradient + title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 32, 12, 12),
                child: Text(
                  list.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ),

            // Gold border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(38), width: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card popup menu ───────────────────────────────────────────────────────────

enum _CardAction { edit, delete }

class _CardMenu extends StatelessWidget {
  const _CardMenu({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CardAction>(
      icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
      color: AppColors.surfaceContainerHigh,
      onSelected: (a) {
        if (a == _CardAction.edit) onEdit();
        if (a == _CardAction.delete) onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _CardAction.edit,
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 10),
            Text('Editar'),
          ]),
        ),
        PopupMenuItem(
          value: _CardAction.delete,
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: AppColors.vermouthRed),
            const SizedBox(width: 10),
            Text('Excluir', style: TextStyle(color: AppColors.vermouthRed)),
          ]),
        ),
      ],
    );
  }
}

// ── Guru IA suggestion card ───────────────────────────────────────────────────

class _GuruSuggestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(51),
                  AppColors.primaryContainer.withAlpha(77),
                ],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crie com o Guru IA',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diga os ingredientes que tem e receba uma receita única.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Chevron
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withAlpha(25),
            ),
            child: const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}
