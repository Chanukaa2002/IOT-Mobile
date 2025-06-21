import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:cw_app/core/utils/app_colors.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/core/utils/time_period.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userId;

  Map<String, double> _userGoals = {
    'calories': 2500,
    'carbs': 300,
    'protein': 150,
    'fats': 80,
  };

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _userId = _user?.uid;

    if (_userId != null) {
      _fetchUserGoals(_userId!);
    }
  }

  void _fetchUserGoals(String userId) {
    _firestoreService.getGoalsStream(userId).listen((snapshot) {
      if (snapshot.docs.isNotEmpty && mounted) {
        final newGoals = <String, double>{};
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('target')) {
            newGoals[doc.id] = (data['target'] as num).toDouble();
          }
        }
        if (mounted) {
          setState(() {
            _userGoals = newGoals;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nutritional History')),
        body: const Center(
          child: Text(
            'Please log in to view your history.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<double>(
              stream: _firestoreService.getTotalCalorieStream(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final totalCalories = snapshot.data ?? 0.0;

                return _buildTotalCaloriesCard(totalCalories);
              },
            ),
            const SizedBox(height: 24),
            WeightTrendCard(userId: _userId!),
            const SizedBox(height: 16),
            CalorieIntakeTrendCard(userId: _userId!),
            const SizedBox(height: 16),
            MacronutrientBreakdownCard(userId: _userId!, userGoals: _userGoals),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCaloriesCard(double totalCalories) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All-Time Calorie Intake',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.stars, color: Colors.orange.shade300),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${totalCalories.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const Text(
            'Your total calories consumed over the lifetime of your account.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class WeightTrendCard extends StatefulWidget {
  final String userId;
  const WeightTrendCard({super.key, required this.userId});

  @override
  State<WeightTrendCard> createState() => _WeightTrendCardState();
}

class _WeightTrendCardState extends State<WeightTrendCard> {
  final FirestoreService _firestoreService = FirestoreService();
  TimePeriod _timePeriod = TimePeriod.weekly;

  @override
  Widget build(BuildContext context) {
    return _buildChartCard(
      title: "Weight Trend",
      icon: Icons.monitor_weight_outlined,
      timePeriod: _timePeriod,
      onPeriodChanged: (period) => setState(() => _timePeriod = period),
      isDark: true,
      chart: StreamBuilder<List<DocumentSnapshot>>(
        stream: _firestoreService.getHistoryForPeriod(
          widget.userId,
          _timePeriod,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No weight data for this period.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final spots = _processDataForLineChart(snapshot.data!, 'weight');

          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine:
                    (value) => FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                getDrawingVerticalLine:
                    (value) => FlLine(
                      color: Colors.white.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                  isCurved: true,
                  color: Colors.white,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CalorieIntakeTrendCard extends StatefulWidget {
  final String userId;
  const CalorieIntakeTrendCard({super.key, required this.userId});

  @override
  State<CalorieIntakeTrendCard> createState() => _CalorieIntakeTrendCardState();
}

class _CalorieIntakeTrendCardState extends State<CalorieIntakeTrendCard> {
  final FirestoreService _firestoreService = FirestoreService();
  TimePeriod _timePeriod = TimePeriod.weekly;

  @override
  Widget build(BuildContext context) {
    return _buildChartCard(
      title: "Calorie Intake Trend",
      icon: Icons.show_chart,
      timePeriod: _timePeriod,
      onPeriodChanged: (period) => setState(() => _timePeriod = period),
      chart: StreamBuilder<List<DocumentSnapshot>>(
        stream: _firestoreService.getHistoryForPeriod(
          widget.userId,
          _timePeriod,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No calorie data for this period."),
            );
          }

          final spots = _processDataForLineChart(snapshot.data!, 'calories');

          return LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                  isCurved: true,
                  color: AppColors.primaryBlue,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryBlue.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MacronutrientBreakdownCard extends StatefulWidget {
  final String userId;
  final Map<String, double> userGoals;
  const MacronutrientBreakdownCard({
    super.key,
    required this.userId,
    required this.userGoals,
  });

  @override
  State<MacronutrientBreakdownCard> createState() =>
      _MacronutrientBreakdownCardState();
}

class _MacronutrientBreakdownCardState
    extends State<MacronutrientBreakdownCard> {
  final FirestoreService _firestoreService = FirestoreService();
  TimePeriod _timePeriod = TimePeriod.monthly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Macronutrient Totals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.pie_chart_outline, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          _CustomToggleButton(
            labels: const ['Today', 'Weekly', 'Monthly'],
            onPressed:
                (index) =>
                    setState(() => _timePeriod = TimePeriod.values[index]),
            selectedIndex: _timePeriod.index,
            isDark: false,
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<DocumentSnapshot>>(
            stream: _firestoreService.getHistoryForPeriod(
              widget.userId,
              _timePeriod,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 280,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 280,
                  child: Center(
                    child: Text("No nutritional data for this period."),
                  ),
                );
              }

              final totals = _calculateTotals(snapshot.data!);
              final barGroups = _createBarGroups(totals);
              final daysInPeriod = _getDaysInPeriod(_timePeriod);

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCircularStat(
                        percent: ((totals['carbs'] ?? 0) /
                                ((widget.userGoals['carbs'] ?? 1) *
                                    daysInPeriod))
                            .clamp(0.0, 1.0),
                        value: '${(totals['carbs'] ?? 0).toStringAsFixed(0)}g',
                        label: 'Carbs',
                        color: AppColors.primaryBlue,
                      ),
                      _buildCircularStat(
                        percent: ((totals['protein'] ?? 0) /
                                ((widget.userGoals['protein'] ?? 1) *
                                    daysInPeriod))
                            .clamp(0.0, 1.0),
                        value:
                            '${(totals['protein'] ?? 0).toStringAsFixed(0)}g',
                        label: 'Protein',
                        color: Colors.orange.shade400,
                      ),
                      _buildCircularStat(
                        percent: ((totals['fats'] ?? 0) /
                                ((widget.userGoals['fats'] ?? 1) *
                                    daysInPeriod))
                            .clamp(0.0, 1.0),
                        value: '${(totals['fats'] ?? 0).toStringAsFixed(0)}g',
                        label: 'Fats',
                        color: Colors.purple.shade300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: _getBarChartTitles,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          checkToShowHorizontalLine:
                              (value) => value % 100 == 0,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey[200]!,
                                strokeWidth: 1,
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
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

  Map<String, double> _calculateTotals(List<DocumentSnapshot> docs) {
    double totalCarbs = 0, totalProtein = 0, totalFats = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalCarbs += (data['carbs'] as num?) ?? 0;
      totalProtein += (data['protein'] as num?) ?? 0;
      totalFats += (data['fats'] as num?) ?? 0;
    }
    return {'carbs': totalCarbs, 'protein': totalProtein, 'fats': totalFats};
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> totals) {
    return [
      _makeGroupData(0, totals['carbs'] ?? 0, AppColors.primaryBlue),
      _makeGroupData(1, totals['protein'] ?? 0, Colors.orange),
      _makeGroupData(2, totals['fats'] ?? 0, Colors.purple),
    ];
  }

  int _getDaysInPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return 1;
      case TimePeriod.weekly:
        return 7;
      case TimePeriod.monthly:
        return 30;
    }
  }
}

Widget _buildChartCard({
  required String title,
  required IconData icon,
  required TimePeriod timePeriod,
  required ValueChanged<TimePeriod> onPeriodChanged,
  required Widget chart,
  Widget? legend,
  bool isDark = false,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.primaryBlue.withOpacity(0.9) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow:
          isDark
              ? []
              : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Icon(icon, color: isDark ? Colors.white70 : Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        _CustomToggleButton(
          labels: const ['Today', 'Weekly', 'Monthly'],
          onPressed: (index) => onPeriodChanged(TimePeriod.values[index]),
          selectedIndex: timePeriod.index,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        SizedBox(height: 180, child: chart),
        if (legend != null) ...[const SizedBox(height: 16), legend],
      ],
    ),
  );
}

List<FlSpot> _processDataForLineChart(
  List<DocumentSnapshot> docs,
  String field,
) {
  if (docs.isEmpty) return [];
  Map<int, double> dailyTotals = {};
  Map<int, int> dailyCounts = {};

  for (var doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = (data['finishedAt'] as Timestamp).toDate();
    final value = (data[field] as num?)?.toDouble() ?? 0.0;
    int dayKey = int.parse(DateFormat('D').format(timestamp));
    dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + value;
    if (field == 'weight') {
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
    }
  }

  if (field == 'weight') {
    dailyTotals.forEach((key, value) {
      dailyTotals[key] = value / dailyCounts[key]!;
    });
  }

  var sortedKeys = dailyTotals.keys.toList()..sort();
  return sortedKeys.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), dailyTotals[entry.value]!);
  }).toList();
}

BarChartGroupData _makeGroupData(int x, double y, Color color) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        color: color,
        width: 22,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
    ],
  );
}

Widget _getBarChartTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Text('Carbs', style: style);
      break;
    case 1:
      text = const Text('Protein', style: style);
      break;
    case 2:
      text = const Text('Fats', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }
  return SideTitleWidget(space: 4, child: text, meta: meta);
}

Widget _buildCircularStat({
  required double percent,
  required String value,
  required String label,
  required Color color,
}) {
  return Column(
    children: [
      CircularPercentIndicator(
        radius: 40.0,
        lineWidth: 8.0,
        percent: percent.isNaN ? 0.0 : percent,
        center: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        progressColor: color,
        backgroundColor: color.withOpacity(0.1),
        circularStrokeCap: CircularStrokeCap.round,
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );
}

class _CustomToggleButton extends StatelessWidget {
  final List<String> labels;
  final ValueChanged<int> onPressed;
  final int selectedIndex;
  final bool isDark;

  const _CustomToggleButton({
    required this.labels,
    required this.onPressed,
    required this.selectedIndex,
    this.isDark = false,
  });

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
                  color:
                      isSelected
                          ? (isDark ? Colors.white : AppColors.primaryBlue)
                          : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? (isDark ? AppColors.primaryBlue : Colors.white)
                              : (isDark ? Colors.white70 : Colors.grey[600]),
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
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
