class MealItem {
  final String name;
  final double weight;

  MealItem({required this.name, required this.weight});

  Map<String, dynamic> toJson() {
    return {'food': name, 'weight': weight};
  }
  @override
  String toString() {
    return 'MealItem(name: $name, weight: $weight)';
  }
}