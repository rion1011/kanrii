class Item {
  final String id;
  final String occasionId;
  String name;
  int sortOrder;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.occasionId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'occasionId': occasionId,
        'name': name,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        occasionId: json['occasionId'] as String,
        name: json['name'] as String,
        sortOrder: json['sortOrder'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
