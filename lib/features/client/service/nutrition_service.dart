import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cw_app/features/client/model/recommendation_models.dart';

class NutritionService {
  static final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: _apiKey ?? '',
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    ],
  );

  Future<Map<String, dynamic>> analyzeMeal(
    List<Map<String, dynamic>> mealItems,
  ) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API Key not found. Please check your .env file.');
    }

    final foodListString = mealItems
        .map((item) => "${item['weight']}g of ${item['food']}")
        .join(', ');

    final prompt = """
    You are a nutrition analysis expert. Analyze the following list of food items and their weights.
    For each item, provide the estimated total calories (kcal), carbohydrates (g), protein (g), and fats (g).

    Food list: $foodListString

    Return the result ONLY as a valid JSON object with a single key "ingredients". 
    "ingredients" should be an array of objects. Each object must have these exact keys: 
    "food_name" (string), "calories" (number), "carbs_g" (number), "protein_g" (number), "fats_g" (number).
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Failed to get an analysis from the API.');
      }

      final jsonString =
          response.text!.replaceAll("```json", "").replaceAll("```", "").trim();

      final nutritionalData = jsonDecode(jsonString);
      return _calculateTotals(nutritionalData);
    } catch (e) {
      print('Error analyzing meal: $e');
      throw Exception('Gemini API Error: $e');
    }
  }

  Future<List<NutrientRecommendation>> getFoodRecommendation(
    Map<String, double> goals,
  ) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API Key not found.');
    }

    final goalsString = goals.entries
        .map((entry) => '${entry.key}: ${entry.value.toStringAsFixed(0)}g')
        .join(', ');
    final prompt = """
    You are a nutrition data expert. My nutritional goals for my next meal are: $goalsString.
    Based on these goals, provide food suggestions.

    Return the result ONLY as a valid JSON object with a single key "recommendations".
    "recommendations" should be an array of objects.
    Each object must represent a single nutrient goal and have these exact keys:
    - "nutrient": A string (e.g., "Carbohydrates", "Protein").
    - "suggestions": An array of food suggestion objects.
    
    Each food suggestion object must have these exact keys:
    - "food": A string (e.g., "Brown Rice").
    - "weight": A number representing the suggested portion size in grams.
    - "weight_unit": The string "g".
    
    Provide 2-3 suggestions for each nutrient goal. Do not include any text, greetings, or explanations outside of the JSON object.
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('Failed to get a recommendation from the API.');
      }

      final jsonString =
          response.text!.replaceAll("```json", "").replaceAll("```", "").trim();

      final decodedJson = jsonDecode(jsonString);
      final List<dynamic> recommendationList = decodedJson['recommendations'];

      return recommendationList
          .map((item) => NutrientRecommendation.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting food recommendation: $e');
      throw Exception('Gemini API Error: $e');
    }
  }

  Map<String, dynamic> _calculateTotals(Map<String, dynamic> nutritionalData) {
    double totalCalories = 0.0;
    double totalCarbs = 0.0;
    double totalProtein = 0.0;
    double totalFats = 0.0;

    List ingredients = nutritionalData['ingredients'];

    for (var item in ingredients) {
      totalCalories += (item['calories'] as num?) ?? 0;
      totalCarbs += (item['carbs_g'] as num?) ?? 0;
      totalProtein += (item['protein_g'] as num?) ?? 0;
      totalFats += (item['fats_g'] as num?) ?? 0;
    }

    return {
      'total_calories': totalCalories,
      'total_carbs': totalCarbs,
      'total_protein': totalProtein,
      'total_fats': totalFats,
      'breakdown': ingredients,
    };
  }
}
