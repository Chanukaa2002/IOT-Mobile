import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  // State for the selected tab in the bottom nav bar

  // State variables for each goal
  int _weightGoal = 75;
  int _calorieGoal = 2000;
  int _carbsGoal = 250;
  int _proteinsGoal = 100;
  int _fatsGoal = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () {
            // TODO: Handle navigation back
          },
        ),
        title: Text(
          'Daily Goal Settings',
          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Set Your Daily Nutrition Goals',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Customize your daily targets for weight, calories, and macronutrients to align with your health journey.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 24),
              
              // Reusable card for each goal setting
              _buildGoalSettingCard(
                icon: Icons.monitor_weight_outlined,
                title: 'Weight Goal',
                value: _weightGoal,
                unit: 'kg',
                onDecrement: () => setState(() => _weightGoal--),
                onIncrement: () => setState(() => _weightGoal++),
                percent: 0.5, // Example percentage
              ),
              _buildGoalSettingCard(
                icon: Icons.local_fire_department_outlined,
                title: 'Calorie Goal',
                value: _calorieGoal,
                unit: 'kcal',
                onDecrement: () => setState(() => _calorieGoal -= 50),
                onIncrement: () => setState(() => _calorieGoal += 50),
                percent: 0.4, // Example percentage
              ),
               _buildGoalSettingCard(
                icon: Icons.brunch_dining_outlined,
                title: 'Carbohydrates',
                value: _carbsGoal,
                unit: 'g',
                onDecrement: () => setState(() => _carbsGoal -= 5),
                onIncrement: () => setState(() => _carbsGoal += 5),
                percent: 0.5, // Example percentage
              ),
              _buildGoalSettingCard(
                icon: Icons.bolt_outlined,
                title: 'Proteins',
                value: _proteinsGoal,
                unit: 'g',
                onDecrement: () => setState(() => _proteinsGoal -= 5),
                onIncrement: () => setState(() => _proteinsGoal += 5),
                percent: 0.4, // Example percentage
              ),
              _buildGoalSettingCard(
                icon: Icons.water_drop_outlined,
                title: 'Fats',
                value: _fatsGoal,
                unit: 'g',
                onDecrement: () => setState(() => _fatsGoal -= 2),
                onIncrement: () => setState(() => _fatsGoal += 2),
                percent: 0.47, // Example percentage
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Save Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
               const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // The "sticky" bottom navigation bar
      //  bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Goals'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
      //     BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Meal Box'),
      //   ],
      //   currentIndex: _selectedIndex, // Set to 1 for Goals
      //   selectedItemColor: AppColors.primaryBlue,
      //   unselectedItemColor: Colors.grey[600],
      //   onTap: (index) => setState(() => _selectedIndex = index),
      //   type: BottomNavigationBarType.fixed,
      //   showUnselectedLabels: true,
      // ),
    );
  }

  // --- Reusable widget for the goal setting cards ---
  Widget _buildGoalSettingCard({
    required IconData icon,
    required String title,
    required int value,
    required String unit,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required double percent,
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '$value ',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.brightBlue),
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
                // Decrement Button
                _buildIncrementDecrementButton(icon: Icons.remove, onPressed: onDecrement),
                const SizedBox(width: 16),
                // Text Field showing the value
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: value.toString()),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                // Increment Button
                _buildIncrementDecrementButton(icon: Icons.add, onPressed: onIncrement),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 8.0,
              percent: percent,
              progressColor: AppColors.brightBlue,
              backgroundColor: Colors.grey[200],
              barRadius: const Radius.circular(4),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              '${(percent * 100).toInt()}% of Goal',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the circular +/- buttons
  Widget _buildIncrementDecrementButton({required IconData icon, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.grey[700]),
    );
  }
}