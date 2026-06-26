import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drink_list_model.dart';
import '../data/lists_repository.dart';

class AddToListSheet extends ConsumerStatefulWidget {
  const AddToListSheet({super.key, required this.externalDrinkId});

  final String externalDrinkId;

  @override
  ConsumerState<AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends ConsumerState<AddToListSheet> {
  String? _addingToListId;
  String? _addedToListId;

  Future<void> _addToList(DrinkList list) async {
    setState(() => _addingToListId = list.id);
    try {
      await ref
          .read(listsRepositoryProvider)
          .addDrinkToList(list.id, widget.externalDrinkId);
      setState(() {
        _addedToListId = list.id;
        _addingToListId = null;
      });
    } catch (e) {
      setState(() => _addingToListId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _createAndAdd() async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova lista'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nome da lista',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameCtrl.text.trim().isNotEmpty) {
      final list = await ref
          .read(listsRepositoryProvider)
          .createList(name: nameCtrl.text.trim());
      await _addToList(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(userListsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Adicionar a uma lista',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            listsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro: $e'),
              data: (lists) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...lists.map(
                    (list) => ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          list.isPublic ? Icons.public : Icons.lock_outline,
                        ),
                      ),
                      title: Text(list.name),
                      trailing: _addedToListId == list.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : _addingToListId == list.id
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                      onTap: _addedToListId == list.id
                          ? null
                          : () => _addToList(list),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.add)),
                    title: const Text('Criar nova lista'),
                    onTap: _createAndAdd,
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
