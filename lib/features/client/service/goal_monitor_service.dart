import 'dart:async';
import 'package:cw_app/features/client/model/daily_summary.dart';
import 'package:cw_app/features/client/service/firestore_service.dart';
import 'package:cw_app/features/client/service/notification_service.dart';

class GoalMonitorService {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _summarySubscription;
  StreamSubscription? _goalsSubscription;
  DailySummary? _currentSummary;
  Map<String, dynamic> _userGoals = {};
  
  final Map<String, bool> _goalsAchievedToday = {};

  void startMonitoring(String userId) {
    if (_summarySubscription != null || _goalsSubscription != null) {
      return;
    }
    print("Starting goal monitoring for user: $userId");

    // 1. Listen to the user's goals
    _goalsSubscription = _firestoreService.getGoalsStream(userId).listen((goalsSnapshot) {
      if (goalsSnapshot.docs.isNotEmpty) {
        _userGoals = {
          for (var doc in goalsSnapshot.docs) doc.id: (doc.data() as Map)['target']
        };
        _checkAllGoals();
      }
    });

    _summarySubscription = _firestoreService.getDailySummaryStream(userId).listen((summary) {
      _currentSummary = summary;
      _checkAllGoals(); 
    });
  }

  void _checkAllGoals() {
    if (_currentSummary == null || _userGoals.isEmpty) {
      return;
    }

    final summaryMap = {
      'calories': _currentSummary!.totalCalories,
      'carbohydrates': _currentSummary!.totalCarbs,
      'proteins': _currentSummary!.totalProtein,
      'fats': _currentSummary!.totalFats,
    };

    _userGoals.forEach((goalName, goalTarget) {
      if (summaryMap.containsKey(goalName)) {
        final double currentValue = summaryMap[goalName]!;
        final double targetValue = (goalTarget as num).toDouble();

        if (currentValue >= targetValue && _goalsAchievedToday[goalName] != true) {
          
          print("Goal '$goalName' achieved! Current: $currentValue, Target: $targetValue. Sending notification.");
          
          _notificationService.showGoalAchievedNotification(goalName);
          _goalsAchievedToday[goalName] = true;
        }
      }
    });
  }

  void stopMonitoring() {
    print("Stopping goal monitoring.");
    _summarySubscription?.cancel();
    _goalsSubscription?.cancel();
    _summarySubscription = null;
    _goalsSubscription = null;
    _userGoals.clear();
    _currentSummary = null;
    _goalsAchievedToday.clear();
  }
}