class DrinkList {
  const DrinkList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;

  factory DrinkList.fromJson(Map<String, dynamic> json) => DrinkList(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        isPublic: json['is_public'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ListItem {
  const ListItem({
    required this.id,
    required this.listId,
    this.externalDrinkId,
    this.customDrinkId,
  });

  final String id;
  final String listId;
  final String? externalDrinkId;
  final String? customDrinkId;

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        id: json['id'] as String,
        listId: json['list_id'] as String,
        externalDrinkId: json['external_drink_id'] as String?,
        customDrinkId: json['custom_drink_id'] as String?,
      );
}
