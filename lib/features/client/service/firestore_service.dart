import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';
import 'package:cw_app/core/utils/time_period.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
   Future<void> saveMealHistory(String userId, Map<String, dynamic> mealData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(mealData);
    } catch (e) {
      throw Exception('Error saving meal history: $e');
    }
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
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        break;
      case TimePeriod.monthly:
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
        .orderBy('finishedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<QuerySnapshot> getGoalsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots();
  }

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
