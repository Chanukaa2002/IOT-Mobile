import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';
import 'package:cw_app/core/utils/time_period.dart';
// Make sure this enum is accessible

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a real-time summary for the current day.
  Stream<DailySummary> getDailySummaryStream(String userId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    final query = _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .where('finishedAt', isGreaterThanOrEqualTo: startOfToday)
        .where('finishedAt', isLessThan: endOfToday)
        .orderBy('finishedAt', descending: true);

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return DailySummary();
      }

      double totalCalories = 0, totalCarbs = 0, totalProtein = 0, totalFats = 0;
      final latestMealData = snapshot.docs.first.data();
      double latestWeight =
          (latestMealData['weight'] as num?)?.toDouble() ?? 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] as num?) ?? 0;
        totalCarbs += (data['carbs'] as num?) ?? 0;
        totalProtein += (data['protein'] as num?) ?? 0;
        totalFats += (data['fats'] as num?) ?? 0;
      }

      return DailySummary(
        totalCalories: totalCalories,
        totalCarbs: totalCarbs,
        totalProtein: totalProtein,
        totalFats: totalFats,
        latestWeight: latestWeight,
      );
    });
  }

  Stream<double> getTotalCalorieStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return 0.0;
          }

          double totalCalories = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            totalCalories += (data['calories'] as num?) ?? 0;
          }
          return totalCalories;
        });
  }

  /// Fetches historical data for a given time period.
  Stream<List<DocumentSnapshot>> getHistoryForPeriod(
    String userId,
    TimePeriod period,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case TimePeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimePeriod.weekly:
        // Go back 6 days to get a total of 7 days including today
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        break;
      case TimePeriod.monthly:
        // Go back 29 days to get a total of 30 days
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 29));
        break;
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .where(
          'finishedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .orderBy('finishedAt', descending: false) // oldest first for charts
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// Fetches the user's nutritional goals.
  Stream<QuerySnapshot> getGoalsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots();
  }

  /// Saves user goals (unchanged from your original code).
  Future<void> saveUserGoals(String userId, Map<String, int> goals) async {
    final userDocRef = _firestore.collection('users').doc(userId);
    final batch = _firestore.batch();
    goals.forEach((goalName, targetValue) {
      final goalDocRef = userDocRef.collection('goals').doc(goalName);
      batch.set(goalDocRef, {'target': targetValue});
    });
    await batch.commit();
  }
}
