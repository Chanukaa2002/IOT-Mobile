import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cw_app/features/client/model/container_item.dart';
import 'package:cw_app/features/client/service/rtdb_service.dart';
import 'package:cw_app/features/client/service/nutrition_service.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/core/utils/app_colors.dart';

class MealBoxPage extends StatefulWidget {
  const MealBoxPage({super.key});

  @override
  State<MealBoxPage> createState() => _MealBoxPageState();
}

class _MealBoxPageState extends State<MealBoxPage>
    with TickerProviderStateMixin {
  // Services
  final RtdbService _rtdbService = RtdbService();
  final NutritionService _nutritionService = NutritionService();
  final FirestoreService _firestoreService = FirestoreService();

  // UI State
  late TabController _tabController;
  double _currentTemperature = 0.0;
  bool _isAnalyzing = false;

  // Data State
  final Map<String, List<ContainerItem>> _mealItems = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  final Map<String, TextEditingController> _foodNameControllers = {};

  // Subscriptions
  StreamSubscription? _containerDataSubscription;
  StreamSubscription? _sensorDataSubscription;

  // List of meal types to create tabs. Must match the keys in _mealItems.
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mealTypes.length, vsync: this);

    // Start listening to data streams from Firebase.
    _listenToSensorData();
    _listenToContainerData();
  }

  /// Listens to the 'live' node in RTDB for temperature updates.
  void _listenToSensorData() {
    _sensorDataSubscription = _rtdbService.getSensorDataStream().listen((
      sensorData,
    ) {
      if (mounted) {
        setState(() {
          _currentTemperature = sensorData.temperature;
        });
      }
    });
  }

  void _listenToContainerData() {
    _containerDataSubscription = _rtdbService
        .getContainerWeightsStream()
        .listen(
          (data) {
            if (mounted) {
              setState(() {
                final normalizedFirebaseKeys = data.keys
                    .fold<Map<String, String>>({}, (map, key) {
                      final normalized = key
                          .toLowerCase()
                          .replaceAll('breckfast', 'breakfast')
                          .replaceAll('diner', 'dinner');
                      map[normalized] = key;
                      return map;
                    });

                for (var mealType in _mealTypes) {
                  final normalizedMealType = mealType.toLowerCase();
                  final firebaseKey =
                      normalizedFirebaseKeys[normalizedMealType];

                  if (firebaseKey != null && data.containsKey(firebaseKey)) {
                    final containerWeights = data[firebaseKey]!;
                    final List<ContainerItem> updatedItems = [];

                    containerWeights.forEach((id, weight) {
                      final newItem = ContainerItem(id: id, weight: weight);
                      final controllerKey = '$mealType-$id';

                      if (_foodNameControllers.containsKey(controllerKey)) {
                        newItem.foodName =
                            _foodNameControllers[controllerKey]!.text;
                      } else {
                        _foodNameControllers[controllerKey] =
                            TextEditingController();
                      }
                      updatedItems.add(newItem);
                    });

                    updatedItems.sort(
                      (a, b) => int.parse(a.id).compareTo(int.parse(b.id)),
                    );
                    _mealItems[mealType] = updatedItems;
                  } else {
                    _mealItems[mealType] = [];
                  }
                }
              });
            }
          },
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error connecting to container data.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _containerDataSubscription?.cancel();
    _sensorDataSubscription?.cancel();
    _foodNameControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  /// (UPDATED) Analyzes the meal for the CURRENTLY SELECTED TAB and resets its weights.
  Future<void> _analyzeCurrentMeal() async {
    // 1. Get the current meal type from the active tab.
    final String currentMealType = _mealTypes[_tabController.index];
    final List<ContainerItem> itemsToAnalyze =
        _mealItems[currentMealType] ?? [];

    // 2. NEW: Check if total weight is zero to prevent analysis of empty containers.
    final double sumOfWeights = itemsToAnalyze.fold(
      0.0,
      (sum, item) => sum + item.weight,
    );
    if (sumOfWeights <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot analyze an empty meal. Add weight to containers.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // 3. Gather items with entered food names from the current tab.
    final List<Map<String, dynamic>> mealPayload = [];
    double totalWeight = 0;

    for (var item in itemsToAnalyze) {
      final controllerKey = '$currentMealType-${item.id}';
      final controller = _foodNameControllers[controllerKey];
      if (controller != null && controller.text.trim().isNotEmpty) {
        item.foodName = controller.text.trim();
        mealPayload.add(item.toNutritionPayload());
        totalWeight += item.weight;
      }
    }

    if (mealPayload.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter food names for the items you want to analyze.',
            ),
          ),
        );
      }
      return;
    }

    // 4. Get User ID
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
      // 5. Call nutrition service
      final analysisResult = await _nutritionService.analyzeMeal(mealPayload);

      // 6. Prepare data for Firestore.
      final mealDataToSave = {
        'calories': analysisResult['total_calories'],
        'carbs': analysisResult['total_carbs'],
        'fats': analysisResult['total_fats'],
        'protein': analysisResult['total_protein'],
        'weight': totalWeight,
        'finishedAt': DateTime.now(),
        'mealType': currentMealType,
        'breakdown_by_food': analysisResult['breakdown'],
      };

      // 7. Save history and reset weights
      await _firestoreService.saveMealHistory(userId, mealDataToSave);

      // NEW: Reset the container weights in Firebase for the analyzed meal.
      await _rtdbService.resetMealContainerWeights(currentMealType);

      if (mounted) _showResultsDialog(analysisResult);

      // 8. Clear the text controllers for the current meal's items.
      setState(() {
        for (var item in itemsToAnalyze) {
          final controllerKey = '$currentMealType-${item.id}';
          _foodNameControllers[controllerKey]?.clear();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during analysis: $e'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3.0,
          tabs: _mealTypes.map((name) => Tab(text: name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            _mealTypes.map((mealType) {
              final items = _mealItems[mealType] ?? [];
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_tabController.index == 0) ...[
                        // Show status only on the first tab
                        _buildStatusCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildMealContainerList(mealType, items),
                      const SizedBox(height: 24),
                      _buildAnalysisButton(),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSensorDisplay(
            "Temperature",
            "${_currentTemperature.toStringAsFixed(1)} °C",
            Icons.thermostat_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMealContainerList(String mealType, List<ContainerItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'No containers detected for $mealType.\nAdd items to the physical containers to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      );
    }

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
          Text(
            '$mealType Ingredients',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              final controllerKey = '$mealType-${item.id}';
              final controller = _foodNameControllers[controllerKey];

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brightBlue.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '${item.weight.toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            item.weight > 0
                                ? AppColors.brightBlue
                                : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Food in Container ${item.id}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return SizedBox(
      width: double.infinity,
      child:
          _isAnalyzing
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                onPressed: _analyzeCurrentMeal, // UPDATED
                icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                label: const Text(
                  // UPDATED
                  'Analyze Current Meal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
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

  void _showResultsDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) {
        final breakdown = result['breakdown'] as List;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Nutritional Analysis Complete'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Calories: ${result['total_calories']?.toStringAsFixed(1)} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Carbohydrates: ${result['total_carbs']?.toStringAsFixed(1)}g',
                ),
                const SizedBox(height: 4),
                Text(
                  'Protein: ${result['total_protein']?.toStringAsFixed(1)}g',
                ),
                const SizedBox(height: 4),
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
