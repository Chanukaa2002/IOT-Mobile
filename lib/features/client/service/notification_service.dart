import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Method to show a notification
  Future<void> showTemperatureNotification(double temp) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'temperature_channel', // A unique channel ID
      'Temperature Alerts',    // A channel name
      channelDescription: 'Channel for food temperature alerts', // A channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Food Temperature Alert!', // Title
      'Your food is getting cold. Current temperature: ${temp.toStringAsFixed(1)}°C', // Body
      platformChannelSpecifics,
    );
  }

  Future<void> showGoalAchievedNotification(String goalName) async {
    final String title = '🎉 Goal Achieved! 🎉';
    final String body = 'Congratulations! You have reached your daily $goalName goal.';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'goal_achieved_channel',
      'Goal Achievement Alerts',
      channelDescription: 'Notifications for when you reach your daily goals',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      goalName.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}