class Drink {
  const Drink({
    required this.id,
    required this.name,
    this.category,
    this.alcoholic,
    this.glass,
    this.instructions,
    this.imageUrl,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String? category;
  final String? alcoholic;
  final String? glass;
  final String? instructions;
  final String? imageUrl;
  final List<({String name, String? measure})> ingredients;

  factory Drink.fromJson(Map<String, dynamic> json) {
    final ingredients = <({String name, String? measure})>[];
    for (var i = 1; i <= 15; i++) {
      final name = json['strIngredient$i'] as String?;
      if (name == null || name.trim().isEmpty) break;
      final raw = json['strMeasure$i'] as String?;
      final measure = (raw?.trim().isEmpty ?? true) ? null : raw?.trim();
      ingredients.add((name: name.trim(), measure: measure));
    }
    return Drink(
      id: json['idDrink'] as String,
      name: json['strDrink'] as String,
      category: json['strCategory'] as String?,
      alcoholic: json['strAlcoholic'] as String?,
      glass: json['strGlass'] as String?,
      instructions: json['strInstructions'] as String?,
      imageUrl: json['strDrinkThumb'] as String?,
      ingredients: ingredients,
    );
  }
}
