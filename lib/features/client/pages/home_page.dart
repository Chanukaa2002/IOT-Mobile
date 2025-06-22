import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/client/service/rtdb_service.dart';
import 'package:cw_app/features/client/model/sensor_data.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';
import 'package:cw_app/features/client/pages/meal_box_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RtdbService _rtdbService = RtdbService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMealBoxStatusCard(),
            const SizedBox(height: 16),
            _buildNutritionalSummaryCard(),
            const SizedBox(height: 16),
            _buildDailyGoalProgressCard(),
            const SizedBox(height: 16),
            _buildRealTimeMonitoringCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[800]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMealBoxStatusCard() {
    if (currentUser == null) {
      return _buildCard(
        title: 'Meal Box Status',
        icon: Icons.restaurant_menu_outlined,
        child: const Center(child: Text("Please log in.")),
      );
    }

    return _buildCard(
      title: 'Meal Box Status',
      icon: Icons.restaurant_menu_outlined,
      // Wrap the content with a StreamBuilder to listen for the meal count
      child: StreamBuilder<int>(
        stream: _firestoreService.getTodaysMealCountStream(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a simple loader while waiting for the first value
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get the meal count from the stream, default to 0
          final int mealCount = snapshot.data ?? 0;

          // Assuming a goal of 3 meals per day (Breakfast, Lunch, Dinner)
          final double progress = (mealCount / 3).clamp(0.0, 1.0);
          final int remainingMeals = (3 - mealCount).clamp(0, 3);
          final bool isEating = mealCount > 0 && mealCount < 3;

          return Column(
            children: [
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: progress, // Use the calculated progress
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      remainingMeals.toString(), // Show remaining meals
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const Text(
                      "Remaining \n\t   Meals",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                progressColor: AppColors.primaryBlue,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 16),
              // Show a status tag if eating is in progress
              if (isEating)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$mealCount of 3 meals complete",
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Your navigation logic here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MealBoxPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: const Text(
                    "Record Meal",
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildNutritionalSummaryCard() {
    if (currentUser == null) {
      return _buildCard(
        title: 'Nutritional Summary',
        icon: Icons.summarize_outlined,
        child: const Center(child: Text("Please log in to see your summary.")),
      );
    }

    return _buildCard(
      title: 'Nutritional Summary',
      icon: Icons.summarize_outlined,
      child: StreamBuilder<DailySummary>(
        stream: _firestoreService.getDailySummaryStream(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final summary = snapshot.data!;
            return Column(
              children: [
                const Text(
                  "Today's Intake",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "${summary.totalCalories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NutrientInfo(
                      icon: Icons.local_fire_department,
                      value: "${summary.totalCarbs.toStringAsFixed(0)} g",
                      label: "Carbs",
                      color: Colors.orange,
                    ),
                    _NutrientInfo(
                      icon: Icons.bolt,
                      value: "${summary.totalProtein.toStringAsFixed(0)} g",
                      label: "Proteins",
                      color: Colors.red,
                    ),
                    _NutrientInfo(
                      icon: Icons.water_drop,
                      value: "${summary.totalFats.toStringAsFixed(0)} g",
                      label: "Fats",
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            );
          }
          return const Center(child: Text("No meals recorded today."));
        },
      ),
    );
  }

  Widget _buildDailyGoalProgressCard() {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      title: 'Daily Goal Progress',
      icon: Icons.track_changes_outlined,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getGoalsStream(currentUser!.uid),
        builder: (context, goalsSnapshot) {
          if (goalsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (goalsSnapshot.hasError) {
            return Center(child: Text('Error: ${goalsSnapshot.error}'));
          }
          if (!goalsSnapshot.hasData || goalsSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Set a calorie goal to see progress."),
            );
          }

          final goals = {
            for (var doc in goalsSnapshot.data!.docs) doc.id: doc.data() as Map,
          };
          final calorieGoal = (goals['calories']?['target'] ?? 0).toDouble();

          return StreamBuilder<DailySummary>(
            stream: _firestoreService.getDailySummaryStream(currentUser!.uid),
            builder: (context, summarySnapshot) {
              final summary = summarySnapshot.data ?? DailySummary();

              final remainingCalories = (calorieGoal - summary.totalCalories)
                  .clamp(0.0, calorieGoal);
              final progress =
                  calorieGoal > 0
                      ? (summary.totalCalories / calorieGoal).clamp(0.0, 1.0)
                      : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Calories consumed vs. your daily target.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 18.0,
                    percent: progress,
                    progressColor: AppColors.primaryBlue,
                    backgroundColor: Colors.grey[200],
                    barRadius: const Radius.circular(50),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Legend(
                        color: AppColors.primaryBlue,
                        text:
                            "Consumed: ${summary.totalCalories.toStringAsFixed(0)} kcal",
                      ),
                      const Spacer(),
                      _Legend(
                        color: Colors.grey,
                        text:
                            "Remaining: ${remainingCalories.toStringAsFixed(0)} kcal",
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRealTimeMonitoringCard() {
    return _buildCard(
      title: 'Real-Time Monitoring',
      icon: Icons.sensors_outlined,
      child: StreamBuilder<SensorData>(
        stream: _rtdbService.getSensorDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final sensorData = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MonitoringInfo(
                  icon: Icons.thermostat_outlined,
                  value: "${sensorData.temperature.toStringAsFixed(1)} °C",
                  label: "Temperature",
                ),
                _MonitoringInfo(
                  icon: Icons.monitor_weight_outlined,
                  value: "${sensorData.liveWeight.toStringAsFixed(0)} g",
                  label: "Live Weight",
                ),
              ],
            );
          }
          return const Center(child: Text("Waiting for sensor data..."));
        },
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _NutrientInfo({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _MonitoringInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MonitoringInfo({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
