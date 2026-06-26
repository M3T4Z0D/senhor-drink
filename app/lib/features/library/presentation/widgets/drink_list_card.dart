import 'package:flutter/material.dart';
import '../../data/drink_list_model.dart';

enum _ListAction { edit, delete }

class DrinkListCard extends StatelessWidget {
  const DrinkListCard({
    super.key,
    required this.drinkList,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final DrinkList drinkList;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(drinkList.isPublic ? Icons.public : Icons.lock_outline),
        ),
        title: Text(drinkList.name),
        subtitle: drinkList.description != null
            ? Text(
                drinkList.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                drinkList.isPublic ? 'Lista pública' : 'Lista privada',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
        trailing: hasActions
            ? PopupMenuButton<_ListAction>(
                onSelected: (action) {
                  if (action == _ListAction.edit) onEdit?.call();
                  if (action == _ListAction.delete) onDelete?.call();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: _ListAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ListAction.delete,
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Theme.of(ctx).colorScheme.error,
                      ),
                      title: Text(
                        'Excluir',
                        style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
