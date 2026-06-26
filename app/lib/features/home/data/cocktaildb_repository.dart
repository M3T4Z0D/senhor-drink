import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'drink_model.dart';

class CocktailDbRepository {
  static const _base = 'https://www.thecocktaildb.com/api/json/v1/1';

  Future<List<Drink>> search(String name) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeComponent(name)}');
    final response = await http.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final drinks = data['drinks'];
    if (drinks == null) return [];
    return (drinks as List).map((d) => Drink.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<Drink?> random() async {
    final uri = Uri.parse('$_base/random.php');
    final response = await http.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final drinks = data['drinks'] as List?;
    if (drinks == null || drinks.isEmpty) return null;
    return Drink.fromJson(drinks.first as Map<String, dynamic>);
  }

  Future<Drink?> lookup(String id) async {
    final uri = Uri.parse('$_base/lookup.php?i=$id');
    final response = await http.get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final drinks = data['drinks'] as List?;
    if (drinks == null || drinks.isEmpty) return null;
    return Drink.fromJson(drinks.first as Map<String, dynamic>);
  }
}

final cocktailDbRepositoryProvider = Provider((ref) => CocktailDbRepository());

final drinkSearchProvider = FutureProvider.family<List<Drink>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.read(cocktailDbRepositoryProvider).search(query);
});

final randomDrinkProvider = FutureProvider.autoDispose<Drink?>((ref) {
  return ref.read(cocktailDbRepositoryProvider).random();
});

final drinkDetailProvider = FutureProvider.autoDispose.family<Drink?, String>((ref, id) {
  return ref.read(cocktailDbRepositoryProvider).lookup(id);
});
