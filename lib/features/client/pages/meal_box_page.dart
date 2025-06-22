import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cw_app/features/client/model/sensor_data.dart';
import 'package:cw_app/features/client/model/meal_item.dart';
import 'package:cw_app/features/client/service/rtdb_service.dart';
import 'package:cw_app/features/client/service/nutrition_service.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/core/utils/app_colors.dart';

class MealBoxPage extends StatefulWidget {
  const MealBoxPage({super.key});

  @override
  State<MealBoxPage> createState() => _MealBoxPageState();
}

class _MealBoxPageState extends State<MealBoxPage> {
  final TextEditingController _mealTypeController = TextEditingController();

  final RtdbService _rtdbService = RtdbService();
  final NutritionService _nutritionService = NutritionService();
  final FirestoreService _firestoreService = FirestoreService();

  final List<MealItem> _currentMealItems = [];
  double _lastTotalWeight = 0.0;
  double _currentLiveWeight = 0.0;
  double _currentTemperature = 0.0;
  StreamSubscription<SensorData>? _sensorDataSubscription;

  // UI State
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _sensorDataSubscription = _rtdbService.getSensorDataStream().listen(
      (sensorData) {
        setState(() {
          _currentLiveWeight = sensorData.liveWeight;
          _currentTemperature = sensorData.temperature;
        });
      },
      onError: (error) {
        print("Error listening to sensor data: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error connecting to live data.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _mealTypeController.dispose();
    _sensorDataSubscription?.cancel();
    super.dispose();
  }

  void _addMealItem() {
    final String mealName = _mealTypeController.text;
    if (mealName.isEmpty || _currentMealItems.length >= 4) return;

    setState(() {
      final double ingredientWeight = _currentLiveWeight - _lastTotalWeight;
      _currentMealItems.add(
        MealItem(
          name: mealName,
          weight: ingredientWeight > 0 ? ingredientWeight : 0.0,
        ),
      );
      _lastTotalWeight = _currentLiveWeight;
      _mealTypeController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void _removeLastMealItem() {
    if (_currentMealItems.isEmpty) return;
    setState(() {
      _currentMealItems.clear();
      _lastTotalWeight = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Meal items cleared to ensure accurate weights."),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  Future<void> _startNewMealSessionAndAnalyze() async {
    if (_currentMealItems.isEmpty) return;

    // Get the current user's unique ID
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Not logged in! Cannot save history.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final mealPayload =
          _currentMealItems.map((item) => item.toJson()).toList();
      final analysisResult = await _nutritionService.analyzeMeal(mealPayload);

      final mealDataToSave = {
        'calories': analysisResult['total_calories'],
        'carbs': analysisResult['total_carbs'],
        'fats': analysisResult['total_fats'],
        'protein': analysisResult['total_protein'],
        'weight': _lastTotalWeight,
        'finishedAt': DateTime.now(),
      };

      await _firestoreService.saveMealHistory(userId, mealDataToSave);

      if (mounted) _showResultsDialog(analysisResult);

      setState(() {
        _currentMealItems.clear();
        _lastTotalWeight = 0.0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMealSessionCard(),
              const SizedBox(height: 24),
              _buildAddMealTypeCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSensorDisplay(
                "Temperature",
                "${_currentTemperature.toStringAsFixed(1)} °C",
                Icons.thermostat,
              ),
              _buildSensorDisplay(
                "Live Weight",
                "${_currentLiveWeight.toStringAsFixed(1)} g",
                Icons.scale,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'Add ingredients below, then press Start to analyze.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (_isAnalyzing)
            const CircularProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed:
                  _currentMealItems.isNotEmpty
                      ? _startNewMealSessionAndAnalyze
                      : null,
              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
              label: const Text(
                'Start & Analyze',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSensorDisplay(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.brightBlue, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAddMealTypeCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Meal Ingredient',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                _currentMealItems
                    .map(
                      (item) => Chip(
                        label: Text(
                          '${item.name} (${item.weight.toStringAsFixed(1)}g)',
                        ),
                        onDeleted: _removeLastMealItem,
                        labelStyle: const TextStyle(
                          color: AppColors.brightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.blue.shade50,
                        side: BorderSide(
                          color: AppColors.brightBlue.withOpacity(0.5),
                        ),
                      ),
                    )
                    .toList(),
          ),
          if (_currentMealItems.isNotEmpty) const SizedBox(height: 16),
          if (_currentMealItems.length < 4) ...[
            TextField(
              controller: _mealTypeController,
              decoration: InputDecoration(
                hintText: 'e.g., Rice, Meat, Fish...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addMealItem,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  'Maximum of 4 ingredients added.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showResultsDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) {
        final breakdown = result['breakdown'] as List;
        return AlertDialog(
          title: const Text('Nutritional Analysis Complete'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Calories: ${result['total_calories']?.toStringAsFixed(1)} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Carbs: ${result['total_carbs']?.toStringAsFixed(1)}g'),
                Text(
                  'Protein: ${result['total_protein']?.toStringAsFixed(1)}g',
                ),
                Text('Fats: ${result['total_fats']?.toStringAsFixed(1)}g'),
                const Divider(height: 24),
                const Text(
                  'Ingredient Breakdown:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...breakdown.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '• ${item['food_name']}: ${item['calories']?.toStringAsFixed(1)} kcal',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
