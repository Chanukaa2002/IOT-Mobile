// lib/features/client/service/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DailySummary> getDailySummaryStream(String userId) {
    // Get the start and end of today
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    final query = _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .where('finishedAt', isGreaterThanOrEqualTo: startOfToday)
        .where('finishedAt', isLessThan: endOfToday);

    return query.snapshots().map((snapshot) {
      double totalCalories = 0;
      double totalCarbs = 0;
      double totalProtein = 0;
      double totalFats = 0;

      // Loop through each document returned by the query
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] as num?) ?? 0;
        totalCarbs += (data['carbs'] as num?) ?? 0;
        totalProtein += (data['protein'] as num?) ?? 0;
        totalFats += (data['fats'] as num?) ?? 0;
      }

      // Return a DailySummary object with the calculated totals.
      return DailySummary(
        totalCalories: totalCalories,
        totalCarbs: totalCarbs,
        totalProtein: totalProtein,
        totalFats: totalFats,
      );
    });
  }
}