import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // State for the selected tab in the bottom nav bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // The AppBar at the top of the screen
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
              // Replace with your user's profile image
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
        ],
      ),
      // The main content of the screen is a scrollable list of cards
      body: SingleChildScrollView(
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
              const SizedBox(height: 16),
              _buildUpcomingMealCard(),
            ],
          ),
        ),
      ),
      // The "sticky" bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Meal Box',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type:
            BottomNavigationBarType.fixed, // Ensures labels are always visible
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Helper methods to build each card ---

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
    return _buildCard(
      title: 'Meal Box Status',
      icon: Icons.restaurant_menu_outlined,
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 15.0,
            percent: 0.7, // 250g / (total weight) - example
            center: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "250",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
                Text("Remaining", style: TextStyle(color: Colors.grey)),
              ],
            ),
            progressColor: AppColors.primaryBlue,
            backgroundColor: Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Eating in Progress",
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
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
      ),
    );
  }

  Widget _buildNutritionalSummaryCard() {
    return _buildCard(
      title: 'Nutritional Summary',
      icon: Icons.summarize_outlined,
      child: Column(
        children: [
          const Text("Today's Intake", style: TextStyle(color: Colors.grey)),
          const Text(
            "1850 kcal",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientInfo(
                icon: Icons.local_fire_department,
                value: "220 g",
                label: "Carbs",
                color: Colors.orange,
              ),
              _NutrientInfo(
                icon: Icons.bolt,
                value: "85 g",
                label: "Proteins",
                color: Colors.red,
              ),
              _NutrientInfo(
                icon: Icons.water_drop,
                value: "60 g",
                label: "Fats",
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalProgressCard() {
    return _buildCard(
      title: 'Daily Goal Progress',
      icon: Icons.track_changes_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Calories consumed vs. your daily target.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 18.0,
            percent: 1850 / (1850 + 650), // Consumed / Total
            progressColor: AppColors.primaryBlue,
            backgroundColor: Colors.grey[200],
            barRadius: const Radius.circular(50),
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
        ],
      ),
    );
  }

  Widget _buildRealTimeMonitoringCard() {
    return _buildCard(
      title: 'Real-Time Monitoring',
      icon: Icons.sensors_outlined,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MonitoringInfo(
            icon: Icons.thermostat_outlined,
            value: "4 °C",
            label: "Temperature",
          ),
          _MonitoringInfo(
            icon: Icons.monitor_weight_outlined,
            value: "870 g",
            label: "Live Weight",
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMealCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Meal: Lunch",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text("Ready To Start", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Empty - Add food to begin!",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                "Start Meal",
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
      ),
    );
  }
}

// --- Custom sub-widgets for cards to avoid repetition ---

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
