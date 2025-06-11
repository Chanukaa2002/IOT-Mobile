import 'package:cw_app/home.dart';
import 'package:flutter/material.dart';
//! main package
import 'home.dart';

//! testing packages
import 'package:cw_app/features/auth/pages/login_page.dart';
import 'package:cw_app/features/auth/pages/signup_page.dart';
import 'package:cw_app/features/client/pages/home_page.dart';
import 'package:cw_app/features/client/pages/goal_page.dart';
import 'package:cw_app/features/client/pages/meal_box_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MealBoxPage(),
    );
  }
}
