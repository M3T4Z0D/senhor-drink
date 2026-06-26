import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import 'drink_list_model.dart';

class ListsRepository {
  const ListsRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<DrinkList>> getUserLists() async {
    final data = await _client
        .from('drink_lists')
        .select('*, list_items(count)')
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return (data as List).map((r) => DrinkList.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<DrinkList> createList({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    final data = await _client.from('drink_lists').insert({
      'user_id': _uid,
      'name': name,
      'description': description,
      'is_public': isPublic,
    }).select().single();
    return DrinkList.fromJson(data);
  }

  Future<void> updateList(
    String id, {
    required String name,
    String? description,
    required bool isPublic,
  }) =>
      _client.from('drink_lists').update({
        'name': name,
        'description': description,
        'is_public': isPublic,
      }).eq('id', id);

  Future<void> deleteList(String id) =>
      _client.from('drink_lists').delete().eq('id', id);

  Future<List<ListItem>> getListItems(String listId) async {
    final data = await _client
        .from('list_items')
        .select()
        .eq('list_id', listId);
    return (data as List).map((r) => ListItem.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> addDrinkToList(String listId, String externalDrinkId) =>
      _client.from('list_items').insert({
        'list_id': listId,
        'external_drink_id': externalDrinkId,
      });

  Future<void> removeItem(String itemId) =>
      _client.from('list_items').delete().eq('id', itemId);
}

// ── Providers ────────────────────────────────────────────────────────────────

final listsRepositoryProvider =
    Provider((ref) => ListsRepository(supabase));

final userListsProvider = FutureProvider.autoDispose<List<DrinkList>>((ref) {
  return ref.read(listsRepositoryProvider).getUserLists();
});

final listItemsProvider =
    FutureProvider.autoDispose.family<List<ListItem>, String>((ref, listId) {
  return ref.read(listsRepositoryProvider).getListItems(listId);
});
