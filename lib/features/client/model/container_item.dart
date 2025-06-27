/// Represents a single food container with its weight and assigned food name.
class ContainerItem {
  final String id; // The container number, e.g., "1", "2"
  double weight; // The weight of the food in the container
  String foodName; // The name entered by the user, e.g., "Rice"

  ContainerItem({
    required this.id,
    required this.weight,
    this.foodName = '', // Starts as empty until the user types a name.
  });

  /// Creates a map suitable for the nutrition analysis service payload.
  Map<String, dynamic> toNutritionPayload() {
    return {'food': foodName, 'weight': weight};
  }
}
