import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
// Adjust this import path to point to your AppColors file
import 'package:cw_app/core/utils/app_colors.dart';

// Enum to manage the state of the toggle buttons for time periods
enum TimePeriod { today, weekly, monthly }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedIndex = 2; // Set to 2 for the "History" tab

  // State for the toggle buttons
  TimePeriod _weightTrendPeriod = TimePeriod.weekly;
  TimePeriod _calorieTrendPeriod = TimePeriod.weekly;
  TimePeriod _macroTrendPeriod = TimePeriod.monthly;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey[800]),
          onPressed: () {},
        ),
        title: Text('Nutritional History', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800]),
            onPressed: () {},
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalCaloriesCard(),
              const SizedBox(height: 24),
              _buildTotalNutritionalsSection(),
              const SizedBox(height: 16),
              _buildWeightTrendCard(),
              const SizedBox(height: 16),
              _buildCalorieIntakeTrendCard(),
              const SizedBox(height: 16),
              _buildMacronutrientBreakdownCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Meal Box'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  // --- Card Builder Methods ---

  Widget _buildTotalCaloriesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Calories Consumed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.insights, color: Colors.blue.shade300),
            ],
          ),
          const SizedBox(height: 8),
          const Text('15900 kcal', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const Text('Your total caloric intake for today.', style: TextStyle(color: Colors.grey)),
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.4), FlSpot(3, 3.4),
                      FlSpot(4, 2), FlSpot(5, 2.2), FlSpot(6, 1.8),
                    ],
                    isCurved: true,
                    color: AppColors.primaryBlue.withOpacity(0.5),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalNutritionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total Nutritionals Consumed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCircularStat(percent: 0.6, value: '120 g', label: 'Carbs', color: AppColors.primaryBlue),
            _buildCircularStat(percent: 0.5, value: '50 g', label: 'Protein', color: Colors.orange.shade300),
            _buildCircularStat(percent: 0.2, value: '10 g', label: 'Fats', color: Colors.purple.shade200),
          ],
        )
      ],
    );
  }
  
  Widget _buildWeightTrendCard() {
    return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Weight Trend', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _CustomToggleButton(
            labels: const ['Today', 'Weekly', 'Monthly'],
            onPressed: (index) => setState(() => _weightTrendPeriod = TimePeriod.values[index]),
            selectedIndex: _weightTrendPeriod.index,
            isDark: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.2), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.white.withOpacity(0.2), strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                   LineChartBarData(
                     spots: const [ // This data would change based on _weightTrendPeriod
                       FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4),
                     ],
                     isCurved: true,
                     color: Colors.white,
                     barWidth: 4,
                     isStrokeCapRound: true,
                     dotData: const FlDotData(show: false),
                     belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.2)),
                   ),
                ]
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalorieIntakeTrendCard() {
     return _buildChartCard(
      title: "Calorie Intake Trend",
      icon: Icons.show_chart,
      timePeriod: _calorieTrendPeriod,
      onPeriodChanged: (period) => setState(() => _calorieTrendPeriod = period),
      chart: LineChart(
        LineChartData( /* ... Chart Data ... */ ) // Placeholder for dynamic chart
      )
     );
  }

  Widget _buildMacronutrientBreakdownCard() {
    return _buildChartCard(
      title: "Macronutrient Breakdown",
      icon: Icons.settings_outlined,
      timePeriod: _macroTrendPeriod,
      onPeriodChanged: (period) => setState(() => _macroTrendPeriod = period),
      chart: BarChart(
         BarChartData( /* ... Chart Data ... */) // Placeholder for dynamic chart
      ),
      legend: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Legend(color: Colors.red, text: "Protein"),
          SizedBox(width: 16),
          _Legend(color: Colors.blue, text: "Carbs"),
          SizedBox(width: 16),
          _Legend(color: Colors.purple, text: "Fats"),
        ],
      )
    );
  }

  // --- Helper & Custom Widgets ---

   Widget _buildCircularStat({required double percent, required String value, required String label, required Color color}) {
    return CircularPercentIndicator(
      radius: 45.0,
      lineWidth: 8.0,
      percent: percent,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
      progressColor: color,
      backgroundColor: color.withOpacity(0.1),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required TimePeriod timePeriod,
    required ValueChanged<TimePeriod> onPeriodChanged,
    required Widget chart,
    Widget? legend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(icon, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          _CustomToggleButton(
            labels: const ['Today', 'Weekly', 'Monthly'],
            onPressed: (index) => onPeriodChanged(TimePeriod.values[index]),
            selectedIndex: timePeriod.index,
          ),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: chart),
          if (legend != null) ...[
            const SizedBox(height: 16),
            legend,
          ]
        ],
      ),
    );
  }
}

// Custom Toggle Button for a nicer look
class _CustomToggleButton extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<int> onPressed;
  final int selectedIndex;
  final bool isDark;

  const _CustomToggleButton({required this.labels, required this.onPressed, required this.selectedIndex, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.15) : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPressed(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? Colors.white : AppColors.primaryBlue) : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? (isDark ? AppColors.primaryBlue : Colors.white) : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.grey)),
    ]);
  }
}