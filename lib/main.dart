import 'package:cw_app/home.dart';
import 'package:flutter/material.dart';

import 'package:cw_app/features/client/widget/nav_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavWidget(),
    );
  }
}
