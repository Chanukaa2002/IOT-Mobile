/// Represents a single food container with its weight and assigned food name.
class ContainerItem {
  final String id; 
  double weight; 
  String foodName; 

  ContainerItem({
    required this.id,
    required this.weight,
    this.foodName = '', 
  });


  Map<String, dynamic> toNutritionPayload() {
    return {'food': foodName, 'weight': weight};
  }
}
