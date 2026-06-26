import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../home/data/cocktaildb_repository.dart';
import '../../home/data/drink_model.dart';
import '../../library/data/drink_list_model.dart';
import 'profile_model.dart';

class ProfileRepository {
  String get _uid => supabase.auth.currentUser!.id;

  Future<UserProfile> getProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> getMyProfile() => getProfile(_uid);

  Future<void> updateProfile({
    String? username,
    String? displayName,
    String? nickname,
    String? pronouns,
    String? bio,
    String? avatarUrl,
  }) async {
    await supabase.from('profiles').update({
      if (username != null) 'username': username,
      'display_name': displayName,
      'nickname': nickname,
      'pronouns': pronouns,
      'bio': bio,
      'avatar_url': avatarUrl,
    }).eq('id', _uid);
  }

  Future<String> uploadAvatar(Uint8List bytes, String extension) async {
    final path = '$_uid/avatar.$extension';
    await supabase.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    // Cache bust para forçar recarga da imagem
    final url = supabase.storage.from('avatars').getPublicUrl(path);
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> completeOnboarding() async {
    await supabase.from('profiles')
        .update({'onboarding_completed': true}).eq('id', _uid);
  }

  Future<void> changePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> toggleFavoriteDrink(
      String drinkId, List<String> currentFavorites) async {
    final updated = currentFavorites.contains(drinkId)
        ? currentFavorites.where((id) => id != drinkId).toList()
        : [...currentFavorites, drinkId];
    await supabase.from('profiles').update(
        {'favorite_drink_ids': updated}).eq('id', _uid);
  }

  Future<List<DrinkList>> getPublicLists(String userId) async {
    final data = await supabase
        .from('drink_lists')
        .select()
        .eq('user_id', userId)
        .eq('is_public', true)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => DrinkList.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<DrinkList>> getMyAllLists() async {
    final data = await supabase
        .from('drink_lists')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return (data as List)
        .map((r) => DrinkList.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final userProfileProvider =
    FutureProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).getProfile(userId);
});

final myProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

final userPublicListsProvider =
    FutureProvider.autoDispose.family<List<DrinkList>, String>((ref, userId) {
  return ref.read(profileRepositoryProvider).getPublicLists(userId);
});

final myAllListsProvider = FutureProvider.autoDispose<List<DrinkList>>((ref) {
  return ref.read(profileRepositoryProvider).getMyAllLists();
});

// True = onboarding ainda não foi concluído
final onboardingNeededProvider = FutureProvider<bool>((ref) async {
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return false;
  final data = await supabase
      .from('profiles')
      .select('onboarding_completed')
      .eq('id', uid)
      .single();
  return !(data['onboarding_completed'] as bool? ?? true);
});

// Busca os drinks favoritos de um usuário, dependente do perfil dele
final userFavoriteDrinksProvider =
    FutureProvider.autoDispose.family<List<Drink?>, String>((ref, userId) async {
  final profile = await ref.watch(userProfileProvider(userId).future);
  if (profile.favoriteDrinkIds.isEmpty) return [];
  final repo = ref.read(cocktailDbRepositoryProvider);
  return Future.wait(profile.favoriteDrinkIds.map((id) => repo.lookup(id)));
});
