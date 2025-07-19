import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cw_app/features/client/service/nutrition_service.dart';
import 'package:cw_app/features/client/model/recommendation_models.dart';
import 'package:cw_app/core/utils/app_colors.dart';

class FoodRecommendationPage extends StatefulWidget {
  final Map<String, double> userGoals;

  const FoodRecommendationPage({super.key, required this.userGoals});

  @override
  State<FoodRecommendationPage> createState() => _FoodRecommendationPageState();
}

class _FoodRecommendationPageState extends State<FoodRecommendationPage> {
  final NutritionService _nutritionService = NutritionService();
  List<NutrientRecommendation>? _recommendations;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecommendation();
  }

  Future<void> _fetchRecommendation() async {
    try {
      final result = await _nutritionService.getFoodRecommendation(
        widget.userGoals,
      );
      if (mounted) {
        setState(() {
          _recommendations = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Helper to get an icon based on the nutrient name
  IconData _getIconForNutrient(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'carbohydrates':
        return Icons.brunch_dining_outlined;
      case 'protein':
        return Icons.bolt_outlined;
      case 'fats':
        return Icons.water_drop_outlined;
      case 'calories':
        return Icons.local_fire_department_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Recommendations'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body:
          _isLoading
              ? _buildLoadingShimmer()
              : _error != null
              ? _buildErrorWidget()
              : _buildRecommendationList(),
    );
  }

  Widget _buildRecommendationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _recommendations?.length ?? 0,
      itemBuilder: (context, index) {
        final recommendation = _recommendations![index];
        return _buildRecommendationCard(recommendation);
      },
    );
  }

  Widget _buildRecommendationCard(NutrientRecommendation recommendation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForNutrient(recommendation.nutrient),
                  color: AppColors.brightBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  "To Reach ${recommendation.nutrient} Goal",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Display each food suggestion
            ...recommendation.suggestions.map((suggestion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(suggestion.food, style: const TextStyle(fontSize: 16)),
                    Text(
                      "${suggestion.weight}${suggestion.weightUnit}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brightBlue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // Modern loading effect
  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3, // Show 3 shimmer cards
        itemBuilder:
            (_, __) => Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 200, height: 24.0, color: Colors.white),
                    const Divider(height: 24),
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
