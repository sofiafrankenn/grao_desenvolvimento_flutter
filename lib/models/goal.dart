/// Meta de gasto mensal para uma categoria.
class Goal {
  final String categoryId;
  final double limit;

  const Goal({required this.categoryId, required this.limit});

  Map<String, dynamic> toMap() => {
        'category': categoryId,
        'monthly_limit': limit,
      };

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      categoryId: map['category'] as String,
      limit: (map['monthly_limit'] as num).toDouble(),
    );
  }
}
