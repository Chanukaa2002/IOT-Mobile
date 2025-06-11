import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  // Set the initial index to 1 for the "Goals" tab


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // The AppBar is identical to the HomePage
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {}, // TODO: Handle drawer opening
        ),
        title: Text(
          'EATRO',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            onPressed: () {}, // TODO: Handle notifications
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
        ],
      ),
      // Scrollable body content
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTopStatusCard(),
              const SizedBox(height: 16),
              _buildNutrientGrid(),
              const SizedBox(height: 16),
              _buildDailyGoalProgressCard(),
            ],
          ),
        ),
      ),
      // The "sticky" bottom navigation bar
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.track_changes),
      //       label: 'Goals',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.history_outlined),
      //       label: 'History',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.inventory_2_outlined),
      //       label: 'Meal Box',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: AppColors.primaryBlue,
      //   unselectedItemColor: Colors.grey[600],
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   showUnselectedLabels: true,
      // ),
    );
  }

  // --- Helper methods to build each section ---

  Widget _buildTopStatusCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Make sure you have this image in core/assets/
            image: AssetImage('lib/core/assets/frosty_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "450 grams",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black45)],
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thermostat, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    "25°C, Optimal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(blurRadius: 8.0, color: Colors.black45)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientGrid() {
    // Using GridView.count to create a 2x2 grid automatically
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap:
          true, // Important to use GridView inside a SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1, // Adjust ratio to make cards look good
      children: [
        _NutrientCard(
          icon: Icons.local_fire_department_outlined,
          label: 'Calories',
          value: '1250',
          unit: 'kcal',
          target: 'Target: 2000kcal',
          progress: 1250 / 2000,
          color: Colors.lightBlue,
        ),
        _NutrientCard(
          icon: Icons.bolt_outlined,
          label: 'Protein',
          value: '75',
          unit: 'g',
          target: 'Target: 100g',
          progress: 75 / 100,
          color: Colors.lightBlue,
        ),
        _NutrientCard(
          icon: Icons.brunch_dining_outlined,
          label: 'Carbs',
          value: '150',
          unit: 'g',
          target: 'Target: 250g',
          progress: 150 / 250,
          color: Colors.pinkAccent,
        ),
        _NutrientCard(
          icon: Icons.water_drop_outlined,
          label: 'Fats',
          value: '40',
          unit: 'g',
          target: 'Target: 60g',
          progress: 40 / 60,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildDailyGoalProgressCard() {
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
                "Daily Goal Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Calories consumed vs. your daily target.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 18.0,
            percent: 1850 / (1850 + 650),
            progressColor: AppColors.primaryBlue,
            backgroundColor: Colors.grey[200],
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _Legend(
                color: AppColors.primaryBlue,
                text: "Consumed: 1850 kcal",
              ),
              SizedBox(width: 5),
              _Legend(color: Colors.grey, text: "Remaining: 650 kcal"),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            label: const Text("Adjust Goals"),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: Colors.grey[800],
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom sub-widgets for cards to avoid repetition ---

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
