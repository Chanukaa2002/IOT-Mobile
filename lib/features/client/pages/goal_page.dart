import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/features/client/pages/goal_setting_page.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';
import 'package:cw_app/features/client/pages/food_recommendation_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _navigateToRecommendations(Map<String, dynamic> userGoals) {
    final goalsForRecommendation = {
      'Carbohydrates':
          (userGoals['carbohydrates']?['target'] ?? 0.0).toDouble(),
      'Protein': (userGoals['proteins']?['target'] ?? 0.0).toDouble(),
      'Fats': (userGoals['fats']?['target'] ?? 0.0).toDouble(),
      'Calories': (userGoals['calories']?['target'] ?? 0.0).toDouble(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FoodRecommendationPage(
              userGoals: {
                for (var key in goalsForRecommendation.keys)
                  key: goalsForRecommendation[key]?.toDouble() ?? 0.0,
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopStatusCard(),
            const SizedBox(height: 16),
            _buildNutrientGrid(),
            const SizedBox(height: 16),
            _buildActionCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatusCard() {
    if (currentUser == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Please log in.")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getGoalsStream(currentUser!.uid),
      builder: (context, goalsSnapshot) {
        if (!goalsSnapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final goals = {
          for (var doc in goalsSnapshot.data!.docs) doc.id: doc.data() as Map,
        };
        final weightGoal = (goals['weight']?['target'] ?? 0).toDouble();

        return StreamBuilder<DailySummary>(
          stream: _firestoreService.getDailySummaryStream(currentUser!.uid),
          builder: (context, summarySnapshot) {
            final latestWeight = summarySnapshot.data?.latestWeight ?? 0.0;
            final weightText =
                latestWeight > 0 ? latestWeight.toStringAsFixed(0) : '0';
            final progress =
                weightGoal > 0
                    ? (latestWeight / weightGoal).clamp(0.0, 1.0)
                    : 0.0;

            return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/core/assets/frosty_background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$weightText grams",
                      style: const TextStyle(
                        color: AppColors.brightBlue,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 10.0, color: Colors.black45),
                        ],
                      ),
                    ),
                    const Spacer(),
                    LinearPercentIndicator(
                      lineHeight: 10.0,
                      percent: progress,
                      progressColor: AppColors.brightBlue,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      barRadius: const Radius.circular(5),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${weightGoal.toStringAsFixed(0)} g',
                      style: const TextStyle(
                        color: AppColors.brightBlue,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(blurRadius: 2.0, color: Colors.black45),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutrientGrid() {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getGoalsStream(currentUser!.uid),
      builder: (context, goalsSnapshot) {
        if (goalsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!goalsSnapshot.hasData || goalsSnapshot.data!.docs.isEmpty) {
          return _buildEmptyGoalsState();
        }

        final goals = {
          for (var doc in goalsSnapshot.data!.docs) doc.id: doc.data() as Map,
        };
        final calorieGoal = (goals['calories']?['target'] ?? 0).toDouble();
        final proteinGoal = (goals['proteins']?['target'] ?? 0).toDouble();
        final carbsGoal = (goals['carbohydrates']?['target'] ?? 0).toDouble();
        final fatsGoal = (goals['fats']?['target'] ?? 0).toDouble();

        return StreamBuilder<DailySummary>(
          stream: _firestoreService.getDailySummaryStream(currentUser!.uid),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data ?? DailySummary();

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _NutrientCard(
                  label: 'Calories',
                  icon: Icons.local_fire_department_outlined,
                  value: summary.totalCalories.toStringAsFixed(0),
                  unit: 'kcal',
                  target: 'Target: ${calorieGoal.toStringAsFixed(0)}kcal',
                  progress:
                      calorieGoal > 0
                          ? (summary.totalCalories / calorieGoal).clamp(
                            0.0,
                            1.0,
                          )
                          : 0.0,
                  color: AppColors.primaryBlue,
                ),
                _NutrientCard(
                  label: 'Protein',
                  icon: Icons.bolt_outlined,
                  value: summary.totalProtein.toStringAsFixed(0),
                  unit: 'g',
                  target: 'Target: ${proteinGoal.toStringAsFixed(0)}g',
                  progress:
                      proteinGoal > 0
                          ? (summary.totalProtein / proteinGoal).clamp(0.0, 1.0)
                          : 0.0,
                  color: AppColors.primaryBlue,
                ),
                _NutrientCard(
                  label: 'Carbs',
                  icon: Icons.brunch_dining_outlined,
                  value: summary.totalCarbs.toStringAsFixed(0),
                  unit: 'g',
                  target: 'Target: ${carbsGoal.toStringAsFixed(0)}g',
                  progress:
                      carbsGoal > 0
                          ? (summary.totalCarbs / carbsGoal).clamp(0.0, 1.0)
                          : 0.0,
                  color: Colors.pinkAccent,
                ),
                _NutrientCard(
                  label: 'Fats',
                  icon: Icons.water_drop_outlined,
                  value: summary.totalFats.toStringAsFixed(0),
                  unit: 'g',
                  target: 'Target: ${fatsGoal.toStringAsFixed(0)}g',
                  progress:
                      fatsGoal > 0
                          ? (summary.totalFats / fatsGoal).clamp(0.0, 1.0)
                          : 0.0,
                  color: Colors.pinkAccent,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyGoalsState() {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalSettingsPage()),
          ),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryBlue,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                "Set Your Nutrition Goals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap here to get started.",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getGoalsStream(currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final goals = {
          for (var doc in snapshot.data!.docs) doc.id: doc.data() as Map,
        };

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
                  Icon(Icons.track_changes_outlined, color: Colors.grey[800]),
                  const SizedBox(width: 8),
                  const Text(
                    "Actions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // NEW: The recommendation button is added here
              ElevatedButton.icon(
                onPressed: () => _navigateToRecommendations(goals),
                icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                label: const Text("Get Food Recommendations"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalSettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text("Adjust Goals"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.grey[800],
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final IconData icon;
  final String label, value, unit, target;
  final double progress;
  final Color color;

  const _NutrientCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.target,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            target,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            progressColor: color,
            backgroundColor: Colors.grey[200],
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
