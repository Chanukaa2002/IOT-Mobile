import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {
    'weight': TextEditingController(text: '75000'),
    'calories': TextEditingController(text: '2000'),
    'carbohydrates': TextEditingController(text: '250'),
    'proteins': TextEditingController(text: '100'),
    'fats': TextEditingController(text: '70'),
  };

  @override
  void initState() {
    super.initState();
    _fetchAndSetCurrentUserGoals();
  }

  Future<void> _fetchAndSetCurrentUserGoals() async {
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final goalsSnapshot =
          await _firestoreService.getGoalsStream(currentUser!.uid).first;
      if (goalsSnapshot.docs.isNotEmpty && mounted) {
        final goals = {
          for (var doc in goalsSnapshot.docs) doc.id: doc.data() as Map,
        };

        _controllers['weight']?.text =
            (goals['weight']?['target'] ?? 75000).toString();
        _controllers['calories']?.text =
            (goals['calories']?['target'] ?? 2000).toString();
        _controllers['carbohydrates']?.text =
            (goals['carbohydrates']?['target'] ?? 250).toString();
        _controllers['proteins']?.text =
            (goals['proteins']?['target'] ?? 100).toString();
        _controllers['fats']?.text =
            (goals['fats']?['target'] ?? 70).toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not load saved goals: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _handleSaveGoals() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, int> goalsData = {
        'weight': int.tryParse(_controllers['weight']!.text) ?? 0,
        'calories': int.tryParse(_controllers['calories']!.text) ?? 0,
        'carbohydrates': int.tryParse(_controllers['carbohydrates']!.text) ?? 0,
        'proteins': int.tryParse(_controllers['proteins']!.text) ?? 0,
        'fats': int.tryParse(_controllers['fats']!.text) ?? 0,
      };

      await _firestoreService
          .saveUserGoals(currentUser!.uid, goalsData)
          .timeout(const Duration(seconds: 20));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Goals saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection timed out."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save goals: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Daily Goal Settings',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Set Your Daily Nutrition Goals',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Customize your daily targets for weight, calories, and macronutrients to align with your health journey.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      _buildGoalSettingCard(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Weight Goal',
                        unit: 'g', // Changed unit
                        controller: _controllers['weight']!,
                        incrementAmount: 1000,
                      ),
                      _buildGoalSettingCard(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Calorie Goal',
                        unit: 'kcal',
                        controller: _controllers['calories']!,
                        incrementAmount: 50,
                      ),
                      _buildGoalSettingCard(
                        icon: Icons.brunch_dining_outlined,
                        title: 'Carbohydrates',
                        unit: 'g',
                        controller: _controllers['carbohydrates']!,
                        incrementAmount: 10,
                      ),
                      _buildGoalSettingCard(
                        icon: Icons.bolt_outlined,
                        title: 'Proteins',
                        unit: 'g',
                        controller: _controllers['proteins']!,
                        incrementAmount: 5,
                      ),
                      _buildGoalSettingCard(
                        icon: Icons.water_drop_outlined,
                        title: 'Fats',
                        unit: 'g',
                        controller: _controllers['fats']!,
                        incrementAmount: 5,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSaveGoals,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text(
                                    'Save Goals',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildGoalSettingCard({
    required IconData icon,
    required String title,
    required String unit,
    required TextEditingController controller,
    required int incrementAmount,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.text} ',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brightBlue,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIncrementDecrementButton(
                  icon: Icons.remove,
                  controller: controller,
                  amount: -incrementAmount,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged:
                        (value) => setState(
                          () {},
                        ), // Redraws the UI to update the value display above
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildIncrementDecrementButton(
                  icon: Icons.add,
                  controller: controller,
                  amount: incrementAmount,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementDecrementButton({
    required IconData icon,
    required TextEditingController controller,
    required int amount,
  }) {
    return OutlinedButton(
      onPressed: () {
        final currentValue = int.tryParse(controller.text) ?? 0;
        // Ensure the value doesn't go below zero
        final newValue = (currentValue + amount).clamp(0, 999999);
        setState(() {
          controller.text = newValue.toString();
        });
      },
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.grey[700]),
    );
  }
}
