import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/drink_list_model.dart';
import '../data/lists_repository.dart';
import 'widgets/drink_list_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showListDialog(context, ref),
        child: const Icon(Icons.add),
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
                  Icon(Icons.menu_book_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Nenhuma lista ainda.'),
                  Text('Crie sua primeira lista!'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => DrinkListCard(
              drinkList: lists[i],
              onTap: () => context.push('/list/${lists[i].id}'),
              onEdit: () => _showListDialog(context, ref, existing: lists[i]),
              onDelete: () => _confirmDelete(context, ref, lists[i]),
            ),
          );
        },
      ),
    );
  }

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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Editar lista' : 'Nova lista',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                ),
                autofocus: !isEdit,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                title: const Text('Lista pública'),
                subtitle: const Text('Visível no Explorar para outros usuários'),
                value: isPublic,
                onChanged: loading ? null : (v) => setState(() => isPublic = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    error!,
                    style: TextStyle(
                        color: Theme.of(ctx).colorScheme.error, fontSize: 12),
                  ),
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
                              setState(() {
                                loading = true;
                                error = null;
                              });
                              try {
                                final repo = ref.read(listsRepositoryProvider);
                                if (isEdit) {
                                  await repo.updateList(
                                    existing.id,
                                    name: nameCtrl.text.trim(),
                                    description: descCtrl.text.trim().isEmpty
                                        ? null
                                        : descCtrl.text.trim(),
                                    isPublic: isPublic,
                                  );
                                } else {
                                  await repo.createList(
                                    name: nameCtrl.text.trim(),
                                    description: descCtrl.text.trim().isEmpty
                                        ? null
                                        : descCtrl.text.trim(),
                                    isPublic: isPublic,
                                  );
                                }
                                ref.invalidate(userListsProvider);
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setState(() {
                                  loading = false;
                                  error = e.toString();
                                });
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DrinkList list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lista?'),
        content: Text('A lista "${list.name}" será removida permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
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
