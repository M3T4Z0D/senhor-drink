import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../library/data/drink_list_model.dart';
import '../../profile/data/profile_model.dart';

class PublicDrinkList {
  const PublicDrinkList({
    required this.list,
    required this.author,
  });

  final DrinkList list;
  final UserProfile author;
}

class ExploreRepository {
  Future<List<PublicDrinkList>> fetchPublicLists({
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await supabase
        .from('drink_lists')
        .select('*, profiles(id, username, avatar_url)')
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((r) {
      final map = r as Map<String, dynamic>;
      final profileMap = map['profiles'] as Map<String, dynamic>;
      return PublicDrinkList(
        list: DrinkList.fromJson(map),
        author: UserProfile.fromJson(profileMap),
      );
    }).toList();
  }
}

final exploreRepositoryProvider = Provider((ref) => ExploreRepository());

final publicListsProvider =
    FutureProvider.autoDispose<List<PublicDrinkList>>((ref) {
  return ref.read(exploreRepositoryProvider).fetchPublicLists();
});
