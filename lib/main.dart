import 'package:cw_app/features/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cw_app/features/client/service/notification_service.dart';
import 'package:cw_app/features/client/service/temp_monitor_service.dart';
import 'package:cw_app/features/client/service/goal_monitor_service.dart';



final TemperatureMonitorService tempMonitorService = TemperatureMonitorService();
final GoalMonitorService goalMonitorService = GoalMonitorService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await NotificationService().init();
  tempMonitorService.startMonitoring();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
