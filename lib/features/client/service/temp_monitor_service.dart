import 'dart:async';
import 'package:cw_app/features/client/service/rtdb_service.dart';
import 'package:cw_app/features/client/service/notification_service.dart';

class TemperatureMonitorService {
  final RtdbService _rtdbService = RtdbService();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription? _temperatureSubscription;
  
  bool _isColdNotificationSent = false; // A flag to prevent spamming notifications

  void startMonitoring() {
    // If already monitoring, do nothing
    if (_temperatureSubscription != null) return;

    print("Starting temperature monitoring...");

    _temperatureSubscription = _rtdbService.getSensorDataStream().listen((sensorData) {
      final double currentTemp = sensorData.temperature;

      // Check if temperature is below 20°C
      if (currentTemp < 20.0 && currentTemp > 0) { // currentTemp > 0 avoids initial default value
        // Only send the notification if it hasn't been sent already for this "cold session"
        if (!_isColdNotificationSent) {
          print("Temperature is low ($currentTemp°C). Sending notification.");
          _notificationService.showTemperatureNotification(currentTemp);
          _isColdNotificationSent = true; // Set flag to true after sending
        }
      } else if (currentTemp >= 20.0) {
        // If the temperature goes back up, reset the flag so we can notify again if it drops.
        if (_isColdNotificationSent) {
          print("Temperature is back to normal. Resetting notification flag.");
          _isColdNotificationSent = false;
        }
      }
    });
  }

  void stopMonitoring() {
    print("Stopping temperature monitoring.");
    _temperatureSubscription?.cancel();
    _temperatureSubscription = null;
  }
}