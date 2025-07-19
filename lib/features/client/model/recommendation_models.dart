class FoodSuggestion {
  final String food;
  final int weight;
  final String weightUnit;

  FoodSuggestion({
    required this.food,
    required this.weight,
    required this.weightUnit,
  });

  factory FoodSuggestion.fromJson(Map<String, dynamic> json) {
    return FoodSuggestion(
      food: json['food'] ?? 'Unknown Food',
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      weightUnit: json['weight_unit'] ?? 'g',
    );
  }
}

class NutrientRecommendation {
  final String nutrient;
  final List<FoodSuggestion> suggestions;

  NutrientRecommendation({required this.nutrient, required this.suggestions});

  factory NutrientRecommendation.fromJson(Map<String, dynamic> json) {
    var suggestionsList =
        (json['suggestions'] as List?)
            ?.map((item) => FoodSuggestion.fromJson(item))
            .toList() ??
        [];

    return NutrientRecommendation(
      nutrient: json['nutrient'] ?? 'Unknown Nutrient',
      suggestions: suggestionsList,
    );
  }
}
