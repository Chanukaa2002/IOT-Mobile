import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cw_app/features/client/model/daily_summary.dart';

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
        .orderBy(
          'finishedAt',
          descending: true,
        );

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return DailySummary();
      }

      double totalCalories = 0;
      double totalCarbs = 0;
      double totalProtein = 0;
      double totalFats = 0;

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

  Future<void> saveUserGoals(String userId, Map<String, int> goals) async {
    final userDocRef = _firestore.collection('users').doc(userId);

    final batch = _firestore.batch();

    goals.forEach((goalName, targetValue) {
      final goalDocRef = userDocRef.collection('goals').doc(goalName);

      batch.set(goalDocRef, {'target': targetValue});
    });

    // Commit the batch to save all changes to Firestore.
    await batch.commit();
  }

  Stream<QuerySnapshot> getGoalsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots();
  }
}
