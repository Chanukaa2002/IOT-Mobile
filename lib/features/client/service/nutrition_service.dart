import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NutritionService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  final String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<Map<String, dynamic>> analyzeMeal(
    List<Map<String, dynamic>> mealItems,
  ) async {
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
      if (_apiKey == "YOUR_GEMINI_API_KEY") {
        throw Exception(
          "Please replace 'YOUR_GEMINI_API_KEY' with your actual API key.",
        );
      }
      final response = await http.post(
        Uri.parse("$_url?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final jsonString =
            responseBody['candidates'][0]['content']['parts'][0]['text']
                .replaceAll("```json", "")
                .replaceAll("```", "")
                .trim();

        final nutritionalData = jsonDecode(jsonString);
        return _calculateTotals(nutritionalData);
      } else {
        throw Exception('Failed to get nutritional data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing meal: $e');
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
