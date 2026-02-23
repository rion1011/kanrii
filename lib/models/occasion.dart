class Occasion {
  final String id;
  String name;
  String? emoji;
  final DateTime createdAt;
  DateTime updatedAt;

  Occasion({
    required this.id,
    required this.name,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Occasion.fromJson(Map<String, dynamic> json) => Occasion(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
